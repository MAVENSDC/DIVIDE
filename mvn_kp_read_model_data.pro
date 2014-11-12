;+
; Prototype version of modeled data netcdf reader for toolkit
;
; :Author: John Martin
; 
; :Description:
;     Parse a NetCDF file with modeled data results and return in three data structures.
;     In order to work correctly with the toolkit, modeled data must conform to our 
;     modeled data requirements - FIXME say where this is hosted.
;     
; :Keywords:
;    file: in, required, type=string or strarr
;       Scalar of path & filename of NetCDF file
;
;    meta: out, required, type=struct
;       Output named variable containing a struct with meta information about the 
;       modeled data.
;
;;    dim: out, required, type=struct
;       Output named variable containing a struct with dimension information about the
;       modeled data.
;       
;    data: out, required, type=array of pointers
;       Output named variable containing an array of pointers where each element is
;       one modeled species (stored in a struct with 'name' and 'data' tags).
;
;-


pro mvn_kp_read_model_data, file, meta, dim, data

  id = ncdf_open(file, /NOWRITE)
  format = ncdf_inquire(id)
  
  ;; Check dimensions
  lat_size = 0
  lon_size = 0
  alt_size = 0
  for n=0, format.ndims-1 do begin
    ncdf_diminq, id, n, dname, dsize
    dname = strupcase(dname)
    
    ;;
    ;; FIXME Add x,y,z cartesian
    CASE dname OF
      'LATITUDE': lat_size = dsize
      'LONGITUDE': lon_size = dsize
      'ALTITUDE': alt_size = dsize
      ELSE:
    ENDCASE
    
  endfor
  
  ;; Init dim structure
  dim_struct = create_struct(NAME='Dimensions', 'lon',dblarr(lon_size), 'lat', dblarr(lat_size), 'alt',dblarr(alt_size))
  ;; Init Meta Structure
  meta_struct = create_struct(NAME='MetaInfo', 'ls',0.0D, 'longsubsol', 0.0D, 'declination', 0.0D, $
                              'mars_radius', -1.0D, 'altitude_from', '')
    
  ;; Gather variable information
  data = []  ;; FIXME make idl 7 compatable.
  
  for n=0, format.nvars-1 do begin
    value=0
    var_info = ncdf_varinq(id, n)
    ncdf_varget, id, n, value
    
    ;; If dimension variable, store in dim_struct
    ;; If mars orientation info, store in meta_struct
    case strupcase(var_info.name) of
      'LATITUDE': dim_struct.lat = value
      'LONGITUDE': dim_struct.lon = value
      'ALTITUDE': dim_struct.alt = value
      'LS': meta_struct.ls = value
      'LONGSUBSOL': meta_struct.longsubsol = value
      'DEC' : meta_struct.declination = value
      'MARS_RADIUS' : meta_struct.mars_radius = value
      'ALTITUDE_FROM' : meta_struct.altitude_from = string(value)
        
      ;; If not dimension, store data in data pointer array
      ELSE: begin
      
        ;; Only add data if dimensions match lat,lon,alt (discard other input conditions)
        if (size(value, /n_dimensions) eq 3) then begin
          value_dim = size(value, /dimensions)
          
          stop
          ;; FIXME - Add check of dimension sizes
          
          ;; Create pointer to structure containing variable data & meta data
          var_ptr = ptr_new(create_struct('name',var_info.name, 'data', value))
          data = [data,var_ptr]
        endif
      end
    endcase
  endfor
  
  ;; output
  meta = meta_struct
  dim = dim_struct
   
end