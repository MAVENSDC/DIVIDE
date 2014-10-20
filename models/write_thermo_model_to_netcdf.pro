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


function write_thermo_model_to_netcdf, input_savefile

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
    print, "Something wrong with filename. Expected </optional/path/><filename>.sav"
    return, -1
  endif
  out_file = out_path+path_sep()+out_base_split[0]+'.nc'
  
  
  ; FIXME - nans or some mission value?
  ; 
  ; Define missing value and replace NaNs in the modeled data with it. 
  ;;missing_value = -99.0

  
 
  ; ===================================================================================
  ; Create NetCDF file for writing output
  ; ===================================================================================
  
  ;id = NCDF_CREATE(out_file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  id = NCDF_CREATE(out_file, /CLOBBER, /netCDF4_format) ;; FIXME - Currently overwriting file if it already exists.
  
  
  ; ===================================================================================
  ; Global Attributes
  ; ===================================================================================
  
  NCDF_ATTPUT, id, /GLOBAL, "file_format", "NetCDF"
  NCDF_ATTPUT, id, /GLOBAL, "title", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "source", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "FIXME? None at the moment"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "summary", "FIXME"


  ; ===================================================================================
  ; Define Dimensions
  ; ===================================================================================
  
  lon_id = NCDF_DIMDEF(id, 'lon', meta.nlons)
  lat_id = NCDF_DIMDEF(id, 'lat', meta.nlats)
  alt_id = NCDF_DIMDEF(id, 'alt', meta.nalts)
  
  
  ; ===================================================================================
  ; Variable Declaration & Attributes
  ; ===================================================================================

  ;; ------------------------------
  ;  ;; Plasma Densities
  o2plus_var = NCDF_VARDEF(id, 'o2plus', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, o2plus_var, 'title', 'O2+ ion density'
  NCDF_ATTPUT, id, o2plus_var, 'units', 'm-3'
  
  oplus_var = NCDF_VARDEF(id, 'oplus', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, oplus_var, 'title', 'O+ ion density'
  NCDF_ATTPUT, id, oplus_var, 'units', 'm-3'
  
  co2plus_var = NCDF_VARDEF(id, 'co2plus', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, co2plus_var, 'title', 'CO2+ ion density'
  NCDF_ATTPUT, id, co2plus_var, 'units', 'm-3'
  
  ne_var = NCDF_VARDEF(id, 'ne', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, ne_var, 'title', 'Ne ion density'
  NCDF_ATTPUT, id, ne_var, 'units', 'm-3'
  
  
  ;; ------------------------------
  ;; Neutral Densities
  co2_var = NCDF_VARDEF(id, 'co2', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, co2_var, 'title', 'CO2 neutral density'
  NCDF_ATTPUT, id, co2_var, 'units', 'm-3'
  
  co_var = NCDF_VARDEF(id, 'co', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, co_var, 'title', 'CO neutral density'
  NCDF_ATTPUT, id, co_var, 'units', 'm-3'
  
  n2_var = NCDF_VARDEF(id, 'n2', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, n2_var, 'title', 'N2 neutral density'
  NCDF_ATTPUT, id, n2_var, 'units', 'm-3'
  
  o2_var = NCDF_VARDEF(id, 'o2', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, o2_var, 'title', 'O2 neutral density'
  NCDF_ATTPUT, id, o2_var, 'units', 'm-3'
  
  o_var = NCDF_VARDEF(id, 'o', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, o_var, 'title', 'O neutral density'
  NCDF_ATTPUT, id, o_var, 'units', 'm-3'
  
  
  ;; ------------------------------
  ;; Neutral Winds
  zonal_vel_var = NCDF_VARDEF(id, 'Zonal_vel', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, zonal_vel_var, 'title', 'Un Zonal Velocity neutral'
  NCDF_ATTPUT, id, zonal_vel_var, 'units', 'm/s'
  
  merid_vel_var = NCDF_VARDEF(id, 'Medrid_vel', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, merid_vel_var, 'title', 'Vn Meridional Velocity neutral'
  NCDF_ATTPUT, id, merid_vel_var, 'units', 'm/s'
  
  vert_vel = NCDF_VARDEF(id, 'Vert_vel', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, vert_vel, 'title', 'Wn Vertical Velocity neutral'
  NCDF_ATTPUT, id, vert_vel, 'units', 'm/s'
  
  ;; ------------------------------
  ;  ;; Temperatures
  temp_tn_var = NCDF_VARDEF(id, 'Temp_tn', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, temp_tn_var, 'title', 'Tn Temperature'
  NCDF_ATTPUT, id, temp_tn_var, 'units', 'K'
  
  temp_ti_var = NCDF_VARDEF(id, 'Temp_ti', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, temp_ti_var, 'title', 'Ti Temperature'
  NCDF_ATTPUT, id, temp_ti_var, 'units', 'K'
  
  temp_te_var = NCDF_VARDEF(id, 'Temp_te', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, temp_te_var, 'title', 'Te Temperature'
  NCDF_ATTPUT, id, temp_te_var, 'units', 'K'
  
  
  ;; ------------------------------
  ;  ;; Dimensions
  lon_var = NCDF_VARDEF(id, 'lon', [lon_id], /FLOAT)
  NCDF_ATTPUT, id, lon_var, 'title', 'Longitude'
  NCDF_ATTPUT, id, lon_var, 'units', 'degrees east'
  
  lat_var = NCDF_VARDEF(id, 'lat', [lat_id], /FLOAT)
  NCDF_ATTPUT, id, lat_var, 'title', 'Latitude'
  NCDF_ATTPUT, id, lat_var, 'units', 'degreesn north'
  
  alt_var = NCDF_VARDEF(id, 'alt', [alt_id], /FLOAT)
  NCDF_ATTPUT, id, alt_var, 'title', 'Altitude'
  NCDF_ATTPUT, id, alt_var, 'units', 'km'
  
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  
  ; ===================================================================================
  ; Input data into the netcdf variables declared above
  ; ===================================================================================
  
  NCDF_VARPUT, id, o2plus_var, iondensity.o2p
  NCDF_VARPUT, id, oplus_var, iondensity.op
  NCDF_VARPUT, id, co2plus_var, iondensity.co2p
  NCDF_VARPUT, id, ne_var, iondensity.n_e    ;; FIXME - why underscore?
  
  NCDF_VARPUT, id, co2_var, neutraldensity.co2
  NCDF_VARPUT, id, co_var, neutraldensity.co
  NCDF_VARPUT, id, n2_var, neutraldensity.n2
  NCDF_VARPUT, id, o2_var, neutraldensity.o2
  NCDF_VARPUT, id, o_var, neutraldensity.o
  
  NCDF_VARPUT, id, zonal_vel_var, neutralwinds.veast
  NCDF_VARPUT, id, merid_vel_var, neutralwinds.vnorth
  NCDF_VARPUT, id, vert_vel, neutralwinds.vup
  
  NCDF_VARPUT, id, temp_tn_var, temperature.tn
  NCDF_VARPUT, id, temp_ti_var, temperature.ti
  NCDF_VARPUT, id, temp_te_var, temperature.te
  
  NCDF_VARPUT, id, lon_var, meta.longitude
  NCDF_VARPUT, id, lat_var, meta.latitude
  NCDF_VARPUT, id, alt_var, meta.altitude
  
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id
  
  ;TODO: error status
  return, 0
end