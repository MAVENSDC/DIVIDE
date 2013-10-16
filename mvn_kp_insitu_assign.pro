;+
; Searches the input line of kp data based on the search parameters
;
; :Params:
;    record : in, required, type=structure
;       the named structure for the sorted and output INSITU KP data
;    data_array: in, required, type=fltarr(ndims)
;       the KP data read from the ascii or binary files, includes all instrument data
;    instrument_array: in, required, type=fltarr(13)
;       the instrument choice flags that determine which data will be returned from data_array
;    

;-
pro MVN_KP_INSITU_ASSIGN, record, data_array, instrument_array


  record.time_string = data_array.time_string
  record.time = time_double(record.time_string)
  if instrument_array[0] eq 1 then begin            ;return all the LPW data
    record.lpw.electron_density = data_array.data[0]
    record.lpw.electron_density_qual = data_array.data[1]
    record.lpw.electron_temperature = data_array.data[2]
    record.lpw.electron_temperature_qual = data_array.data[3]
    record.lpw.spacecraft_potential = data_array.data[4]
    record.lpw.spacecraft_potential_qual = data_array.data[5]
    record.lpw.ewave_low = data_array.data[6]
    record.lpw.ewave_low_qual = data_array.data[7]
    record.lpw.ewave_mid = data_array.data[8]
    record.lpw.ewave_mid_qual = data_array.data[9]
    record.lpw.ewave_high = data_array.data[10]
    record.lpw.ewave_high_qual = data_array.data[11]
    record.lpw.euv_irradiance_low = data_array.data[12]
    record.lpw.euv_irradiance_low_qual = data_array.data[13]
    record.lpw.euv_irradiance_mid = data_array.data[14]
    record.lpw.euv_irradiance_mid_qual = data_array.data[15]
    record.lpw.euv_irradiance_high = data_array.data[16]
    record.lpw.euv_irradiance_high_qual = data_array.data[17]
  endif
  if instrument_array[1] eq 1 then begin          ;return all teh Static data
    record.static.hplus_density = data_array.data[48]
    record.static.hplus_density_qual = data_array.data[49]
    record.static.oplus_density = data_array.data[50]
    record.static.oplus_density_qual = data_array.data[51]
    record.static.o2plus_density = data_array.data[52]
    record.static.o2plus_density_qual = data_array.data[53]
    record.static.hplus_temperature = data_array.data[54]
    record.static.hplus_temperature_qual = data_array.data[55]
    record.static.oplus_temperature =data_array.data[56]
    record.static.oplus_temperature_qual = data_array.data[57]
    record.static.o2plus_temperature = data_array.data[58]
    record.static.o2plus_temperature_qual= data_array.data[59]
    record.static.hplus_flow_v_msox = data_array.data[60]
    record.static.hplus_flow_v_msox_qual = data_array.data[61]
    record.static.hplus_flow_v_msoy = data_array.data[62]
    record.static.hplus_flow_v_msoy_qual = data_array.data[63]
    record.static.hplus_flow_v_msoz = data_array.data[64]
    record.static.hplus_flow_v_msoz_qual = data_array.data[65]
    record.static.oplus_flow_v_msox = data_array.data[66]
    record.static.oplus_flow_v_msox_qual = data_array.data[67]
    record.static.oplus_flow_v_msoy = data_array.data[68]
    record.static.oplus_flow_v_msoy_qual = data_array.data[69]
    record.static.oplus_flow_v_msoz = data_array.data[70]
    record.static.oplus_flow_v_msoz_qual = data_array.data[71]
    record.static.o2plus_flow_v_msox = data_array.data[72]
    record.static.o2plus_flow_v_msox_qual = data_array.data[73]
    record.static.o2plus_flow_v_msoy = data_array.data[74]
    record.static.o2plus_flow_v_msoy_qual = data_array.data[75]
    record.static.o2plus_flow_v_msoz = data_array.data[76]
    record.static.o2plus_flow_v_msoz_qual = data_array.data[77]
    record.static.hhe_omni_flux = data_array.data[78]
    record.static.hhe_omni_flux_qual = data_array.data[79]
    record.static.hhe_char_energy = data_array.data[80]
    record.static.hhe_char_energy_qual = data_array.data[81]
    record.static.hhe_char_dir_msox = data_array.data[82]
    record.static.hhe_char_dir_msox_qual = data_array.data[83]
    record.static.hhe_char_dir_msoy = data_array.data[84]
    record.static.hhe_char_dir_msoy_qual = data_array.data[85]
    record.static.hhe_char_dir_msoz = data_array.data[86]
    record.static.hhe_char_dir_msoz_qual = data_array.data[87]
    record.static.hhe_char_angular_width = data_array.data[88]
    record.static.hhe_char_angular_width_qual = data_array.data[89]
    record.static.pickup_ion_omni_flux = data_array.data[90]
    record.static.pickup_ion_omni_flux_qual = data_array.data[91]
    record.static.pickup_ion_char_energy = data_array.data[92]
    record.static.pickup_ion_char_energy_qual = data_array.data[93]
    record.static.pickup_ion_char_dir_msox = data_array.data[94]
    record.static.pickup_ion_char_dir_msox_qual = data_array.data[95]
    record.static.pickup_ion_char_dir_msoy = data_array.data[96]
    record.static.pickup_ion_char_dir_msoy_qual = data_array.data[97]
    record.static.pickup_ion_char_dir_msoz = data_array.data[98]
    record.static.pickup_ion_char_dir_msoz_qual = data_array.data[99]
    record.static.pickup_ion_char_angular_width = data_array.data[100]
    record.static.pickup_ion_char_angular_width_qual = data_array.data[101]
  endif 
  if instrument_array[2] eq 1 then begin      ;return all the swia data
    record.swia.hplus_density = data_array.data[36]
    record.swia.hplus_density_qual = data_array.data[37]
    record.swia.hplus_flow_v_msox = data_array.data[38]
    record.swia.hplus_flow_v_msox_qual = data_array.data[39]
    record.swia.hplus_flow_v_msoy = data_array.data[40]
    record.swia.hplus_flow_v_msoy_qual = data_array.data[41]
    record.swia.hplus_flow_v_msoz = data_array.data[42]
    record.swia.hplus_flow_v_msoz_qual = data_array.data[43]
    record.swia.hplus_temperature = data_array.data[44]
    record.swia.hplus_temperature_qual = data_array.data[45]
    record.swia.solarwind_dynamic_pressure = data_array.data[46]
    record.swia.solarwind_dynamic_pressure_qual = data_array.data[47]
  endif
  if instrument_array[3] eq 1 then begin      ;return all the swea data
    record.swea.solarwind_e_density = data_array.data[18]
    record.swea.solarwind_e_density_qual = data_array.data[19]
    record.swea.solarwind_e_temperature = data_array.data[20]
    record.swea.solarwind_e_temperature = data_array.data[21]
    record.swea.electron_parallel_flux_low = data_array.data[22]
    record.swea.electron_parallel_flux_low_qual = data_array.data[23]
    record.swea.electron_parallel_flux_mid = data_array.data[24]
    record.swea.electron_parallel_flux_mid_qual = data_array.data[25]
    record.swea.electron_parallel_flux_high = data_array.data[26]
    record.swea.electron_parallel_flux_high_qual = data_array.data[27]
    record.swea.electron_antiparallel_flux_low = data_array.data[28]
    record.swea.electron_antiparallel_flux_low_qual = data_array.data[29]
    record.swea.electron_antiparallel_flux_mid = data_array.data[30]
    record.swea.electron_antiparallel_flux_mid_qual = data_array.data[31]
    record.swea.electron_antiparallel_flux_high  = data_array.data[32]
    record.swea.electron_antiparallel_flux_high_qual = data_array.data[33]
    record.swea.electron_spectrum_shape = data_array.data[34]
    record.swea.electron_spectrum_shape_qual = data_array.data[35]
  endif
  if instrument_array[4] eq 1 then begin      ;retunr all the mag data
    record.mag.mso_x = data_array.data[130]
    record.mag.mso_x_qual= data_array.data[131]
    record.mag.mso_y = data_array.data[132]
    record.mag.mso_y_qual = data_array.data[133]
    record.mag.mso_z = data_array.data[134]
    record.mag.mso_z_qual = data_array.data[135]
    record.mag.geo_x = data_array.data[136]
    record.mag.geo_x_qual = data_array.data[137]
    record.mag.geo_y = data_array.data[138]
    record.mag.geo_y_qual = data_array.data[139]
    record.mag.geo_z = data_array.data[140]
    record.mag.geo_z_qual = data_array.data[141]
    record.mag.rms = data_array.data[142]
    record.mag.rms_qual = data_array.data[143]
  endif
  if instrument_array[5] eq 1 then begin    ;return atll the SEP data  
    record.sep.ion_energy_flux_1 = data_array.data[102]
    record.sep.ion_energy_flux_1_qual = data_array.data[103]
    record.sep.ion_energy_flux_2 = data_array.data[104]
    record.sep.ion_energy_flux_2_qual = data_array.data[105]
    record.sep.ion_energy_flux_3 = data_array.data[106]
    record.sep.ion_energy_flux_3_qual = data_array.data[107]
    record.sep.ion_energy_flux_4 = data_array.data[108]
    record.sep.ion_energy_flux_4_qual = data_array.data[109]
    record.sep.electron_energy_flux_1 = data_array.data[110]
    record.sep.electron_energy_flux_1_qual = data_array.data[111]
    record.sep.electron_energy_flux_2 = data_array.data[112]
    record.sep.electron_energy_flux_2_qual = data_array.data[113]
    record.sep.electron_energy_flux_3 = data_array.data[114]
    record.sep.electron_energy_flux_3_qual = data_array.data[115]
    record.sep.electron_energy_flux_4 = data_array.data[116]
    record.sep.electron_energy_flux_4_qual = data_array.data[117]
    record.sep.look_direction_1_msox = data_array.data[118]
    record.sep.look_direction_1_msoy = data_array.data[119]
    record.sep.look_direction_1_msoz = data_array.data[120]
    record.sep.look_direction_2_msox = data_array.data[121]
    record.sep.look_direction_2_msoy = data_array.data[122]
    record.sep.look_direction_2_msoz = data_array.data[123]
    record.sep.look_direction_3_msox = data_array.data[124]
    record.sep.look_direction_3_msoy = data_array.data[125]
    record.sep.look_direction_3_msoz = data_array.data[126]
    record.sep.look_direction_4_msox = data_array.data[127]
    record.sep.look_direction_4_msoy = data_array.data[128]
    record.sep.look_direction_4_msoz = data_array.data[129]
  endif 
  if instrument_array[6] eq 1 then begin        ;return all the NGIMS data
    record.ngims.he_density = data_array.data[144]
    record.ngims.he_density_qual = data_array.data[145]
    record.ngims.o_density = data_array.data[146]
    record.ngims.o_density_qual = data_array.data[147]
    record.ngims.co_density = data_array.data[148]
    record.ngims.co_density_qual = data_array.data[149]
    record.ngims.n2_density = data_array.data[150]
    record.ngims.n2_density_qual = data_array.data[151]
    record.ngims.no_density = data_array.data[152]
    record.ngims.no_density_qual = data_array.data[153]
    record.ngims.ar_density = data_array.data[154]
    record.ngims.ar_density_qual = data_array.data[155]
    record.ngims.co2_density = data_array.data[156]
    record.ngims.co2_density_qual = data_array.data[157]
    record.ngims.o2plus_density = data_array.data[158]
    record.ngims.o2plus_density_qual = data_array.data[159]
    record.ngims.co2plus_density = data_array.data[160]
    record.ngims.co2plus_density_qual = data_array.data[161]
    record.ngims.noplus_density = data_array.data[162]
    record.ngims.noplus_density_qual = data_array.data[163]
    record.ngims.oplus_density = data_array.data[164]
    record.ngims.oplus_density_qual = data_array.data[165]
    record.ngims.conplus_density = data_array.data[166]
    record.ngims.conplus_density_qual = data_array.data[167]
    record.ngims.cplus_density = data_array.data[168]
    record.ngims.cplus_density_qual = data_array.data[169]
    record.ngims.ohplus_density = data_array.data[170]
    record.ngims.ohplus_density_qual = data_array.data[171]
    record.ngims.nplus_density = data_array.data[172]
    record.ngims.nplus_density_qual = data_array.data[173]
  endif 
