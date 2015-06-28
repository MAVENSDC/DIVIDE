;+
; Takes input array of insitu data and assigns the values to input structure
;
; :Params:
;    record : in, required, type=structure
;       the named structure for the sorted and output INSITU KP data
;    data_array: in, required, type=fltarr(ndims)
;       the KP data read from the ascii or binary files, includes all instrument data
;    instruments: in, required, type=struct
;       the instrument choice flags that determine which data will be returned from struct
;

;-
pro MVN_KP_INSITU_ASSIGN, record, data_array, instruments, colmap

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  record.time_string = data_array.time_string
  record.time        = time_double(record.time_string, tformat='YYYY-MM-DDThh:mm:ss')
  record.orbit       = data_array.orbit
  record.io_bound    = data_array.io_bound
  
  if instruments.lpw then begin            ;return all the LPW data   
;-km-rm
;    record.lpw.electron_density              = data_array.data[1]
;    record.lpw.electron_density_qual_min     = data_array.data[2]
;    record.lpw.electron_density_qual_max     = data_array.data[3]
;    record.lpw.electron_temperature          = data_array.data[4]
;    record.lpw.electron_temperature_qual_min = data_array.data[5]
;    record.lpw.electron_temperature_qual_max = data_array.data[6]
;    record.lpw.spacecraft_potential          = data_array.data[7]
;    record.lpw.spacecraft_potential_error    = data_array.data[8]
;    record.lpw.spacecraft_potential_qual     = data_array.data[9]
;    record.lpw.ewave_low                     = data_array.data[10]
;    record.lpw.ewave_low_qual                = data_array.data[11]
;    record.lpw.ewave_mid                     = data_array.data[12]
;    record.lpw.ewave_mid_qual                = data_array.data[13]
;    record.lpw.ewave_high                    = data_array.data[14]
;    record.lpw.ewave_high_qual               = data_array.data[15]  
;-km-/rm
;-km-add
    for i = 0,n_tags(record.lpw)-1 do begin
      record.lpw.(i) = data_array.data[colmap.lpw.(i)-1]
    endfor
;-km-/add
  endif
  if instruments.euv then begin             ;return all EUV data
;-km-rm
;    record.euv.irradiance_low            = data_array.data[16]
;    record.euv.irradiance_low_qual       = data_array.data[17]
;    record.euv.irradiance_mid            = data_array.data[18]
;    record.euv.irradiance_mid_qual       = data_array.data[19]
;    record.euv.irradiance_lyman          = data_array.data[20]
;    record.euv.irradiance_lyman_qual     = data_array.data[21]
;-km-/rm
;-km-add
    for i = 0,n_tags(record.euv)-1 do begin
      record.euv.(i) = data_array.data[colmap.lpw.(i)-1]
    endfor
;-km-/add
  endif
  if instruments.static then begin          ;return all teh Static data    
