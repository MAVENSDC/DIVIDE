;+
; :NAME:
;   write_thermo_model_to_netcdf
;
; :DESCRIPTION:
;   Restore given IDL sav file containing model output from Bougher's
;   MGITM and produce netCDF files containing all relevant data
;   and metadata.
;
; :INPUTS:
;  input_savefile: string: name of the IDL save file to restore
;
; :Keywords:
;  overwrite - if present, overwrite existing nc file.
;
; :OUTPUTS:
;  NONE: but it writes a netCDF file
;
; :AUTHOR:
;  ???
;
; :HISTORY:
;
;-

function write_thermo_model_to_netcdf, input_savefile, overwrite=overwrite

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

  
 
  ; ==========================================================================
  ; Create NetCDF file for writing output
  ; ==========================================================================

; ToDo: Maybe add a check on file existence?
  id = (keyword_set(overwrite)) $
     ? NCDF_CREATE( out_file, /clobber, /netCDF4_format ) $
     : NCDF_CREATE( out_file, /noclobber, /netCDF4_format )  
  
  ; ==========================================================================
  ; Global Attributes
  ; ==========================================================================
  
  NCDF_ATTPUT, id, /GLOBAL, "file_format", "NetCDF"
  NCDF_ATTPUT, id, /GLOBAL, "title", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "source", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "FIXME? None at the moment"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "FIXME"
  NCDF_ATTPUT, id, /GLOBAL, "summary", "FIXME"
