;+
; Prototype version of generic netcdf reader for toolkit
;
; :Author: John Martin
;
;-


pro mvn_kp_read_model_data, file, meta, dim, data


id = ncdf_open(file, /NOWRITE)
format = ncdf_inquire(id)
        
;; Check dimensions
for n=0, format.ndims-1 do begin
  ncdf_diminq, id, n, dname, dsize  
  dname = strupcase(dname)
;  
;  CASE dname OF
;    'LAT': lat_size = dsize
;    'LON': lon_size = dsize
;    'ALT': alt_size = dsize
;  ENDCASE


;;
;; FIXME - Temp for french model dimension names
  CASE dname OF
    'NLAT': lat_size = dsize
    'NLONG': lon_size = dsize
    'ALTN': alt_size = dsize
    ELSE: 
  ENDCASE

endfor


;; Init dim structure
dim_struct = create_struct(NAME='Dimensions', 'lon',fltarr(lon_size), 'lat',fltarr(lat_size), 'alt',fltarr(alt_size))
;; Init Meta Structure
meta_struct = create_struct(NAME='MetaInfo', 'ls',0.0, 'longsubsol', 0.0, 'declination', 0.0)

;; Gather variable information
;data = ptrarr(format.nvars)
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
    'ZLS': meta_struct.ls = value
    'LONGSUBSOL': meta_struct.longsubsol = value
    'DEC' : meta_struct.declination = value
    
    ;; If not dimension, store data in data pointer array
    ELSE: begin
    
      ;; Only add data if dimensions match lat,lon,alt (discard other input conditions)
      if (size(value, /n_dimensions) eq 3) then begin
        value_dim = size(value, /dimensions)
        
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