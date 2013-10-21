;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    record : in, required, type=structure
;       The single data record structure to hold INSITU KP data
;    iuvs_record: in, required, type=structure
;       the single data record structure to hold IUVS KP data
;    instrument_array: in, required, type=intarr(13)
;       an array that signals which types of data have been requested, so that only those fields are included in the structures.
;

;-
pro MVN_KP_STRUCTURE_BUILD, record, iuvs_record, instrument_array
  

  
;DEFINE THE ALWAYS INCLUDED STRUCTURES OF SPACECRAFT AND APP PARAMETERS 

  s1 =  {spacecraft, geo_x:0.0, geo_y:0.0, geo_z:0.0, mso_x:0.0, mso_y:0.0, mso_z:0.0, $
                                     sub_sc_longitude:0.0, sub_sc_latitude:0.0, sza:0.0, local_time:0.0, altitude:0.0, attitude_geo_x:0.0, $
                                     attitude_geo_y:0.0, attitude_geo_z:0.0, attitude_mso_x:0.0, $
                                     attitude_mso_y:0.0, attitude_mso_z:0.0, mars_season:0.0, $
                                     mars_sun_distance:0.0, subsolar_point_GEO_longitude:0.0, subsolar_point_GEO_latitude:0.0, $
                                     submars_point_solar_longitude:0.0, submars_point_solar_latitude:0.0}
  S2 =  {app, attitude_geo_x:0.0, attitude_geo_y:0.0, attitude_geo_z:0.0, attitude_mso_x:0.0,  $
                                    attitude_mso_y:0.0,  attitude_mso_z:0.0}                                
                                     
 record_temp1 = create_struct(['spacecraft','app'],s1,s2)

  ;CREATE THE BASE ARRAY FOR THE INSITU DATA, BASED ON WHAT DATA WILL BE RETURNED

  if instrument_array[0] eq 1 then begin    ;INCLUDE LPW DATA STRUCTURE
    s3 = {lpw, electron_density:0.0, electron_density_qual:0.0, electron_temperature:0.0, electron_temperature_qual:0.0,$
                             spacecraft_potential:0.0, spacecraft_potential_qual:0.0, ewave_low:0.0, ewave_low_qual:0.0, ewave_mid:0.0, $
                             ewave_mid_qual:0.0, ewave_high:0.0, ewave_high_qual:0.0, euv_irradiance_low:0.0, euv_irradiance_low_qual:0.0, $
                             euv_irradiance_mid:0.0, euv_irradiance_mid_qual:0.0, euv_irradiance_high:0.0, euv_irradiance_high_qual:0.0}
    record_temp2 = create_struct(['lpw'],s3,record_temp1)                         
  endif else begin
    record_temp2 = create_struct(record_temp1)
  endelse
  if instrument_array[1] eq 1 then begin  ;INCLUDE STATIC DATA STRUCTURE  
    s4 = {static, hplus_density:0.0, hplus_density_qual:0.0, oplus_density:0.0, oplus_density_qual:0.0,$
                  o2plus_density:0.0, o2plus_density_qual:0.0, hplus_temperature:0.0, hplus_temperature_qual:0.0, oplus_temperature:0.0, $
                  oplus_temperature_qual:0.0, o2plus_temperature:0.0, o2plus_temperature_qual:0.0, hplus_flow_v_msox:0.0, $
                  hplus_flow_v_msox_qual:0.0, hplus_flow_v_msoy:0.0, hplus_flow_v_msoy_qual:0.0, hplus_flow_v_msoz:0.0, $
                  hplus_flow_v_msoz_qual:0.0, oplus_flow_v_msox:0.0, oplus_flow_v_msox_qual:0.0, oplus_flow_v_msoy:0.0,$
                  oplus_flow_v_msoy_qual:0.0, oplus_flow_v_msoz:0.0, oplus_flow_v_msoz_qual:0.0, o2plus_flow_v_msox:0.0,  o2plus_flow_v_msox_qual:0.0, $
                  o2plus_flow_v_msoy:0.0, o2plus_flow_v_msoy_qual:0.0, o2plus_flow_v_msoz:0.0, o2plus_flow_v_msoz_qual:0.0, $
                  hhe_omni_flux:0.0, hhe_omni_flux_qual:0.0, hhe_char_energy:0.0, hhe_char_energy_qual:0.0, hhe_char_dir_msox:0.0, $
                  hhe_char_dir_msox_qual:0.0, hhe_char_dir_msoy:0.0, hhe_char_dir_msoy_qual:0.0, hhe_char_dir_msoz:0.0, hhe_char_dir_msoz_qual:0.0, $
                  hhe_char_angular_width:0.0, hhe_char_angular_width_qual:0.0, pickup_ion_omni_flux:0.0, pickup_ion_omni_flux_qual:0.0, pickup_ion_char_energy:0.0, $
                  pickup_ion_char_energy_qual:0.0, pickup_ion_char_dir_msox:0.0, pickup_ion_char_dir_msox_qual:0.0, pickup_ion_char_dir_msoy:0.0, pickup_ion_char_dir_msoy_qual:0.0, $
                  pickup_ion_char_dir_msoz:0.0, pickup_ion_char_dir_msoz_qual:0.0, pickup_ion_char_angular_width:0.0, pickup_ion_char_angular_width_qual:0.0}
   record_temp3 = create_struct(['static'],s4,record_temp2)
  endif else begin
    record_temp3 = create_struct(record_temp2)
  endelse
  if instrument_array[2] eq 1 then begin   ;INCLUDE SWIA DATA STRUCTURE
    s5 = {swia, hplus_density:0.0, hplus_density_qual:0.0, hplus_flow_v_msox:0.0, hplus_flow_v_msox_qual:0.0, $
                hplus_flow_v_msoy:0.0, hplus_flow_v_msoy_qual:0.0, hplus_flow_v_msoz:0.0, hplus_flow_v_msoz_qual:0.0, hplus_temperature:0.0, $
                hplus_temperature_qual:0.0, solarwind_dynamic_pressure:0.0, solarwind_dynamic_pressure_qual:0.0}
    record_temp4 = create_struct(['swia'],s5,record_temp3)
  endif else begin
    record_temp4 = create_struct(record_temp3)
  endelse 
  if instrument_array[3] eq 1 then begin   ;INCLUDE SWEA DATA STRUCTURE
    s6 = {swea, solarwind_e_density:0.0, solarwind_e_density_qual:0.0, solarwind_e_temperature:0.0, solarwind_e_temperature_qual:0.0, $
                electron_parallel_flux_low:0.0, electron_parallel_flux_low_qual:0.0, electron_parallel_flux_mid:0.0, electron_parallel_flux_mid_qual:0.0, $
                electron_parallel_flux_high:0.0, electron_parallel_flux_high_qual:0.0, electron_antiparallel_flux_low:0.0, electron_antiparallel_flux_low_qual:0.0,$
                electron_antiparallel_flux_mid:0.0, electron_antiparallel_flux_mid_qual:0.0, electron_antiparallel_flux_high:0.0, electron_antiparallel_flux_high_qual:0.0,$
                electron_spectrum_shape:0.0, electron_spectrum_shape_qual:0.0}
    record_temp5 = create_struct(['swea'], s6, record_temp4)
  endif else begin
    record_temp5 = create_struct(record_temp4)
  endelse
  if instrument_array[4] eq 1 then begin   ;INCLUDE MAG DATA STRUCTURE
    s7 = {mag, mso_x:0.0, mso_x_qual:0.0, mso_y:0.0, mso_y_qual:0.0, mso_z:0.0, mso_z_qual:0.0, geo_x:0.0, geo_x_qual:0.0, $
               geo_y:0.0, geo_y_qual:0.0, geo_z:0.0, geo_z_qual:0.0, rms:0.0, rms_qual:0.0  }
    record_temp6 = create_struct(['mag'], s7, record_temp5)
  endif else begin
    record_temp6 = create_struct(record_temp5)
  endelse
  if instrument_array[5] eq 1 then begin   ;INCLUDE SEP DATA STRUCTURE
    s8 = {sep, ion_energy_flux_1:0.0, ion_energy_flux_1_qual:0.0, ion_energy_flux_2:0.0, ion_energy_flux_2_qual:0.0,$
               ion_energy_flux_3:0.0, ion_energy_flux_3_qual:0.0, ion_energy_flux_4:0.0, ion_energy_flux_4_qual:0.0,$'
               electron_energy_flux_1:0.0, electron_energy_flux_1_qual:0.0, electron_energy_flux_2:0.0, electron_energy_flux_2_qual:0.0,$
               electron_energy_flux_3:0.0, electron_energy_flux_3_qual:0.0, electron_energy_flux_4:0.0, electron_energy_flux_4_qual:0.0,$
               look_direction_1_msox:0.0, look_direction_1_msoy:0.0, look_direction_1_msoz:0.0, $
               look_direction_2_msox:0.0, look_direction_2_msoy:0.0, look_direction_2_msoz:0.0, $
               look_direction_3_msox:0.0, look_direction_3_msoy:0.0, look_direction_3_msoz:0.0, $
               look_direction_4_msox:0.0, look_direction_4_msoy:0.0, look_direction_4_msoz:0.0}
    record_temp7 = create_struct(['sep'], s8, record_temp6)
  endif else begin
    record_temp7 = create_struct(record_temp6)
  endelse
  if instrument_array[6] eq 1 then begin   ;INCLUDE NGIMS DATA STRUCTURE
    s9 = {ngims, he_density:0.0, he_density_qual:0.0, o_density:0.0, o_density_qual:0.0, co_density:0.0, co_density_qual:0.0,$
                 n2_density:0.0, n2_density_qual:0.0, no_density:0.0, no_density_qual:0.0, ar_density:0.0, ar_density_qual:0.0,$
                 co2_density:0.0, co2_density_qual:0.0, o2plus_density:0.0, o2plus_density_qual:0.0, co2plus_density:0.0, $
                 co2plus_density_qual:0.0, noplus_density:0.0, noplus_density_qual:0.0, oplus_density:0.0, $
                 oplus_density_qual:0.0, conplus_density:0.0, conplus_density_qual:0.0, cplus_density:0.0, cplus_density_qual:0.0, $
                 ohplus_density:0.0, ohplus_density_qual:0.0, nplus_density:0.0, nplus_density_qual:0.0}
    record_temp8 = create_struct( ['ngims'], s9, record_temp7)
  endif else begin
    record_temp8 = create_struct(record_temp7)
  endelse

  
    
    record = 0
    record = create_struct(['time_string','time','orbit','io_bound'],'',0l,0L,'',record_temp8)


  ;CREATE THE IUVS BASE STRUCTURE, ASSUMING IT HAS BEEN REQUESTED.
  
  iuvs_record_temp = create_struct(['orbit'],0L)
 
  
  if instrument_array[7] eq 1 then begin    ;INCLUDE IUVS PERIAPSE DATA STRUCTURE
    i1 = {periapse,time_start:'', time_stop:'', scale_height_id:strarr(7), scale_height:fltarr(7), scale_height_err:fltarr(7), $
                   density_id:strarr(7), density:fltarr(7,31), density_err:fltarr(7,31), radiance_id:strarr(11), $
                   radiance:fltarr(11,31), radiance_err:fltarr(11,31), temperature_id:'', temperature:0.0, temperature_err:0.0, sza:0.0,$
                   local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, alt:fltarr(31), orbit_number:0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                   spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
                   spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                   subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                   mars_sun_distance:0.0}
    iuvs_record_temp1 = create_struct(['periapse'],[i1,i1,i1],iuvs_record_temp)
  endif else begin
    iuvs_record_temp1 = create_struct(iuvs_record_temp)
  endelse 
  if instrument_array[8] eq 1 then begin    ;INCLUDE IUVS APOAPSE DATA STRUCTURE
    i2 = {apoapse, time_start:'', time_stop:'', ozone_depth:fltarr(90,45), ozone_depth_err:fltarr(90,45), auroral_index:fltarr(90,45), dust_depth:fltarr(90,45), $
                   dust_depth_err:fltarr(90,45), radiance_id:strarr(4), radiance:fltarr(4,90,45), radiance_err:fltarr(4,90,45), sza_bp:fltarr(90,45), $
                   local_time_bp:fltarr(90,45), lon_bins:fltarr(90), lat_bins:fltarr(45), sza:0.0,$
                   local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, orbit_number:0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                   spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
                   spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                   subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                   mars_sun_distance:0.0}
    iuvs_record_temp2 = create_struct(['apoapse'],i2,iuvs_record_temp1)
  endif else begin
    iuvs_record_temp2 = create_struct(iuvs_record_temp1)
  endelse
  if instrument_array[9] eq 1 then begin    ;INCLUDE IUVS ECHELLE HIGH ALTITUDE CORONA DATA STRUCTURE
    i3 = {c_e_high, time_start:'', time_stop:'', half_int_distance_id:strarr(3), half_int_distance:fltarr(3), half_int_distance_err:fltarr(3), $
                    radiance_id:strarr(3), radiance:fltarr(3,77), radiance_err:fltarr(3,77), sza:0.0, local_time:0.0, lat:0.0, lon:0.0, $
                    lat_mso:0.0, lon_mso:0.0, alt:fltarr(77), orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                    spacecraft_mso:dblarr(3), sun_geo:dblarr(3), sun_mso:dblarr(3), spacecraft_geo_longitude:0.0,$
                    spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                    subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                    mars_sun_distance:0.0}
    iuvs_record_temp3 = create_struct(['corona_e_high'],i3,iuvs_record_temp2)
  endif else begin
    iuvs_record_temp3 = create_struct(iuvs_record_temp2)
  endelse
  if instrument_array[10] eq 1 then begin    ;INCLUDE IUVS ECHELLE LIMB CORONA DATA STRUCTURE
    i4 = {c_e_limb, time_start:'', time_stop:'', half_int_distance_id:strarr(3), half_int_distance:fltarr(3), half_int_distance_err:fltarr(3), $
                    radiance_id:strarr(3), radiance:fltarr(3,31), radiance_err:fltarr(3,31), sza:0.0, local_time:0.0, lat:0.0, lon:0.0, $
                    lat_mso:0.0, lon_mso:0.0, alt:fltarr(31), orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                    spacecraft_mso:dblarr(3), sun_geo:dblarr(3), sun_mso:dblarr(3), spacecraft_geo_longitude:0.0,$
                    spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                    subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                    mars_sun_distance:0.0}
    iuvs_record_temp4 = create_struct(['corona_e_limb'],i4,iuvs_record_temp3)
  endif else begin
    iuvs_record_temp4 = create_struct(iuvs_record_temp3)
  endelse
  if instrument_array[11] eq 1 then begin    ;INCLUDE IUVS STELLAR OCCULTATION DATA STRUCTURE
    i5 = {stellar, time_start:'', time_stop:'', test1:0.0}
    iuvs_record_temp5 = create_struct(['stellar_occ'],i5,iuvs_record_temp4)
  endif else begin
    iuvs_record_temp5 = create_struct(iuvs_record_temp4)
  endelse
  if instrument_array[12] eq 1 then begin     ;INCLUDE IUVS LO RES HIGH ALITUDE CORONA DATA STRUCTURE
    i6 = {c_l_high, time_start:'', time_stop:'', half_int_distance_id:strarr(6), half_int_distance:fltarr(6), half_int_distance_err:fltarr(6), $
                    density_id:strarr(4), density:fltarr(4,77), density_err:fltarr(4,77), radiance_id:strarr(6), radiance:fltarr(6,77), radiance_err:fltarr(6,77), $
                    sza:0.0, local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, alt:fltarr(77), orbit_number:0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                    spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
                    spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                    subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                    mars_sun_distance:0.0}
    iuvs_record_temp6 = create_struct(['corona_lo_high'],i6,iuvs_record_temp5)
  endif else begin
    iuvs_record_temp6 = create_struct(iuvs_record_temp5)
  endelse
  if instrument_array[13] eq 1 then begin     ;INCLUDE IUVS LO RES LIMB CORONA DATA STRUCTURE
    i7 = {c_l_limb, time_start:'', time_stop:'', scale_height_id:strarr(7), scale_height:fltarr(7), scale_height_err:fltarr(7), density_id:strarr(7), density:fltarr(7,31), $
                    density_err:fltarr(7,31), radiance_id:strarr(11), radiance:fltarr(11,31), radiance_err:fltarr(11,31), temperature_id:'', temperature:0.0, temperature_err:0.0, $
                    sza:0.0, local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, alt:fltarr(31), orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                    spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
                    spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                    subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                    mars_sun_distance:0.0}
    iuvs_record_temp7 = create_struct(['corona_lo_limb'],i7,iuvs_record_temp6)
  endif else begin
    iuvs_record_temp7 = create_struct(iuvs_record_temp6)
  endelse
  if instrument_array[14] eq 1 then begin     ;INCLUDE IUVS LO RES DISK CORONA DATA STRUCTURE
    i8 = {c_l_disk, time_start:'', time_stop:'', ozone_depth:0.0, ozone_depth_err:0.0, auroral_index:0.0, dust_depth:0.0, $
                    dust_depth_err:0.0, radiance_id:strarr(4), radiance:fltarr(4), radiance_err:fltarr(4), sza:0.0, local_time:0.0, $
                    lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                    spacecraft_mso:dblarr(3), sun_geo:dblarr(3), sun_mso:dblarr(3), spacecraft_geo_longitude:0.0,$
                    spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                    subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                    mars_sun_distance:0.0}
    iuvs_record_temp8 = create_struct(['corona_lo_disk'],i8,iuvs_record_temp7)
  endif else begin
    iuvs_record_temp8 = create_struct(iuvs_record_temp7)
  endelse  
  if instrument_array[15] eq 1 then begin     ;INCLUDE IUVS ECHELLE LIMB CORONA DATA STRUCTURE
    i9 = {c_e_disk, time_start:'', time_stop:'', radiance_id:strarr(3), radiance:fltarr(3), radiance_err:fltarr(3), sza:0.0,$
                   local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, orbit_number: 0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
                   spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
                   spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
                   subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
                   mars_sun_distance:0.0}
    iuvs_record_temp9 = create_struct(['corona_e_disk'],i9,iuvs_record_temp8)
  endif else begin
    iuvs_record_temp9 = create_struct(iuvs_record_temp8)
  endelse 

  iuvs_record = 0
  iuvs_record = create_struct(iuvs_record_temp9)

;return,record
end