;-km-rm
;    record.static.static_qual_flag                            = data_array.data[52]
;    record.static.co2plus_density                             = data_array.data[53]
;    record.static.co2plus_density_qual                        = data_array.data[54]
;    record.static.oplus_density                               = data_array.data[55]
;    record.static.oplus_density_qual                          = data_array.data[56]
;    record.static.o2plus_density                              = data_array.data[57]
;    record.static.o2plus_density_qual                         = data_array.data[58]
;    record.static.co2plus_temperature                         = data_array.data[59]
;    record.static.co2plus_temperature_qual                    = data_array.data[60]
;    record.static.oplus_temperature                           = data_array.data[61]
;    record.static.oplus_temperature_qual                      = data_array.data[62]
;    record.static.o2plus_temperature                          = data_array.data[63]
;    record.static.o2plus_temperature_qual                     = data_array.data[64]
;    record.static.o2plus_flow_v_appx                          = data_array.data[65]
;    record.static.o2plus_flow_v_appx_qual                     = data_array.data[66]
;    record.static.o2plus_flow_v_appy                          = data_array.data[67]
;    record.static.o2plus_flow_v_appy_qual                     = data_array.data[68]
;    record.static.o2plus_flow_v_appz                          = data_array.data[69]
;    record.static.o2plus_flow_v_appz_qual                     = data_array.data[70]
;    record.static.o2plus_flow_v_msox                          = data_array.data[71]
;    record.static.o2plus_flow_v_msox_qual                     = data_array.data[72]
;    record.static.o2plus_flow_v_msoy                          = data_array.data[73]
;    record.static.o2plus_flow_v_msoy_qual                     = data_array.data[74]
;    record.static.o2plus_flow_v_msoz                          = data_array.data[75]
;    record.static.o2plus_flow_v_msoz_qual                     = data_array.data[76]
;    record.static.hplus_omni_flux                             = data_array.data[77]
;    record.static.hplus_char_energy                           = data_array.data[78]
;    record.static.hplus_char_energy_qual                      = data_array.data[79]
;    record.static.heplus_omni_flux                            = data_array.data[80]
;    record.static.heplus_char_energy                          = data_array.data[81]
;    record.static.heplus_char_energy_qual                     = data_array.data[82]
;    record.static.oplus_omni_flux                             = data_array.data[83]
;    record.static.oplus_char_energy                           = data_array.data[84]
;    record.static.oplus_char_energy_qual                      = data_array.data[85]
;    record.static.o2plus_omni_flux                            = data_array.data[86]
;    record.static.o2plus_char_energy                          = data_array.data[87]
;    record.static.o2plus_char_energy_qual                     = data_array.data[88]
;    record.static.hplus_char_dir_msox                         = data_array.data[89]
;    record.static.hplus_char_dir_msoy                         = data_array.data[90]
;    record.static.hplus_char_dir_msoz                         = data_array.data[91]
;    record.static.hplus_char_angular_width                    = data_array.data[92]
;    record.static.hplus_char_angular_width_qual               = data_array.data[93]
;    record.static.dominant_pickup_ion_char_dir_msox           = data_array.data[94]
;    record.static.dominant_pickup_ion_char_dir_msoy           = data_array.data[95]
;    record.static.dominant_pickup_ion_char_dir_msoz           = data_array.data[96]
;    record.static.dominant_pickup_ion_char_angular_width      = data_array.data[97]
;    record.static.dominant_pickup_ion_char_angular_width_qual = data_array.data[98]
;-km-/rm
;-km-add
    for i = 0,n_tags(record.static)-1 do begin
      record.static.(i) = data_array.data[colmap.static.(i)-1]
    endfor
;-km-/add    
  endif
  if instruments.swia then begin      ;return all the swia data
;-km-rm
;    record.swia.hplus_density                    = data_array.data[40]
;    record.swia.hplus_density_qual               = data_array.data[41]
;    record.swia.hplus_flow_v_msox                = data_array.data[42]
;    record.swia.hplus_flow_v_msox_qual           = data_array.data[43]
;    record.swia.hplus_flow_v_msoy                = data_array.data[44]
;    record.swia.hplus_flow_v_msoy_qual           = data_array.data[45]
;    record.swia.hplus_flow_v_msoz                = data_array.data[46]
;    record.swia.hplus_flow_v_msoz_qual           = data_array.data[47]
;    record.swia.hplus_temperature                = data_array.data[48]
;    record.swia.hplus_temperature_qual           = data_array.data[49]
;    record.swia.solarwind_dynamic_pressure       = data_array.data[50]
;    record.swia.solarwind_dynamic_pressure_qual  = data_array.data[51]
;-km-/rm
;-km-add
;-km-add
    for i = 0,n_tags(record.swia)-1 do begin
      record.swia.(i) = data_array.data[colmap.swia.(i)-1]
    endfor
;-km-/add    
  endif
  if instruments.swea then begin      ;return all the swea data
;-km-rm
;    record.swea.solarwind_e_density                   = data_array.data[22]
;    record.swea.solarwind_e_density_qual              = data_array.data[23]
;    record.swea.solarwind_e_temperature               = data_array.data[24]
;    record.swea.solarwind_e_temperature_qual          = data_array.data[25]
;    record.swea.electron_parallel_flux_low            = data_array.data[26]
;    record.swea.electron_parallel_flux_low_qual       = data_array.data[27]
;    record.swea.electron_parallel_flux_mid            = data_array.data[28]
;    record.swea.electron_parallel_flux_mid_qual       = data_array.data[29]
;    record.swea.electron_parallel_flux_high           = data_array.data[30]
;    record.swea.electron_parallel_flux_high_qual      = data_array.data[31]
;    record.swea.electron_antiparallel_flux_low        = data_array.data[32]
;    record.swea.electron_antiparallel_flux_low_qual   = data_array.data[33]
;    record.swea.electron_antiparallel_flux_mid        = data_array.data[34]
;    record.swea.electron_antiparallel_flux_mid_qual   = data_array.data[35]
;    record.swea.electron_antiparallel_flux_high       = data_array.data[36]
;    record.swea.electron_antiparallel_flux_high_qual  = data_array.data[37]
;    record.swea.electron_spectrum_shape               = data_array.data[38]
;    record.swea.electron_spectrum_shape_qual          = data_array.data[39]
;-km-/rm
;-km-add
    for i = 0,n_tags(record.swea)-1 do begin
      record.swea.(i) = data_array.data[colmap.swea.(i)-1]
    endfor