; Added from Steve's docx header file
  NCDF_ATTPUT, id, /GLOBAL, "Dust conditions", "tau=0.5, CR=0.003"
  NCDF_ATTPUT, id, /GLOBAL, "Crustal Fields", "OFF"
  NCDF_ATTPUT, id, /GLOBAL, "Dynamical Ionosphere", "OFF"
  NCDF_ATTPUT, id, /GLOBAL, "Linkage to other models", "N/A"
  refs=["Bougher et al. (2015), JGR 120:311-342, doi:10.1002/2014JE004715", $
        "Bougher et al. (2014), SSR, doi:10.1007/s11214-014-0053-7"]
  NCDF_ATTPUT, id, /GLOBAL, "References", refs

  ; ==========================================================================
  ; Define Dimensions
  ; ==========================================================================
  lon_id = NCDF_DIMDEF(id, 'longitude', meta.nlons)
  lat_id = NCDF_DIMDEF(id, 'latitude', meta.nlats)
  alt_id = NCDF_DIMDEF(id, 'altitude', meta.nalts)

  ; We need to calculate solar declination from LS
  case (meta.ls) of
    0: dec = 0.
    90: dec = 25.19
    180: dec = 0.
    270: dec = -25.19
    else: begin
      message, "Invalid LS provided.  Must be among {0,90,180,270}"
    end 
  endcase
  meta = create_struct( meta, 'dec', dec )
  
  ; ==========================================================================
  ; Variable Declaration & Attributes
  ; ==========================================================================

  ;; -------------------------------
  ;  ;; meta data
  coord_var      = ncdf_vardef( id, 'coordinate_system', /string )
  ls_var         = ncdf_vardef( id, 'ls', /int )
  longsubsol_var = ncdf_vardef( id, 'longsubsol', /int )
  dec_var        = ncdf_vardef( id, 'dec', /float )
  marsrad_var    = ncdf_vardef( id, 'mars_radius', /float )
  alt_from_var   = ncdf_vardef( id, 'altitude_from', /string )

  ;; ------------------------------
  ;  ;; Dimensions
  lon_var = NCDF_VARDEF(id, 'Longitude', [lon_id], /FLOAT)
  NCDF_ATTPUT, id, lon_var, 'title', 'Longitude'
  NCDF_ATTPUT, id, lon_var, 'units', 'degrees east'

  lat_var = NCDF_VARDEF(id, 'Latitude', [lat_id], /FLOAT)
  NCDF_ATTPUT, id, lat_var, 'title', 'Latitude'
  NCDF_ATTPUT, id, lat_var, 'units', 'degrees north'

  alt_var = NCDF_VARDEF(id, 'altitude', [alt_id], /FLOAT)
  NCDF_ATTPUT, id, alt_var, 'title', 'Altitude'
  NCDF_ATTPUT, id, alt_var, 'units', 'km'

  ;; ------------------------------
  ;  ;; Plasma Densities
  ;
  o2plus_var = NCDF_VARDEF(id, 'o2plus', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, o2plus_var, 'title', 'O2+ ion density'
  NCDF_ATTPUT, id, o2plus_var, 'units', 'm-3'
  
  oplus_var = NCDF_VARDEF(id, 'oplus', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, oplus_var, 'title', 'O+ ion density'
  NCDF_ATTPUT, id, oplus_var, 'units', 'm-3'
  
  co2plus_var = NCDF_VARDEF(id, 'co2plus', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, co2plus_var, 'title', 'CO2+ ion density'
  NCDF_ATTPUT, id, co2plus_var, 'units', 'm-3'
  
  ne_var = NCDF_VARDEF(id, 'n_e', [lon_id, lat_id, alt_id], /FLOAT)
  NCDF_ATTPUT, id, ne_var, 'title', 'electron density'
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
  zonal_vel_var = NCDF_VARDEF(id, 'Zonal_vel', [lon_id, lat_id, alt_id], $
                              /FLOAT)
  NCDF_ATTPUT, id, zonal_vel_var, 'title', 'Un Zonal Velocity neutral'
  NCDF_ATTPUT, id, zonal_vel_var, 'units', 'm/s'
  
  merid_vel_var = NCDF_VARDEF(id, 'Merid_vel', [lon_id, lat_id, alt_id], $
                              /FLOAT)
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
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  
  ; ==========================================================================
  ; Input data into the netcdf variables declared above
  ; ==========================================================================
  
;
; placing the meta information first
  ncdf_varput, id, coord_var, meta.coordinate_system
  ncdf_varput, id, ls_var, meta.ls
  ncdf_varput, id, longsubsol_var, meta.longsubsol
  ncdf_varput, id, dec_var, meta.dec
  ncdf_varput, id, marsrad_var, meta.mars_radius
  ncdf_varput, id, alt_from_var, meta.altitude_from
;
; placing the dimension second
  NCDF_VARPUT, id, lon_var, meta.longitude
  NCDF_VARPUT, id, lat_var, meta.latitude
  NCDF_VARPUT, id, alt_var, meta.altitude
;
; placing the model parameters last

  NCDF_VARPUT, id, o2plus_var, idensitys.o2p
  NCDF_VARPUT, id, oplus_var, idensitys.op
  NCDF_VARPUT, id, co2plus_var, idensitys.co2p 
  NCDF_VARPUT, id, ne_var, idensitys.n_e    ;; FIXME - why underscore?
                                            ;; bc ne is forbidden as 
                                            ;; an attribute name
  
  NCDF_VARPUT, id, co2_var, ndensitys.co2
  NCDF_VARPUT, id, co_var, ndensitys.co
  NCDF_VARPUT, id, n2_var, ndensitys.n2
  NCDF_VARPUT, id, o2_var, ndensitys.o2
  NCDF_VARPUT, id, o_var, ndensitys.o
  
  NCDF_VARPUT, id, zonal_vel_var, nvelocity.veast
  NCDF_VARPUT, id, merid_vel_var, nvelocity.vnorth
  NCDF_VARPUT, id, vert_vel, nvelocity.vup
  
  NCDF_VARPUT, id, temp_tn_var, temperature.tn
  NCDF_VARPUT, id, temp_ti_var, temperature.ti
  NCDF_VARPUT, id, temp_te_var, temperature.te
  
  ; ToDo: Do we not care about qeuvionrate?
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id
  
  ;TODO: error status
  return, 0
end
