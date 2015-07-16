;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds 
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;       input for start argument to H5S_SELECT_HYPERSLAB
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to H5S_SELECT_HYPERSLAB
;    block : out, optional, type=lonarr(ndims)
;       input for block keyword to H5S_SELECT_HYPERSLAB
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to H5S_SELECT_HYPERSLAB
;-
pro MVN_KP_3D_VECTOR_INIT, old_data, vector_name, vector_scale, coord_sys, insitu


      case vector_name of 
                           'Magnetic Field': begin
                                                 
                                                 if coord_sys eq 0 then begin
                                                  for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                    old_data[0,(i*2)+1] = insitu[i].mag.geo_x
                                                    old_data[1,(i*2)+1] = insitu[i].mag.geo_y
                                                    old_data[2,(i*2)+1] = insitu[i].mag.geo_z
                                                   endfor
                                                 endif
                                                 if coord_sys eq 1 then begin
                                                   for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                    old_data[0,(i*2)+1] = insitu[i].mag.mso_x
                                                    old_data[1,(i*2)+1] = insitu[i].mag.mso_y
                                                    old_data[2,(i*2)+1] = insitu[i].mag.mso_z
                                                   endfor
                                                 endif
                                                 MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                   
                                              end
                            'SWIA H+ Flow Velocity': begin
                             
                                                      if coord_sys eq 0 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_X*insitu[i].spacecraft.t11)+$
                                                                                (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Y*insitu[i].spacecraft.t12)+$
                                                                                (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Z*insitu[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_X*insitu[i].spacecraft.t21)+$
                                                                                (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Y*insitu[i].spacecraft.t22)+$
                                                                                (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Z*insitu[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_X*insitu[i].spacecraft.t31)+$
                                                                                (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Y*insitu[i].spacecraft.t32)+$
                                                                                (insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Z*insitu[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if coord_sys eq 1 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_X
                                                          old_data[1,(i*2)+1] = insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Y
                                                          old_data[2,(i*2)+1] = insitu[i].swia.HPLUS_FLOW_VELOCITY_MSO_Z
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                     
                                                     end
                    ;        'STATIC H+ Flow Velocity': begin
                    ;                                    if coord_sys eq 0 then begin
                    ;                                      for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                    ;                                        old_data[0,(i*2)+1] = (insitu[i].static.hplus_flow_v_msox*insitu[i].spacecraft.t11)+$
                    ;                                                              (insitu[i].static.hplus_flow_v_msoy*insitu[i].spacecraft.t12)+$
                    ;                                                              (insitu[i].static.hplus_flow_v_msoz*insitu[i].spacecraft.t13)
                    ;                                        old_data[1,(i*2)+1] = (insitu[i].static.hplus_flow_v_msox*insitu[i].spacecraft.t21)+$
                    ;                                                              (insitu[i].static.hplus_flow_v_msoy*insitu[i].spacecraft.t22)+$
                    ;                                                              (insitu[i].static.hplus_flow_v_msoz*insitu[i].spacecraft.t23)
                    ;                                        old_data[2,(i*2)+1] = (insitu[i].static.hplus_flow_v_msox*insitu[i].spacecraft.t31)+$
                    ;                                                              (insitu[i].static.hplus_flow_v_msoy*insitu[i].spacecraft.t32)+$
                    ;                                                              (insitu[i].static.hplus_flow_v_msoz*insitu[i].spacecraft.t33)
                    ;                                      endfor
                    ;                                    endif
                    ;                                    if coord_sys eq 1 then begin
                    ;                                      for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                    ;                                        old_data[0,(i*2)+1] = insitu[i].static.hplus_flow_v_msox
                    ;                                        old_data[1,(i*2)+1] = insitu[i].static.hplus_flow_v_msoy
                    ;                                        old_data[2,(i*2)+1] = insitu[i].static.hplus_flow_v_msoz
                     ;                                     endfor
                     ;                                   endif
                     ;                                   MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                     ;                                 
                     ;                                  end
                            'STATIC O+ Flow Velocity': begin
                                                        if coord_sys eq 0 then begin
                                                          for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                            old_data[0,(i*2)+1] = (insitu[i].static.oplus_flow_v_msox*insitu[i].spacecraft.t11)+$
                                                                                  (insitu[i].static.oplus_flow_v_msoy*insitu[i].spacecraft.t12)+$
                                                                                  (insitu[i].static.oplus_flow_v_msoz*insitu[i].spacecraft.t13)
                                                            old_data[1,(i*2)+1] = (insitu[i].static.oplus_flow_v_msox*insitu[i].spacecraft.t21)+$
                                                                                  (insitu[i].static.oplus_flow_v_msoy*insitu[i].spacecraft.t22)+$
                                                                                  (insitu[i].static.oplus_flow_v_msoz*insitu[i].spacecraft.t23)
                                                            old_data[2,(i*2)+1] = (insitu[i].static.oplus_flow_v_msox*insitu[i].spacecraft.t31)+$
                                                                                  (insitu[i].static.oplus_flow_v_msoy*insitu[i].spacecraft.t32)+$
                                                                                  (insitu[i].static.oplus_flow_v_msoz*insitu[i].spacecraft.t33)
                                                          endfor
                                                        endif
                                                        if coord_sys eq 1 then begin
                                                         for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                            old_data[0,(i*2)+1] = insitu[i].static.oplus_flow_v_msox
                                                            old_data[1,(i*2)+1] = insitu[i].static.oplus_flow_v_msoy
                                                            old_data[2,(i*2)+1] = insitu[i].static.oplus_flow_v_msoz
                                                          endfor
                                                        endif
                                                        MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                        
                                                       end
                            'STATIC O2+ Flow Velocity': begin
                                                          if coord_sys eq 0 then begin
                                                            for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                              old_data[0,(i*2)+1] = (insitu[i].static.o2plus_flow_v_msox*insitu[i].spacecraft.t11)+$
                                                                                    (insitu[i].static.o2plus_flow_v_msoy*insitu[i].spacecraft.t12)+$
                                                                                    (insitu[i].static.o2plus_flow_v_msoz*insitu[i].spacecraft.t13)
                                                              old_data[1,(i*2)+1] = (insitu[i].static.o2plus_flow_v_msox*insitu[i].spacecraft.t21)+$
                                                                                    (insitu[i].static.o2plus_flow_v_msoy*insitu[i].spacecraft.t22)+$
                                                                                    (insitu[i].static.o2plus_flow_v_msoz*insitu[i].spacecraft.t23)
                                                              old_data[2,(i*2)+1] = (insitu[i].static.o2plus_flow_v_msox*insitu[i].spacecraft.t31)+$
                                                                                    (insitu[i].static.o2plus_flow_v_msoy*insitu[i].spacecraft.t32)+$
                                                                                    (insitu[i].static.o2plus_flow_v_msoz*insitu[i].spacecraft.t33)
                                                            endfor
                                                          endif
                                                          if coord_sys eq 1 then begin
                                                            for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                              old_data[0,(i*2)+1] = insitu[i].static.o2plus_flow_v_msox
                                                              old_data[1,(i*2)+1] = insitu[i].static.o2plus_flow_v_msoy
                                                              old_data[2,(i*2)+1] = insitu[i].static.o2plus_flow_v_msoz
                                                            endfor
                                                          endif
                                                          MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                         
                                                        end  
                            'STATIC H+ Characteristic Direction': begin
                                                                          if coord_sys eq 0 then begin
                                                                            for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                                              old_data[0,(i*2)+1] = (insitu[i].static.hplus_char_dir_msox*insitu[i].spacecraft.t11)+$
                                                                                                    (insitu[i].static.hplus_char_dir_msoy*insitu[i].spacecraft.t12)+$
                                                                                                    (insitu[i].static.hplus_char_dir_msoz*insitu[i].spacecraft.t13)
                                                                              old_data[1,(i*2)+1] = (insitu[i].static.hplus_char_dir_msox*insitu[i].spacecraft.t21)+$
                                                                                                    (insitu[i].static.hplus_char_dir_msoy*insitu[i].spacecraft.t22)+$
                                                                                                    (insitu[i].static.hplus_char_dir_msoz*insitu[i].spacecraft.t23)
                                                                              old_data[2,(i*2)+1] = (insitu[i].static.hplus_char_dir_msox*insitu[i].spacecraft.t31)+$
                                                                                                    (insitu[i].static.hplus_char_dir_msoy*insitu[i].spacecraft.t32)+$
                                                                                                    (insitu[i].static.hplus_char_dir_msoz*insitu[i].spacecraft.t33)
                                                                            endfor    
                                                                          endif 
                                                                          if coord_sys eq 1 then begin
                                                                            for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                                              old_data[0,(i*2)+1] = insitu[i].static.hplus_char_dir_msox
                                                                              old_data[1,(i*2)+1] = insitu[i].static.hplus_char_dir_msoy
                                                                              old_data[2,(i*2)+1] = insitu[i].static.hplus_char_dir_msoz
                                                                            endfor
                                                                          endif
                                                                          MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                                          
                                                                       end
                            'STATIC Pickup Ion Characteristic Direction': begin
                                                                            if coord_sys eq 0 then begin
                                                                              for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                                                old_data[0,(i*2)+1] = (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_X*insitu[i].spacecraft.t11)+$
                                                                                                      (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Y*insitu[i].spacecraft.t12)+$
                                                                                                      (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Z*insitu[i].spacecraft.t13)
                                                                                old_data[1,(i*2)+1] = (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_X*insitu[i].spacecraft.t21)+$
                                                                                                      (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Y*insitu[i].spacecraft.t22)+$
                                                                                                      (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Z*insitu[i].spacecraft.t23)
                                                                                old_data[2,(i*2)+1] = (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_X*insitu[i].spacecraft.t31)+$
                                                                                                      (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Y*insitu[i].spacecraft.t32)+$
                                                                                                      (insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Z*insitu[i].spacecraft.t33)
                                                                              endfor
                                                                            endif
                                                                            if coord_sys eq 1 then begin
                                                                              for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                                                old_data[0,(i*2)+1] = insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_X
                                                                                old_data[1,(i*2)+1] = insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Y
                                                                                old_data[2,(i*2)+1] = insitu[i].static.DOMINANT_PICKUP_ION_CHARACTERISTIC_DIRECTION_MSO_Z
                                                                              endfor
                                                                            endif
                                                                            MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                                         
                                                                          end
                            'SEP Look Direction 1 Front': begin
                                                      if coord_sys eq 0 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_X*insitu[i].spacecraft.t11)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Y*insitu[i].spacecraft.t12)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Z*insitu[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_X*insitu[i].spacecraft.t21)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Y*insitu[i].spacecraft.t22)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Z*insitu[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_X*insitu[i].spacecraft.t31)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Y*insitu[i].spacecraft.t32)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Z*insitu[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if coord_sys eq 1 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_1_F_MSO_X
                                                          old_data[1,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Y
                                                          old_data[2,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_1_F_MSO_Z
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                     
                                                    end     
                            'SEP Look Direction 1 Back': begin
                                                      if coord_sys eq 0 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_X*insitu[i].spacecraft.t11)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Y*insitu[i].spacecraft.t12)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Z*insitu[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_X*insitu[i].spacecraft.t21)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Y*insitu[i].spacecraft.t22)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Z*insitu[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_X*insitu[i].spacecraft.t31)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Y*insitu[i].spacecraft.t32)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Z*insitu[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if coord_sys eq 1 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_1_R_MSO_X
                                                          old_data[1,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Y
                                                          old_data[2,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_1_R_MSO_Z
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                     
                                                    end
                            'SEP Look Direction 2 Front': begin
                                                      if coord_sys eq 0 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_X*insitu[i].spacecraft.t11)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Y*insitu[i].spacecraft.t12)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Z*insitu[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_X*insitu[i].spacecraft.t21)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Y*insitu[i].spacecraft.t22)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Z*insitu[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_X*insitu[i].spacecraft.t31)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Y*insitu[i].spacecraft.t32)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Z*insitu[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if coord_sys eq 1 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_2_F_MSO_X
                                                          old_data[1,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Y
                                                          old_data[2,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_2_F_MSO_Z
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                  
                                                    end
                            'SEP Look Direction 2 Back': begin
                                                      if coord_sys eq 0 then begin
                                                        for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_X*insitu[i].spacecraft.t11)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Y*insitu[i].spacecraft.t12)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Z*insitu[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_X*insitu[i].spacecraft.t21)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Y*insitu[i].spacecraft.t22)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Z*insitu[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_X*insitu[i].spacecraft.t31)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Y*insitu[i].spacecraft.t31)+$
                                                                                (insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Z*insitu[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if coord_sys eq 1 then begin
                                                       for i=0,n_elements(insitu.spacecraft.geo_x)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_2_R_MSO_X
                                                          old_data[1,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Y
                                                          old_data[2,(i*2)+1] = insitu[i].sep.LOOK_DIRECTION_2_R_MSO_Z
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, vector_scale
                                                 
                                                    end          

            endcase

    length = fltarr(n_elements(old_data[0,*])/2)
    for i=0,n_elements(old_data[0,*])/2 - 1 do begin
      length = sqrt(((old_data[0,(i*2)+1]-old_data[0,i])^2)+((old_data[1,(i*2)+1]-old_data[1,i])^2)+((old_data[2,(i*2)+1]-old_data[2,i])^2))
    endfor
   
    max_length = max(length)/vector_scale
    
    for i=0,(n_elements(old_data[0,*])/2)-1 do begin
      old_data[0,(i*2)+1] = old_data[0,(i*2)+1]/max_length
      old_data[1,(i*2)+1] = old_data[1,(i*2)+1]/max_length
      old_data[2,(i*2)+1] = old_data[2,(i*2)+1]/max_length
    endfor


END