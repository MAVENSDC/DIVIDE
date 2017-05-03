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
mars_radius = model.meta.mars_radius

;Get the path of the spacecraft
sc_mso_x = kp_data.spacecraft.mso_x
sc_mso_y = kp_data.spacecraft.mso_y
sc_mso_z = kp_data.spacecraft.mso_z
sc_r = sqrt(sc_mso_x^2 + sc_mso_y^2 + sc_mso_z^2)
sc_alt_mso = kp_data.spacecraft.altitude
sc_lat_mso = 90.0 - (acos(sc_mso_z/sc_r)/ !dtor)
sc_lon_mso = atan(sc_mso_x , sc_mso_y) / !dtor

;
;Determine if the model is in lat/lon/alt or x/y/z
;
if ((*model.data[0]).dim_order[0] eq 'longitude' || $
    (*model.data[0]).dim_order[0] eq 'latitude' || $
    (*model.data[0]).dim_order[0] eq 'altitude') then begin

  ;
  ; Determine the coordinate system for the input model
  ;
  coord_sys = strtrim(strtrim(model.meta[0].coord_sys, 1),0)
  case coord_sys of
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
    lat_mso_model = model.dim.lat
    lon_mso_model = model.dim.lon
    alt_mso_model = model.dim.alt
  
    ;Create Longitude Array
    lon_array = replicate(0.0, n_elements(lat_mso_model)*n_elements(lon_mso_model)*n_elements(alt_mso_model))
    for i=1,n_elements(lon_mso_model) do begin
      lon_array[(i-1)*n_elements(lat_mso_model)*n_elements(alt_mso_model) : i*n_elements(lat_mso_model)*n_elements(alt_mso_model)-1] = lon_mso_model[i-1]
    endfor
  
    ;Create Latitude Array
    lat_array = []
    for k=1,n_elements(lon_mso_model) do begin
      temp_lat_array = replicate(0.0, n_elements(lat_mso_model)*n_elements(alt_mso_model))
      for i=1,n_elements(lat_mso_model) do begin
        temp_lat_array[(i-1)*n_elements(alt_mso_model) : i*n_elements(alt_mso_model)-1] = lat_mso_model[i-1]
      endfor
      lat_array = [lat_array, temp_lat_array]
    endfor
  
    ;Create Altitude Array
    alt_array = replicate(0.0, n_elements(lat_mso_model)*n_elements(lon_mso_model)*n_elements(alt_mso_model))
    for i=1,n_elements(lat_mso_model)*n_elements(lon_mso_model) do begin
      alt_array[(i-1)*n_elements(alt_mso_model) : i*n_elements(alt_mso_model)-1] = alt_mso_model
    endfor
    
    data_points = transpose([[lon_array], [lat_array], [alt_array]])
    
    
      for i = 0,n_elements(model.data)-1 do begin
        if strlowcase((*model.data[i]).name) eq "geo_x" then continue
        if strlowcase((*model.data[i]).name) eq "geo_y" then continue
        if strlowcase((*model.data[i]).name) eq "geo_z" then continue
      
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
        data_new = transpose( (*model.data[i]).data, dim_order_array )
      
        index = 0.0
        values = replicate(0.0, n_elements(lat_mso_model)*n_elements(lon_mso_model)*n_elements(alt_mso_model))
        for lon=0,n_elements(lon_mso_model)-1 do begin
          for lat=0,n_elements(lat_mso_model)-1 do begin
            for alt=0,n_elements(alt_mso_model)-1 do begin
              values[index] = data_new[lon,lat,alt]
              index++
            endfor
          endfor
        endfor
          
        
        tracer_interpol = replicate(!VALUES.F_NAN, n_elements(sc_lon_mso))
        indices_to_interpolate = where(kp_data.spacecraft.altitude le max(alt_mso_model))
        interp_values = mvn_kp_shepards_method(lon_array, lat_array, alt_array, values, sc_lon_mso[indices_to_interpolate], sc_lat_mso[indices_to_interpolate], sc_alt_mso[indices_to_interpolate], nearest_neighbor = nearest_neighbor)
        tracer_interpol[indices_to_interpolate] = interp_values
        
        model_interpol = create_struct( model_interpol, $
          (*model.data[i]).name, $
          tracer_interpol )
      
    endfor 
  endif
  if( geo )then begin
    
    
    modellon = - model.meta.longsubsol *!dtor
    ls_rad = model.meta.ls * !dtor 
    rads_tilted_y = 25.19 * sin(ls_rad) * !dtor
    rads_tilted_x = -25.19 * cos(ls_rad) * !dtor
    
    z_rotation = [[cos(modellon), -sin(modellon), 0], $
                  [sin(modellon), cos(modellon), 0], $
                  [0,0,1]]
    y_rotation = [[cos(rads_tilted_y), 0, sin(rads_tilted_y)], $
                  [0,1,0], $
                  [-sin(rads_tilted_y), 0, cos(rads_tilted_y)]]
    x_rotation = [[1,0,0], $
                  [0,cos(rads_tilted_x),-sin(rads_tilted_x)], $
                  [0,sin(rads_tilted_x),cos(rads_tilted_x)]]
    
    geo_to_mso_matrix = x_rotation##(y_rotation##z_rotation)
    
    lat_geo_model = model.dim.lat
    lon_geo_model = model.dim.lon
    alt_geo_model = model.dim.alt
    
    ;Create Longitude Array
    lon_array = replicate(0.0, n_elements(lat_geo_model)*n_elements(lon_geo_model)*n_elements(alt_geo_model))
    for i=1,n_elements(lon_geo_model) do begin
      lon_array[(i-1)*n_elements(lat_geo_model)*n_elements(alt_geo_model) : i*n_elements(lat_geo_model)*n_elements(alt_geo_model)-1] = lon_geo_model[i-1]
    endfor 
    
    ;Create Latitude Array
    lat_array = []
    for k=1,n_elements(lon_geo_model) do begin
      temp_lat_array = replicate(0.0, n_elements(lat_geo_model)*n_elements(alt_geo_model))
      for i=1,n_elements(lat_geo_model) do begin
        temp_lat_array[(i-1)*n_elements(alt_geo_model) : i*n_elements(alt_geo_model)-1] = lat_geo_model[i-1]
      endfor
      lat_array = [lat_array, temp_lat_array]
    endfor
    
    ;Create Altitude Array
    alt_array = replicate(0.0, n_elements(lat_geo_model)*n_elements(lon_geo_model)*n_elements(alt_geo_model))
    for i=1,n_elements(lat_geo_model)*n_elements(lon_geo_model) do begin
      alt_array[(i-1)*n_elements(alt_geo_model) : i*n_elements(alt_geo_model)-1] = alt_geo_model
    endfor
    
    ;Convert lat/lon/alt to GEO, then to MSO
    data_points = transpose([[lon_array], [lat_array], [alt_array]])
    for i=0,n_elements(alt_array)-1 do begin
      r = data_points[2, i] + mars_radius
      x = r * sin((90-data_points[1,i]) * !dtor) * cos(data_points[0,i] * !dtor)
      y = r * sin((90-data_points[1,i]) * !dtor) * sin(data_points[0,i] * !dtor)
      z = r * cos((90-data_points[1,i]) * !dtor)
      data_points[*,i] = geo_to_mso_matrix##[x,y,z]
    endfor
  
    
    
    for i = 0,n_elements(model.data)-1 do begin     
      if strlowcase((*model.data[i]).name) eq "geo_x" then continue
      if strlowcase((*model.data[i]).name) eq "geo_y" then continue
      if strlowcase((*model.data[i]).name) eq "geo_z" then continue
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
      data_new = transpose( (*model.data[i]).data, dim_order_array )
    
      index = 0.0
      values = replicate(0.0, n_elements(lat_geo_model)*n_elements(lon_geo_model)*n_elements(alt_geo_model))
      for lon=0,n_elements(lon_geo_model)-1 do begin
        for lat=0,n_elements(lat_geo_model)-1 do begin
          for alt=0,n_elements(alt_geo_model)-1 do begin
            values[index] = data_new[lon,lat,alt]
            index++
          endfor
        endfor
      endfor
      
      ;Convert everything in an MSO lat/lon/alt so that things are weighted properly
      r = sqrt(reform(data_points[0,*])^2 + reform(data_points[1,*])^2 + reform(data_points[2,*])^2)
      alt_mso = r - mars_radius
      lat_mso = 90.0 - (acos(reform(data_points[2,*])/r) / !dtor)
      lon_mso = atan(reform(data_points[0,*]) , reform(data_points[1,*])) / !dtor
      
      
      tracer_interpol = replicate(!VALUES.F_NAN, n_elements(sc_lon_mso))
      indices_to_interpolate = where(kp_data.spacecraft.altitude le max(alt_geo_model))
      interp_values = mvn_kp_shepards_method(lon_mso, lat_mso, alt_mso, values, sc_lon_mso[indices_to_interpolate], sc_lat_mso[indices_to_interpolate], sc_alt_mso[indices_to_interpolate], nearest_neighbor=nearest_neighbor)
      tracer_interpol[indices_to_interpolate] = interp_values
      model_interpol = create_struct( model_interpol, $
        (*model.data[i]).name, $
        tracer_interpol )
      
    endfor 
  
  endif

endif else begin
  
  
for i = 0,n_elements(model.data)-1 do begin
  dim_order_array = bytarr(3)
  for j = 0,2 do begin
    case (*model.data[i]).dim_order[j] of
      'x': dim_order_array[0] = j
      'y': dim_order_array[1] = j
      'z': dim_order_array[2] = j
      else: message, "Invalid dimension Identifier in model_data: ",i,j
    endcase
  endfor 
  tracer = transpose( (*model.data[i]).data, dim_order_array )
  ;
  ;  Now, interpolate the model to the SC trajectory
  ;
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
endfor

endelse

return
end