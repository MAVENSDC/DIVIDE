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
        geo_x                         :!VALUES.F_NAN, $
        geo_y                         :!VALUES.F_NAN, $
        geo_z                         :!VALUES.F_NAN, $
        mso_x                         :!VALUES.F_NAN, $
        mso_y                         :!VALUES.F_NAN, $
        mso_z                         :!VALUES.F_NAN, $
        sub_sc_longitude              :!VALUES.F_NAN, $
        sub_sc_latitude               :!VALUES.F_NAN, $
        sza                           :!VALUES.F_NAN, $
        local_time                    :!VALUES.F_NAN, $
        altitude                      :!VALUES.F_NAN, $
        attitude_geo_x                :!VALUES.F_NAN, $
        attitude_geo_y                :!VALUES.F_NAN, $
        attitude_geo_z                :!VALUES.F_NAN, $
        attitude_mso_x                :!VALUES.F_NAN, $
        attitude_mso_y                :!VALUES.F_NAN, $
        attitude_mso_z                :!VALUES.F_NAN, $
        mars_season                   :!VALUES.F_NAN, $
        mars_sun_distance             :!VALUES.F_NAN, $
        subsolar_point_GEO_longitude  :!VALUES.F_NAN, $
        subsolar_point_GEO_latitude   :!VALUES.F_NAN, $
        submars_point_solar_longitude :!VALUES.F_NAN, $
        submars_point_solar_latitude  :!VALUES.F_NAN, $
        t11                           :!VALUES.F_NAN, $
        t12                           :!VALUES.F_NAN, $
        t13                           :!VALUES.F_NAN, $
        t21                           :!VALUES.F_NAN, $
        t22                           :!VALUES.F_NAN, $
        t23                           :!VALUES.F_NAN, $
        t31                           :!VALUES.F_NAN, $
        t32                           :!VALUES.F_NAN, $
        t33                           :!VALUES.F_NAN}
  
  S2 = {app,                           $
        attitude_geo_x :!VALUES.F_NAN, $
        attitude_geo_y :!VALUES.F_NAN, $
        attitude_geo_z :!VALUES.F_NAN, $
        attitude_mso_x :!VALUES.F_NAN, $
        attitude_mso_y :!VALUES.F_NAN, $
        attitude_mso_z :!VALUES.F_NAN}                                
                                   
  record_temp1 = create_struct(['spacecraft','app'],s1,s2)

  ;CREATE THE BASE ARRAY FOR THE INSITU DATA, BASED ON WHAT DATA WILL BE RETURNED
  if instruments.lpw then begin    ;INCLUDE LPW DATA STRUCTURE
    s3 = {lpw,                                      $
          electron_density          :!VALUES.F_NAN, $
          electron_density_qual     :!VALUES.F_NAN, $
          electron_temperature      :!VALUES.F_NAN, $
          electron_temperature_qual :!VALUES.F_NAN, $
          spacecraft_potential      :!VALUES.F_NAN, $
          spacecraft_potential_qual :!VALUES.F_NAN, $
          ewave_low                 :!VALUES.F_NAN, $
          ewave_low_qual            :!VALUES.F_NAN, $
          ewave_mid                 :!VALUES.F_NAN, $
          ewave_mid_qual            :!VALUES.F_NAN, $
          ewave_high                :!VALUES.F_NAN, $
          ewave_high_qual           :!VALUES.F_NAN, $
          euv_irradiance_low        :!VALUES.F_NAN, $
          euv_irradiance_low_qual   :!VALUES.F_NAN, $
          euv_irradiance_mid        :!VALUES.F_NAN, $
          euv_irradiance_mid_qual   :!VALUES.F_NAN, $
          euv_irradiance_high       :!VALUES.F_NAN, $
          euv_irradiance_high_qual  :!VALUES.F_NAN}
          
    record_temp2 = create_struct(['lpw'],s3,record_temp1)
  endif else begin
    record_temp2 = create_struct(record_temp1)
  endelse
  if instruments.static then begin  ;INCLUDE STATIC DATA STRUCTURE
    s4 = {static,                                            $
          hplus_density                      :!VALUES.F_NAN, $
          hplus_density_qual                 :!VALUES.F_NAN, $
          oplus_density                      :!VALUES.F_NAN, $
          oplus_density_qual                 :!VALUES.F_NAN, $
          o2plus_density                     :!VALUES.F_NAN, $
          o2plus_density_qual                :!VALUES.F_NAN, $
          hplus_temperature                  :!VALUES.F_NAN, $
          hplus_temperature_qual             :!VALUES.F_NAN, $
          oplus_temperature                  :!VALUES.F_NAN, $
          oplus_temperature_qual             :!VALUES.F_NAN, $
          o2plus_temperature                 :!VALUES.F_NAN, $
          o2plus_temperature_qual            :!VALUES.F_NAN, $
          hplus_flow_v_msox                  :!VALUES.F_NAN, $
          hplus_flow_v_msox_qual             :!VALUES.F_NAN, $
          hplus_flow_v_msoy                  :!VALUES.F_NAN, $
          hplus_flow_v_msoy_qual             :!VALUES.F_NAN, $
          hplus_flow_v_msoz                  :!VALUES.F_NAN, $
          hplus_flow_v_msoz_qual             :!VALUES.F_NAN, $
          oplus_flow_v_msox                  :!VALUES.F_NAN, $
          oplus_flow_v_msox_qual             :!VALUES.F_NAN, $
          oplus_flow_v_msoy                  :!VALUES.F_NAN, $
          oplus_flow_v_msoy_qual             :!VALUES.F_NAN, $
          oplus_flow_v_msoz                  :!VALUES.F_NAN, $
          oplus_flow_v_msoz_qual             :!VALUES.F_NAN, $
          o2plus_flow_v_msox                 :!VALUES.F_NAN, $
          o2plus_flow_v_msox_qual            :!VALUES.F_NAN, $
          o2plus_flow_v_msoy                 :!VALUES.F_NAN, $
          o2plus_flow_v_msoy_qual            :!VALUES.F_NAN, $
          o2plus_flow_v_msoz                 :!VALUES.F_NAN, $
          o2plus_flow_v_msoz_qual            :!VALUES.F_NAN, $
          hhe_omni_flux                      :!VALUES.F_NAN, $
          hhe_omni_flux_qual                 :!VALUES.F_NAN, $
          hhe_char_energy                    :!VALUES.F_NAN, $
          hhe_char_energy_qual               :!VALUES.F_NAN, $
          hhe_char_dir_msox                  :!VALUES.F_NAN, $
          hhe_char_dir_msox_qual             :!VALUES.F_NAN, $
          hhe_char_dir_msoy                  :!VALUES.F_NAN, $
          hhe_char_dir_msoy_qual             :!VALUES.F_NAN, $
          hhe_char_dir_msoz                  :!VALUES.F_NAN, $
          hhe_char_dir_msoz_qual             :!VALUES.F_NAN, $
          hhe_char_angular_width             :!VALUES.F_NAN, $
          hhe_char_angular_width_qual        :!VALUES.F_NAN, $
          pickup_ion_omni_flux               :!VALUES.F_NAN, $
          pickup_ion_omni_flux_qual          :!VALUES.F_NAN, $
          pickup_ion_char_energy             :!VALUES.F_NAN, $
          pickup_ion_char_energy_qual        :!VALUES.F_NAN, $
          pickup_ion_char_dir_msox           :!VALUES.F_NAN, $
          pickup_ion_char_dir_msox_qual      :!VALUES.F_NAN, $
          pickup_ion_char_dir_msoy           :!VALUES.F_NAN, $
          pickup_ion_char_dir_msoy_qual      :!VALUES.F_NAN, $
          pickup_ion_char_dir_msoz           :!VALUES.F_NAN, $
          pickup_ion_char_dir_msoz_qual      :!VALUES.F_NAN, $
          pickup_ion_char_angular_width      :!VALUES.F_NAN, $
          pickup_ion_char_angular_width_qual :!VALUES.F_NAN}
          
    record_temp3 = create_struct(['static'],s4,record_temp2)
  endif else begin
    record_temp3 = create_struct(record_temp2)
  endelse
  if instruments.swia then begin   ;INCLUDE SWIA DATA STRUCTURE
    s5 = {swia,                                           $
          hplus_density                   :!VALUES.F_NAN, $
          hplus_density_qual              :!VALUES.F_NAN, $
          hplus_flow_v_msox               :!VALUES.F_NAN, $
          hplus_flow_v_msox_qual          :!VALUES.F_NAN, $
          hplus_flow_v_msoy               :!VALUES.F_NAN, $
          hplus_flow_v_msoy_qual          :!VALUES.F_NAN, $
          hplus_flow_v_msoz               :!VALUES.F_NAN, $
          hplus_flow_v_msoz_qual          :!VALUES.F_NAN, $
          hplus_temperature               :!VALUES.F_NAN, $
          hplus_temperature_qual          :!VALUES.F_NAN, $
          solarwind_dynamic_pressure      :!VALUES.F_NAN, $
          solarwind_dynamic_pressure_qual :!VALUES.F_NAN}
          
    record_temp4 = create_struct(['swia'],s5,record_temp3)
  endif else begin
    record_temp4 = create_struct(record_temp3)
  endelse
  if instruments.swea eq 1 then begin   ;INCLUDE SWEA DATA STRUCTURE
    s6 = {swea,                                                $
          solarwind_e_density                  :!VALUES.F_NAN, $
          solarwind_e_density_qual             :!VALUES.F_NAN, $
          solarwind_e_temperature              :!VALUES.F_NAN, $
          solarwind_e_temperature_qual         :!VALUES.F_NAN, $
          electron_parallel_flux_low           :!VALUES.F_NAN, $
          electron_parallel_flux_low_qual      :!VALUES.F_NAN, $
          electron_parallel_flux_mid           :!VALUES.F_NAN, $
          electron_parallel_flux_mid_qual      :!VALUES.F_NAN, $
          electron_parallel_flux_high          :!VALUES.F_NAN, $
          electron_parallel_flux_high_qual     :!VALUES.F_NAN, $
          electron_antiparallel_flux_low       :!VALUES.F_NAN, $
          electron_antiparallel_flux_low_qual  :!VALUES.F_NAN, $
          electron_antiparallel_flux_mid       :!VALUES.F_NAN, $
          electron_antiparallel_flux_mid_qual  :!VALUES.F_NAN, $
          electron_antiparallel_flux_high      :!VALUES.F_NAN, $
          electron_antiparallel_flux_high_qual :!VALUES.F_NAN, $
          electron_spectrum_shape              :!VALUES.F_NAN, $
          electron_spectrum_shape_qual         :!VALUES.F_NAN}
          
    record_temp5 = create_struct(['swea'], s6, record_temp4)
  endif else begin
    record_temp5 = create_struct(record_temp4)
  endelse
  if instruments.mag eq 1 then begin   ;INCLUDE MAG DATA STRUCTURE
    s7 = {mag,                       $
          mso_x      :!VALUES.F_NAN, $
          mso_x_qual :!VALUES.F_NAN, $
          mso_y      :!VALUES.F_NAN, $
          mso_y_qual :!VALUES.F_NAN, $
          mso_z      :!VALUES.F_NAN, $
          mso_z_qual :!VALUES.F_NAN, $
          geo_x      :!VALUES.F_NAN, $
          geo_x_qual :!VALUES.F_NAN, $
          geo_y      :!VALUES.F_NAN, $
          geo_y_qual :!VALUES.F_NAN, $
          geo_z      :!VALUES.F_NAN, $
          geo_z_qual :!VALUES.F_NAN, $
          rms        :!VALUES.F_NAN, $
          rms_qual   :!VALUES.F_NAN}
          
    record_temp6 = create_struct(['mag'], s7, record_temp5)
  endif else begin
    record_temp6 = create_struct(record_temp5)
  endelse
  if instruments.sep eq 1 then begin   ;INCLUDE SEP DATA STRUCTURE
    s8 = {sep,                                        $
          ion_energy_flux_1           :!VALUES.F_NAN, $ 
          ion_energy_flux_1_qual      :!VALUES.F_NAN, $ 
          ion_energy_flux_2           :!VALUES.F_NAN, $ 
          ion_energy_flux_2_qual      :!VALUES.F_NAN, $
          ion_energy_flux_3           :!VALUES.F_NAN, $ 
          ion_energy_flux_3_qual      :!VALUES.F_NAN, $ 
          ion_energy_flux_4           :!VALUES.F_NAN, $ 
          ion_energy_flux_4_qual      :!VALUES.F_NAN, $
          electron_energy_flux_1      :!VALUES.F_NAN, $ 
          electron_energy_flux_1_qual :!VALUES.F_NAN, $
          electron_energy_flux_2      :!VALUES.F_NAN, $ 
          electron_energy_flux_2_qual :!VALUES.F_NAN, $
          electron_energy_flux_3      :!VALUES.F_NAN, $ 
          electron_energy_flux_3_qual :!VALUES.F_NAN, $ 
          electron_energy_flux_4      :!VALUES.F_NAN, $ 
          electron_energy_flux_4_qual :!VALUES.F_NAN, $
          look_direction_1_msox       :!VALUES.F_NAN, $ 
          look_direction_1_msoy       :!VALUES.F_NAN, $ 
          look_direction_1_msoz       :!VALUES.F_NAN, $
          look_direction_2_msox       :!VALUES.F_NAN, $ 
          look_direction_2_msoy       :!VALUES.F_NAN, $ 
          look_direction_2_msoz       :!VALUES.F_NAN, $
          look_direction_3_msox       :!VALUES.F_NAN, $ 
          look_direction_3_msoy       :!VALUES.F_NAN, $ 
          look_direction_3_msoz       :!VALUES.F_NAN, $
          look_direction_4_msox       :!VALUES.F_NAN, $ 
          look_direction_4_msoy       :!VALUES.F_NAN, $ 
          look_direction_4_msoz       :!VALUES.F_NAN}
          
    record_temp7 = create_struct(['sep'], s8, record_temp6)
  endif else begin
    record_temp7 = create_struct(record_temp6)
  endelse
  if instruments.ngims eq 1 then begin   ;INCLUDE NGIMS DATA STRUCTURE
    s9 = {ngims,                                $ 
          he_density            :!VALUES.F_NAN, $ 
          he_density_qual       :!VALUES.F_NAN, $ 
          o_density             :!VALUES.F_NAN, $ 
          o_density_qual        :!VALUES.F_NAN, $ 
          co_density            :!VALUES.F_NAN, $ 
          co_density_qual       :!VALUES.F_NAN, $
          n2_density            :!VALUES.F_NAN, $ 
          n2_density_qual       :!VALUES.F_NAN, $ 
          no_density            :!VALUES.F_NAN, $ 
          no_density_qual       :!VALUES.F_NAN, $ 
          ar_density            :!VALUES.F_NAN, $ 
          ar_density_qual       :!VALUES.F_NAN, $
          co2_density           :!VALUES.F_NAN, $ 
          co2_density_qual      :!VALUES.F_NAN, $ 
          o2plus_density        :!VALUES.F_NAN, $ 
          o2plus_density_qual   :!VALUES.F_NAN, $ 
          co2plus_density       :!VALUES.F_NAN, $
          co2plus_density_qual  :!VALUES.F_NAN, $ 
          noplus_density        :!VALUES.F_NAN, $ 
          noplus_density_qual   :!VALUES.F_NAN, $ 
          oplus_density         :!VALUES.F_NAN, $
          oplus_density_qual    :!VALUES.F_NAN, $ 
          conplus_density       :!VALUES.F_NAN, $ 
          conplus_density_qual  :!VALUES.F_NAN, $ 
          cplus_density         :!VALUES.F_NAN, $ 
          cplus_density_qual    :!VALUES.F_NAN, $
          ohplus_density        :!VALUES.F_NAN, $ 
          ohplus_density_qual   :!VALUES.F_NAN, $ 
          nplus_density         :!VALUES.F_NAN, $ 
          nplus_density_qual    :!VALUES.F_NAN}
          
          
    record_temp8 = create_struct( ['ngims'], s9, record_temp7)
  endif else begin
    record_temp8 = create_struct(record_temp7)
  endelse
  
  insitu_record = 0
  insitu_record = create_struct(['time_string','time','orbit','io_bound'],'',0l,-1L,'',record_temp8)

end