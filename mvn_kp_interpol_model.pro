;+
; Function to return the model output interpolated to a given spacecraft 
; trajectory
;
; :Author: Kevin McGouldrick (2015-Apr-15)
;
; :Description:
;     Parse a NetCDF file with modeled data results and return in three data
;     structures.  In order to work correctly with the toolkit, modeled
;     data must conform to our modeled results file requirements
;     - FIXME say where this is hosted.
;
; :Keywords:
;    kp_data: in, required, type=struct
;       Key Parameter data file containing spacecraft trajectory information.
;
;    model_meta: in, required, type=struct
;       Structure containing relevant model metadata.
;
;    model_dims: in, required, type=struct
;       Structure containing relevant model dimension information.
;
;    model_data: in, required, type=struct
;       Structure containing relevant model data.
;       
;    help: optional: opens a window describing the function
;
;  :Returns:
;    model_interpol: out, type=TBD
;       Object containing the model tracers interpolated to the provided 
;       spacecraft trajectory from the kp_data
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
; Determine the coordinate system for the input model
;
case model.meta.coord_sys of
  'MSO': begin
    mso = keyword_set(1B) & geo = keyword_set(1B)
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
  ; Calculate xyz of subsolar vector in GEO coordinates
  ; 
  ss_lon = kp_data.spacecraft.subsolar_point_geo_longitude
  ss_lat = kp_data.spacecraft.subsolar_point_geo_latitude
  ss_x_geo = sin(ss_lat*!dtor) * cos(ss_lon*!dtor) ; actually x/r
  ss_y_geo = sin(ss_lat*!dtor) * sin(ss_lon*!dtor) ; actually y/r
  ss_z_geo = cos(ss_lat*!dtor)                     ; actually z/r
  ss_geo = [[ss_x_geo],[ss_y_geo],[ss_z_geo]]
  ;
  ; Apply the rotation matrix to make the subsolar vector into MSO coords
  ;
  ss_x_mso = ss_geo[0] * kp_data.spacecraft.t11 $
           + ss_geo[1] * kp_data.spacecraft.t12 $
           + ss_geo[2] * kp_data.spacecraft.t13
  ss_y_mso = ss_geo[0] * kp_data.spacecraft.t21 $
           + ss_geo[1] * kp_data.spacecraft.t22 $
           + ss_geo[2] * kp_data.spacecraft.t23
  ss_z_mso = ss_geo[0] * kp_data.spacecraft.t31 $
           + ss_geo[1] * kp_data.spacecraft.t32 $
           + ss_geo[2] * kp_data.spacecraft.t33
  ;
  ; Now, convert MSO(x,y,z) into MSO(r,lon,lat)
  ;
  ss_lon_mso = acos( ss_z_mso ) * !radeg
  ss_lat_mso = atan( ss_y_mso, ss_x_mso ) * !radeg
  ;
  ;  And calcaulte the change in subsolar lat and lon from the model
  ;
  if model.meta.longsubsol lt 0 then begin
    delta_lon = ss_lon_mso - ( 360 - abs(model.meta.longsubsol) )
  endif else begin
    delta_lon = ss_lon_mso - model.meta.longsubsol
  endelse
  delta_lat = ss_lat_mso - model.meta.declination
  ;
  ;  calculate maven MSO lat,lon from MSO x,y,z
  ;
  r_mso = sqrt( kp_data.spacecraft.mso_x^2 + kp_data.spacecraft.mso_y^2 $
              + kp_data.spacecraft.mso_z^2 )
  lon_sc_mso = acos( kp_data.spacecraft.mso_z / r_mso ) * !radeg
  lat_sc_mso = atan( kp_data.spacecraft.mso_y, $
                     kp_data.spacecraft.mso_x ) * !radeg
  ;
  ; Apply the deltas to the sc lon,lat
  ; 
  lon_sc_model = ( lon_sc_mso + delta_lon ) mod 360 
  lat_sc_model = acos( cos( ( lat_sc_mso + delta_lat ) * !dtor ) )
  ;
  ;  correct for rotations that take us over the pole
  ;
  overpole = where( lat_sc_model - lat_sc_mso ne delta_lat, count )
  if count gt 0 then $
    lon_sc_model[overpole] = ( lon_sc_model[overpole] + 180 ) mod 360
endif
;
if( geo )then begin
  ;
  ; Calculate deltas
  ;
  if model.meta.longsubsol lt 0 then begin
    delta_lon = kp_data.spacecraft.subsolar_point_geo_longitude $
              - ( 360 - abs(model.meta.longsubsol) )
  endif else begin
    delta_lon = kp_data.spacecraft.subsolar_point_geo_longitude $
              - model.meta.longsubsol
  endelse
  delta_lat = kp_data.spacecraft.subsolar_point_geo_latitude $
            - model.meta.declination
  ;
  ; Update the lon,lat in GEO coords
  ;
  lon_sc_model = ( kp_data.spacecraft.sub_sc_longitude + delta_lon ) mod 360
  lat_sc_model = acos( cos( ( kp_data.spacecraft.sub_sc_latitude $
                            + delta_lat ) * !dtor ) )
  overpole = where( lat_sc_model - kp_data.spacecraft.sub_sc_latitude ne delta_lat, count )
  if count gt 0 then $
    lon_sc_model[overpole] = ( lon_sc_model[overpole] + 180 ) mod 360
endif
;
; Start the output model with the meta data
;
model_interpol = model.meta
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
                                           kp_data.spacecraft.altitude )
    if nearest_neighbor then $
      tracer_interpol = mvn_kp_sc_traj_nn( tracer, model.dim, $
                                           lon_sc_model, lat_sc_model, $
                                           kp_data.spacecraft.altitude )   
;
;  Add the interpolated model data to the structure
;
    model_interpol = create_struct( model_interpol, $
                                    (*model.data[i]).name, $
                                    tracer_interpol )
  endfor ; i=0,n_elements(data)

return
end