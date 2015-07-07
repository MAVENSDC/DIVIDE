;+
; Modeled data netcdf reader for toolkit
;
; :Author: John Martin
; 
; :Description:
;     Parse a NetCDF file with modeled data results and return in three data 
;     structures.  In order to work correctly with the toolkit, modeled 
;     data must conform to our modeled results file requirements 
;     - FIXME say where this is hosted.
;     
; :Keywords:
;    file: in, required, type=string or strarr
;       Scalar of path & filename of NetCDF file
;
;    output: out, required, type=struct
;       Output named variable containing three substructures: 
;        - a struct with meta information about the modeled results.
;        - a struct with dimension information about the modeled results.
;        - a struct containing an array of pointers where each 
;          element is one modeled species (stored in a struct with 'name' 
;          and 'data' tags).
;
; :History:
;   v1.0 (John Martin)
;   Original version; generates three structures
;   
; :Version: 1.1 (McGouldrick) 2015-Jun-12
; 
;-


pro mvn_kp_read_model_results, file, output

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
    if (not keyword_set(lon_size) or not keyword_set(alt_size)) then $
        message, "Couldn't find all dimensions: LATITUDE,LONGITUDE,ALTITUDE"
    dimensions='latlonalt'
  endif else if (keyword_set(x_size)) then begin
    if (not keyword_set(y_size) or not keyword_set(z_size)) then $
        message, "Couldn't find all dimensions: X,Y,Z"
    dimensions='xyz'
  endif else begin
    message, "Problem finding either cartesian (X,Y,Z) or Lat Lon Alt dimensions"
  endelse
  
  ;; Init dim structure
  if (dimensions eq 'latlonalt') then begin
    dim_struct = create_struct( 'lon',dblarr(lon_size), $
                                'lat', dblarr(lat_size), $
                                'alt',dblarr(alt_size) )
  endif else begin
    dim_struct = create_struct( 'x', dblarr(x_size), $
                                'y', dblarr(y_size), $
                                'z', dblarr(z_size) )
  endelse
  
  ;; Init Meta Structure
  meta_struct = create_struct( 'ls',!VALUES.D_NAN, $
                               'longsubsol', !VALUES.D_NAN, $
                               'declination', !VALUES.D_NAN, $
                               'mars_radius', !VALUES.D_NAN, $
                               'coord_sys', '', $
                               'altitude_from', '')  
  

  ;; Gather variable information
  data = []  ;; Note, declaring an empty array like this requires IDL ge v8.0
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
      'LS': begin
          ;Check if the attribute has an attribute named units
          unitsfound=0
          for i=0, var_info.natts-1 do begin
            attname = ncdf_attname(id, n, i)
            if (attname = 'units') then unitsfound=1
            endfor
          ;If found then determine the units
          ;If the units are radians, convert the value to degrees
          if (unitsfound) then begin
            ncdf_attget,id,n,'units',units
            if strmatch(string(units),'rad') then begin
              meta_struct.ls = value*(1.0/!dtor)
            endif else begin
              meta_struct.ls = value
            endelse
          endif else begin
            meta_struct.ls = value
          endelse
          end
      'LONGSUBSOL': begin
          ;Check if the attribute has an attribute named units
          unitsfound=0
          for i=0, var_info.natts-1 do begin
            attname = ncdf_attname(id, n, i)
            if (attname = 'units') then unitsfound=1
            endfor
          ;If found then determine the units
          ;If the units are radians, convert the value to degrees
          if (unitsfound) then begin
            ncdf_attget,id,n,'units',units
            if strmatch(string(units),'rad') then begin
              meta_struct.longsubsol = value*(1.0/!dtor)
            endif else begin
              meta_struct.longsubsol = value
            endelse
          endif else begin
            meta_struct.longsubsol = value
          endelse
          end
      'DEC' : begin
          ;Check if the attribute has an attribute named units
          unitsfound=0
          for i=0, var_info.natts-1 do begin
            attname = ncdf_attname(id, n, i)
            if (attname = 'units') then unitsfound=1
            endfor
          ;If found then determine the units
          ;If the units are radians, convert the value to degrees
          if (unitsfound) then begin
            ncdf_attget,id,n,'units',units
            if strmatch(string(units),'rad') then begin
              meta_struct.declination = value*(1.0/!dtor)
            endif else begin
              meta_struct.declination = value
            endelse
          endif else begin
            meta_struct.declination = value
          endelse
          end
      'MARS_RADIUS' : meta_struct.mars_radius = value
      'ALTITUDE_FROM' : meta_struct.altitude_from = string(value)
        
      ;; If not dimension or meta info, check if this is a modeled measurement 
      ELSE: begin
      
        ;; Only add data if dimensions match lat,lon,alt (discard other 
        ;; input conditions)
        if (size(value, /n_dimensions) eq 3) then begin 
          
          ;
          ; If the units of the variable are m-3 (per m^3), then convert
          ;  the data to cm^-3 to be consistent with MAVEn
          ;
          ncdf_attget,id,n,'units',units
          if strmatch(string(units),'m-3') then value = value / 1e6

          ; Create dimension order array
          dim_order = strarr(var_info.ndims)
          for z=0, var_info.ndims-1 do begin
            ncdf_diminq, id, var_info.dim[z], dname, dsize
            dim_order[z] = dname
          endfor
          
          ;; Create pointer to structure containing variable data & meta data
          var_ptr = ptr_new(create_struct('name',var_info.name, $
                                          'data', value, $
                                          'dim_order', dim_order) )
          data = [data,var_ptr]


        ;; Check if this is the situation where we have component, dim1, 
        ;; dim2, dim3.  Assume component is the last dimension, and we want 
        ;; the zero entry (sum of all processes, i.e. the total neutral 
        ;; corona of a given species)          
        endif else if (size(value, /n_dimensions) eq 4) then begin
          
          ;
          ; If the units of the variable are m-3 (per m^3), then convert
          ;  the data to cm^-3 to be consistent with MAVEn
          ;
          ncdf_attget,id,n,'units',units
          if strmatch(units,'m-3') then value = value / 1e6

          ; Create dimension order array
          dim_order = strarr(var_info.ndims - 1)
          for z=0, var_info.ndims-2 do begin
            ncdf_diminq, id, var_info.dim[z], dname, dsize
            dim_order[z] = dname
          endfor
          
          ;; Create pointer to structure containing variable data & meta data
          var_ptr = ptr_new(create_struct( 'name',var_info.name, $
                                           'data', value[*,*,*,0], $
                                           'dim_order', dim_order[*,*,*,0]) )
          data = [data,var_ptr]
      
        endif
      
      end
    endcase
  endfor
  
  ;; output
  meta = meta_struct
  dim = dim_struct
  output = {meta:meta_struct, dim:dim_struct, data:data}
   
end