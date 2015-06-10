;+
; :Name:
;   mvn_kp_3d_event_time
;
; :Description:
;   Procedure to respond to widget events changing time of current view
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
pro mvn_kp_3d_event_time, event
  ;
  ;  This is required to be able to update pstate
  ;
  widget_control, event.top, get_uvalue=pstate
  ;
  ;  This captures the current event
  ;
  widget_control, event.id, get_value=newval

  ;MOVE THE SPACECRAFT MODEL TO IT'S NEW LOCATION
  t = min(abs(((*pstate).insitu.time - newval)),t_index)

  ;    data = *(*pstate).orbit_path.data
  (*pstate).orbit_path -> getproperty, data=data
  (*pstate).orbit_model->GetProperty,transform=curtrans
  cur_x = data[0,(*pstate).time_index*2]
  cur_y = data[1,(*pstate).time_index*2]
  cur_z = data[2,(*pstate).time_index*2]
  new = fltarr(1,3)
  new[0,0] = data[0,t_index*2]-cur_x
  new[0,1] = data[1,t_index*2]-cur_y
  new[0,2] = data[2,t_index*2]-cur_z
  delta = new # curtrans[0:2,0:2]
  (*pstate).maven_model -> translate, delta[0],delta[1],delta[2]
  (*pstate).maven_location[0] = (*pstate).maven_location[0]+delta[0]
  (*pstate).maven_location[1] = (*pstate).maven_location[1]+delta[1]
  (*pstate).maven_location[2] = (*pstate).maven_location[2]+delta[2]

  ;UPDATE THE PARAMETERS ON SCREEN
  (*pstate).paratext1->setProperty,$
    strings='Distance to Sun:'$
    +strtrim(string((*pstate).insitu(t_index).spacecraft.$
    mars_sun_distance),2)+' AU'
  (*pstate).paratext2->setProperty,$
    strings='Mars Season:'$
    +strtrim(string((*pstate).insitu(t_index)$
    .spacecraft.mars_season),2)
  (*pstate).paratext3->setProperty,$
    strings='MAVEN Altitude:'$
    +strtrim(string((*pstate).insitu(t_index)$
    .spacecraft.altitude),2)
  (*pstate).paratext4->setProperty,$
    strings='Solar Zenith Angle:'$
    +strtrim(string((*pstate).insitu(t_index)$
    .spacecraft.sza),2)
  (*pstate).paratext5->setProperty,$
    strings='Local Time:'$
    +strtrim(string((*pstate).insitu(t_index)$
    .spacecraft.local_time),2)
  (*pstate).paratext6->setProperty,$
    strings='SubMaven Lat:'$
    +strtrim(string((*pstate).insitu(t_index)$
    .spacecraft.sub_sc_latitude),2)
  (*pstate).paratext7->setProperty,$
    strings='SubMaven Lon:'$
    +strtrim(string((*pstate).insitu(t_index)$
    .spacecraft.sub_sc_longitude),2)
  (*pstate).timetext->setProperty,$
    strings=time_string(newval,format=0)
  (*pstate).plottext1->getproperty,strings=temp_string
  if temp_string ne '' then begin
    temp_string = strtrim( string( (*pstate).insitu(t_index)$
      .((*pstate).level0_index)$
      .((*pstate).level1_index)),2)
    (*pstate).plottext2->setProperty, strings = temp_string

  endif

  ;MOVE THE SUN'S LIGHT SOURCE TO THE PROPER LOCATION
  if (*pstate).coord_sys eq 0 then begin        ;GEO COORDINATE SYSTEM
    (*pstate).dirlight->setProperty,$
      location=[(*pstate).solar_x_coord(t_index),$
      (*pstate).solar_y_coord(t_index),$
      (*pstate).solar_z_coord(t_index)]
    ;UPDATE THE SUBSOLAR POINT
    (*pstate).sub_solar_line->setProperty,$
      data=[(*pstate).subsolar_x_coord[t_index],$
      (*pstate).subsolar_y_coord[t_index],$
      (*pstate).subsolar_z_coord[t_index]]
    ;UPDATE THE SUBMAVEN POINT
    (*pstate).sub_maven_line->setProperty,$
      data=[(*pstate).submaven_x_coord[t_index],$
      (*pstate).submaven_y_coord[t_index],$
      (*pstate).submaven_z_coord[t_index]]
    ;UPDATE THE SUN VECTOR
    (*pstate).sun_vector -> getproperty, data=data1
    data1[0,1] = (*pstate).solar_x_coord(t_index)
    data1[1,1] = (*pstate).solar_y_coord(t_index)
    data1[2,1] = (*pstate).solar_z_coord(t_index)
    (*pstate).sun_vector->setProperty,data=data1
    
    ;Pretty sure MSO axis will stay the same all the time 
    ;
    ;UPDATE THE MSO AXES, EVEN THOUGH THEY'RE HIDDEN
    ;lon1 = (*pstate).insitu(t_index).spacecraft.$
    ;  subsolar_point_geo_longitude
    ;lon2 = (*pstate).insitu((*pstate).time_index).spacecraft.$
    ;  subsolar_point_geo_longitude
    ;(*pstate).axesModel_mso->rotate, [0,0,1], lon2-lon1

  endif else begin  ;MSO COORDINATE DISPLAY
    
    ;Rotate the mars globe back zero (so that 0 lat/lon is on the x axis)
    (*pstate).mars_globe -> rotate, [0,-1,0], (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_latitude
    (*pstate).mars_globe -> rotate, [0,0,-1], -(*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude
    
    ;Rotate the globe so that the subsolar point aligns with the x axis
    (*pstate).mars_globe -> rotate, [0,0,1], -(*pstate).insitu(t_index).spacecraft.subsolar_point_geo_longitude
    (*pstate).mars_globe -> rotate, [0,1,0], (*pstate).insitu(t_index).spacecraft.subsolar_point_geo_latitude
    
    ;Same logic as above, but with the axes model instead of the globe
    (*pstate).axesmodel -> rotate, [0,-1,0], (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_latitude
    (*pstate).axesmodel -> rotate, [0,0,-1], -(*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude
    (*pstate).axesmodel -> rotate, [0,0,1], -(*pstate).insitu(t_index).spacecraft.subsolar_point_geo_longitude
    (*pstate).axesmodel -> rotate, [0,1,0], (*pstate).insitu(t_index).spacecraft.subsolar_point_geo_latitude
    
    
    ;Change submaven point to the mso coordinates
    (*pstate).sub_maven_line_mso->setproperty,$
      data=[(*pstate).submaven_x_coord_mso[t_index],$
      (*pstate).submaven_y_coord_mso[t_index],$
      (*pstate).submaven_z_coord_mso[t_index]]
      

  endelse


  ;UPDATE THE TERMINATOR LOCATION

  ;UPDATE THE PARAMETER PLOT COLORS
  (*pstate).parameter_plot->getproperty,vert_colors=colors

  for i=0,n_elements(colors[0,*])-1 do begin
    if i lt t_index then begin
      colors[*,i] = (*pstate).parameter_plot_before_color
    endif else begin
      colors[*,i] = (*pstate).parameter_plot_after_color
    endelse
  endfor

  (*pstate).parameter_plot->setproperty,vert_colors=colors

  if (*pstate).instrument_array[8] eq 1 then begin
    ;UPDATE THE IUVS PERIAPSE ALTITUDE PLOT
    MVN_KP_3D_CURRENT_PERIAPSE, (*pstate).iuvs.periapse, $
      (*pstate).insitu[t_index].time, peri_data, $
      (*pstate).periapse_limb_scan, xlabel
    (*pstate).alt_xaxis_title->setproperty,strings=xlabel
    (*pstate).alt_plot->setproperty,datax=peri_data[1,*]
    (*pstate).alt_plot->setproperty,datay=peri_data[0,*]
    (*pstate).alt_plot->setproperty,$
      xrange=[min(peri_data[1,*]),max(peri_data[1,*])]
    (*pstate).alt_plot->getproperty, xrange=xr, yrange=yr
    xc = mg_linear_function(xr, [-1.75,-1.5])
    yc = mg_linear_function(yr, [-1.3,1.0])
    (*pstate).alt_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
    (*pstate).alt_xaxis_ticks->setproperty,$
      strings=strtrim(string([min(peri_data[1,*]),max(peri_data[1,*])],$
      format='(E8.2)'),2)
  endif

  (*pstate).time_index = t_index

  ;IF THE SCENE IS SPACECRAFT LOCKED, ROTATE EVERYTHING TO KEEP MAVEN CENTERED
  if (*pstate).camera_view eq 1 then begin

    v1 = [0.0,0.0,1.0]
    v2 = (*pstate).maven_location[0:2]

    axis = crossp(v1,v2)
    angle = acos( transpose(v1)#v2 $
      / ( sqrt(total(v1^2)) * sqrt(total(v2^2)) ) $
      ) * !radeg
    ;    print,axis
    ;    print,angle
    ;rotate everything around to the right location
    (*pstate).maven_model->rotate,axis,-angle
    (*pstate).model->rotate,axis,-angle
    (*pstate).atmModel1->rotate,axis,-angle
    (*pstate).atmModel2->rotate,axis,-angle
    (*pstate).atmModel3->rotate,axis,-angle
    (*pstate).atmModel4->rotate,axis,-angle
    (*pstate).atmModel5->rotate,axis,-angle
    (*pstate).atmModel6->rotate,axis,-angle
    (*pstate).gridlines -> rotate,axis,-angle
    (*pstate).orbit_model -> rotate,axis,-angle
    (*pstate).sub_solar_model->rotate,axis,-angle
    (*pstate).sub_maven_model->rotate,axis,-angle
    (*pstate).vector_model->rotate,axis,-angle
    (*pstate).axesmodel -> rotate,axis,-angle
    if (*pstate).instrument_array[8] eq 1 then begin
      (*pstate).periapse_limb_model ->rotate,axis,-angle
    endif
    ;
    ;update the maven location
    (*pstate).maven_location[0:2] = [0.0,0.0,1.0]
  endif

  ;IF APOAPSE IMAGES ARE DISPLAYED AS A SINGLE FRAME
  ;(APOPAPSE_BLEND = 0) THEN UPDATE
  if (*pstate).instrument_array[9] eq 1 then begin
    if (*pstate).apoapse_blend eq 0 then begin
      if (*pstate).mars_base_map eq 'apoapse' then begin
        image = bytarr(3,90,45)
        time = (*pstate).insitu[(*pstate).time_index].time_string
        case (*pstate).apoapse_image_choice of
          'Ozone Depth': $
            MVN_KP_3D_APOAPSE_IMAGES, $
            (*pstate).iuvs.apoapse.ozone_depth, image, $
            (*pstate).apoapse_blend, time, $
            (*pstate).iuvs.apoapse.time_start, $
            (*pstate).iuvs.apoapse.time_stop, $
            (*pstate).apo_time_blend
          'Dust Depth' : $
            MVN_KP_3D_APOAPSE_IMAGES, $
            (*pstate).iuvs.apoapse.dust_depth, image, $
            (*pstate).apoapse_blend, time, $
            (*pstate).iuvs.apoapse.time_start, $
            (*pstate).iuvs.apoapse.time_stop, $
            (*pstate).apo_time_blend
          'Radiance Map: H': $
            begin
            sizes = size((*pstate).iuvs.apoapse.radiance[0,*,*])
            input_data = fltarr(sizes(2),sizes(3),sizes(4))
            for i=0,sizes(4)-1 do begin
              input_data[*,*,i] = (*pstate).iuvs[i].apoapse.$
                radiance[0,*,*]
            endfor
            MVN_KP_3D_APOAPSE_IMAGES, input_data, image, $
              (*pstate).apoapse_blend, time, $
              (*pstate).iuvs.apoapse.time_start, $
              (*pstate).iuvs.apoapse.time_stop, $
              (*pstate).apo_time_blend
          end
          'Radiance Map: O_1304': $
            begin
            sizes = size((*pstate).iuvs.apoapse.radiance[1,*,*])
            input_data = fltarr(sizes(2),sizes(3),sizes(4))
            for i=0,sizes(4)-1 do begin
              input_data[*,*,i] = (*pstate).iuvs[i].apoapse.$
                radiance[1,*,*]
            endfor
            MVN_KP_3D_APOAPSE_IMAGES, input_data, image, $
              (*pstate).apoapse_blend, time, $
              (*pstate).iuvs.apoapse.time_start, $
              (*pstate).iuvs.apoapse.time_stop, $
              (*pstate).apo_time_blend
          end
          'Radiance Map: CO': $
            begin
            sizes = size((*pstate).iuvs.apoapse.radiance[2,*,*])
            input_data = fltarr(sizes(2),sizes(3),sizes(4))
            for i=0,sizes(4)-1 do begin
              input_data[*,*,i] = (*pstate).iuvs[i].apoapse.$
                radiance[2,*,*]
            endfor
            MVN_KP_3D_APOAPSE_IMAGES, input_data, image, $
              (*pstate).apoapse_blend, time, $
              (*pstate).iuvs.apoapse.time_start, $
              (*pstate).iuvs.apoapse.time_stop, $
              (*pstate).apo_time_blend
          end
          'Radiance Map: NO': $
            begin
            sizes = size((*pstate).iuvs.apoapse.radiance[3,*,*])
            input_data = fltarr(sizes(2),sizes(3),sizes(4))
            for i=0,sizes(4)-1 do begin
              input_data[*,*,i] = (*pstate).iuvs[i].apoapse.$
                radiance[3,*,*]
            endfor
            MVN_KP_3D_APOAPSE_IMAGES, input_data, image, $
              (*pstate).apoapse_blend, time, $
              (*pstate).iuvs.apoapse.time_start, $
              (*pstate).iuvs.apoapse.time_stop, $
              (*pstate).apo_time_blend
          end
        endcase
        oImage = OBJ_NEW('IDLgrImage', image )
        (*pstate).opolygons -> setproperty, texture_map=oimage
      endif ; mars_base_map eq apoapse
    endif   ; apoapse blend eq 0
  endif     ; instrument_array[9] = 1

  ;FINALLY, REDRAW THE SCENE

  (*pstate).window->draw, (*pstate).view
  return
end
