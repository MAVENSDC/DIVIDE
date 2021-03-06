;+
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;
; THE ROUTINE TO PARSE THE INPUT BINARY DATA READ FROM KP FILES AND EXTRACT THE REQUESTED PORTIONS TO IUVS_RECORD
;
; :Params:
;    iuvs_record: in, required, type=structure
;       the output iuvs data structure to hold the requested KP data
;    input: in, required, type=structure
;       the IUVS KP data read from binary format, including all observational modes for a given orbit
;    instrument: in, required, type=string
;       the name of an observational mode, the data from which will be read
;
; :Keywords:
;    index: in, optional, type=integer
;       a counter used only within the periapse data to account for multiple limb scans per orbit
;-
pro MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, input, instrument, index=index


  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif


  if instrument eq 'APOAPSE' then begin
    iuvs_record.apoapse.time_start = input.time_start
    iuvs_record.apoapse.time_stop = input.time_stop
    iuvs_record.apoapse.ozone_depth = input.ozone_depth 
    iuvs_record.apoapse.ozone_depth_err = input.ozone_depth_err
    iuvs_record.apoapse.auroral_index =input.auroral_index
    iuvs_record.apoapse.dust_depth = input.dust_depth
    iuvs_record.apoapse.dust_depth_err = input.dust_depth_err
    iuvs_record.apoapse.radiance_id = input.radiance_id
    iuvs_record.apoapse.radiance = input.radiance
    iuvs_record.apoapse.radiance_err = input.radiance_err
    iuvs_record.apoapse.sza_bp = input.sza_bp
    iuvs_record.apoapse.local_time_bp = input.local_time_bp
    iuvs_record.apoapse.lon_bins = input.lon_bins
    iuvs_record.apoapse.lat_bins = input.lat_bins
    iuvs_record.apoapse.sza = input.sza
    iuvs_record.apoapse.local_time =input.local_time
    iuvs_record.apoapse.lat = input.lat
    iuvs_record.apoapse.lon = input.lon
    iuvs_record.apoapse.lat_mso = input.lat_mso 
    iuvs_record.apoapse.lon_mso = input.lon_mso 
    iuvs_record.apoapse.orbit_number = input.orbit_number
    iuvs_record.apoapse.mars_season_ls = input.mars_season_ls 
    iuvs_record.apoapse.spacecraft_geo = input.sc_geo 
    iuvs_record.apoapse.spacecraft_mso = input.sc_mso
    iuvs_record.apoapse.sun_geo = input.sun_geo
    iuvs_record.apoapse.spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.apoapse.spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.apoapse.spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.apoapse.spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.apoapse.subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.apoapse.subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.apoapse.spacecraft_sza = input.sc_sza
    iuvs_record.apoapse.spacecraft_local_time = input.sc_local_time
    iuvs_record.apoapse.spacecraft_altitude = input.sc_altitude
    iuvs_record.apoapse.mars_sun_distance = input.mars_sun_dist   
  endif

  if instrument eq 'CORONA_ECHELLE_LIMB' then begin
    iuvs_record.corona_e_limb.time_start = input.time_start
    iuvs_record.corona_e_limb.time_stop = input.time_stop
    iuvs_record.corona_e_limb.half_int_distance_id = input.half_int_distance_id
    iuvs_record.corona_e_limb.half_int_distance = input.half_int_distance
    iuvs_record.corona_e_limb.half_int_distance_err = input.half_int_distance_err
    iuvs_record.corona_e_limb.radiance_id = input.radiance_id
    iuvs_record.corona_e_limb.radiance = input.radiance
    iuvs_record.corona_e_limb.radiance_err = input.radiance_err
    iuvs_record.corona_e_limb.sza = input.sza
    iuvs_record.corona_e_limb.local_time = input.local_time
    iuvs_record.corona_e_limb.lat = input.lat
    iuvs_record.corona_e_limb.lon = input.lon
    iuvs_record.corona_e_limb.lat_mso = input.lat_mso
    iuvs_record.corona_e_limb.lon_mso = input.lon_mso
    iuvs_record.corona_e_limb.alt = input.alt
    iuvs_record.corona_e_limb.orbit_number = input.orbit_number
    iuvs_record.corona_e_limb.mars_season_ls = input.mars_season_ls
    iuvs_record.corona_e_limb.spacecraft_geo = input.sc_geo
    iuvs_record.corona_e_limb.spacecraft_mso = input.sc_mso
    iuvs_record.corona_e_limb.sun_geo = input.sun_geo
    iuvs_record.corona_e_limb.spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.corona_e_limb.spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.corona_e_limb.spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.corona_e_limb.spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.corona_e_limb.subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.corona_e_limb.subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.corona_e_limb.spacecraft_sza = input.sc_sza
    iuvs_record.corona_e_limb.spacecraft_local_time = input.sc_local_time
    iuvs_record.corona_e_limb.spacecraft_altitude = input.sc_altitude
    iuvs_record.corona_e_limb.mars_sun_distance = input.mars_sun_dist
  endif

  if instrument eq 'CORONA_ECHELLE_HIGH' then begin
    iuvs_record.corona_e_high.time_start = input.time_start
    iuvs_record.corona_e_high.time_stop = input.time_stop
    iuvs_record.corona_e_high.half_int_distance_id = input.half_int_distance_id
    iuvs_record.corona_e_high.half_int_distance = input.half_int_distance
    iuvs_record.corona_e_high.half_int_distance_err = input.half_int_distance_err
    iuvs_record.corona_e_high.radiance_id = input.radiance_id
    iuvs_record.corona_e_high.radiance = input.radiance
    iuvs_record.corona_e_high.radiance_err = input.radiance_err
    iuvs_record.corona_e_high.sza = input.sza
    iuvs_record.corona_e_high.local_time = input.local_time
    iuvs_record.corona_e_high.lat = input.lat
    iuvs_record.corona_e_high.lon = input.lon
    iuvs_record.corona_e_high.lat_mso = input.lat_mso
    iuvs_record.corona_e_high.lon_mso = input.lon_mso
    iuvs_record.corona_e_high.alt = input.alt
    iuvs_record.corona_e_high.orbit_number = input.orbit_number
    iuvs_record.corona_e_high.mars_season_ls = input.mars_season_ls
    iuvs_record.corona_e_high.spacecraft_geo = input.sc_geo
    iuvs_record.corona_e_high.spacecraft_mso = input.sc_mso
    iuvs_record.corona_e_high.sun_geo = input.sun_geo
    iuvs_record.corona_e_high.spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.corona_e_high.spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.corona_e_high.spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.corona_e_high.spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.corona_e_high.subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.corona_e_high.subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.corona_e_high.spacecraft_sza = input.sc_sza
    iuvs_record.corona_e_high.spacecraft_local_time = input.sc_local_time
    iuvs_record.corona_e_high.spacecraft_altitude = input.sc_altitude
    iuvs_record.corona_e_high.mars_sun_distance = input.mars_sun_dist
  endif
  
  if instrument eq 'CORONA_ECHELLE_DISK' then begin
    iuvs_record.corona_e_disk.time_start = input.time_start
    iuvs_record.corona_e_disk.time_stop = input.time_stop
    iuvs_record.corona_e_disk.radiance_id = input.radiance_id
    iuvs_record.corona_e_disk.radiance = input.radiance
    iuvs_record.corona_e_disk.radiance_err = input.radiance_err
    iuvs_record.corona_e_disk.sza = input.sza
    iuvs_record.corona_e_disk.local_time = input.local_time
    iuvs_record.corona_e_disk.lat = input.lat
    iuvs_record.corona_e_disk.lon = input.lon
    iuvs_record.corona_e_disk.lat_mso = input.lat_mso
    iuvs_record.corona_e_disk.lon_mso = input.lon_mso
    iuvs_record.corona_e_disk.orbit_number = input.orbit_number
    iuvs_record.corona_e_disk.mars_season_ls = input.mars_season_ls
    iuvs_record.corona_e_disk.spacecraft_geo = input.sc_geo
    iuvs_record.corona_e_disk.spacecraft_mso = input.sc_mso
    iuvs_record.corona_e_disk.sun_geo = input.sun_geo
    iuvs_record.corona_e_disk.spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.corona_e_disk.spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.corona_e_disk.spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.corona_e_disk.spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.corona_e_disk.subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.corona_e_disk.subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.corona_e_disk.spacecraft_sza = input.sc_sza
    iuvs_record.corona_e_disk.spacecraft_local_time = input.sc_local_time
    iuvs_record.corona_e_disk.spacecraft_altitude = input.sc_altitude
    iuvs_record.corona_e_disk.mars_sun_distance = input.mars_sun_dist
  endif
  
  if instrument eq 'PERIAPSE' then begin
    iuvs_record.periapse[index].time_start = input.time_start
    iuvs_record.periapse[index].time_stop = input.time_stop
    iuvs_record.periapse[index].scale_height_id = input.scale_height_id
    iuvs_record.periapse[index].scale_height = input.scale_height
    iuvs_record.periapse[index].scale_height_err = input.scale_height_err
    iuvs_record.periapse[index].density_id = input.density_id
    iuvs_record.periapse[index].density = input.density
    iuvs_record.periapse[index].density_err = input.density_err
    iuvs_record.periapse[index].radiance_id = input.radiance_id
    iuvs_record.periapse[index].radiance = input.radiance
    iuvs_record.periapse[index].radiance_err = input.radiance_err
    iuvs_record.periapse[index].temperature_id = input.temperature_id
    iuvs_record.periapse[index].temperature = input.temperature
    iuvs_record.periapse[index].temperature_err = input.temperature_err
    iuvs_record.periapse[index].sza = input.sza
    iuvs_record.periapse[index].local_time = input.local_time
    iuvs_record.periapse[index].lat = input.lat
    iuvs_record.periapse[index].lon = input.lon
    iuvs_record.periapse[index].lat_mso = input.lat_mso
    iuvs_record.periapse[index].lon_mso = input.lon_mso
    iuvs_record.periapse[index].alt = input.alt
    iuvs_record.periapse[index].orbit_number = input.orbit_number
    iuvs_record.periapse[index].mars_season_ls = input.mars_season_ls
    iuvs_record.periapse[index].spacecraft_geo = input.sc_geo
    iuvs_record.periapse[index].spacecraft_mso = input.sc_mso
    iuvs_record.periapse[index].sun_geo = input.sun_geo
    iuvs_record.periapse[index].spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.periapse[index].spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.periapse[index].spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.periapse[index].spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.periapse[index].subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.periapse[index].subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.periapse[index].spacecraft_sza = input.sc_sza
    iuvs_record.periapse[index].spacecraft_local_time = input.sc_local_time
    iuvs_record.periapse[index].spacecraft_altitude = input.sc_altitude
    iuvs_record.periapse[index].mars_sun_distance = input.mars_sun_dist
  endif
  
  if instrument eq 'CORONA_LORES_HIGH' then begin
    iuvs_record.corona_lo_high.time_start = input.time_start
    iuvs_record.corona_lo_high.time_stop = input.time_stop
    iuvs_record.corona_lo_high.half_int_distance_id = input.half_int_distance_id
    iuvs_record.corona_lo_high.half_int_distance = input.half_int_distance
    iuvs_record.corona_lo_high.half_int_distance_err = input.half_int_distance_err
    iuvs_record.corona_lo_high.density_id = input.density_id
    iuvs_record.corona_lo_high.column_density = input.density
    iuvs_record.corona_lo_high.density_err = input.density_err
    iuvs_record.corona_lo_high.radiance_id = input.radiance_id
    iuvs_record.corona_lo_high.radiance = input.radiance
    iuvs_record.corona_lo_high.radiance_err = input.radiance_err
    iuvs_record.corona_lo_high.sza = input.sza
    iuvs_record.corona_lo_high.local_time = input.local_time
    iuvs_record.corona_lo_high.lat = input.lat
    iuvs_record.corona_lo_high.lon = input.lon
    iuvs_record.corona_lo_high.lat_mso = input.lat_mso
    iuvs_record.corona_lo_high.lon_mso = input.lon_mso
    iuvs_record.corona_lo_high.alt = input.alt
    iuvs_record.corona_lo_high.orbit_number = input.orbit_number
    iuvs_record.corona_lo_high.mars_season_ls = input.mars_season_ls
    iuvs_record.corona_lo_high.spacecraft_geo = input.sc_geo
    iuvs_record.corona_lo_high.spacecraft_mso = input.sc_mso
    iuvs_record.corona_lo_high.sun_geo = input.sun_geo
    iuvs_record.corona_lo_high.spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.corona_lo_high.spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.corona_lo_high.spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.corona_lo_high.spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.corona_lo_high.subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.corona_lo_high.subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.corona_lo_high.spacecraft_sza = input.sc_sza
    iuvs_record.corona_lo_high.spacecraft_local_time = input.sc_local_time
    iuvs_record.corona_lo_high.spacecraft_altitude = input.sc_altitude
    iuvs_record.corona_lo_high.mars_sun_distance = input.mars_sun_dist
  endif
  
  if instrument eq 'CORONA_LORES_LIMB' then begin
    iuvs_record.corona_lo_limb.time_start = input.time_start
    iuvs_record.corona_lo_limb.time_stop = input.time_stop
    iuvs_record.corona_lo_limb.scale_height_id = input.scale_height_id
    iuvs_record.corona_lo_limb.scale_height = input.scale_height
    iuvs_record.corona_lo_limb.scale_height_err = input.scale_height_err
    iuvs_record.corona_lo_limb.density_id = input.density_id
    iuvs_record.corona_lo_limb.density = input.density
    iuvs_record.corona_lo_limb.density_err = input.density_err
    iuvs_record.corona_lo_limb.radiance_id = input.radiance_id
    iuvs_record.corona_lo_limb.radiance = input.radiance
    iuvs_record.corona_lo_limb.radiance_err = input.radiance_err
    iuvs_record.corona_lo_limb.temperature_id = input.temperature_id
    iuvs_record.corona_lo_limb.temperature = input.temperature
    iuvs_record.corona_lo_limb.temperature_err = input.temperature_err
    iuvs_record.corona_lo_limb.sza = input.sza
    iuvs_record.corona_lo_limb.local_time = input.local_time
    iuvs_record.corona_lo_limb.lat = input.lat
    iuvs_record.corona_lo_limb.lon = input.lon
    iuvs_record.corona_lo_limb.lat_mso = input.lat_mso
    iuvs_record.corona_lo_limb.lon_mso = input.lon_mso
    iuvs_record.corona_lo_limb.alt = input.alt
    iuvs_record.corona_lo_limb.orbit_number = input.orbit_number
    iuvs_record.corona_lo_limb.mars_season_ls = input.mars_season_ls
    iuvs_record.corona_lo_limb.spacecraft_geo = input.sc_geo
    iuvs_record.corona_lo_limb.spacecraft_mso = input.sc_mso
    iuvs_record.corona_lo_limb.sun_geo = input.sun_geo
    iuvs_record.corona_lo_limb.spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.corona_lo_limb.spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.corona_lo_limb.spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.corona_lo_limb.spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.corona_lo_limb.subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.corona_lo_limb.subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.corona_lo_limb.spacecraft_sza = input.sc_sza
    iuvs_record.corona_lo_limb.spacecraft_local_time = input.sc_local_time
    iuvs_record.corona_lo_limb.spacecraft_altitude = input.sc_altitude
    iuvs_record.corona_lo_limb.mars_sun_distance = input.mars_sun_dist
  endif

  if instrument eq 'CORONA_LORES_DISK' then begin
    iuvs_record.corona_lo_disk.time_start = input.time_start
    iuvs_record.corona_lo_disk.time_stop = input.time_stop
    iuvs_record.corona_lo_disk.ozone_depth = input.ozone_depth
    iuvs_record.corona_lo_disk.ozone_depth_err = input.ozone_depth_err
    iuvs_record.corona_lo_disk.auroral_index = input.auroral_index
    iuvs_record.corona_lo_disk.dust_depth = input.dust_depth
    iuvs_record.corona_lo_disk.dust_depth_err = input.dust_depth_err
    iuvs_record.corona_lo_disk.radiance_id = input.radiance_id
    iuvs_record.corona_lo_disk.radiance = input.radiance
    iuvs_record.corona_lo_disk.radiance_err = input.radiance_err
    iuvs_record.corona_lo_disk.sza = input.sza
    iuvs_record.corona_lo_disk.local_time = input.local_time
    iuvs_record.corona_lo_disk.lat = input.lat
    iuvs_record.corona_lo_disk.lon = input.lon
    iuvs_record.corona_lo_disk.lat_mso = input.lat_mso
    iuvs_record.corona_lo_disk.lon_mso = input.lon_mso
    iuvs_record.corona_lo_disk.orbit_number = input.orbit_number
    iuvs_record.corona_lo_disk.mars_season_ls = input.mars_season_ls
    iuvs_record.corona_lo_disk.spacecraft_geo = input.sc_geo
    iuvs_record.corona_lo_disk.spacecraft_mso = input.sc_mso
    iuvs_record.corona_lo_disk.sun_geo = input.sun_geo
    iuvs_record.corona_lo_disk.spacecraft_geo_longitude = input.sc_geo_lon
    iuvs_record.corona_lo_disk.spacecraft_geo_latitude = input.sc_geo_lat
    iuvs_record.corona_lo_disk.spacecraft_mso_longitude = input.sc_mso_lon
    iuvs_record.corona_lo_disk.spacecraft_mso_latitude = input.sc_mso_lat
    iuvs_record.corona_lo_disk.subsolar_point_geo_longitude = input.subsol_geo_lon
    iuvs_record.corona_lo_disk.subsolar_point_geo_latitude = input.subsol_geo_lat
    iuvs_record.corona_lo_disk.spacecraft_sza = input.sc_sza
    iuvs_record.corona_lo_disk.spacecraft_local_time = input.sc_local_time
    iuvs_record.corona_lo_disk.spacecraft_altitude = input.sc_altitude
    iuvs_record.corona_lo_disk.mars_sun_distance = input.mars_sun_dist
  endif


end