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
function mvn_kp_interpol_model, kp_data, model_meta, model_dims, model_data, $
                                grid3=grid3, nearest_neighbor=nearest_neighbor, $
                                help=help
;
; Place an argument check here,  Should provide 4 args (unless IUVS will be needed)
;

;
; Provide help if requested
;
if keyword_set(help) then begin
  mvn_kp_get_help,'mvn_kp_interpol_model'
  return,0
endif
;
;  Set the keywords for the interpoaltion style
;
grid3=keyword_set(grid3)
nearest_neighbor=keyword_set(nearest_neighbor)
;
;---
;
; Determine the coordinate system for the input model
;
case model_meta.coord_sys of
  'MSO': mso = keyword_set(1)
  'GEO': geo = keyword_set(1)
  else: message, "Ill-defined or undefined coord_sys in meta structure"
endcase
;
;;  Hack to use GEO for Ronan's data too
;
mso=keyword_set(0) & geo=keyword_set(1) ; HACK
;
;  Get the appropriate spacecraft geometry
;
if( mso )then begin
;
;  Just grab the MSO coords from the KP data
;
   sc_x = kp_data.spacecraft.mso_x
   sc_y = kp_data.spacecraft.mso_y
   sc_z = kp_data.spacecraft.mso_z
endif
;
if( geo )then begin
;
;  The altitude above a spherical Mars must be determined from GEO
;  The sub_spacecraft longitude and latitude are part of the KP
;
  sc_x = kp_data.spacecraft.sub_sc_longitude
  sc_y = kp_data.spacecraft.sub_sc_latitude
  sc_z = sqrt( kp_data.spacecraft.geo_x^2 $
             + kp_data.spacecraft.geo_y^2 $
             + kp_data.spacecraft.geo_z^2 ) $
       - model_meta.mars_radius
endif
;
;  Define the structure for the model output to the toolkit.
;  May want to do the pointer thing with this in the future.
;
model_interpol = model_meta
;
;  Now, cycle through the provided variables and interpolate them to the
;  spacecraft trajectory.  Note, the data are arrays of pointers to structures
;  Note also the lat/lon coords are reversed for each 
;  (wait, Ronan is supposed to be MSO)
if( geo )then begin
  for i = 0,n_elements(model_data)-1 do begin
;
;  First, ensure the data are in lon / lat / alt order
;
    dim_order_array = bytarr(3)
    for j = 0,2 do begin
      case (*model_data[i]).dim_order[j] of
        'longitude': dim_order_array[0] = j
        'latitude': dim_order_array[1] = j
        'altitude': dim_order_array[2] = j
        else: message, "Invalid dimension Identifier in model_data: ",i,j
      endcase
    endfor ; j=0,2
    tracer = transpose( (*model_data[i]).data, dim_order_array )
;
;  Now, interpolate the model to the SC trajectory
;  (Will need to consider what to do when SC outside of model domain)
;
    if( grid3 )then $
      tracer_interpol = mvn_kp_sc_traj_g3(tracer,model_dims,sc_x,sc_y,sc_z)
    
    if( nearest_neighbor )then $
      tracer_interpol = mvn_kp_sc_traj_nn(tracer,model_dims,sc_x,sc_y,sc_z)     
;
;  Add the interpolated model data to the structure
;
    model_interpol = create_struct( model_interpol, $
                                    (*model_data[i]).name, $
                                    tracer_interpol )
  endfor ; i=0,n_elements(data)
endif ; if geo
;
;  For now, lacking MSO data, skip this 
;  But we will want to implement this later.
;
return, model_interpol
end