;-km-/add    
  endif
  if instruments.mag then begin      ;retunr all the mag data
;-km-rm
;    record.mag.mso_x       = data_array.data[127]
;    record.mag.mso_x_qual  = data_array.data[128]
;    record.mag.mso_y       = data_array.data[129]
;    record.mag.mso_y_qual  = data_array.data[130]
;    record.mag.mso_z       = data_array.data[131]
;    record.mag.mso_z_qual  = data_array.data[132]
;    record.mag.geo_x       = data_array.data[133]
;    record.mag.geo_x_qual  = data_array.data[134]
;    record.mag.geo_y       = data_array.data[135]
;    record.mag.geo_y_qual  = data_array.data[136]
;    record.mag.geo_z       = data_array.data[137]
;    record.mag.geo_z_qual  = data_array.data[138]
;    record.mag.rms         = data_array.data[139]
;    record.mag.rms_qual    = data_array.data[140]
;-km-/rm
;-km-add
    for i = 0,n_tags(record.mag)-1 do begin
      record.mag.(i) = data_array.data[colmap.mag.(i)-1]
    endfor
;-km-/add    
  endif
  if instruments.sep then begin    ;return atll the SEP data
;-km-rm
;    ion_energy_flux_1_front           = data_array.data[99]
;    ion_energy_flux_1_front_qual      = data_array.data[100]
;    ion_energy_flux_1_back            = data_array.data[101]
;    ion_energy_flux_1_back_qual       = data_array.data[102]
;    ion_energy_flux_2_front           = data_array.data[103]
;    ion_energy_flux_2_front_qual      = data_array.data[104]
;    ion_energy_flux_2_back            = data_array.data[105]
;    ion_energy_flux_2_back_qual       = data_array.data[106]
;    electron_energy_flux_1_front      = data_array.data[107]
;    electron_energy_flux_1_front_qual = data_array.data[108]
;    electron_energy_flux_1_back       = data_array.data[109]
;    electron_energy_flux_1_back_qual  = data_array.data[110]
;    electron_energy_flux_2_front      = data_array.data[111]
;    electron_energy_flux_2_front_qual = data_array.data[112]
;    electron_energy_flux_2_back       = data_array.data[113]
;    electron_energy_flux_2_back_qual  = data_array.data[114]
;    look_direction_1_front_msox       = data_array.data[115]
;    look_direction_1_front_msoy       = data_array.data[116]
;    look_direction_1_front_msoz       = data_array.data[117]
;    look_direction_1_back_msox        = data_array.data[118]
;    look_direction_1_back_msoy        = data_array.data[119]
;    look_direction_1_back_msoz        = data_array.data[120]
;    look_direction_2_front_msox       = data_array.data[121]
;    look_direction_2_front_msoy       = data_array.data[122]
;    look_direction_2_front_msoz       = data_array.data[123]
;    look_direction_2_back_msox        = data_array.data[124]
;    look_direction_2_back_msoy        = data_array.data[125]
;    look_direction_2_back_msoz        = data_array.data[126]
;-km-/rm
;-km-add
    for i = 0,n_tags(record.sep)-1 do begin
      record.sep.(i) = data_array.data[colmap.sep.(i)-1]
    endfor
;-km-/add    
    
  endif
  if instruments.ngims then begin        ;return all the NGIMS data
