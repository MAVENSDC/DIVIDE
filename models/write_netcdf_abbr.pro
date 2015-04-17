;
; NAME
;
;
; PURPOSE
;
; DESCRIPTION
;
; INPUTS
;
; OUTPUTS
;
; AUTHOR
;
;
; REVISION HISTORY
;
;
; USAGE
;


function write_netcdf_abbr, input_savefile

  ;; Load save file into memory
  ;; Expecting/Required variables:
  ;
  ;; meta.<year,month,day,hour,min,sec>
  ;; meta.<nalts, nlons, nlats>
  ;; meta.<altitude, longitude, latitude>
  ;; meta.sza
  ;; temperature.<tn,ti,te>
  ;; iondensity.<o2p, op, co2p, n_e>
  ;; neutraldensity.<co2, co, n2, o2, o>
  ;; neutralwinds.<veast, vnorth, vup>
  restore, input_savefile
  
  
  ;; Create output filename
  out_path = FILE_DIRNAME(input_savefile)
  out_base = FILE_BASENAME(input_savefile)
  out_base_split = STRSPLIT(out_base, '.', /EXTRACT, count=n) 
  if n ne 2 then begin
    print, "Something wrong with filename."
    print, "Expected </optional/path/><filename>.sav"
    return, -1
  endif
  out_file = out_path+path_sep()+out_base_split[0]+'.nc'
  
  
  ; FIXME - nans or some mission value?
  ; 
  ; Define missing value and replace NaNs in the modeled data with it. 
  ;;missing_value = -99.0

  
 
  ; ===========================================================================
  ; Create NetCDF file for writing output
  ; ===========================================================================
  
  ;id = NCDF_CREATE(out_file, /NOCLOBBER, /netCDF4_format) 
        ;noclobber = don't overwrite existing file
  id = NCDF_CREATE(out_file, /CLOBBER, /netCDF4_format) 
        ;; FIXME - Currently overwriting file if it already exists.
  
  
  ; ===========================================================================
  ; Global Attributes
  ; ===========================================================================
  
  NCDF_ATTPUT, id, /GLOBAL, "file_format", "NetCDF"
  NCDF_ATTPUT, id, /GLOBAL, "title", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "source", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "FIXME? None at the moment"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "summary", "FIXME"


  ; ===========================================================================
  ; Define Dimensions
  ; ===========================================================================
;-km-temporary hack
;    Until Steve's sav file is fixed
  meta = create_struct(meta,'nlats',n_elements(reform(meta.latitude)))
  meta.nalts = 1
;-km-/temporary-hack
  lon_id = NCDF_DIMDEF(id, 'lon', meta.nlons)
  lat_id = NCDF_DIMDEF(id, 'lat', meta.nlats)
  alt_id = NCDF_DIMDEF(id, 'alt', meta.nalts)
  print,meta.nlons,meta.nlats,meta.nalts
  
  
  ; ===========================================================================
  ; Variable Declaration & Attributes
  ; ===========================================================================

  ;; ------------------------------
  ;  ;; Plasma Densities
;  o2plus_var = NCDF_VARDEF(id, 'o2plus', [lon_id, lat_id, alt_id], /FLOAT)
  o2plus_var = NCDF_VARDEF(id, 'o2plus', [lat_id, lon_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, o2plus_var, 'title', 'O2+ ion density'
  NCDF_ATTPUT, id, o2plus_var, 'units', 'm-3'
  
  ;; ------------------------------
  ;  ;; Dimensions
  lon_var = NCDF_VARDEF(id, 'lon', [lon_id], /FLOAT)
  NCDF_ATTPUT, id, lon_var, 'title', 'Longitude'
  NCDF_ATTPUT, id, lon_var, 'units', 'degrees east'
  
  lat_var = NCDF_VARDEF(id, 'lat', [lat_id], /FLOAT)
  NCDF_ATTPUT, id, lat_var, 'title', 'Latitude'
  NCDF_ATTPUT, id, lat_var, 'units', 'degreesn north'
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  
  ; ===========================================================================
  ; Input data into the netcdf variables declared above
  ; ===========================================================================
  
;  o2plus_id = ncdf_varid(id, 'o2plus')
  NCDF_VARPUT, id, o2plus_var, idensitys.o2p
;  ncdf_varput,id,'o2plus',idensitys.o2p
help,idensitys.o2p, o2plus_var, lon_var,lat_var
print,minmax(idensitys.o2p)

  NCDF_VARPUT, id, lon_var, meta.longitude
;-temphack
  NCDF_VARPUT, id, lat_var, reform(meta.latitude)
;  NCDF_VARPUT, id, alt_var, meta.altitude
  
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id
  
  ;TODO: error status
  return, 0
end