;  if instrument_array eq 'spacecraft' then begin
    record.orbit = data_array.orbit
    record.io_bound = data_array.io_bound
    record.spacecraft.geo_x = data_array.data[174]
    record.spacecraft.geo_y = data_array.data[175]
    record.spacecraft.geo_z = data_array.data[176]
    record.spacecraft.mso_x = data_array.data[177]
    record.spacecraft.mso_y = data_array.data[178]
    record.spacecraft.mso_z = data_array.data[179]
    record.spacecraft.sub_sc_longitude = data_array.data[180]
    record.spacecraft.sub_sc_latitude = data_array.data[181]
    record.spacecraft.sza = data_array.data[182]
    record.spacecraft.local_time = data_array.data[183]
    record.spacecraft.altitude = data_array.data[184]
    record.spacecraft.attitude_geo_x = data_array.data[185]
    record.spacecraft.attitude_geo_y = data_array.data[186]
    record.spacecraft.attitude_geo_z = data_array.data[187]
    record.spacecraft.attitude_mso_x = data_array.data[188]
    record.spacecraft.attitude_mso_y = data_array.data[189]
    record.spacecraft.attitude_mso_z = data_array.data[190]
    record.spacecraft.mars_season = data_array.data[197]
    record.spacecraft.mars_sun_distance = data_array.data[198]
    record.spacecraft.subsolar_point_GEO_longitude = data_array.data[199]
    record.spacecraft.subsolar_point_GEO_latitude = data_array.data[200]
    record.spacecraft.submars_point_solar_longitude = data_array.data[201]
    record.spacecraft.submars_point_solar_latitude = data_array.data[202]
    record.app.attitude_geo_x = data_array.data[191]
    record.app.attitude_geo_y = data_array.data[192]
    record.app.attitude_geo_z = data_array.data[193]
    record.app.attitude_mso_x = data_array.data[194]
    record.app.attitude_mso_y = data_array.data[195]
    record.app.attitude_mso_z = data_array.data[196]
;  endif


end