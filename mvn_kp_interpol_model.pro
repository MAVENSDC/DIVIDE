;+
; :Name: mvn_kp_interpol_model
;
; :Author: Kevin McGouldrick (2015-Apr-15)
;
; :Description:
;    Convert a model cube and its metadata into an a structure of arrays 
;    interpolated to the spacecraft trajectory given by kp_data
;
; :Keywords:
;    kp_data: in, required, type=struct
;       Key Parameter data file containing spacecraft trajectory information.
;
;    model: in, required, type=struct
;       Structure containing relevant model metadata, dimensions, and data
;
;    model_interpol: out, required, type=struct
;       Structure containing the model tracers interpolated to the provided
;       spacecraft trajectory from the kp_data
;    help: optional: opens a window describing the function
;
; :Version:
;   1.1 (2015-Jun-16)
;
;-
pro mvn_kp_interpol_model, kp_data, model, model_interpol, $
                           grid3=grid3, nearest_neighbor=nearest_neighbor, $
                           help=help
;
; Place an argument check here,  Should provide 4 args 
; (unless IUVS will be needed)
;

;
;  Place a check on passed parameters here.  I.e., this is a verification
;  that the required elements (model_{meta,dims,data}) have been provided
;  It will be needed to catch typos gracefully.
;  This may be internal use only, so maybe unnecessary...

;
; Provide help if requested
;
if keyword_set(help) then begin
  mvn_kp_get_help,'mvn_kp_interpol_model'
  return
endif
;
;  Set the keywords for the interpoaltion style
;
grid3=keyword_set(grid3)
nearest_neighbor=keyword_set(nearest_neighbor)
;
; Start the output model with the meta data
;
model_interpol = model.meta


;
;Determine if the model is in lat/lon/alt or x/y/z
;
if ((*model.data[0]).dim_order[0] eq 'longitude' || $
    (*model.data[0]).dim_order[0] eq 'latitude' || $
    (*model.data[0]).dim_order[0] eq 'altitude') then begin

;
; Determine the coordinate system for the input model
;
case model.meta.coord_sys of
  'MSO': begin
    mso = keyword_set(1B) & geo = keyword_set(0B)
         end
  'GEO': begin
    geo = keyword_set(1B) & mso = keyword_set(0B)
         end
  else: message, "Ill-defined or undefined coord_sys in meta structure"
endcase

;
;  Get the appropriate spacecraft geometry
;
if( mso )then begin
  ;
  ;  calculate maven MSO lat,lon from MSO x,y,z
  ;
  r_mso = sqrt( kp_data.spacecraft.mso_x^2 + kp_data.spacecraft.mso_y^2 $
              + kp_data.spacecraft.mso_z^2 )
  lat_sc_mso = 90. - acos( kp_data.spacecraft.mso_z / r_mso ) * !radeg
  lon_sc_mso = atan( kp_data.spacecraft.mso_y, $
                     kp_data.spacecraft.mso_x ) * !radeg ; returns on -180..180
  ;
  ; convert lon_sc_mso to 0..360 scale if needed
  ;
  if (max(abs(model.dim[0].lon), /NAN) gt 180) then begin
    neg_lon = where( lon_sc_mso lt 0, count )
    if count gt 0 then lon_sc_mso[neg_lon] = lon_sc_mso[neg_lon] + 360
  endif
  ;
  ;Give the values to the correct variable names for the logic below
  ;
  lon_sc_model = lon_sc_mso
  lat_sc_model = lat_sc_mso
  sc_altitude = r_mso - model.meta[0].mars_radius
endif
;TODO: I don't think that this geo procedure takes into account the rotation of Mars due to its tilt
if( geo )then begin
  ;
  ; Calculate delta offset from subsolar point in Model to subsolar point from insitu data
  ;
  delta_lon = model.meta.longsubsol $
            - kp_data.spacecraft.subsolar_point_geo_longitude
  delta_lat = model.meta.declination $
            - kp_data.spacecraft.subsolar_point_geo_latitude
  ;
  ;  Correct for negative delta longitude
  ;
  neg_lon = where( delta_lon lt 0, count)
  if count gt 0 then delta_lon[neg_lon] = delta_lon[neg_lon] + 360
  ;
  ; Update the lon,lat in GEO coords
  ;
  lon_sc_model = ( kp_data.spacecraft.sub_sc_longitude + delta_lon ) mod 360
  colat_sc_model = acos( cos( ( 90. - kp_data.spacecraft.sub_sc_latitude $
                              + delta_lat ) * !dtor ) ) * !radeg
  lat_sc_model = 90. - colat_sc_model
  
  overpole = where( abs( colat_sc_model $
                       - ( 90 - kp_data.spacecraft.sub_sc_latitude + delta_lat ) ) gt 1e-4, count )
  if count gt 0 then $
    lon_sc_model[overpole] = ( lon_sc_model[overpole] + 180 ) mod 360
    
  sc_altitude = kp_data.spacecraft.altitude
endif

;
;  Now, cycle through the provided variables and interpolate them to the
;  spacecraft trajectory.  Note, the data are arrays of pointers to structures
;  Note also the lat/lon coords are reversed for each 
;
  for i = 0,n_elements(model.data)-1 do begin
;
;  First, ensure the data are in lon / lat / alt order
;
    dim_order_array = bytarr(3)
    for j = 0,2 do begin
      case (*model.data[i]).dim_order[j] of
        'longitude': dim_order_array[0] = j
        'latitude': dim_order_array[1] = j
        'altitude': dim_order_array[2] = j
        else: message, "Invalid dimension Identifier in model_data: ",i,j
      endcase
    endfor ; j=0,2
    tracer = transpose( (*model.data[i]).data, dim_order_array )
;
;  Now, interpolate the model to the SC trajectory
;  (Will need to consider what to do when SC outside of model domain)
;
    if grid3 then $
      tracer_interpol = mvn_kp_sc_traj_g3( tracer, model.dim, $
                                           lon_sc_model, lat_sc_model, $
                                           sc_altitude )
    if nearest_neighbor then $
      tracer_interpol = mvn_kp_sc_traj_nn( tracer, model.dim, $
                                           lon_sc_model, lat_sc_model, $
                                           sc_altitude ) 
;
;  Add the interpolated model data to the structure
;
    model_interpol = create_struct( model_interpol, $
                                    (*model.data[i]).name, $
                                    tracer_interpol )
  endfor ; i=0,n_elements(data)

endif else begin



for i = 0,n_elements(model.data)-1 do begin
;
;  First, ensure the data are in x / y / z order
;
    dim_order_array = bytarr(3)
    for j = 0,2 do begin
      case (*model.data[i]).dim_order[j] of
        'size_x': dim_order_array[0] = j
        'size_y': dim_order_array[1] = j
        'size_z': dim_order_array[2] = j
        else: message, "Invalid dimension Identifier in model_data: ",i,j
      endcase
    endfor ; j=0,2
    tracer = transpose( (*model.data[i]).data, dim_order_array )
;
;  Now, interpolate the model to the SC trajectory
;  (Will need to consider what to do when SC outside of model domain)
      tracer_interpol = mvn_kp_sc_traj_xyz( tracer, model.dim, $
                                           kp_data.spacecraft.mso_x, $
                                           kp_data.spacecraft.mso_y, $
                                           kp_data.spacecraft.mso_z, $
                                           grid3=grid3, nn=nearest_neighbor)                                   
;
;  Add the interpolated model data to the structure
;
    model_interpol = create_struct( model_interpol, $
                                    (*model.data[i]).name, $
                                    tracer_interpol )
  endfor ; i=0,n_elements(data)




endelse

return
end