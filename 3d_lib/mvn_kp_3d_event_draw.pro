;+
; :Name:
;   mvn_kp_3d_event_draw
;
; :Description:
;   Procedure to respond to widget events changing current camera view
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
pro mvn_kp_3d_event_draw, event
  ;
  ;  This is required to be able to update pstate
  ;
  widget_control, event.top, get_uvalue=pstate
  ;
  ;  This captures the current event
  ;
;  widget_control, event.id, get_value=newval

  if (*pstate).camera_view eq 0 then begin
    ; rotate
    translate = event.modifiers and 1
    update = (*pstate).track->update(event, transform=rotTransform, $
      translate=translate)

    if (update) then begin
      (*pstate).model->getProperty, transform=curTransform
      (*pstate).atmModel1->getproperty,transform=atmtrans1
      (*pstate).atmModel2->getproperty,transform=atmtrans2
      (*pstate).atmModel3->getproperty,transform=atmtrans3
      (*pstate).atmModel4->getproperty,transform=atmtrans4
      (*pstate).atmModel5->getproperty,transform=atmtrans5
      (*pstate).atmModel6->getproperty,transform=atmtrans6
      (*pstate).maven_model->getProperty, transform=mavTrans
      (*pstate).sub_solar_model->getProperty,transform=ssTrans
      (*pstate).sub_maven_model->getProperty,transform=smTrans
      (*pstate).sub_maven_model_mso->getProperty,transform=smTransMSO
      (*pstate).vector_model->getProperty,transform=vertTrans
      (*pstate).sun_model->getproperty,transform=SunTrans
      (*pstate).axesmodel_mso->getproperty,transform=xaxesTrans
      newTransform = curTransform # rotTransform
      newatmtrans1 = atmtrans1 # rotTransform
      newatmtrans2 = atmtrans2 # rotTransform
      newatmtrans3 = atmtrans3 # rotTransform
      newatmtrans4 = atmtrans4 # rotTransform
      newatmtrans5 = atmtrans5 # rotTransform
      newatmtrans6 = atmtrans6 # rotTransform
      newMavTrans = mavTrans # rotTransform
      newSsTrans = ssTrans # rotTransform
      newSmTrans = smTrans # rotTransform
      newSmTransMSO = smTransMSO # rotTransform
      newVertTrans = vertTrans # rotTransform
      newSunTrans = sunTrans # rotTransform
      newXaxes = xAxesTrans # rotTransform
      (*pstate).model->setProperty, transform=newTransform
      (*pstate).atmModel1->setProperty, transform=newatmtrans1
      (*pstate).atmModel2->setProperty, transform=newatmtrans2
      (*pstate).atmModel3->setProperty, transform=newatmtrans3
      (*pstate).atmModel4->setProperty, transform=newatmtrans4
      (*pstate).atmModel5->setProperty, transform=newatmtrans5
      (*pstate).atmModel6->setProperty, transform=newatmtrans6
      (*pstate).gridlines->setproperty, transform=newtransform
      (*pstate).orbit_model -> setProperty, transform=newTransform
      (*pstate).maven_model -> setProperty, transform=newMavTrans
      (*pstate).sub_solar_model->setProperty,transform=newSsTrans
      (*pstate).sub_maven_model->setProperty,transform=newSmTrans
      (*pstate).sub_maven_model_mso->setProperty,transform=newSmTransMSO
      (*pstate).vector_model->setProperty,transform=newVertTrans
      (*pstate).axesmodel -> setProperty, transform=newtransform
      (*pstate).sun_model ->setProperty, transform=newSunTrans
      (*pstate).axesmodel_mso->setProperty, transform=newXaxes
      if (*pstate).instrument_array[8] eq 1 then begin
        (*pstate).periapse_limb_model->getProperty,transform=periTrans
        newPeriTrans = periTrans # rotTransform
        (*pstate).periapse_limb_model->setproperty, transform=newPeriTrans
      endif
      if (*pstate).instrument_array[10] eq 1 then begin
        (*pstate).corona_e_high_model->getProperty, transform=cEHtrans
        newCEHtrans = cEHtrans # rotTransform
        (*pstate).corona_e_high_model->setProperty, transform=newCEHtrans
      endif
      if (*pstate).instrument_array[11] eq 1 then begin
        (*pstate).corona_e_disk_model->getproperty, transform=cEDtrans
        newcEDtrans = cEDtrans # rotTransform
        (*pstate).corona_e_disk_model->setproperty, transform=newcEDtrans
      endif
      if (*pstate).instrument_array[13] eq 1 then begin
        (*pstate).corona_lo_high_model->getProperty, transform=cLHtrans
        newCLHtrans = cLHtrans # rotTransform
        (*pstate).corona_lo_high_model->setproperty, transform=newCLHtrans
      endif
      if (*pstate).instrument_array[14] eq 1 then begin
        (*pstate).corona_lo_limb_model->getProperty, transform=cLLtrans
        newCLLtrans = cLLtrans # rotTransform
        (*pstate).corona_lo_limb_model->setproperty, transform=newCLLtrans
      endif
      if (*pstate).instrument_array[15] eq 1 then begin
        (*pstate).corona_e_limb_model->getProperty, transform=cELtrans
        newCELtrans = cELtrans # rotTransform
        (*pstate).corona_e_limb_model->setproperty, transform=newCELtrans
      endif
      if (*pstate).instrument_array[16] eq 1 then begin
        (*pstate).corona_lo_disk_model->getProperty, transform=cLDTrans
        newcLDTrans = cLDTrans # rotTransform
        (*pstate).corona_lo_disk_model->setProperty, transform=newcLDTrans
      endif
      (*pstate).maven_location = (*pstate).maven_location#rotTransform
      (*pstate).z_position = (*pstate).z_position#rotTransform

      (*pstate).window->draw, (*pstate).view
    endif
  endif       ;end of camera view check
  ; scale
  if (event.type eq 7) then begin
    s = 1.07 ^ event.clicks

    if( ( ( (*pstate).z_position(3) ge 0.25 ) and $
      ( (*pstate).z_position(3) le 10.0 ) ) or $
      ( ( (*pstate).z_position(3) le 0.25) and (s ge 1.0) ) or $
      ( ( (*pstate).z_position(3) ge 10.0) and (s le 1.0) ) )then begin

      (*pstate).model->scale, s, s, s
      (*pstate).atmModel1->scale,s,s,s
      (*pstate).atmModel2->scale,s,s,s
      (*pstate).atmModel3->scale,s,s,s
      (*pstate).atmModel4->scale,s,s,s
      (*pstate).atmModel5->scale,s,s,s
      (*pstate).atmModel6->scale,s,s,s
      (*pstate).gridlines->scale,s,s,s
      (*pstate).orbit_model->scale,s,s,s
      (*pstate).maven_model->scale,s,s,s
      (*pstate).sub_solar_model->scale,s,s,s
      (*pstate).sub_maven_model->scale,s,s,s
      (*pstate).sub_maven_model_mso->scale,s,s,s
      (*pstate).axesmodel->scale,s,s,s
      (*pstate).vector_model->scale,s,s,s
      (*pstate).sun_model -> scale,s,s,s
      (*pstate).axesmodel_mso->scale, s,s,s
      if (*pstate).instrument_array[8] eq 1 then begin
        (*pstate).periapse_limb_model->scale,s,s,s
      endif
      if (*pstate).instrument_array[10] eq 1 then begin
        (*pstate).corona_e_high_model->scale,s,s,s
      endif
      if (*pstate).instrument_array[11] eq 1 then begin
        (*pstate).corona_e_disk_model->scale, s,s,s
      endif
      if (*pstate).instrument_array[13] eq 1 then begin
        (*pstate).corona_lo_high_model->scale, s,s,s
      endif
      if (*pstate).instrument_array[14] eq 1 then begin
        (*pstate).corona_lo_limb_model->scale, s,s,s
      endif
      if (*pstate).instrument_array[15] eq 1 then begin
        (*pstate).corona_e_limb_model->scale, s,s,s
      endif
      if (*pstate).instrument_array[16] eq 1 then begin
        (*pstate).corona_lo_disk_model->scale, s,s,s
      endif
      (*pstate).maven_location = (*pstate).maven_location*s
      (*pstate).z_position = (*pstate).z_position*s
      (*pstate).window->draw, (*pstate).view
    endif ; multi-tiered conditional
  endif   ; event type eq 7
  return
end