;+
; :Name:
;   mvn_kp_3d_event_insitu_vector_field
; 
; :Description:
;   Procedure to respond to widget events selecting vector field
;   dropdown menu
;
; :Author:
;   Kevin McGouldrick (2015-May-21)
;
; :Parameters:
;   event: in, required
;     widget event
;     
; :Version:
;  1.0
;
;-
pro mvn_kp_3d_event_insitu_vector_field,event
;
;  This is required to be able to update pstate
;
  widget_control, event.top, get_uvalue=pstate
;
;  This captures the current event
;
  index = widget_info( event.id, /droplist_select )
  widget_control, event.id, get_value=newval
  
  ;; Make idl 8.2.2 happy -
  ;; We found that dereferencing the pointer to the struct in each
  ;; iteration of the for loop was very slow in 8.2.2
  insitu_spec = (*pstate).insitu

  case newval(index) of
    'Magnetic Field': $
      begin
      (*pstate).vector_path->getproperty,data=old_data
      if (*pstate).coord_sys eq 0 then begin
        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
          old_data[0,(i*2)+1] = insitu_spec[i].mag.geo_x
          old_data[1,(i*2)+1] = insitu_spec[i].mag.geo_y
          old_data[2,(i*2)+1] = insitu_spec[i].mag.geo_z
        endfor
      endif
      if (*pstate).coord_sys eq 1 then begin
        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
          old_data[0,(i*2)+1] = insitu_spec[i].mag.mso_x
          old_data[1,(i*2)+1] = insitu_spec[i].mag.mso_y
          old_data[2,(i*2)+1] = insitu_spec[i].mag.mso_z
        endfor
      endif
      MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
      (*pstate).vector_path->setproperty,data=old_data
      (*pstate).window->draw,(*pstate).view
    end

    'SWIA H+ Flow Velocity': $
      begin
      (*pstate).vector_path->getproperty,data=old_data
      if (*pstate).coord_sys eq 0 then begin
        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
          old_data[0,(i*2)+1] $
            = ( insitu_spec[i].swia.hplus_flow_v_msox $
            * insitu_spec[i].spacecraft.t11 ) $
            + ( insitu_spec[i].swia.hplus_flow_v_msoy $
            * insitu_spec[i].spacecraft.t12 ) $
            + ( insitu_spec[i].swia.hplus_flow_v_msoz $
            * insitu_spec[i].spacecraft.t13 )
          old_data[1,(i*2)+1] $
            = ( insitu_spec[i].swia.hplus_flow_v_msox $
            * insitu_spec[i].spacecraft.t21 ) $
            + ( insitu_spec[i].swia.hplus_flow_v_msoy $
            * insitu_spec[i].spacecraft.t22 ) $
            + ( insitu_spec[i].swia.hplus_flow_v_msoz $
            * insitu_spec[i].spacecraft.t23 )
          old_data[2,(i*2)+1] $
            = ( insitu_spec[i].swia.hplus_flow_v_msox $
            * insitu_spec[i].spacecraft.t31 ) $
            + ( insitu_spec[i].swia.hplus_flow_v_msoy $
            * insitu_spec[i].spacecraft.t32 ) $
            + ( insitu_spec[i].swia.hplus_flow_v_msoz $
            * insitu_spec[i].spacecraft.t33 )
        endfor
      endif
      if (*pstate).coord_sys eq 1 then begin
        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
          old_data[0,(i*2)+1] = insitu_spec[i].swia.hplus_flow_v_msox
          old_data[1,(i*2)+1] = insitu_spec[i].swia.hplus_flow_v_msoy
          old_data[2,(i*2)+1] = insitu_spec[i].swia.hplus_flow_v_msoz
        endfor
      endif
      MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
      (*pstate).vector_path->setproperty,data=old_data
      (*pstate).window->draw,(*pstate).view
    end
    ;  'STATIC H+ Flow Velocity': $
    ;    begin
    ;      (*pstate).vector_path->getproperty,data=old_data
    ;      if (*pstate).coord_sys eq 0 then begin
    ;        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
    ;          old_data[0,(i*2)+1] $
    ;             = (insitu_spec[i].static.hplus_flow_v_msox $
    ;               * insitu_spec[i].spacecraft.t11 ) $
    ;             + (insitu_spec[i].static.hplus_flow_v_msoy $
    ;               * insitu_spec[i].spacecraft.t12 ) $
    ;             + (insitu_spec[i].static.hplus_flow_v_msoz $
    ;               * insitu_spec[i].spacecraft.t13 )
    ;          old_data[1,(i*2)+1] $
    ;            = (insitu_spec[i].static.hplus_flow_v_msox $
    ;              * insitu_spec[i].spacecraft.t21 ) $
    ;            + (insitu_spec[i].static.hplus_flow_v_msoy $
    ;              * insitu_spec[i].spacecraft.t22 ) $
    ;            + (insitu_spec[i].static.hplus_flow_v_msoz $
    ;              * insitu_spec[i].spacecraft.t23)
    ;          old_data[2,(i*2)+1] $
    ;            = (insitu_spec[i].static.hplus_flow_v_msox $
    ;              * insitu_spec[i].spacecraft.t31 ) $
    ;            + (insitu_spec[i].static.hplus_flow_v_msoy $
    ;              * insitu_spec[i].spacecraft.t32 ) $
    ;            + (insitu_spec[i].static.hplus_flow_v_msoz $
    ;              * insitu_spec[i].spacecraft.t33)
    ;        endfor
    ;      endif
    ;      if (*pstate).coord_sys eq 1 then begin
    ;        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
    ;          old_data[0,(i*2)+1] = insitu_spec[i].static.hplus_flow_v_msox
    ;          old_data[1,(i*2)+1] = insitu_spec[i].static.hplus_flow_v_msoy
    ;          old_data[2,(i*2)+1] = insitu_spec[i].static.hplus_flow_v_msoz
    ;        endfor
    ;      endif
    ;      MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
    ;      (*pstate).vector_path->setproperty,data=old_data
    ;      (*pstate).window->draw,(*pstate).view
    ;    end
    'STATIC O+ Flow Velocity': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] = (insitu_spec[i].static.oplus_flow_v_msox $
                                  * insitu_spec[i].spacecraft.t11 ) $
                                + (insitu_spec[i].static.oplus_flow_v_msoy $
                                  * insitu_spec[i].spacecraft.t12 ) $
                                + (insitu_spec[i].static.oplus_flow_v_msoz $
                                  * insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] = (insitu_spec[i].static.oplus_flow_v_msox $
                                  * insitu_spec[i].spacecraft.t21 ) $
                                + (insitu_spec[i].static.oplus_flow_v_msoy $
                                  *insitu_spec[i].spacecraft.t22 ) $
                                + (insitu_spec[i].static.oplus_flow_v_msoz $
                                  * insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] = (insitu_spec[i].static.oplus_flow_v_msox $
                                  * insitu_spec[i].spacecraft.t31) $
                                + (insitu_spec[i].static.oplus_flow_v_msoy $
                                  *insitu_spec[i].spacecraft.t32) $
                                + (insitu_spec[i].static.oplus_flow_v_msoz $
                                  *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] = insitu_spec[i].static.oplus_flow_v_msox
            old_data[1,(i*2)+1] = insitu_spec[i].static.oplus_flow_v_msoy
            old_data[2,(i*2)+1] = insitu_spec[i].static.oplus_flow_v_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end
    'STATIC O2+ Flow Velocity': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] = (insitu_spec[i].static.o2plus_flow_v_msox $
                                  *insitu_spec[i].spacecraft.t11) $
                                + (insitu_spec[i].static.o2plus_flow_v_msoy $
                                  *insitu_spec[i].spacecraft.t12) $
                                + (insitu_spec[i].static.o2plus_flow_v_msoz $
                                  *insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] = (insitu_spec[i].static.o2plus_flow_v_msox $
                                  *insitu_spec[i].spacecraft.t21) $
                                + (insitu_spec[i].static.o2plus_flow_v_msoy $
                                  *insitu_spec[i].spacecraft.t22) $
                                + (insitu_spec[i].static.o2plus_flow_v_msoz $
                                  *insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] = (insitu_spec[i].static.o2plus_flow_v_msox $
                                  *insitu_spec[i].spacecraft.t32) $
                                + (insitu_spec[i].static.o2plus_flow_v_msoy $
                                  *insitu_spec[i].spacecraft.t32) $
                                + (insitu_spec[i].static.o2plus_flow_v_msoz $
                                  *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] = insitu_spec[i].static.o2plus_flow_v_msox
            old_data[1,(i*2)+1] = insitu_spec[i].static.o2plus_flow_v_msoy
            old_data[2,(i*2)+1] = insitu_spec[i].static.o2plus_flow_v_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end
    'STATIC H+ Char Dir': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] = (insitu_spec[i].static.hplus_char_dir_msox $
                                  *insitu_spec[i].spacecraft.t11) $
                                + (insitu_spec[i].static.hplus_char_dir_msoy $
                                  *insitu_spec[i].spacecraft.t12) $
                                + (insitu_spec[i].static.hplus_char_dir_msoz $
                                  *insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] = (insitu_spec[i].static.hplus_char_dir_msox $
                                  *insitu_spec[i].spacecraft.t21) $
                                + (insitu_spec[i].static.hplus_char_dir_msoy $
                                  *insitu_spec[i].spacecraft.t22) $
                                + (insitu_spec[i].static.hplus_char_dir_msoz $
                                  *insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] = (insitu_spec[i].static.hplus_char_dir_msox $
                                  *insitu_spec[i].spacecraft.t31) $
                                + (insitu_spec[i].static.hplus_char_dir_msoy $
                                  *insitu_spec[i].spacecraft.t32) $
                                + (insitu_spec[i].static.hplus_char_dir_msoz $
                                  *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] = insitu_spec[i].static.hplus_char_dir_msox
            old_data[1,(i*2)+1] = insitu_spec[i].static.hplus_char_dir_msoy
            old_data[2,(i*2)+1] = insitu_spec[i].static.hplus_char_dir_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end
    'STATIC Dom Ion Char Dir': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = (insitu_spec[i].static.dominant_pickup_ion_char_dir_msox $
                *insitu_spec[i].spacecraft.t11) $
              + (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy $
                *insitu_spec[i].spacecraft.t12) $
              + (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz $
                *insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] $
              = (insitu_spec[i].static.dominant_pickup_ion_char_dir_msox $
                *insitu_spec[i].spacecraft.t21) $
              + (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy $
                *insitu_spec[i].spacecraft.t22) $
              + (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz $
                *insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] $
              = (insitu_spec[i].static.dominant_pickup_ion_char_dir_msox $
                *insitu_spec[i].spacecraft.t31) $
              + (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy $
                *insitu_spec[i].spacecraft.t32) $
              + (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz $
                *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = insitu_spec[i].static.dominant_pickup_ion_char_dir_msox
            old_data[1,(i*2)+1] $
              = insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy
            old_data[2,(i*2)+1] $
              = insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end

    'SEP Look Direction 1 Front': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_1_front_msox $
                *insitu_spec[i].spacecraft.t11) $
              + (insitu_spec[i].sep.look_direction_1_front_msoy $
                *insitu_spec[i].spacecraft.t12) $
              + (insitu_spec[i].sep.look_direction_1_front_msoz $
                *insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_1_front_msox $
                *insitu_spec[i].spacecraft.t21) $
              + (insitu_spec[i].sep.look_direction_1_front_msoy $
                *insitu_spec[i].spacecraft.t22) $
              + (insitu_spec[i].sep.look_direction_1_front_msoz $
                *insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_1_front_msox $
                *insitu_spec[i].spacecraft.t31) $
              + (insitu_spec[i].sep.look_direction_1_front_msoy $
                *insitu_spec[i].spacecraft.t32) $
              + (insitu_spec[i].sep.look_direction_1_front_msoz $
                *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_1_front_msox
            old_data[1,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_1_front_msoy
            old_data[2,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_1_front_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end
    
    'SEP Look Direction 1 Back': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_1_back_msox $
                *insitu_spec[i].spacecraft.t11) $
              + (insitu_spec[i].sep.look_direction_1_back_msoy $
                *insitu_spec[i].spacecraft.t12) $
              + (insitu_spec[i].sep.look_direction_1_back_msoz $
                *insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_1_back_msox $
                *insitu_spec[i].spacecraft.t21) $
              + (insitu_spec[i].sep.look_direction_1_back_msoy $
                *insitu_spec[i].spacecraft.t22) $
              + (insitu_spec[i].sep.look_direction_1_back_msoz $
                *insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_1_back_msox $
                *insitu_spec[i].spacecraft.t31) $
              + (insitu_spec[i].sep.look_direction_1_back_msoy $
                *insitu_spec[i].spacecraft.t32) $
              + (insitu_spec[i].sep.look_direction_1_back_msoz $
                *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_1_back_msox
            old_data[1,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_1_back_msoy
            old_data[2,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_1_back_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end

    'SEP Look Direction 2 Front': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_2_front_msox $
                *insitu_spec[i].spacecraft.t11) $
              + (insitu_spec[i].sep.look_direction_2_front_msoy $
                *insitu_spec[i].spacecraft.t12) $
              + (insitu_spec[i].sep.look_direction_2_front_msoz $
                *insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_2_front_msox $
                *insitu_spec[i].spacecraft.t21) $
              + (insitu_spec[i].sep.look_direction_2_front_msoy $
                *insitu_spec[i].spacecraft.t22) $
              + (insitu_spec[i].sep.look_direction_2_front_msoz $
                *insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_2_front_msox $
                *insitu_spec[i].spacecraft.t31) $
              + (insitu_spec[i].sep.look_direction_2_front_msoy $
                *insitu_spec[i].spacecraft.t32) $
              + (insitu_spec[i].sep.look_direction_2_front_msoz $
                *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_2_front_msox
            old_data[1,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_2_front_msoy
            old_data[2,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_2_front_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end

    'SEP Look Direction 2 Back': $
      begin
        (*pstate).vector_path->getproperty,data=old_data
        if (*pstate).coord_sys eq 0 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_2_back_msox $
                *insitu_spec[i].spacecraft.t11) $
              + (insitu_spec[i].sep.look_direction_2_back_msoy $
                *insitu_spec[i].spacecraft.t12) $
              + (insitu_spec[i].sep.look_direction_2_back_msoz $
                *insitu_spec[i].spacecraft.t13)
            old_data[1,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_2_back_msox $
                *insitu_spec[i].spacecraft.t21) $
              + (insitu_spec[i].sep.look_direction_2_back_msoy $
                *insitu_spec[i].spacecraft.t22) $
              + (insitu_spec[i].sep.look_direction_2_back_msoz $
                *insitu_spec[i].spacecraft.t23)
            old_data[2,(i*2)+1] $
              = (insitu_spec[i].sep.look_direction_2_back_msox $
                *insitu_spec[i].spacecraft.t31) $
              + (insitu_spec[i].sep.look_direction_2_back_msoy $
                *insitu_spec[i].spacecraft.t32) $
              + (insitu_spec[i].sep.look_direction_2_back_msoz $
                *insitu_spec[i].spacecraft.t33)
          endfor
        endif
        if (*pstate).coord_sys eq 1 then begin
          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
            old_data[0,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_2_back_msox
            old_data[1,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_2_back_msoy
            old_data[2,(i*2)+1] $
              = insitu_spec[i].sep.look_direction_2_back_msoz
          endfor
        endif
        MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
        (*pstate).vector_path->setproperty,data=old_data
        (*pstate).window->draw,(*pstate).view
      end
  endcase

  return
end
