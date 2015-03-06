;+
; Modeled data netcdf reader for toolkit
;
; :Author: John Martin
; 
; :Description:
;     Parse a NetCDF file with modeled data results and return in three data structures.
;     In order to work correctly with the toolkit, modeled data must conform to our 
;     modeled results file requirements - FIXME say where this is hosted.
;     
; :Keywords:
;    file: in, required, type=string or strarr
;       Scalar of path & filename of NetCDF file
;
;    meta: out, required, type=struct
;       Output named variable containing a struct with meta information about the 
;       modeled results.
;
;;    dim: out, required, type=struct
;       Output named variable containing a struct with dimension information about the
;       modeled results.
;       
;    data: out, required, type=array of pointers
;       Output named variable containing an array of pointers where each element is
;       one modeled species (stored in a struct with 'name' and 'data' tags).
;
;-


pro mvn_kp_read_model_results, file, meta, dim, data

  ;; Open netcdf file for reading
  id = ncdf_open(file, /NOWRITE)
  format = ncdf_inquire(id)
  
  ;; Loop through all dimension variables in netcdf file
  for n=0, format.ndims-1 do begin
    ncdf_diminq, id, n, dname, dsize
    dname = strupcase(dname)
    
    ;; Pick out dimensions
    CASE dname OF
      'LATITUDE': lat_size = dsize
      'LONGITUDE': lon_size = dsize
      'ALTITUDE': alt_size = dsize
      'SIZE_X': x_size = dsize
      'SIZE_Y': y_size = dsize
      'SIZE_Z': z_size = dsize
      'X': x_size = dsize
      'Y': y_size = dsize
      'Z': z_size = dsize
      ELSE:
    ENDCASE  
  endfor
  
  ;; Determine if lat/lon/alt or x/y/z data cube
  if (keyword_set(lat_size)) then begin
    if (not keyword_set(lon_size) or not keyword_set(alt_size)) then message, "Couldn't find all dimensions: LATITUDE,LONGITUDE,ALTITUDE"
    dimensions='latlonalt'
  endif else if (keyword_set(x_size)) then begin
    if (not keyword_set(y_size) or not keyword_set(z_size)) then message, "Couldn't find all dimensions: X,Y,Z"
    dimensions='xyz'
  endif else begin
    message, "Problem finding either cartesian (X,Y,Z) or Lat Lon Alt dimensions"
  endelse
  
  ;; Init dim structure
  if (dimensions eq 'latlonalt') then begin
    dim_struct = create_struct( 'lon',dblarr(lon_size), 'lat', dblarr(lat_size), 'alt',dblarr(alt_size))
  endif else begin
    dim_struct = create_struct( 'x', dblarr(x_size), 'y', dblarr(y_size), 'z', dblarr(z_size))
  endelse
  
  ;; Init Meta Structure
  meta_struct = create_struct( 'ls',!VALUES.D_NAN, 'longsubsol', !VALUES.D_NAN, 'declination', !VALUES.D_NAN, $
                              'mars_radius', !VALUES.D_NAN, 'coord_sys', '', 'altitude_from', '')  
  

  ;; Gather variable information
  data = []  ;; Note, declaring an empty array like this requires IDL 8.0 and up
  for n=0, format.nvars-1 do begin
    value=0
    var_info = ncdf_varinq(id, n)
    ncdf_varget, id, n, value
    
    ;; If dimension variable, store in dim_struct
    ;; If mars orientation info, store in meta_struct
    case strupcase(var_info.name) of
      ;; Lat lon alt
      'LATITUDE': dim_struct.lat = value
      'LONGITUDE': dim_struct.lon = value
      'ALTITUDE': dim_struct.alt = value
      
      ;; X Y Z
      'X': dim_struct.x = value
      'Y': dim_struct.y = value
      'Z': dim_struct.z = value
      
      ;; Meta information
      'COORDINATE_SYSTEM' : meta_struct.coord_sys = string(value)
      'LS': meta_struct.ls = value
      'LONGSUBSOL': meta_struct.longsubsol = value
      'DEC' : meta_struct.declination = value
      'MARS_RADIUS' : meta_struct.mars_radius = value
      'ALTITUDE_FROM' : meta_struct.altitude_from = string(value)
        
      ;; If not dimension or meta info, check if this is a modeled measurement 
      ELSE: begin
      
        ;; Only add data if dimensions match lat,lon,alt (discard other input conditions)
        if (size(value, /n_dimensions) eq 3) then begin 
          
          ; Create dimension order array
          dim_order = strarr(var_info.ndims)
          for z=0, var_info.ndims-1 do begin
            ncdf_diminq, id, var_info.dim[z], dname, dsize
            dim_order[z] = dname
          endfor
          
          ;; Create pointer to structure containing variable data & meta data
          var_ptr = ptr_new(create_struct('name',var_info.name, 'data', value, 'dim_order', dim_order))
          data = [data,var_ptr]


        ;; Check if this is the situation where we have component, dim1, dim2, dim3
        ;; Assume component is the last dimension, and we want the zero entry
        ;; (sum of all processes, i.e. the total neutral corona of a given species)          
        endif else if (size(value, /n_dimensions) eq 4) then begin
          
          ; Create dimension order array
          dim_order = strarr(var_info.ndims - 1)
          for z=0, var_info.ndims-2 do begin
            ncdf_diminq, id, var_info.dim[z], dname, dsize
            dim_order[z] = dname
          endfor
          
          ;; Create pointer to structure containing variable data & meta data
          var_ptr = ptr_new(create_struct('name',var_info.name, 'data', value[*,*,*,0], 'dim_order', dim_order[*,*,*,0]))
          data = [data,var_ptr]
      
        endif
      
      end
    endcase
  endfor
  
  ;; output
  meta = meta_struct
  dim = dim_struct
   
end