;-km-rm
;    record.ngims.he_density            = data_array.data[141]
;    record.ngims.he_density_qual       = data_array.data[142]
;    record.ngims.o_density             = data_array.data[143]
;    record.ngims.o_density_qual        = data_array.data[144]
;    record.ngims.co_density            = data_array.data[145]
;    record.ngims.co_density_qual       = data_array.data[146]
;    record.ngims.n2_density            = data_array.data[147]
;    record.ngims.n2_density_qual       = data_array.data[148]
;    record.ngims.no_density            = data_array.data[149]
;    record.ngims.no_density_qual       = data_array.data[150]
;    record.ngims.ar_density            = data_array.data[151]
;    record.ngims.ar_density_qual       = data_array.data[152]
;    record.ngims.co2_density           = data_array.data[153]
;    record.ngims.co2_density_qual      = data_array.data[154]
;    record.ngims.o2plus_density        = data_array.data[155]
;    record.ngims.o2plus_density_qual   = data_array.data[156]
;    record.ngims.co2plus_density       = data_array.data[157]
;    record.ngims.co2plus_density_qual  = data_array.data[158]
;    record.ngims.noplus_density        = data_array.data[159]
;    record.ngims.noplus_density_qual   = data_array.data[160]
;    record.ngims.oplus_density         = data_array.data[161]
;    record.ngims.oplus_density_qual    = data_array.data[162]
;    record.ngims.conplus_density       = data_array.data[163]
;    record.ngims.conplus_density_qual  = data_array.data[164]
;    record.ngims.cplus_density         = data_array.data[165]
;    record.ngims.cplus_density_qual    = data_array.data[166]
;    record.ngims.ohplus_density        = data_array.data[167]
;    record.ngims.ohplus_density_qual   = data_array.data[168]
;    record.ngims.nplus_density         = data_array.data[169]
;    record.ngims.nplus_density_qual    = data_array.data[170]
;-km-/rm
;-km-add
    ;
    ;  This is hack; we should use format string to determine strings
    ;  For now, we know that ngims*_qual are strings
    ;
    names = tag_names(record.ngims)
    for i = 0,n_tags(record.ngims)-1 do begin
      record.ngims.(i) = strmatch( names[i], '*qual*', /fold_case ) $
                       ? string( fix( data_array.data[colmap.ngims.(i)-1], $
                                      type=1 ) ) $
                       : data_array.data[colmap.ngims.(i)-1]
    endfor
;-km-/add    
  endif
  
;-km-rm
;  record.spacecraft.geo_x                           = data_array.data[171]
;  record.spacecraft.geo_y                           = data_array.data[172]
;  record.spacecraft.geo_z                           = data_array.data[173]
;  record.spacecraft.mso_x                           = data_array.data[174]
;  record.spacecraft.mso_y                           = data_array.data[175]
;  record.spacecraft.mso_z                           = data_array.data[176]
;  record.spacecraft.sub_sc_longitude                = data_array.data[177]
;  record.spacecraft.sub_sc_latitude                 = data_array.data[178]
;  record.spacecraft.sza                             = data_array.data[179]
;  record.spacecraft.local_time                      = data_array.data[180]
;  record.spacecraft.altitude                        = data_array.data[181]
;  record.spacecraft.attitude_geo_x                  = data_array.data[182]
;  record.spacecraft.attitude_geo_y                  = data_array.data[183]
;  record.spacecraft.attitude_geo_z                  = data_array.data[184]
;  record.spacecraft.attitude_mso_x                  = data_array.data[185]
;  record.spacecraft.attitude_mso_y                  = data_array.data[186]
;  record.spacecraft.attitude_mso_z                  = data_array.data[187]
;  
;  record.spacecraft.mars_season                     = data_array.data[196]
;  record.spacecraft.mars_sun_distance               = data_array.data[197]
;  record.spacecraft.subsolar_point_GEO_longitude    = data_array.data[198]
;  record.spacecraft.subsolar_point_GEO_latitude     = data_array.data[199]
;  record.spacecraft.submars_point_solar_longitude   = data_array.data[200]
;  record.spacecraft.submars_point_solar_latitude    = data_array.data[201]
;  record.spacecraft.t11                             = data_array.data[202]
;  record.spacecraft.t21                             = data_array.data[203]
;  record.spacecraft.t31                             = data_array.data[204]
;  record.spacecraft.t12                             = data_array.data[205]
;  record.spacecraft.t22                             = data_array.data[206]
;  record.spacecraft.t32                             = data_array.data[207]
;  record.spacecraft.t13                             = data_array.data[208]
;  record.spacecraft.t23                             = data_array.data[209]
;  record.spacecraft.t33                             = data_array.data[210]
;-km-/rm
;-km-add
    for i = 0,n_tags(record.static)-1 do begin
      record.static.(i) = data_array.data[colmap.static.(i)-1]
    endfor
;-km-/add    
;-km-rm
;  record.app.attitude_geo_x                         = data_array.data[188]
;  record.app.attitude_geo_y                         = data_array.data[189]
;  record.app.attitude_geo_z                         = data_array.data[190]
;  record.app.attitude_mso_x                         = data_array.data[191]
;  record.app.attitude_mso_y                         = data_array.data[192]
;  record.app.attitude_mso_z                         = data_array.data[193]
;-km-/rm
;-km-add
    for i = 0,n_tags(record.static)-1 do begin
      record.static.(i) = data_array.data[colmap.static.(i)-1]
    endfor
;-km-/add    
  
end
