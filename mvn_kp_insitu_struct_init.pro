;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    insitu_record : in, required, type=structure
;       The single data record structure to hold INSITU KP data
;    instruments: in, optional, type=struct
;       a struct that signals which types of data have been requested, so that only those fields are included in the structures.
;       


;-
pro MVN_KP_INSITU_STRUCT_INIT, insitu_record, instruments=instruments
  

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
  ;; Default to filling all instruments if not specified
  if not keyword_set(instruments) then begin
    instruments = CREATE_STRUCT('lpw',      1, 'static',   1, 'swia',     1, $
                                'swea',     1, 'mag',      1, 'sep',      1, $
                                'ngims',    1, 'periapse', 1, 'c_e_disk', 1, $
                                'c_e_limb', 1, 'c_e_high', 1, 'c_l_disk', 1, $
                                'c_l_limb', 1, 'c_l_high', 1, 'apoapse' , 1, 'stellarocc', 1)
  endif
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ------------------------- Create In situ structure --------------------------------- ;;
  
  ;DEFINE THE ALWAYS INCLUDED STRUCTURES OF SPACECRAFT AND APP PARAMETERS 
  s1 = {spacecraft,                                   $
        geo_x                         :!VALUES.D_NAN, $
        geo_y                         :!VALUES.D_NAN, $
        geo_z                         :!VALUES.D_NAN, $
        mso_x                         :!VALUES.D_NAN, $
        mso_y                         :!VALUES.D_NAN, $
        mso_z                         :!VALUES.D_NAN, $
        sub_sc_longitude              :!VALUES.D_NAN, $
        sub_sc_latitude               :!VALUES.D_NAN, $
        sza                           :!VALUES.D_NAN, $
        local_time                    :!VALUES.D_NAN, $
        altitude                      :!VALUES.D_NAN, $
        attitude_geo_x                :!VALUES.D_NAN, $
        attitude_geo_y                :!VALUES.D_NAN, $
        attitude_geo_z                :!VALUES.D_NAN, $
        attitude_mso_x                :!VALUES.D_NAN, $
        attitude_mso_y                :!VALUES.D_NAN, $
        attitude_mso_z                :!VALUES.D_NAN, $
        mars_season                   :!VALUES.D_NAN, $
        mars_sun_distance             :!VALUES.D_NAN, $
        subsolar_point_GEO_longitude  :!VALUES.D_NAN, $
        subsolar_point_GEO_latitude   :!VALUES.D_NAN, $
        submars_point_solar_longitude :!VALUES.D_NAN, $
        submars_point_solar_latitude  :!VALUES.D_NAN, $
        t11                           :!VALUES.D_NAN, $
        t12                           :!VALUES.D_NAN, $
        t13                           :!VALUES.D_NAN, $
        t21                           :!VALUES.D_NAN, $
        t22                           :!VALUES.D_NAN, $
        t23                           :!VALUES.D_NAN, $
        t31                           :!VALUES.D_NAN, $
        t32                           :!VALUES.D_NAN, $
        t33                           :!VALUES.D_NAN}
  
  S2 = {app,                           $
        attitude_geo_x :!VALUES.D_NAN, $
        attitude_geo_y :!VALUES.D_NAN, $
        attitude_geo_z :!VALUES.D_NAN, $
        attitude_mso_x :!VALUES.D_NAN, $
        attitude_mso_y :!VALUES.D_NAN, $
        attitude_mso_z :!VALUES.D_NAN}                                
                                   
  record_temp1 = create_struct(['spacecraft','app'],s1,s2)

  ;CREATE THE BASE ARRAY FOR THE INSITU DATA, BASED ON WHAT DATA WILL BE RETURNED
  if instruments.lpw then begin    ;INCLUDE LPW DATA STRUCTURE
    s3 = {lpw,                                          $
          electron_density              :!VALUES.D_NAN, $
          electron_density_qual_min     :!VALUES.D_NAN, $   
          electron_density_qual_max     :!VALUES.D_NAN, $    
          electron_temperature          :!VALUES.D_NAN, $
          electron_temperature_qual_min :!VALUES.D_NAN, $   
          electron_temperature_qual_max :!VALUES.D_NAN, $   
          spacecraft_potential          :!VALUES.D_NAN, $
          spacecraft_potential_error    :!VALUES.D_NAN, $   
          spacecraft_potential_qual     :!VALUES.D_NAN, $   
          ewave_low                     :!VALUES.D_NAN, $
          ewave_low_qual                :!VALUES.D_NAN, $
          ewave_mid                     :!VALUES.D_NAN, $
          ewave_mid_qual                :!VALUES.D_NAN, $
          ewave_high                    :!VALUES.D_NAN, $
          ewave_high_qual               :!VALUES.D_NAN, $
          euv_irradiance_low            :!VALUES.D_NAN, $
          euv_irradiance_low_qual       :!VALUES.D_NAN, $
          euv_irradiance_mid            :!VALUES.D_NAN, $
          euv_irradiance_mid_qual       :!VALUES.D_NAN, $
          euv_irradiance_lyman          :!VALUES.D_NAN, $
          euv_irradiance_lyman_qual     :!VALUES.D_NAN}
          
    record_temp2 = create_struct(['lpw'],s3,record_temp1)
  endif else begin
    record_temp2 = create_struct(record_temp1)
  endelse
  if instruments.static then begin  ;INCLUDE STATIC DATA STRUCTURE
    s4 = {static,                                                     $
          static_qual_flag                            :!VALUES.D_NAN, $
          co2plus_density                             :!VALUES.D_NAN, $
          co2plus_density_qual                        :!VALUES.D_NAN, $
          oplus_density                               :!VALUES.D_NAN, $
          oplus_density_qual                          :!VALUES.D_NAN, $
          o2plus_density                              :!VALUES.D_NAN, $
          o2plus_density_qual                         :!VALUES.D_NAN, $
          co2plus_temperature                         :!VALUES.D_NAN, $
          co2plus_temperature_qual                    :!VALUES.D_NAN, $
          oplus_temperature                           :!VALUES.D_NAN, $
          oplus_temperature_qual                      :!VALUES.D_NAN, $
          o2plus_temperature                          :!VALUES.D_NAN, $
          o2plus_temperature_qual                     :!VALUES.D_NAN, $
          o2plus_flow_v_appx                          :!VALUES.D_NAN, $  
          o2plus_flow_v_appx_qual                     :!VALUES.D_NAN, $  
          o2plus_flow_v_appy                          :!VALUES.D_NAN, $  
          o2plus_flow_v_appy_qual                     :!VALUES.D_NAN, $  
          o2plus_flow_v_appz                          :!VALUES.D_NAN, $
          o2plus_flow_v_appz_qual                     :!VALUES.D_NAN, $
          o2plus_flow_v_msox                          :!VALUES.D_NAN, $
          o2plus_flow_v_msox_qual                     :!VALUES.D_NAN, $
          o2plus_flow_v_msoy                          :!VALUES.D_NAN, $
          o2plus_flow_v_msoy_qual                     :!VALUES.D_NAN, $
          o2plus_flow_v_msoz                          :!VALUES.D_NAN, $
          o2plus_flow_v_msoz_qual                     :!VALUES.D_NAN, $
          hplus_omni_flux                             :!VALUES.D_NAN, $
          hplus_char_energy                           :!VALUES.D_NAN, $
          hplus_char_energy_qual                      :!VALUES.D_NAN, $
          heplus_omni_flux                            :!VALUES.D_NAN, $
          heplus_char_energy                          :!VALUES.D_NAN, $
          heplus_char_energy_qual                     :!VALUES.D_NAN, $
          oplus_omni_flux                             :!VALUES.D_NAN, $
          oplus_char_energy                           :!VALUES.D_NAN, $
          oplus_char_energy_qual                      :!VALUES.D_NAN, $
          o2plus_omni_flux                            :!VALUES.D_NAN, $
          o2plus_char_energy                          :!VALUES.D_NAN, $
          o2plus_char_energy_qual                     :!VALUES.D_NAN, $         
          hplus_char_dir_msox                         :!VALUES.D_NAN, $
          hplus_char_dir_msoy                         :!VALUES.D_NAN, $
          hplus_char_dir_msoz                         :!VALUES.D_NAN, $
          hplus_char_angular_width                    :!VALUES.D_NAN, $
          hplus_char_angular_width_qual               :!VALUES.D_NAN, $
          dominant_pickup_ion_char_dir_msox           :!VALUES.D_NAN, $
          dominant_pickup_ion_char_dir_msoy           :!VALUES.D_NAN, $
          dominant_pickup_ion_char_dir_msoz           :!VALUES.D_NAN, $
          dominant_pickup_ion_char_angular_width      :!VALUES.D_NAN, $
          dominant_pickup_ion_char_angular_width_qual :!VALUES.D_NAN}    
          
    record_temp3 = create_struct(['static'],s4,record_temp2)
  endif else begin
    record_temp3 = create_struct(record_temp2)
  endelse
  if instruments.swia then begin   ;INCLUDE SWIA DATA STRUCTURE
    s5 = {swia,                                           $
          hplus_density                   :!VALUES.D_NAN, $
          hplus_density_qual              :!VALUES.D_NAN, $
          hplus_flow_v_msox               :!VALUES.D_NAN, $
          hplus_flow_v_msox_qual          :!VALUES.D_NAN, $
          hplus_flow_v_msoy               :!VALUES.D_NAN, $
          hplus_flow_v_msoy_qual          :!VALUES.D_NAN, $
          hplus_flow_v_msoz               :!VALUES.D_NAN, $
          hplus_flow_v_msoz_qual          :!VALUES.D_NAN, $
          hplus_temperature               :!VALUES.D_NAN, $
          hplus_temperature_qual          :!VALUES.D_NAN, $
          solarwind_dynamic_pressure      :!VALUES.D_NAN, $
          solarwind_dynamic_pressure_qual :!VALUES.D_NAN}
          
    record_temp4 = create_struct(['swia'],s5,record_temp3)
  endif else begin
    record_temp4 = create_struct(record_temp3)
  endelse
  if instruments.swea eq 1 then begin   ;INCLUDE SWEA DATA STRUCTURE
    s6 = {swea,                                                $
          solarwind_e_density                  :!VALUES.D_NAN, $
          solarwind_e_density_qual             :!VALUES.D_NAN, $
          solarwind_e_temperature              :!VALUES.D_NAN, $
          solarwind_e_temperature_qual         :!VALUES.D_NAN, $
          electron_parallel_flux_low           :!VALUES.D_NAN, $
          electron_parallel_flux_low_qual      :!VALUES.D_NAN, $
          electron_parallel_flux_mid           :!VALUES.D_NAN, $
          electron_parallel_flux_mid_qual      :!VALUES.D_NAN, $
          electron_parallel_flux_high          :!VALUES.D_NAN, $
          electron_parallel_flux_high_qual     :!VALUES.D_NAN, $
          electron_antiparallel_flux_low       :!VALUES.D_NAN, $
          electron_antiparallel_flux_low_qual  :!VALUES.D_NAN, $
          electron_antiparallel_flux_mid       :!VALUES.D_NAN, $
          electron_antiparallel_flux_mid_qual  :!VALUES.D_NAN, $
          electron_antiparallel_flux_high      :!VALUES.D_NAN, $
          electron_antiparallel_flux_high_qual :!VALUES.D_NAN, $
          electron_spectrum_shape              :!VALUES.D_NAN, $
          electron_spectrum_shape_qual         :!VALUES.D_NAN}
          
    record_temp5 = create_struct(['swea'], s6, record_temp4)
  endif else begin
    record_temp5 = create_struct(record_temp4)
  endelse
  if instruments.mag eq 1 then begin   ;INCLUDE MAG DATA STRUCTURE
    s7 = {mag,                       $
          mso_x      :!VALUES.D_NAN, $
          mso_x_qual :!VALUES.D_NAN, $
          mso_y      :!VALUES.D_NAN, $
          mso_y_qual :!VALUES.D_NAN, $
          mso_z      :!VALUES.D_NAN, $
          mso_z_qual :!VALUES.D_NAN, $
          geo_x      :!VALUES.D_NAN, $
          geo_x_qual :!VALUES.D_NAN, $
          geo_y      :!VALUES.D_NAN, $
          geo_y_qual :!VALUES.D_NAN, $
          geo_z      :!VALUES.D_NAN, $
          geo_z_qual :!VALUES.D_NAN, $
          rms        :!VALUES.D_NAN, $
          rms_qual   :!VALUES.D_NAN}
          
    record_temp6 = create_struct(['mag'], s7, record_temp5)
  endif else begin
    record_temp6 = create_struct(record_temp5)
  endelse
  if instruments.sep eq 1 then begin   ;INCLUDE SEP DATA STRUCTURE
    s8 = {sep,                                        $
          ion_energy_flux_1_front           :!VALUES.D_NAN, $
          ion_energy_flux_1_front_qual      :!VALUES.D_NAN, $
          ion_energy_flux_1_back            :!VALUES.D_NAN, $
          ion_energy_flux_1_back_qual       :!VALUES.D_NAN, $
          ion_energy_flux_2_front           :!VALUES.D_NAN, $
          ion_energy_flux_2_front_qual      :!VALUES.D_NAN, $
          ion_energy_flux_2_back            :!VALUES.D_NAN, $
          ion_energy_flux_2_back_qual       :!VALUES.D_NAN, $ 
          electron_energy_flux_1_front      :!VALUES.D_NAN, $
          electron_energy_flux_1_front_qual :!VALUES.D_NAN, $
          electron_energy_flux_1_back       :!VALUES.D_NAN, $ 
          electron_energy_flux_1_back_qual  :!VALUES.D_NAN, $
          electron_energy_flux_2_front      :!VALUES.D_NAN, $ 
          electron_energy_flux_2_front_qual :!VALUES.D_NAN, $ 
          electron_energy_flux_2_back       :!VALUES.D_NAN, $ 
          electron_energy_flux_2_back_qual  :!VALUES.D_NAN, $
          look_direction_1_front_msox       :!VALUES.D_NAN, $
          look_direction_1_front_msoy       :!VALUES.D_NAN, $    
          look_direction_1_front_msoz       :!VALUES.D_NAN, $
          look_direction_1_back_msox        :!VALUES.D_NAN, $
          look_direction_1_back_msoy        :!VALUES.D_NAN, $ 
          look_direction_1_back_msoz        :!VALUES.D_NAN, $
          look_direction_2_front_msox       :!VALUES.D_NAN, $
          look_direction_2_front_msoy       :!VALUES.D_NAN, $ 
          look_direction_2_front_msoz       :!VALUES.D_NAN, $
          look_direction_2_back_msox        :!VALUES.D_NAN, $
          look_direction_2_back_msoy        :!VALUES.D_NAN, $ 
          look_direction_2_back_msoz        :!VALUES.D_NAN}
          
    record_temp7 = create_struct(['sep'], s8, record_temp6)
  endif else begin
    record_temp7 = create_struct(record_temp6)
  endelse
  if instruments.ngims eq 1 then begin   ;INCLUDE NGIMS DATA STRUCTURE
    s9 = {ngims,                                $ 
          he_density            :!VALUES.D_NAN, $ 
          he_density_qual       :!VALUES.D_NAN, $ 
          o_density             :!VALUES.D_NAN, $ 
          o_density_qual        :!VALUES.D_NAN, $ 
          co_density            :!VALUES.D_NAN, $ 
          co_density_qual       :!VALUES.D_NAN, $
          n2_density            :!VALUES.D_NAN, $ 
          n2_density_qual       :!VALUES.D_NAN, $ 
          no_density            :!VALUES.D_NAN, $ 
          no_density_qual       :!VALUES.D_NAN, $ 
          ar_density            :!VALUES.D_NAN, $ 
          ar_density_qual       :!VALUES.D_NAN, $
          co2_density           :!VALUES.D_NAN, $ 
          co2_density_qual      :!VALUES.D_NAN, $ 
          o2plus_density        :!VALUES.D_NAN, $ 
          o2plus_density_qual   :!VALUES.D_NAN, $ 
          co2plus_density       :!VALUES.D_NAN, $
          co2plus_density_qual  :!VALUES.D_NAN, $ 
          noplus_density        :!VALUES.D_NAN, $ 
          noplus_density_qual   :!VALUES.D_NAN, $ 
          oplus_density         :!VALUES.D_NAN, $
          oplus_density_qual    :!VALUES.D_NAN, $ 
          conplus_density       :!VALUES.D_NAN, $ 
          conplus_density_qual  :!VALUES.D_NAN, $ 
          cplus_density         :!VALUES.D_NAN, $ 
          cplus_density_qual    :!VALUES.D_NAN, $
          ohplus_density        :!VALUES.D_NAN, $ 
          ohplus_density_qual   :!VALUES.D_NAN, $ 
          nplus_density         :!VALUES.D_NAN, $ 
          nplus_density_qual    :!VALUES.D_NAN}
          
          
    record_temp8 = create_struct( ['ngims'], s9, record_temp7)
  endif else begin
    record_temp8 = create_struct(record_temp7)
  endelse
  
  insitu_record = 0
  insitu_record = create_struct(['time_string','time','orbit','io_bound'],'',0l,-1L,'',record_temp8)

end