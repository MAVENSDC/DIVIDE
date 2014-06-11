
pro mvn_kp_3d_event, event

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  widget_control, event.top, get_uvalue=pstate
  uname = widget_info(event.id,/uname)
  
    IF TAG_NAMES(Event, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
        WIDGET_CONTROL, Event.top, GET_UVALUE=(*pState)

       ; Destroy the objects.
       OBJ_DESTROY, (*pstate).window
       WIDGET_CONTROL, Event.top, /DESTROY
       RETURN
    ENDIF
  
  
  case uname of 
    'draw': begin
              if (*pstate).camera_view eq 0 then begin
                 ; rotate
                translate = event.modifiers and 1
                update = (*pstate).track->update(event, transform=rotTransform, translate=translate)
                              
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
                  (*pstate).axesmodel_msox->getproperty,transform=xaxesTrans
                  (*pstate).axesmodel_msoy->getproperty,transform=yaxesTrans
                  (*pstate).axesmodel_msoz->getproperty,transform=zaxesTrans
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
                  newYaxes = yAxesTrans # rotTransform
                  newZaxes = zAxesTrans # rotTransform
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
                  (*pstate).axesmodel_msox->setProperty, transform=newXaxes
                  (*pstate).axesmodel_msoy->setProperty, transform=newYaxes
                  (*pstate).axesmodel_msoz->setProperty, transform=newZaxes
                  if (*pstate).instrument_array[8] eq 1 then begin
                    (*pstate).periapse_limb_model->getProperty,transform=periTrans
                    newPeriTrans = periTrans # rotTransform
                    (*pstate).periapse_limb_model ->setproperty, transform=newPeriTrans
                  endif
                  (*pstate).maven_location = (*pstate).maven_location#rotTransform
                  (*pstate).z_position = (*pstate).z_position#rotTransform
                  
                  (*pstate).window->draw, (*pstate).view          
                endif
             endif       ;end of camera view check     
                ; scale
                if (event.type eq 7) then begin
                  s = 1.07 ^ event.clicks
              
                  if (((*pstate).z_position(3) ge 0.25) and ((*pstate).z_position(3) le 10.0)) $
                    or (((*pstate).z_position(3) le 0.25) and (s ge 1.0)) $
                    or (((*pstate).z_position(3) ge 10.0) and (s le 1.0)) then begin
                    
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
                    (*pstate).axesmodel_msox->scale, s,s,s
                    (*pstate).axesmodel_msoy->scale, s,s,s
                    (*pstate).axesmodel_msoz->scale, s,s,s
                    if (*pstate).instrument_array[8] eq 1 then begin
                      (*pstate).periapse_limb_model->scale,s,s,s
                    endif
                    (*pstate).maven_location = (*pstate).maven_location*s
                    (*pstate).z_position = (*pstate).z_position*s
                    (*pstate).window->draw, (*pstate).view       
                  endif 
                endif       
           
            end
    'mars': begin
              widget_control, (*pstate).subbaseR1, map=0
              widget_control, (*pstate).subbaseR2, map=1
            end
    'mars_return': begin
                    widget_control, (*pstate).subbaseR2, map=0
                    widget_control, (*pstate).subbaseR1, map=1
                   end
    'animation': begin
                    widget_control, (*pstate).subbaseR1, map=0
                    widget_control, (*pstate).subbaseR9, map=1
                 end
                 
     'anim_return': begin
                      widget_control, (*pstate).subbaseR9, map=0
                      widget_control, (*pstate).subbaseR1, map=1
                    end
     'time': begin
                widget_control, event.id, get_value=newval
               
                ;MOVE THE SPACECRAFT MODEL TO IT'S NEW LOCATION
                  t = min(abs(((*pstate).insitu.time - newval)),t_index)

     ;             data = *(*pstate).orbit_path.data
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
                  (*pstate).paratext1->setProperty,strings='Distance to Sun:'+strtrim(string((*pstate).insitu(t_index).spacecraft.mars_sun_distance),2)+' AU'
                  (*pstate).paratext2->setProperty,strings='Mars Season:'+strtrim(string((*pstate).insitu(t_index).spacecraft.mars_season),2)
                  (*pstate).paratext3->setProperty,strings='MAVEN Altitude:'+strtrim(string((*pstate).insitu(t_index).spacecraft.altitude),2)
                  (*pstate).paratext4->setProperty,strings='Solar Zenith Angle:'+strtrim(string((*pstate).insitu(t_index).spacecraft.sza),2)
                  (*pstate).paratext5->setProperty,strings='Local Time:'+strtrim(string((*pstate).insitu(t_index).spacecraft.local_time),2)
                  (*pstate).paratext6->setProperty,strings='SubMaven Lat:'+strtrim(string((*pstate).insitu(t_index).spacecraft.sub_sc_latitude),2)
                  (*pstate).paratext7->setProperty,strings='SubMaven Lon:'+strtrim(string((*pstate).insitu(t_index).spacecraft.sub_sc_longitude),2)
                  (*pstate).timetext->setProperty,strings=time_string(newval,format=0)
                  (*pstate).plottext1->getproperty,strings=temp_string
                  if temp_string ne '' then begin
                    (*pstate).plottext2->setProperty, strings = strtrim(string((*pstate).insitu(t_index).((*pstate).level0_index).((*pstate).level1_index)),2)
                  endif
                  
                ;MOVE THE SUN'S LIGHT SOURCE TO THE PROPER LOCATION
                if (*pstate).coord_sys eq 0 then begin        ;GEO COORDINATE SYSTEM
                  (*pstate).dirlight->setProperty,location=[(*pstate).solar_x_coord(t_index),(*pstate).solar_y_coord(t_index),(*pstate).solar_z_coord(t_index)]
                ;UPDATE THE SUBSOLAR POINT
                 (*pstate).sub_solar_line->setProperty,data=[(*pstate).subsolar_x_coord[t_index],(*pstate).subsolar_y_coord[t_index],(*pstate).subsolar_z_coord[t_index]]
                ;UPDATE THE SUBMAVEN POINT  
                 (*pstate).sub_maven_line->setProperty,data=[(*pstate).submaven_x_coord[t_index],(*pstate).submaven_y_coord[t_index],(*pstate).submaven_z_coord[t_index]]
                ;UPDATE THE SUN VECTOR
                  (*pstate).sun_vector -> getproperty, data=data1
                  data1[0,1] = (*pstate).solar_x_coord(t_index)
                  data1[1,1] = (*pstate).solar_y_coord(t_index)
                  data1[2,1] = (*pstate).solar_z_coord(t_index)
                  (*pstate).sun_vector->setProperty,data=data1
                ;UPDATE THE MSO AXES, EVEN THOUGH THEY'RE HIDDEN
                  lon1 = (*pstate).insitu(t_index).spacecraft.subsolar_point_geo_longitude 
                  lon2 = (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude
                 (*pstate).axesModel_msox->rotate, [0,0,1], lon2-lon1
                 (*pstate).axesModel_msoy->rotate, [0,0,1], lon2-lon1
      
                endif else begin                              ;MSO COORDINATE DISPLAY
                  lon1 = (*pstate).insitu(t_index).spacecraft.subsolar_point_geo_longitude 
                  lon2 = (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude

                  (*pstate).sub_maven_line_mso->setproperty,data=[(*pstate).submaven_x_coord_mso[t_index],(*pstate).submaven_y_coord_mso[t_index],(*pstate).submaven_z_coord_mso[t_index]]
                  (*pstate).mars_globe -> rotate, [0,0,1], lon2-lon1
                 (*pstate).axesmodel-> rotate, [0,0,1], lon2-lon1
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
   ;               ;UPDATE THE IUVS PERIAPSE ALTITUDE PLOT
                   MVN_KP_3D_CURRENT_PERIAPSE, (*pstate).iuvs.periapse, (*pstate).insitu[t_index].time, peri_data, (*pstate).periapse_limb_scan, xlabel
                   (*pstate).alt_xaxis_title->setproperty,strings=xlabel
                   (*pstate).alt_plot->setproperty,datax=peri_data[1,*]
                   (*pstate).alt_plot->setproperty,datay=peri_data[0,*]
                   (*pstate).alt_plot->setproperty,xrange=[min(peri_data[1,*]),max(peri_data[1,*])]
                   (*pstate).alt_plot->getproperty, xrange=xr, yrange=yr
                   xc = mg_linear_function(xr, [-1.75,-1.5])
                   yc = mg_linear_function(yr, [-1.3,1.0])
                   (*pstate).alt_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                   (*pstate).alt_xaxis_ticks->setproperty,strings=strtrim(string([min(peri_data[1,*]),max(peri_data[1,*])], format='(E8.2)'),2)       
                 endif
                  
                 (*pstate).time_index = t_index 
                  
                 ;IF THE SCENE IS SPACECRAFT LOCKED, ROTATE EVERYTHING TO KEEP MAVEN CENTERED
                 if (*pstate).camera_view eq 1 then begin

                     v1 = [0.0,0.0,1.0]
                     v2 = (*pstate).maven_location[0:2]

                     axis = crossp(v1,v2)
                     angle = acos( transpose(v1)#v2 / sqrt(total(v1^2)) / sqrt(total(v2^2)) ) * 180./!pi 
      ;              print,axis
      ;              print,angle
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
                      endif;;
;
;                      ;update the maven location 
                     (*pstate).maven_location[0:2] = [0.0,0.0,1.0]
                 endif 
              
                 ;IF APOAPSE IMAGES ARE DISPLAYED AS A SINGLE FRAME (APOPAPSE_BLEND = 0) THEN UPDATE
                 if (*pstate).instrument_array[9] eq 1 then begin
                   if (*pstate).apoapse_blend eq 0 then begin
                    if (*pstate).mars_base_map eq 'apoapse' then begin
                      image = bytarr(3,90,45)
                      time = (*pstate).insitu[(*pstate).time_index].time_string
                      case (*pstate).apoapse_image_choice of 
                                'Ozone Depth': MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.ozone_depth, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                'Dust Depth' : MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.dust_depth, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                'Radiance Map: H': begin
                                                      sizes = size((*pstate).iuvs.apoapse.radiance[0,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[0,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                   end
                                'Radiance Map: O_1304': begin
                                                            sizes = size((*pstate).iuvs.apoapse.radiance[1,*,*])
                                                            input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                            for i=0,sizes(4)-1 do begin
                                                              input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[1,*,*]
                                                            endfor
                                                            MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                         end  
                                'Radiance Map: CO': begin
                                                      sizes = size((*pstate).iuvs.apoapse.radiance[2,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[2,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                   end
                                'Radiance Map: NO': begin
                                                      sizes = size((*pstate).iuvs.apoapse.radiance[3,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[3,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                   end
                              endcase                           
                      oImage = OBJ_NEW('IDLgrImage', image )
                      (*pstate).opolygons -> setproperty, texture_map=oimage
                     endif  
                   endif
                 endif
                  
                  
                ;FINALLY, REDRAW THE SCENE  
           
                (*pstate).window->draw, (*pstate).view
             end                   
                 
     'timestep_define': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).time_step_size = fix(newval)
                        end
     'timeminusone': begin
                        mvn_kp_3d_time_increment, (*pstate), -(*pstate).time_step_size
                        (*pstate).window->draw, (*pstate).view
                        widget_control,(*pstate).timeline,set_value=(*pstate).insitu[(*pstate).time_index].time
                     end
     'timeplusone':  begin
                        mvn_kp_3d_time_increment, (*pstate), (*pstate).time_step_size
                        (*pstate).window->draw, (*pstate).view
                        widget_control,(*pstate).timeline,set_value=(*pstate).insitu[(*pstate).time_index].time
                     end
                 
     'basemap1': begin
              widget_control,event.id,get_value=newval
              
              case newval of 
                'BLANK': begin
                          ;START WITH A WHITE GLOBE
                            image = bytarr(3,2048,1024)
                            image[*,*,*] = 255
                            oImage = OBJ_NEW('IDLgrImage', image )
                            (*pstate).mars_base_map = 'blank'
                            (*pstate).opolygons -> setproperty, texture_map=oimage
                            (*pstate).gridlines -> setProperty, hide=0
                            (*pstate).window ->draw,(*pstate).view
                        end
                'MDIM': begin 
                          read_jpeg,(*pstate).bm_install_directory+'MDIM_2500x1250.jpg',image
                          oImage = OBJ_NEW('IDLgrImage', image )
                          (*pstate).mars_base_map = 'mdim'
                          (*pstate).opolygons -> setproperty, texture_map=oimage
                          (*pstate).window->draw, (*pstate).view 
                        end
                'MOLA': begin
                          read_jpeg,(*pstate).bm_install_directory+'MOLA_color_2500x1250.jpg',image
                          oImage = OBJ_NEW('IDLgrImage', image )
                          (*pstate).mars_base_map = 'mola'
                          (*pstate).opolygons -> setproperty, texture_map=oimage
                          (*pstate).window->draw, (*pstate).view 
                        end
                'MOLA_BW': begin
                             read_jpeg,(*pstate).bm_install_directory+'MOLA_BW_2500x1250.jpg',image
                             oImage = OBJ_NEW('IDLgrImage', image )
                             (*pstate).mars_base_map = 'mola_bw'
                             (*pstate).opolygons -> setproperty, texture_map=oimage
                             (*pstate).window->draw, (*pstate).view 
                           end
                'MAG': begin
                         read_jpeg,(*pstate).bm_install_directory+'Mars_Crustal_Magnetism_MGS.jpg',image
                         oImage = OBJ_NEW('IDLgrImage', image )
                         (*pstate).mars_base_map = 'mag'
                         (*pstate).opolygons -> setproperty, texture_map=oimage
                         (*pstate).window->draw, (*pstate).view
                       end
                'User Defined': begin
                                  input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.jpg')
                                  if input_file ne '' then begin
                                    read_jpeg,input_file,image
                                    oImage = OBJ_NEW('IDLgrImage', image )
                                    (*pstate).mars_base_map = 'user'
                                    (*pstate).opolygons -> setproperty, texture_map=oimage
                                    (*pstate).window->draw, (*pstate).view
                                  endif
                                end
              
              endcase
             end 
       'grid': begin
                (*pstate).gridlines.getProperty, HIDE=result
                if result eq 1 then (*pstate).gridlines -> setProperty,hide=0
                if result eq 0 then (*pstate).gridlines -> setProperty,hide=1
                (*pstate).window -> draw, (*pstate).view
               end
               
       'subsolar': begin

                    (*pstate).sub_solar_model.getProperty, HIDE=result
                    if result eq 1 then (*pstate).sub_solar_model -> setProperty,hide=0
                    if result eq 0 then (*pstate).sub_solar_model -> setProperty,hide=1
                    (*pstate).window -> draw, (*pstate).view
                   end
                  
       'submaven': begin
                    (*pstate).sub_maven_model.getProperty, HIDE=result
                    if (*pstate).coord_sys eq 0 then begin
                      if result eq 1 then (*pstate).sub_maven_model -> setProperty,hide=0
                      if result eq 0 then (*pstate).sub_maven_model -> setProperty,hide=1
                    endif 
                    if (*pstate).coord_sys eq 1 then begin
                      if result eq 1 then (*pstate).sub_maven_model_mso -> setProperty,hide=0
                      if result eq 0 then (*pstate).sub_maven_model_mso -> setProperty,hide=1
                    endif
                    (*pstate).window -> draw, (*pstate).view
                   end
               
       'terminator': begin
                      t1 = dialog_message('Not yet implemented',/information)
;                      (*pstate).terminator.getProperty, HIDE=result
;                      if result eq 1 then (*pstate).terminator -> setProperty,hide=0
;                      if result eq 0 then (*pstate).terminator -> setProperty,hide=1
                      (*pstate).window -> draw, (*pstate).view
                     end

       'sunvector': begin
                      (*pstate).sun_model.getProperty, HIDE=result
                      if result eq 1 then (*pstate).sun_model -> setProperty,hide=0
                      if result eq 0 then (*pstate).sun_model -> setProperty,hide=1
                      (*pstate).window -> draw, (*pstate).view
                     end

       'axes': begin
                      if (*pstate).coord_sys eq 0 then begin
                        (*pstate).axesmodel.getProperty, HIDE=result
                        if result eq 1 then (*pstate).axesmodel -> setProperty,hide=0
                        if result eq 0 then (*pstate).axesmodel -> setProperty,hide=1
                      endif
                      if (*pstate).coord_sys eq 1 then begin
                        (*pstate).axesmodel_msox.getProperty, HIDE=result
                        if result eq 1 then begin
                          (*pstate).axesmodel_msox->setproperty,hide=0
                          (*pstate).axesmodel_msoy->setproperty,hide=0
                          (*pstate).axesmodel_msoz->setproperty,hide=0
                        endif
                        if result eq 0 then begin
                          (*pstate).axesmodel_msox->setproperty,hide=1
                          (*pstate).axesmodel_msoy->setproperty,hide=1
                          (*pstate).axesmodel_msoz->setproperty,hide=1
                        endif
                      endif
                      (*pstate).window -> draw, (*pstate).view
                     end      

       'parameters': begin
                      (*pstate).parameterModel.getProperty, HIDE=result
                      if result eq 1 then (*pstate).parameterModel->setProperty,hide=0
                      if result eq 0 then (*pstate).parameterModel->setProperty,hide=1
                      (*pstate).window ->draw,(*pstate).view
                     end          

       'background_color': begin
                                widget_control, event.id, get_value=newval
                                (*pstate).view->setProperty,color=newval
                                (*pstate).window ->draw,(*pstate).view
                           end
       'ambient': begin
                    widget_control,event.id, get_value=newval
                    (*pstate).ambientlight->setProperty,intensity=newval/100.0
                    (*pstate).window->draw,(*pstate).view
                  end
                            
                            
       'views': begin
                  widget_control,(*pstate).subbaseR1, map=0
                  widget_control,(*pstate).subbaseR3, map=1
               end
       
       'view_return': begin
                    widget_control, (*pstate).subbaseR3, map=0
                    widget_control, (*pstate).subbaseR1, map=1
                   end
               
       'models': begin
                  widget_control,(*pstate).subbaseR1, map=0
                  widget_control,(*pstate).subbaseR4, map=1
                 end

       'model_return': begin
                    widget_control, (*pstate).subbaseR4, map=0
                    widget_control, (*pstate).subbaseR1, map=1
                   end
       
       'atmLevel1': begin
                      result = widget_info((*pstate).button41a, /sensitive)
                      if result eq 0 then begin
                        widget_control, (*pstate).button41a, sensitive=1
                        widget_control, (*pstate).button41b, sensitive=1
                        widget_control, (*pstate).button41c, sensitive=1
                          (*pstate).atmModel1 -> setProperty, hide=0
                          (*pstate).window->draw, (*pstate).view 
                      endif
                      if result eq 1 then begin
                        widget_control, (*pstate).button41a, sensitive=0
                        widget_control, (*pstate).button41b, sensitive=0
                        widget_control, (*pstate).button41c, sensitive=0
                        (*pstate).atmModel1 -> setProperty, hide=1
                        (*pstate).window->draw,(*pstate).view
                      endif
                    end
                    
       'atmLevel1Load': begin
                          input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.png')
                           if input_file ne '' then begin
                            read_png,input_file,image
                            oImage1 = OBJ_NEW('IDLgrImage', image )
                            (*pstate).opolygons1 -> setproperty, texture_map=oimage1
                            (*pstate).opolygons1 -> setProperty, alpha_channel=((*pstate).atmLevel1alpha)/100.0
                            (*pstate).window->draw,(*pstate).view
                           endif
                        end
                        
       'atmLevel1alpha': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).atmLevel1alpha = newval
                          (*pstate).opolygons1 -> setProperty, alpha_channel=((*pstate).atmLevel1alpha)/100.0
                          (*pstate).window->draw, (*pstate).view                           
                         end
                         
       'atmLevel1height': begin
                            widget_control, event.id, get_value=newval
                            (*pstate).atmModel1->GetProperty,transform=curtrans
                            new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel1height))
                            (*pstate).atmLevel1height=newval
                            (*pstate).atmModel1->scale,new_scale,new_scale,new_scale
                            (*pstate).window->draw,(*pstate).view
                          end
       
       'atmLevel2': begin
                      result = widget_info((*pstate).button42a, /sensitive)
                      if result eq 0 then begin
                        widget_control, (*pstate).button42a, sensitive=1
                        widget_control, (*pstate).button42b, sensitive=1
                        widget_control, (*pstate).button42c, sensitive=1
                          (*pstate).atmModel2 -> setProperty, hide=0
                          (*pstate).window->draw, (*pstate).view 
                      endif
                      if result eq 1 then begin
                        widget_control, (*pstate).button42a, sensitive=0
                        widget_control, (*pstate).button42b, sensitive=0
                        widget_control, (*pstate).button42c, sensitive=0
                        (*pstate).atmModel2 -> setProperty, hide=1
                        (*pstate).window->draw,(*pstate).view
                      endif
                    end
                    
       'atmLevel2Load': begin
                          input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.png')
                          if input_file ne '' then begin
                            read_png,input_file,image
                            oImage2 = OBJ_NEW('IDLgrImage', image )
                            (*pstate).opolygons2 -> setproperty, texture_map=oimage2
                            (*pstate).opolygons2 -> setProperty, alpha_channel=((*pstate).atmLevel2alpha)/100.0
                            (*pstate).window->draw,(*pstate).view
                          endif
                        end
                        
       'atmLevel2alpha': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).atmLevel2alpha = newval
                          (*pstate).opolygons2 -> setProperty, alpha_channel=((*pstate).atmLevel2alpha)/100.0
                          (*pstate).window->draw, (*pstate).view                           
                         end    
                         
       'atmLevel2height': begin
                            widget_control, event.id, get_value=newval
                            new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel2height))
                            (*pstate).atmLevel2height=fix(newval)
                            (*pstate).atmModel2->scale,new_scale,new_scale,new_scale
                            (*pstate).window->draw,(*pstate).view
                          end                  
                         
       'atmLevel3': begin
                      result = widget_info((*pstate).button43a, /sensitive)
                      if result eq 0 then begin
                        widget_control, (*pstate).button43a, sensitive=1
                        widget_control, (*pstate).button43b, sensitive=1
                        widget_control, (*pstate).button43c, sensitive=1
                          (*pstate).atmModel3 -> setProperty, hide=0
                          (*pstate).window->draw, (*pstate).view 
                      endif
                      if result eq 1 then begin
                        widget_control, (*pstate).button43a, sensitive=0
                        widget_control, (*pstate).button43b, sensitive=0
                        widget_control, (*pstate).button43c, sensitive=0
                        (*pstate).atmModel3 -> setProperty, hide=1
                        (*pstate).window->draw,(*pstate).view
                      endif
                    end
                    
       'atmLevel3Load': begin
                          input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.png')
                          if input_file ne '' then begin
                          read_png,input_file,image
                            oImage3 = OBJ_NEW('IDLgrImage', image )
                            (*pstate).opolygons3 -> setproperty, texture_map=oimage3
                            (*pstate).opolygons3 -> setProperty, alpha_channel=((*pstate).atmLevel3alpha)/100.0
                            (*pstate).window->draw,(*pstate).view
                          endif
                        end
                        
       'atmLevel3alpha': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).atmLevel3alpha = newval
                          (*pstate).opolygons3 -> setProperty, alpha_channel=((*pstate).atmLevel3alpha)/100.0
                          (*pstate).window->draw, (*pstate).view                           
                         end  

       'atmLevel3height': begin
                            widget_control, event.id, get_value=newval
                            new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel3height))
                            (*pstate).atmLevel3height=fix(newval)
                            (*pstate).atmModel3->scale,new_scale,new_scale,new_scale
                            (*pstate).window->draw,(*pstate).view
                          end
                         
       'atmLevel4': begin
                      result = widget_info((*pstate).button44a, /sensitive)
                      if result eq 0 then begin
                        widget_control, (*pstate).button44a, sensitive=1
                        widget_control, (*pstate).button44b, sensitive=1
                        widget_control, (*pstate).button44c, sensitive=1
                          (*pstate).atmModel4 -> setProperty, hide=0
                          (*pstate).window->draw, (*pstate).view 
                      endif
                      if result eq 1 then begin
                        widget_control, (*pstate).button44a, sensitive=0
                        widget_control, (*pstate).button44b, sensitive=0
                        widget_control, (*pstate).button44c, sensitive=0
                        (*pstate).atmModel4 -> setProperty, hide=1
                        (*pstate).window->draw,(*pstate).view
                      endif
                    end
                    
       'atmLevel4Load': begin
                          input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.png')
                          if input_file ne '' then begin
                            read_png,input_file,image
                            oImage4 = OBJ_NEW('IDLgrImage', image )
                            (*pstate).opolygons4 -> setproperty, texture_map=oimage4
                            (*pstate).opolygons4 -> setProperty, alpha_channel=((*pstate).atmLevel4alpha)/100.0
                            (*pstate).window->draw,(*pstate).view
                          endif
                        end
                        
       'atmLevel4alpha': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).atmLevel4alpha = newval
                          (*pstate).opolygons4 -> setProperty, alpha_channel=((*pstate).atmLevel4alpha)/100.0
                          (*pstate).window->draw, (*pstate).view                           
                         end  

       'atmLevel4height': begin
                            widget_control, event.id, get_value=newval
                            new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel4height))
                            (*pstate).atmLevel4height=fix(newval)
                            (*pstate).atmModel4->scale,new_scale,new_scale,new_scale
                            (*pstate).window->draw,(*pstate).view
                          end
                         
       'atmLevel5': begin
                      result = widget_info((*pstate).button45a, /sensitive)
                      if result eq 0 then begin
                        widget_control, (*pstate).button45a, sensitive=1
                        widget_control, (*pstate).button45b, sensitive=1
                        widget_control, (*pstate).button45c, sensitive=1
                          (*pstate).atmModel5 -> setProperty, hide=0
                          (*pstate).window->draw, (*pstate).view 
                      endif
                      if result eq 1 then begin
                        widget_control, (*pstate).button45a, sensitive=0
                        widget_control, (*pstate).button45b, sensitive=0
                        widget_control, (*pstate).button45c, sensitive=0
                        (*pstate).atmModel5 -> setProperty, hide=1
                        (*pstate).window->draw,(*pstate).view
                      endif
                    end
                    
       'atmLevel5Load': begin
                          input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.png')
                          if input_file ne '' then begin
                            read_png,input_file,image
                            oImage5 = OBJ_NEW('IDLgrImage', image )
                            (*pstate).opolygons5 -> setproperty, texture_map=oimage5
                            (*pstate).opolygons5 -> setProperty, alpha_channel=((*pstate).atmLevel5alpha)/100.0
                            (*pstate).window->draw,(*pstate).view
                          endif
                        end
                        
       'atmLevel5alpha': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).atmLevel5alpha = newval
                          (*pstate).opolygons5 -> setProperty, alpha_channel=((*pstate).atmLevel5alpha)/100.0
                          (*pstate).window->draw, (*pstate).view                           
                         end

       'atmLevel5height': begin
                            widget_control, event.id, get_value=newval
                            new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel5height))
                            (*pstate).atmLevel5height=fix(newval)
                            (*pstate).atmModel5->scale,new_scale,new_scale,new_scale
                            (*pstate).window->draw,(*pstate).view
                          end
                         
       'atmLevel6': begin
                      result = widget_info((*pstate).button46a, /sensitive)
                      if result eq 0 then begin
                        widget_control, (*pstate).button46a, sensitive=1
                        widget_control, (*pstate).button46b, sensitive=1
                        widget_control, (*pstate).button46c, sensitive=1
                          (*pstate).atmModel6 -> setProperty, hide=0
                          (*pstate).window->draw, (*pstate).view 
                      endif
                      if result eq 1 then begin
                        widget_control, (*pstate).button46a, sensitive=0
                        widget_control, (*pstate).button46b, sensitive=0
                        widget_control, (*pstate).button46c, sensitive=0
                        (*pstate).atmModel6 -> setProperty, hide=1
                        (*pstate).window->draw,(*pstate).view
                      endif
                    end
                    
       'atmLevel6Load': begin
                          input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.png')
                          if input_file ne '' then begin
                            read_png,input_file,image
                            oImage6 = OBJ_NEW('IDLgrImage', image )
                            (*pstate).opolygons6 -> setproperty, texture_map=oimage6
                            (*pstate).opolygons6 -> setProperty, alpha_channel=((*pstate).atmLevel6alpha)/100.0
                            (*pstate).window->draw,(*pstate).view
                          endif
                        end
                        
       'atmLevel6alpha': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).atmLevel6alpha = newval
                          (*pstate).opolygons6 -> setProperty, alpha_channel=((*pstate).atmLevel6alpha)/100.0
                          (*pstate).window->draw, (*pstate).view                           
                         end             
                         
       'atmLevel6height': begin
                            widget_control, event.id, get_value=newval
                            new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel6height))
                            (*pstate).atmLevel6height=fix(newval)
                            (*pstate).atmModel6->scale,new_scale,new_scale,new_scale
                            (*pstate).window->draw,(*pstate).view
                          end                         
                                                                                                                                           
       'output': begin
                  widget_control,(*pstate).subbaseR1, map=0
                  widget_control,(*pstate).subbaseR5, map=1
                 end
                 
       'output_return': begin
                    widget_control, (*pstate).subbaseR5, map=0
                    widget_control, (*pstate).subbaseR1, map=1
                   end                 
          
       'insitu_return': begin
                          widget_control, (*pstate).subbaseR7, map=0
                          widget_control, (*pstate).subbaseR1, map=1
                         end    

       'insitu': begin
                  widget_control,(*pstate).subbaseR1, map=0
                  widget_control,(*pstate).subbaseR7, map=1
               end

       'insitu_vector': begin
                          widget_control, (*pstate).subbaseR1, map=0
                          widget_control, (*pstate).subbaseR10, map=1
                        end
                        
       'vec_scale': begin
                      widget_control,event.id, get_value=newval
                      scale_factor=newval/100.0
                      ;RESCALE THE DISPLAYED VECTOR FIELD
                      (*pstate).vector_path->getproperty,data=old_data
                      
                      MVN_KP_3D_VECTOR_SCALE, old_data, (*pstate).vector_scale, scale_factor
                      
                      (*pstate).vector_path->setproperty,data=old_data
                      (*pstate).vector_scale = scale_factor
                      (*pstate).window->draw,(*pstate).view   
                    end
                        
       'insitu_vector_return': begin
                                widget_control, (*pstate).subbaseR10, map=0
                                widget_control, (*pstate).subbaseR1, map=1
                               end

       'iuvs_return': begin
                    widget_control, (*pstate).subbaseR8, map=0
                    widget_control, (*pstate).subbaseR1, map=1
                   end    

       'iuvs': begin
                  widget_control,(*pstate).subbaseR1, map=0
                  widget_control,(*pstate).subbaseR8, map=1
               end

       'help': begin
                  widget_control,(*pstate).subbaseR1, map=0
                  widget_control,(*pstate).subbaseR6, map=1
                  
                  widget_control,(*pstate).text, set_value='Fear not, help is on the way.'
                  widget_control,(*pstate).text, set_value='',/append
                  widget_control,(*pstate).text, set_value='',/append
                  widget_control,(*pstate).text, set_value='Someday.',/append
                  widget_control,(*pstate).text, set_value='',/append
                  widget_control,(*pstate).text, set_value='',/append
                  widget_control,(*pstate).text, set_value='',/append
                  widget_control,(*pstate).text, set_value='',/append
                  widget_control,(*pstate).text, set_value='but not today',/append
               end
        
       'help_return': begin
                        widget_control, (*pstate).subbaseR6, map=0
                        widget_control, (*pstate).subbaseR1, map=1
                      end      
       
       'config_save': begin
                          file = dialog_pickfile(/write, title="Pick a file to save your viz configuration",filter='*.sav')
                          
                          (*pstate).model->getproperty,transform=model_trans
    
                          config_struct = {config, model_trans:model_trans}
                          
                          save,config_struct,filename=file

                  
                      end
                    
       'config_load': begin
                          file = dialog_pickfile(/read, title="Restore a vizualization configuration", filter='*.sav')
                          
                          restore,file
                          
                          (*pstate).model->setproperty,transform = config_struct.model_trans
                          (*pstate).window->draw,(*pstate).view
                      end
                      
       'save_view': begin
                      outfile = dialog_pickfile(default_extension='png',/write)                                     
                      buffer = Obj_New('IDLgrBuffer', DIMENSIONS=[800,800])
                      buffer -> Draw, (*pstate).view
                      buffer -> GetProperty, Image_Data=snapshot
                      Obj_Destroy, buffer
                      write_png, outfile,snapshot
                    end
        
        'orbit_reset': begin
                          temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)
                          temp_vert[0,*] = 255
                          (*pstate).orbit_path->setProperty,vert_color=temp_vert
                          (*pstate).window->draw,(*pstate).view
                       end
        
        'lpw_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'LPW.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr       
                         ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin           
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                          (*pstate).parameter_yaxis_ticktext->setproperty,strings=[strtrim(string(fix(min((*pstate).insitu.(level0_index).(level1_index)))),2),strtrim(string(fix(max((*pstate).insitu.(level0_index).(level1_index)))),2)]
                      (*pstate).window->draw,(*pstate).view   
                    end           
           
        'static_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'STATIC.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr                  
                        ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                          (*pstate).parameter_yaxis_ticktext->setproperty,strings=[strtrim(string(fix(min((*pstate).insitu.(level0_index).(level1_index)))),2),strtrim(string(fix(max((*pstate).insitu.(level0_index).(level1_index)))),2)]
                      (*pstate).window->draw,(*pstate).view   
                       end    
                       
        'swia_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'SWIA.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=strtrim(string((*pstate).colorbar_ticks),2)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr     
                      ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin             
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                          (*pstate).parameter_yaxis_ticktext->setproperty,strings=[strtrim(string(fix(min((*pstate).insitu.(level0_index).(level1_index)))),2),strtrim(string(fix(max((*pstate).insitu.(level0_index).(level1_index)))),2)]
                      (*pstate).window->draw,(*pstate).view   
                     end
                     
        'swea_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'SWEA.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr      
                        ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin            
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                          (*pstate).parameter_yaxis_ticktext->setproperty,strings=[strtrim(string(fix(min((*pstate).insitu.(level0_index).(level1_index)))),2),strtrim(string(fix(max((*pstate).insitu.(level0_index).(level1_index)))),2)]
                      (*pstate).window->draw,(*pstate).view   
                     end 
                     
        'mag_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'MAG.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr    
                       ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                          (*pstate).parameter_yaxis_ticktext->setproperty,strings=[strtrim(string(fix(min((*pstate).insitu.(level0_index).(level1_index)))),2),strtrim(string(fix(max((*pstate).insitu.(level0_index).(level1_index)))),2)]
                      (*pstate).window->draw,(*pstate).view   
                    end
                    
        'sep_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'SEP.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr
                        ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin                  
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                      (*pstate).window->draw,(*pstate).view   
                    end
                    
        'ngims_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'NGIMS.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr    
                          ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin              
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                          (*pstate).parameter_yaxis_ticktext->setproperty,strings=[strtrim(string(fix(min((*pstate).insitu.(level0_index).(level1_index)))),2),strtrim(string(fix(max((*pstate).insitu.(level0_index).(level1_index)))),2)]
                      (*pstate).window->draw,(*pstate).view   
                      end

        'user_list': begin
                      mag_index = widget_info(event.id, /droplist_select)
                      widget_control, event.id, get_value=newval
                      parameter = 'USER.'+strtrim(string(newval[mag_index]))                      
                      MVN_KP_TAG_PARSER, (*pstate).insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
                      MVN_KP_TAG_VERIFY, (*pstate).insitu, parameter,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array             
                      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
                      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
                                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                      (*pstate).colorbar_ticks = new_ticks
                      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
                      (*pstate).level0_index = level0_index
                      (*pstate).level1_index = level1_index
                      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                      (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                      ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                      ;UPDATE THE PARAMETER PLOT 
                          (*pstate).parameter_plot->setproperty,datay=(*pstate).insitu.(level0_index).(level1_index)
                          (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr        
                          ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements((*pstate).insitu.(level0_index).(level1_index))-1 do begin
                              var1 = finite((*pstate).insitu[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                          if nan_error_check eq 1 then begin
                            xc = mg_linear_function(xr, [-1.7,1.4])
                            yc = mg_linear_function(yr, [-1.9,-1.5])
                            if finite(yc[0]) and finite(yc[1])  then begin
                              (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                            endif
                          endif else begin
                            print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS Nan. No data to display.
                          endelse
                          (*pstate).parameter_yaxis_ticktext->setproperty,strings=[strtrim(string(fix(min((*pstate).insitu.(level0_index).(level1_index)))),2),strtrim(string(fix(max((*pstate).insitu.(level0_index).(level1_index)))),2)]
                      (*pstate).window->draw,(*pstate).view   
                      end
                   
        'colortable': begin
                        xloadct,/silent,/use_current,group=(*pstate).base ,/modal
                        (*pstate).orbit_path->getproperty,vert_color=temp_vert
                        MVN_KP_3D_PATH_COLOR, (*pstate).insitu, (*pstate).level0_index, (*pstate).level1_index, (*pstate).path_color_table, temp_vert,$
                                              (*pstate).colorbar_ticks, (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                        (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                        ;CHANGE THE COLOR BAR SETTINGS
                          (*pstate).colorbar1->setproperty,red_Values=r_curr
                          (*pstate).colorbar1->setproperty,green_Values=g_curr
                          (*pstate).colorbar1->setproperty,blue_Values=b_curr
                          (*pstate).colorbar_ticktext->setproperty,strings=string((*pstate).colorbar_ticks)
                        (*pstate).window ->draw,(*pstate).view
                      end   
                      
        'ColorBarPlot': begin
                           (*pstate).colorbarmodel.getProperty, HIDE=result
                           if result eq 1 then (*pstate).colorbarmodel->setProperty,hide=0
                           if result eq 0 then (*pstate).colorbarmodel->setProperty,hide=1
                           (*pstate).window ->draw,(*pstate).view
                        end
             
        'orbitPlotName': begin
                           (*pstate).plottednamemodel.getProperty, HIDE=result
                           if result eq 1 then (*pstate).plottednamemodel->setProperty,hide=0
                           if result eq 0 then (*pstate).plottednamemodel->setProperty,hide=1
                           (*pstate).window ->draw,(*pstate).view
                         end
                         
        'vector_field': begin
                          index = widget_info(event.id, /droplist_select)
                          widget_control, event.id, get_value=newval
                          
                          ;; Make idl 8.2.2 happy - We found that dereferencing the pointer to the struct in each
                          ;; iteration of the for loop was very slow in 8.2.2
                          insitu_spec = (*pstate).insitu
                          
                          case newval(index) of
                            'Magnetic Field': begin
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
                            'SWIA H+ Flow Velocity': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      if (*pstate).coord_sys eq 0 then begin
                                       
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu_spec[i].swia.hplus_flow_v_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                (insitu_spec[i].swia.hplus_flow_v_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                (insitu_spec[i].swia.hplus_flow_v_msoz*insitu_spec[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu_spec[i].swia.hplus_flow_v_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                (insitu_spec[i].swia.hplus_flow_v_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                (insitu_spec[i].swia.hplus_flow_v_msoz*insitu_spec[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu_spec[i].swia.hplus_flow_v_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                (insitu_spec[i].swia.hplus_flow_v_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                (insitu_spec[i].swia.hplus_flow_v_msoz*insitu_spec[i].spacecraft.t33)
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
                          ;  'STATIC H+ Flow Velocity': begin
                          ;                              (*pstate).vector_path->getproperty,data=old_data
                          ;                              if (*pstate).coord_sys eq 0 then begin
                          ;                                for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                          ;                                  old_data[0,(i*2)+1] = (insitu_spec[i].static.hplus_flow_v_msox*insitu_spec[i].spacecraft.t11)+$
                          ;                                                        (insitu_spec[i].static.hplus_flow_v_msoy*insitu_spec[i].spacecraft.t12)+$
                          ;                                                        (insitu_spec[i].static.hplus_flow_v_msoz*insitu_spec[i].spacecraft.t13)
                          ;                                  old_data[1,(i*2)+1] = (insitu_spec[i].static.hplus_flow_v_msox*insitu_spec[i].spacecraft.t21)+$
                          ;                                                        (insitu_spec[i].static.hplus_flow_v_msoy*insitu_spec[i].spacecraft.t22)+$
                          ;                                                        (insitu_spec[i].static.hplus_flow_v_msoz*insitu_spec[i].spacecraft.t23)
                          ;                                  old_data[2,(i*2)+1] = (insitu_spec[i].static.hplus_flow_v_msox*insitu_spec[i].spacecraft.t31)+$
                          ;                                                        (insitu_spec[i].static.hplus_flow_v_msoy*insitu_spec[i].spacecraft.t32)+$
                          ;                                                        (insitu_spec[i].static.hplus_flow_v_msoz*insitu_spec[i].spacecraft.t33)
                          ;                                endfor
                          ;                              endif
                          ;                              if (*pstate).coord_sys eq 1 then begin
                          ;                                for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                          ;                                  old_data[0,(i*2)+1] = insitu_spec[i].static.hplus_flow_v_msox
                          ;                                  old_data[1,(i*2)+1] = insitu_spec[i].static.hplus_flow_v_msoy
                          ;                                  old_data[2,(i*2)+1] = insitu_spec[i].static.hplus_flow_v_msoz
                          ;                                endfor
                          ;                              endif
                          ;                              MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
                          ;                              (*pstate).vector_path->setproperty,data=old_data
                          ;                              (*pstate).window->draw,(*pstate).view
                          ;                             end
                            'STATIC O+ Flow Velocity': begin
                                                        (*pstate).vector_path->getproperty,data=old_data
                                                        if (*pstate).coord_sys eq 0 then begin
                                                          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                            old_data[0,(i*2)+1] = (insitu_spec[i].static.oplus_flow_v_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                  (insitu_spec[i].static.oplus_flow_v_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                  (insitu_spec[i].static.oplus_flow_v_msoz*insitu_spec[i].spacecraft.t13)
                                                            old_data[1,(i*2)+1] = (insitu_spec[i].static.oplus_flow_v_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                  (insitu_spec[i].static.oplus_flow_v_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                  (insitu_spec[i].static.oplus_flow_v_msoz*insitu_spec[i].spacecraft.t23)
                                                            old_data[2,(i*2)+1] = (insitu_spec[i].static.oplus_flow_v_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                  (insitu_spec[i].static.oplus_flow_v_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                  (insitu_spec[i].static.oplus_flow_v_msoz*insitu_spec[i].spacecraft.t33)
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
                            'STATIC O2+ Flow Velocity': begin
                                                          (*pstate).vector_path->getproperty,data=old_data
                                                          if (*pstate).coord_sys eq 0 then begin
                                                            for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                              old_data[0,(i*2)+1] = (insitu_spec[i].static.o2plus_flow_v_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                    (insitu_spec[i].static.o2plus_flow_v_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                    (insitu_spec[i].static.o2plus_flow_v_msoz*insitu_spec[i].spacecraft.t13)
                                                              old_data[1,(i*2)+1] = (insitu_spec[i].static.o2plus_flow_v_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                    (insitu_spec[i].static.o2plus_flow_v_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                    (insitu_spec[i].static.o2plus_flow_v_msoz*insitu_spec[i].spacecraft.t23)
                                                              old_data[2,(i*2)+1] = (insitu_spec[i].static.o2plus_flow_v_msox*insitu_spec[i].spacecraft.t32)+$
                                                                                    (insitu_spec[i].static.o2plus_flow_v_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                    (insitu_spec[i].static.o2plus_flow_v_msoz*insitu_spec[i].spacecraft.t33)
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
                            'STATIC H+ Characteristic Direction': begin
                                                                          (*pstate).vector_path->getproperty,data=old_data
                                                                          if (*pstate).coord_sys eq 0 then begin
                                                                            for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                                              old_data[0,(i*2)+1] = (insitu_spec[i].static.hplus_char_dir_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                                    (insitu_spec[i].static.hplus_char_dir_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                                    (insitu_spec[i].static.hplus_char_dir_msoz*insitu_spec[i].spacecraft.t13)
                                                                              old_data[1,(i*2)+1] = (insitu_spec[i].static.hplus_char_dir_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                                    (insitu_spec[i].static.hplus_char_dir_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                                    (insitu_spec[i].static.hplus_char_dir_msoz*insitu_spec[i].spacecraft.t23)
                                                                              old_data[2,(i*2)+1] = (insitu_spec[i].static.hplus_char_dir_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                                    (insitu_spec[i].static.hplus_char_dir_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                                    (insitu_spec[i].static.hplus_char_dir_msoz*insitu_spec[i].spacecraft.t33)
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
                            'STATIC Dominant Ion Characteristic Direction': begin
                                                                            (*pstate).vector_path->getproperty,data=old_data
                                                                            if (*pstate).coord_sys eq 0 then begin
                                                                              for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                                                old_data[0,(i*2)+1] = (insitu_spec[i].static.dominant_pickup_ion_char_dir_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                                      (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                                      (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz*insitu_spec[i].spacecraft.t13)
                                                                                old_data[1,(i*2)+1] = (insitu_spec[i].static.dominant_pickup_ion_char_dir_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                                      (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                                      (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz*insitu_spec[i].spacecraft.t23)
                                                                                old_data[2,(i*2)+1] = (insitu_spec[i].static.dominant_pickup_ion_char_dir_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                                      (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                                      (insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz*insitu_spec[i].spacecraft.t33)
                                                                              endfor
                                                                            endif
                                                                            if (*pstate).coord_sys eq 1 then begin
                                                                              for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                                                old_data[0,(i*2)+1] = insitu_spec[i].static.dominant_pickup_ion_char_dir_msox
                                                                                old_data[1,(i*2)+1] = insitu_spec[i].static.dominant_pickup_ion_char_dir_msoy
                                                                                old_data[2,(i*2)+1] = insitu_spec[i].static.dominant_pickup_ion_char_dir_msoz
                                                                              endfor
                                                                            endif
                                                                            MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
                                                                            (*pstate).vector_path->setproperty,data=old_data
                                                                            (*pstate).window->draw,(*pstate).view 
                                                                          end
                            'SEP Look Direction 1 Front': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      if (*pstate).coord_sys eq 0 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu_spec[i].sep.look_direction_1_front_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                (insitu_spec[i].sep.look_direction_1_front_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                (insitu_spec[i].sep.look_direction_1_front_msoz*insitu_spec[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu_spec[i].sep.look_direction_1_front_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                (insitu_spec[i].sep.look_direction_1_front_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                (insitu_spec[i].sep.look_direction_1_front_msoz*insitu_spec[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu_spec[i].sep.look_direction_1_front_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                (insitu_spec[i].sep.look_direction_1_front_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                (insitu_spec[i].sep.look_direction_1_front_msoz*insitu_spec[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if (*pstate).coord_sys eq 1 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu_spec[i].sep.look_direction_1_front_msox
                                                          old_data[1,(i*2)+1] = insitu_spec[i].sep.look_direction_1_front_msoy
                                                          old_data[2,(i*2)+1] = insitu_spec[i].sep.look_direction_1_front_msoz
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view 
                                                    end     
                            'SEP Look Direction 1 Back': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      if (*pstate).coord_sys eq 0 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu_spec[i].sep.look_direction_1_back_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                (insitu_spec[i].sep.look_direction_1_back_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                (insitu_spec[i].sep.look_direction_1_back_msoz*insitu_spec[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu_spec[i].sep.look_direction_1_back_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                (insitu_spec[i].sep.look_direction_1_back_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                (insitu_spec[i].sep.look_direction_1_back_msoz*insitu_spec[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu_spec[i].sep.look_direction_1_back_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                (insitu_spec[i].sep.look_direction_1_back_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                (insitu_spec[i].sep.look_direction_1_back_msoz*insitu_spec[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if (*pstate).coord_sys eq 1 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu_spec[i].sep.look_direction_1_back_msox
                                                          old_data[1,(i*2)+1] = insitu_spec[i].sep.look_direction_1_back_msoy
                                                          old_data[2,(i*2)+1] = insitu_spec[i].sep.look_direction_1_back_msoz
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view
                                                    end
                            'SEP Look Direction 2 Front': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      if (*pstate).coord_sys eq 0 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu_spec[i].sep.look_direction_2_front_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                (insitu_spec[i].sep.look_direction_2_front_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                (insitu_spec[i].sep.look_direction_2_front_msoz*insitu_spec[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu_spec[i].sep.look_direction_2_front_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                (insitu_spec[i].sep.look_direction_2_front_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                (insitu_spec[i].sep.look_direction_2_front_msoz*insitu_spec[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu_spec[i].sep.look_direction_2_front_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                (insitu_spec[i].sep.look_direction_2_front_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                (insitu_spec[i].sep.look_direction_2_front_msoz*insitu_spec[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if (*pstate).coord_sys eq 1 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu_spec[i].sep.look_direction_2_front_msox
                                                          old_data[1,(i*2)+1] = insitu_spec[i].sep.look_direction_2_front_msoy
                                                          old_data[2,(i*2)+1] = insitu_spec[i].sep.look_direction_2_front_msoz
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view
                                                    end
                            'SEP Look Direction 2 Back': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      if (*pstate).coord_sys eq 0 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = (insitu_spec[i].sep.look_direction_2_back_msox*insitu_spec[i].spacecraft.t11)+$
                                                                                (insitu_spec[i].sep.look_direction_2_back_msoy*insitu_spec[i].spacecraft.t12)+$
                                                                                (insitu_spec[i].sep.look_direction_2_back_msoz*insitu_spec[i].spacecraft.t13)
                                                          old_data[1,(i*2)+1] = (insitu_spec[i].sep.look_direction_2_back_msox*insitu_spec[i].spacecraft.t21)+$
                                                                                (insitu_spec[i].sep.look_direction_2_back_msoy*insitu_spec[i].spacecraft.t22)+$
                                                                                (insitu_spec[i].sep.look_direction_2_back_msoz*insitu_spec[i].spacecraft.t23)
                                                          old_data[2,(i*2)+1] = (insitu_spec[i].sep.look_direction_2_back_msox*insitu_spec[i].spacecraft.t31)+$
                                                                                (insitu_spec[i].sep.look_direction_2_back_msoy*insitu_spec[i].spacecraft.t32)+$
                                                                                (insitu_spec[i].sep.look_direction_2_back_msoz*insitu_spec[i].spacecraft.t33)
                                                        endfor
                                                      endif
                                                      if (*pstate).coord_sys eq 1 then begin
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = insitu_spec[i].sep.look_direction_2_back_msox
                                                          old_data[1,(i*2)+1] = insitu_spec[i].sep.look_direction_2_back_msoy
                                                          old_data[2,(i*2)+1] = insitu_spec[i].sep.look_direction_2_back_msoz
                                                        endfor
                                                      endif
                                                      MVN_KP_3D_VECTOR_NORM, old_data, (*pstate).vector_scale
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view
                                                    end                                                                                                                                                                                   
                          endcase
                          
                                
                        end
        
        'vector_display': begin
                           (*pstate).vector_model.getProperty, HIDE=result
                           if result eq 1 then begin
                            (*pstate).vector_model->setProperty,hide=0
                            widget_control,(*pstate).subbaseR10a, sensitive=1
                            widget_control,(*pstate).subbaseR10c, sensitive=1
                            widget_control,(*pstate).subbaseR10d, sensitive=1
                           endif
                           if result eq 0 then begin
                            (*pstate).vector_model->setProperty,hide=1
                            widget_control,(*pstate).subbaseR10a, sensitive=0
                            widget_control,(*pstate).subbaseR10c, sensitive=0
                            widget_control,(*pstate).subbaseR10d, sensitive=0
                           endif
                           (*pstate).window ->draw,(*pstate).view
                          end
          
        'vector_color_method': begin
                                  widget_control, event.id, get_value = newval
                                  case newval of 
                                    'Proximity':begin
                                                  (*pstate).vector_color_method = 0
                                                end
                                    
                                    'All': begin
                                            (*pstate).vector_color_method = 1
                                           end
                                  endcase
                               end
        'lpw_list_vec': begin
                          (*pstate).vector_color_source[0] = 'LPW'
                          index = widget_info(event.id, /droplist_select)
                          widget_control, event.id, get_value=newval
                          (*pstate).vector_color_source[1] = newval(index)
                          (*pstate).vector_path->getproperty,vert_color=vert_color
                          MVN_KP_3D_VECTOR_COLOR, (*pstate).insitu.static.(index), vert_color, (*pstate).colorbar_stretch
                          (*pstate).vector_path->setproperty,vert_color=vert_color
                          (*pstate).window ->draw,(*pstate).view
                        end
                        
        'static_list_vec': begin
                            (*pstate).vector_color_source[0] = 'STATIC'
                            index = widget_info(event.id, /droplist_select)
                            widget_control, event.id, get_value=newval
                            (*pstate).vector_color_source[1] = newval(index)
                            (*pstate).vector_path->getproperty,vert_color=vert_color
                            MVN_KP_3D_VECTOR_COLOR, (*pstate).insitu.static.(index), vert_color, (*pstate).colorbar_stretch
                            (*pstate).vector_path->setproperty,vert_color=vert_color
                            (*pstate).window ->draw,(*pstate).view
                           end
        
        'swia_list_vec': begin
                          (*pstate).vector_color_source[0] = 'SWIA'
                          index = widget_info(event.id, /droplist_select)
                          widget_control, event.id, get_value=newval
                          (*pstate).vector_color_source[1] = newval(index)
                          (*pstate).vector_path->getproperty,vert_color=vert_color
                          MVN_KP_3D_VECTOR_COLOR, (*pstate).insitu.static.(index), vert_color, (*pstate).colorbar_stretch
                          (*pstate).vector_path->setproperty,vert_color=vert_color
                          (*pstate).window ->draw,(*pstate).view
                         end
                        
        'swea_list_vec': begin
                          (*pstate).vector_color_source[0] = 'SWEA'
                          index = widget_info(event.id, /droplist_select)
                          widget_control, event.id, get_value=newval
                          (*pstate).vector_color_source[1] = newval(index)
                          (*pstate).vector_path->getproperty,vert_color=vert_color
                          MVN_KP_3D_VECTOR_COLOR, (*pstate).insitu.static.(index), vert_color, (*pstate).colorbar_stretch
                          (*pstate).vector_path->setproperty,vert_color=vert_color
                          (*pstate).window ->draw,(*pstate).view
                        end
                        
        'mag_list_vec': begin
                          (*pstate).vector_color_source[0] = 'MAG'
                          index = widget_info(event.id, /droplist_select)
                          widget_control, event.id, get_value=newval
                          (*pstate).vector_color_source[1] = newval(index)
                          (*pstate).vector_path->getproperty,vert_color=vert_color
                          MVN_KP_3D_VECTOR_COLOR, (*pstate).insitu.static.(index), vert_color, (*pstate).colorbar_stretch
                          (*pstate).vector_path->setproperty,vert_color=vert_color
                          (*pstate).window ->draw,(*pstate).view
                        end                               
        
        'sep_list_vec': begin
                          (*pstate).vector_color_source[0] = 'SEP'
                          index = widget_info(event.id, /droplist_select)
                          widget_control, event.id, get_value=newval
                          (*pstate).vector_color_source[1] = newval(index)
                          (*pstate).vector_path->getproperty,vert_color=vert_color
                          MVN_KP_3D_VECTOR_COLOR, (*pstate).insitu.static.(index), vert_color, (*pstate).colorbar_stretch
                          (*pstate).vector_path->setproperty,vert_color=vert_color
                          (*pstate).window ->draw,(*pstate).view
                        end
                        
        'ngims_list_vec': begin
                            (*pstate).vector_color_source[0] = 'NGIMS'
                            index = widget_info(event.id, /droplist_select)
                            widget_control, event.id, get_value=newval
                            (*pstate).vector_color_source[1] = newval(index)
                            (*pstate).vector_path->getproperty,vert_color=vert_color
                            MVN_KP_3D_VECTOR_COLOR, (*pstate).insitu.static.(index), vert_color, (*pstate).colorbar_stretch
                            (*pstate).vector_path->setproperty,vert_color=vert_color
                            (*pstate).window ->draw,(*pstate).view
                        end               
                        
                                        
        'overplots': begin
                       (*pstate).plot_model.getProperty, HIDE=result
                       if result eq 1 then (*pstate).plot_model->setProperty,hide=0
                       if result eq 0 then (*pstate).plot_model->setProperty,hide=1
                       (*pstate).window ->draw,(*pstate).view
                     end
                     
        'colorbar_stretch': begin
                              widget_control,event.id,get_value=newval
                              if newval eq 'Linear' then temp_stretch = 0
                              if newval eq 'Log' then temp_stretch = 1
                              (*pstate).colorbar_stretch = temp_stretch
                              temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)
                              MVN_KP_3D_PATH_COLOR, (*pstate).insitu, (*pstate).level0_index, (*pstate).level1_index, (*pstate).path_color_table, temp_vert,$
                                                    temp_ticks, (*pstate).colorbar_min, (*pstate).colorbar_max, temp_stretch
                              (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                              ;CHANGE THE COLOR BAR SETTINGS
                               (*pstate).colorbar1->setproperty,red_Values=r_curr
                               (*pstate).colorbar1->setproperty,green_Values=g_curr
                               (*pstate).colorbar1->setproperty,blue_Values=b_curr
                               (*pstate).colorbar_ticktext->setproperty,strings=strtrim(string(temp_ticks),2)
                               (*pstate).window ->draw,(*pstate).view
                            end
                         
        'colorbar_min': begin
                          widget_control,event.id,get_value=newval
                          (*pstate).colorbar_min = newval[0]
                          temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)
                          MVN_KP_3D_PATH_COLOR, (*pstate).insitu, (*pstate).level0_index, (*pstate).level1_index, (*pstate).path_color_table, temp_vert,$
                                                temp_ticks, (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                          (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                          ;CHANGE THE COLOR BAR SETTINGS
                           (*pstate).colorbar1->setproperty,red_Values=r_curr
                           (*pstate).colorbar1->setproperty,green_Values=g_curr
                           (*pstate).colorbar1->setproperty,blue_Values=b_curr
                           (*pstate).colorbar_ticktext->setproperty,strings=strtrim(string(temp_ticks),2)
                           (*pstate).window ->draw,(*pstate).view
                        end
                        
        'colorbar_max': begin
                          widget_control,event.id,get_value=newval
                          (*pstate).colorbar_max = newval[0]
                          temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)
                          MVN_KP_3D_PATH_COLOR, (*pstate).insitu, (*pstate).level0_index, (*pstate).level1_index, (*pstate).path_color_table, temp_vert,$
                                                temp_ticks, (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
                          (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                          ;CHANGE THE COLOR BAR SETTINGS
                           (*pstate).colorbar1->setproperty,red_Values=r_curr
                           (*pstate).colorbar1->setproperty,green_Values=g_curr
                           (*pstate).colorbar1->setproperty,blue_Values=b_curr
                           (*pstate).colorbar_ticktext->setproperty,strings=strtrim(string(temp_ticks),2)
                           (*pstate).window ->draw,(*pstate).view
                        end
                        
        'colorbar_reset': begin
                            temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)
                            colorbar_min = (*pstate).colorbar_min
                            colorbar_max = (*pstate).colorbar_max
                          MVN_KP_3D_PATH_COLOR, (*pstate).insitu, (*pstate).level0_index, (*pstate).level1_index, (*pstate).path_color_table, temp_vert,$
                                                temp_ticks, colorbar_min, colorbar_max, (*pstate).colorbar_stretch, /reset
                          (*pstate).colorbar_min = colorbar_min
                          (*pstate).colorbar_max = colorbar_max                       
                          (*pstate).orbit_path->SetProperty,vert_color=temp_vert
                          ;CHANGE THE COLOR BAR SETTINGS
                           (*pstate).colorbar1->setproperty,red_Values=r_curr
                           (*pstate).colorbar1->setproperty,green_Values=g_curr
                           (*pstate).colorbar1->setproperty,blue_Values=b_curr
                           (*pstate).colorbar_ticktext->setproperty,strings=strtrim(string(temp_ticks),2)
                           (*pstate).window ->draw,(*pstate).view
                          end
                         
        'orbit_onoff': begin
                        (*pstate).orbit_model.getProperty, HIDE=result
                        if result eq 1 then (*pstate).orbit_model->setProperty,hide=0
                        if result eq 0 then (*pstate).orbit_model->setProperty,hide=1
                        (*pstate).window ->draw,(*pstate).view
                       end
                         
        'periapse_all': begin
                          (*pstate).periapse_limb_model.getProperty, HIDE=result
                          if result eq 1 then begin
                            (*pstate).periapse_limb_model->setProperty,hide=0
                            widget_control,(*pstate).subbaseR8b, sensitive=1
                            widget_control,(*pstate).button8b, set_value='Hide All Profiles'
                          endif
                          if result eq 0 then begin
                             (*pstate).periapse_limb_model->setProperty,hide=1
                             widget_control,(*pstate).subbaseR8b, sensitive=0
                             widget_control,(*pstate).button8b, set_value='Display All Profiles'
                          endif
                          
                          (*pstate).window ->draw,(*pstate).view
                        end
                        
        'periapse_some': begin
            
                         end
        
        'peri_select': begin  
                         peri_index = widget_info(event.id, /droplist_select)
                         widget_control, event.id, get_value=newval
                         parameter = strtrim(string(newval[peri_index])) 
                         (*pstate).periapse_limb_scan = parameter
                         
                         p1 = strmid(parameter,0,1)                         
                         
                         data = fltarr(n_elements((*pstate).iuvs.periapse.time_start), n_elements((*pstate).iuvs[0].periapse[0].alt))
                         temp_index=0
                         for i=0,n_elements((*pstate).iuvs)-1 do begin
                          for j=0,n_elements((*pstate).iuvs[i].periapse)-1 do begin
                            if p1 eq 'D' then data[temp_index,*] = (*pstate).iuvs[i].periapse[j].density[peri_index,*]
                            if p1 eq 'R' then data[temp_index,*] = (*pstate).iuvs[i].periapse[j].radiance[peri_index,*]
                            temp_index++
                          endfor
                         endfor
                         (*pstate).periapse_vectors->getproperty,vert_colors=verts
                         MVN_KP_3D_PERI_COLOR, verts, data
                         
                         MVN_KP_3D_CURRENT_PERIAPSE, (*pstate).iuvs.periapse, (*pstate).insitu((*pstate).time_index).time, peri_data, parameter, xlabel
                            
                         (*pstate).alt_xaxis_title->setproperty,strings=xlabel
                         (*pstate).alt_plot->setproperty,datax=peri_data[1,*]
                         (*pstate).alt_plot->setproperty,datay=peri_data[0,*]
                         (*pstate).alt_plot->setproperty,xrange=[min(peri_data[1,*]),max(peri_data[1,*])]
                         (*pstate).alt_plot->getproperty, xrange=xr, yrange=yr
                          xc = mg_linear_function([min(peri_data[1,*]),max(peri_data[1,*])], [-1.75,-1.5])
                          yc = mg_linear_function(yr, [-1.3,1.0])
                          (*pstate).alt_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                          (*pstate).alt_xaxis_ticks->setproperty,strings=strtrim(string([min(peri_data[1,*]),max(peri_data[1,*])], format='(E8.2)'),2)
                         
                          
                         (*pstate).periapse_vectors->setproperty,vert_colors=verts
                         (*pstate).window ->draw,(*pstate).view

                       end
                       
        'peri_profile': begin
                            (*pstate).alt_plot_model.getProperty, HIDE=result
                            if result eq 1 then (*pstate).alt_plot_model->setProperty,hide=0
                            if result eq 0 then (*pstate).alt_plot_model->setProperty,hide=1
                            (*pstate).window ->draw,(*pstate).view            
                        end
                        
        'periapse_scaler': begin
                             widget_control, event.id, get_value=newval
                             
                             old_r = 0.33962+((*pstate).peri_scale_factor*0.001)
                             new_r = 0.33962+(newval*0.001)
                             
                             
                             rescale = new_r/old_r
                             
                             
                             (*pstate).periapse_limb_model->scale,rescale,rescale,rescale
                           
                             
                             (*pstate).peri_scale_factor = newval
                             (*pstate).window->draw,(*pstate).view
                             
                           end
                       
        'full_time_anim_begin': begin
                                  widget_control,(*pstate).button9a,sensitive=0
                                  widget_control,(*pstate).button9b,sensitive=1
                                  
                                  
                                end
                                
        'full_time_anim_end': begin
                                widget_control,(*pstate).button9a,sensitive=1
                                widget_control,(*pstate).button9b,sensitive=0
                              end
                              
        'apoapse_image': begin
                          result = widget_info((*pstate).subbaseR8d, /sensitive)
                            if result eq 0 then begin
                              widget_control,(*pstate).subbaseR8d,sensitive=1
                              widget_control,(*pstate).button8a, set_value='Hide Apoapse Images'
                              (*pstate).mars_base_map = 'mdim'
                            endif else begin
                              widget_control,(*pstate).subbaseR8d, sensitive=0
                              widget_control,(*pstate).button8a, set_value='Display Apoapse Images'
                              (*pstate).mars_base_map = 'apoapse'
                              
                              ;reset the basemap to default MOLA
                               read_jpeg,(*pstate).bm_install_directory+'MDIM_2500x1250.jpg',image
                               oImage = OBJ_NEW('IDLgrImage', image )
                               (*pstate).opolygons -> setproperty, texture_map=oimage
                               (*pstate).window->draw, (*pstate).view 
                              
                            endelse
                         end
                         
        'apoapse_select': begin
                            widget_control,event.id, get_value=choice
                            case choice of
                              'Ozone Depth': begin
                                              image = bytarr(3,90,45)
                                              (*pstate).apoapse_image_choice = 'Ozone Depth'
                                              (*pstate).mars_base_map = 'apoapse'
                                              time = (*pstate).insitu[(*pstate).time_index].time_string
                                              
                                                MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.ozone_depth, image, (*pstate).apoapse_blend, time, $
                                                                          (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                 
                                                        oImage = OBJ_NEW('IDLgrImage', image )
                                                        (*pstate).opolygons -> setproperty, texture_map=oimage
                                                        (*pstate).gridlines -> setProperty, hide=0
                                                        (*pstate).window ->draw,(*pstate).view  
                                                     
                                             end
                              'Dust Depth': begin
                                              image = bytarr(3,90,45)
                                              (*pstate).apoapse_image_choice = 'Dust Depth'
                                              (*pstate).mars_base_map = 'apoapse'
                                              time = (*pstate).insitu[(*pstate).time_index].time_string
                                              
                                                 MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.dust_depth, image, (*pstate).apoapse_blend, time, $
                                                                          (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                
                                                        oImage = OBJ_NEW('IDLgrImage', image )
                                                        (*pstate).opolygons -> setproperty, texture_map=oimage
                                                        (*pstate).gridlines -> setProperty, hide=0
                                                        (*pstate).window ->draw,(*pstate).view  
                                             end
                              'Radiance Map: H': begin
                                                  image = bytarr(3,90,45)
                                                  (*pstate).apoapse_image_choice = 'Radiance Map: H'
                                                  (*pstate).mars_base_map = 'apoapse'
                                                  time = (*pstate).insitu[(*pstate).time_index].time_string
                                                  sizes = size((*pstate).iuvs.apoapse.radiance[0,*,*])
                                                  input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                  for i=0,sizes(4)-1 do begin
                                                    input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[0,*,*]
                                                  endfor
                                                  MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, $
                                                                              (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                    
                                                            oImage = OBJ_NEW('IDLgrImage', image )
                                                            (*pstate).opolygons -> setproperty, texture_map=oimage
                                                            (*pstate).gridlines -> setProperty, hide=0
                                                            (*pstate).window ->draw,(*pstate).view  
                                                 end
                              'Radiance Map: O_1304': begin
                                                        image = bytarr(3,90,45)
                                                        (*pstate).apoapse_image_choice = 'Radiance Map: O_1304'
                                                        (*pstate).mars_base_map = 'apoapse'
                                                        time = (*pstate).insitu[(*pstate).time_index].time_string
                                                        sizes = size((*pstate).iuvs.apoapse.radiance[1,*,*])
                                                        input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                        for i=0,sizes(4)-1 do begin
                                                          input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[1,*,*]
                                                        endfor
                                                        MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, $
                                                                                    (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                          
                                                                  oImage = OBJ_NEW('IDLgrImage', image )
                                                                  (*pstate).opolygons -> setproperty, texture_map=oimage
                                                                  (*pstate).gridlines -> setProperty, hide=0
                                                                  (*pstate).window ->draw,(*pstate).view  
                                                       end
                              'Radiance Map: CO': begin
                                                    image = bytarr(3,90,45)
                                                    (*pstate).apoapse_image_choice = 'Radiance Map: CO'
                                                    (*pstate).mars_base_map = 'apoapse'
                                                    time = (*pstate).insitu[(*pstate).time_index].time_string
                                                    sizes = size((*pstate).iuvs.apoapse.radiance[2,*,*])
                                                    input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                    for i=0,sizes(4)-1 do begin
                                                      input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[2,*,*]
                                                    endfor
                                                    MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, $
                                                                                (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                      
                                                              oImage = OBJ_NEW('IDLgrImage', image )
                                                              (*pstate).opolygons -> setproperty, texture_map=oimage
                                                              (*pstate).gridlines -> setProperty, hide=0
                                                              (*pstate).window ->draw,(*pstate).view  
                                                   end
                              'Radiance Map: NO': begin
                                                    image = bytarr(3,90,45)
                                                    (*pstate).apoapse_image_choice = 'Radiance Map: NO'
                                                    (*pstate).mars_base_map = 'apoapse'
                                                    time = (*pstate).insitu[(*pstate).time_index].time_string
                                                    sizes = size((*pstate).iuvs.apoapse.radiance[3,*,*])
                                                    input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                    for i=0,sizes(4)-1 do begin
                                                      input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[3,*,*]
                                                    endfor
                                                    MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, $
                                                                                (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                      
                                                              oImage = OBJ_NEW('IDLgrImage', image )
                                                              (*pstate).opolygons -> setproperty, texture_map=oimage
                                                              (*pstate).gridlines -> setProperty, hide=0
                                                              (*pstate).window ->draw,(*pstate).view  
                                                   end
                              
                            endcase  
                          end
          
          'apo_blend': begin
                        widget_control, event.id, get_value=choice
                        if choice eq 'Average' then begin
                          (*pstate).apoapse_blend = 1
                          image = bytarr(3,90,45)
                          time = (*pstate).insitu[(*pstate).time_index].time_string
                          case (*pstate).apoapse_image_choice of 
                            'Ozone Depth': MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.ozone_depth, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).apo_time_blend
                            'Dust Depth' : MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.dust_depth, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).apo_time_blend
                            'Radiance Map: H': begin
                                                sizes = size((*pstate).iuvs.apoapse.radiance[0,*,*])
                                                input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                for i=0,sizes(4)-1 do begin
                                                  input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[0,*,*]
                                                endfor
                                                MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                               end
                            'Radiance Map: O_1304': begin
                                                      sizes = size((*pstate).iuvs.apoapse.radiance[1,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[1,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                     end
                            'Radiance Map: CO': begin
                                                  sizes = size((*pstate).iuvs.apoapse.radiance[2,*,*])
                                                  input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                  for i=0,sizes(4)-1 do begin
                                                    input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[2,*,*]
                                                  endfor
                                                  MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                 end
                            'Radiance Map: NO': begin
                                                  sizes = size((*pstate).iuvs.apoapse.radiance[3,*,*])
                                                  input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                  for i=0,sizes(4)-1 do begin
                                                    input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[3,*,*]
                                                  endfor
                                                  MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                 end
                          endcase
                          oImage = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons -> setproperty, texture_map=oimage
                          (*pstate).gridlines -> setProperty, hide=0
                          (*pstate).window ->draw,(*pstate).view  
                        endif
                        if choice eq 'None' then begin
                          (*pstate).apoapse_blend = 0
                          image = bytarr(3,90,45)
                          time = (*pstate).insitu[(*pstate).time_index].time_string
                          case (*pstate).apoapse_image_choice of 
                            'Ozone Depth': MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.ozone_depth, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                            'Dust Depth' : MVN_KP_3D_APOAPSE_IMAGES, (*pstate).iuvs.apoapse.dust_depth, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                            'Radiance Map: H':begin
                                                sizes = size((*pstate).iuvs.apoapse.radiance[0,*,*])
                                                input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                for i=0,sizes(4)-1 do begin
                                                  input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[0,*,*]
                                                endfor
                                                MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                               end
                            'Radiance Map: O_1304': begin
                                                      sizes = size((*pstate).iuvs.apoapse.radiance[1,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[1,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                     end
                            'Radiance Map: CO': begin
                                                  sizes = size((*pstate).iuvs.apoapse.radiance[2,*,*])
                                                  input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                  for i=0,sizes(4)-1 do begin
                                                    input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[2,*,*]
                                                  endfor
                                                  MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                 end
                            'Radiance Map: NO': begin
                                                  sizes = size((*pstate).iuvs.apoapse.radiance[3,*,*])
                                                  input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                  for i=0,sizes(4)-1 do begin
                                                    input_data[*,*,i] = (*pstate).iuvs[i].apoapse.radiance[3,*,*]
                                                  endfor
                                                  MVN_KP_3D_APOAPSE_IMAGES, input_data, image, (*pstate).apoapse_blend, time, (*pstate).iuvs.apoapse.time_start, (*pstate).iuvs.apoapse.time_stop, (*pstate).apo_time_blend
                                                 end
                          endcase
                          oImage = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons -> setproperty, texture_map=oimage
                          (*pstate).gridlines -> setProperty, hide=0
                          (*pstate).window ->draw,(*pstate).view 
                        endif
                       end
          'camera': begin
                          ;FREE THE CAMERA TO MOVE AS THE USER CHOOSES
                          widget_control,event.id, get_value=choice, /use_text_select
                          
                          if choice eq 'Free-view Camera' then (*pstate).camera_view = 0
                          
                          if choice eq 'Spacecraft Camera' then begin
                             (*pstate).camera_view =1
                             v1 = [0.0,0.0,1.0]
                             v2 = (*pstate).maven_location[0:2]
                          
                             axis = crossp(v1,v2)
                             angle = acos( transpose(v1)#v2 / sqrt(total(v1^2)) / sqrt(total(v2^2)) ) * 180./!pi 
                            
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
                                (*pstate).periapse_limb_model->rotate,axis,-angle
                                newPeriTrans = periTrans # rotTransform
                                (*pstate).periapse_limb_model ->rotate,axis,-angle
                              endif
                      
                             ;scale everything to zoom into MAVEN
                                                 
                             s = 5.0/(*pstate).maven_location[3] 
                             
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
                             (*pstate).axesmodel->scale,s,s,s
                             (*pstate).vector_model->scale,s,s,s
                             if (*pstate).instrument_array[8] eq 1 then begin
                              (*pstate).periapse_limb_model->scale,s,s,s
                              endif
                              (*pstate).maven_location = (*pstate).maven_location*s
                             
                                     ;update the maven location 
                            ;  (*pstate).maven_location[0:2] = [0.0,0.0,1.0]
                             
                             ;redraw the scene
                              (*pstate).window->draw,(*pstate).view
                             
                          endif
                         end
           
          'coordinates': begin
                           widget_control,event.id, get_value=choice, /use_text_select
                           (*pstate).orbit_path -> getproperty, data=data
                           (*pstate).orbit_model->GetProperty,transform=curtrans
                              cur_x = data[0,(*pstate).time_index*2]
                              cur_y = data[1,(*pstate).time_index*2]
                              cur_z = data[2,(*pstate).time_index*2]
                           (*pstate).vector_path -> getproperty, data=vec_data
                           
                           ;; Make idl 8.2.2 happy - We found that dereferencing the pointer to the struct in each
                           ;; iteration of the for loop was very slow in 8.2.2
                           insitu_spec = (*pstate).insitu

                           if choice eq 'Planetocentric' then begin
                            if (*pstate).speckle eq 1 then begin
                              orbit_offset = 0.001
                            endif else begin
                              orbit_offset = 0.00001
                            endelse
                            ;UPDATE THE ORBITAL PATH
                              for i=0L,n_elements((*pstate).insitu.spacecraft.geo_x)-1 do begin
                                data[0,i*2] = insitu_spec[i].spacecraft.geo_x/10000.0
                                data[0,(i*2)+1] = insitu_spec[i].spacecraft.geo_x/10000.0+orbit_offset
                                data[1,i*2] = insitu_spec[i].spacecraft.geo_y/10000.0
                                data[1,(i*2)+1] = (insitu_spec[i].spacecraft.geo_y/10000.0)+orbit_offset
                                data[2,i*2] = (insitu_spec[i].spacecraft.geo_z/10000.0)
                                data[2,(i*2)+1] = (insitu_spec[i].spacecraft.geo_z/10000.0)+orbit_offset
                              endfor
                            ;UPDATE MAVEN POSITION
                              new = fltarr(1,3)
                              new[0,0] = data[0,(*pstate).time_index*2]-cur_x
                              new[0,1] = data[1,(*pstate).time_index*2]-cur_y
                              new[0,2] = data[2,(*pstate).time_index*2]-cur_z
                              delta = new # curtrans[0:2,0:2]
                              (*pstate).maven_model -> translate, delta[0],delta[1],delta[2]
                              (*pstate).coord_sys = 0
                             ;SWITCH SUB-SC POINT IF NECESSARY
                               (*pstate).sub_maven_model_mso.getProperty, HIDE=result
                               if result eq 0 then begin
                                (*pstate).sub_maven_model_mso -> setproperty, hide=1
                                (*pstate).sub_maven_model ->setproperty, hide=0
                               endif
                             ;switch axes if necessary
                               (*pstate).axesmodel_msox.getProperty, HIDE=result
                               if result eq 0 then begin
                                (*pstate).axesmodel_msox->setproperty,hide=1
                                (*pstate).axesmodel_msoy->setproperty,hide=1
                                (*pstate).axesmodel_msoz->setproperty,hide=1
                                (*pstate).axesmodel->setproperty,hide=0
                               endif
                              ;UPDATE THE VECTOR WHISKERS, IF NECESSARY
                               (*pstate).vector_model.getProperty, HIDE=result
                               if result eq 0 then begin
                                vec_data1 = vec_data
                                for i=0, n_elements((*pstate).insitu.spacecraft.geo_x)-1 do begin
                                  vec_data[0,i*2] = insitu_spec[i].spacecraft.geo_x/10000.0
                                  vec_data[1,i*2] = insitu_spec[i].spacecraft.geo_y/10000.0
                                  vec_data[2,i*2] = insitu_spec[i].spacecraft.geo_z/10000.0
                                  vec_data[0,(i*2)+1] = (vec_data1[0,(i*2)+1]*insitu_spec[i].spacecraft.t11)+$
                                                        (vec_data1[1,(i*2)+1]*insitu_spec[i].spacecraft.t12)+$
                                                        (vec_data1[2,(i*2)+1]*insitu_spec[i].spacecraft.t13)
                                  vec_data[1,(i*2)+1] = (vec_data1[0,(i*2)+1]*insitu_spec[i].spacecraft.t21)+$
                                                        (vec_data1[1,(i*2)+1]*insitu_spec[i].spacecraft.t22)+$
                                                        (vec_data1[2,(i*2)+1]*insitu_spec[i].spacecraft.t23)
                                  vec_data[2,(i*2)+1] = (vec_data1[0,(i*2)+1]*insitu_spec[i].spacecraft.t31)+$
                                                        (vec_data1[1,(i*2)+1]*insitu_spec[i].spacecraft.t32)+$
                                                        (vec_data1[2,(i*2)+1]*insitu_spec[i].spacecraft.t33)                                   
                                endfor
                                (*pstate).vector_path->setproperty,data=vec_data
                               endif
                           endif else begin
                            if (*pstate).speckle eq 1 then begin
                              orbit_offset = 0.001
                            endif else begin
                              orbit_offset = 0.00001
                            endelse
                            ;UPDATE THE ORBITAL PATH 
                              for i=0L,n_elements((*pstate).insitu.spacecraft.mso_x)-1 do begin
                                data[0,i*2] = insitu_spec[i].spacecraft.mso_x/10000.0
                                data[0,(i*2)+1] = insitu_spec[i].spacecraft.mso_x/10000.0+orbit_offset
                                data[1,i*2] = insitu_spec[i].spacecraft.mso_y/10000.0
                                data[1,(i*2)+1] = (insitu_spec[i].spacecraft.mso_y/10000.0)+orbit_offset
                                data[2,i*2] = (insitu_spec[i].spacecraft.mso_z/10000.0)
                                data[2,(i*2)+1] = (insitu_spec[i].spacecraft.mso_z/10000.0)+orbit_offset
                              endfor
                            ;UPDATE MAVEN POSITION
                              new = fltarr(1,3)
                              new[0,0] = data[0,(*pstate).time_index*2]-cur_x
                              new[0,1] = data[1,(*pstate).time_index*2]-cur_y
                              new[0,2] = data[2,(*pstate).time_index*2]-cur_z
                              delta = new # curtrans[0:2,0:2]
                              (*pstate).maven_model -> translate, delta[0],delta[1],delta[2]
                              (*pstate).coord_sys = 1
                            ;SWITCH SUB-SC POINT IF NECESSARY
                               (*pstate).sub_maven_model.getproperty, HIDE=result
                               if result eq 0 then begin
                                (*pstate).sub_maven_model_mso -> setproperty, hide=0
                                (*pstate).sub_maven_model ->setproperty, hide=1
                               endif
                             ;switch axes if necessary
                               (*pstate).axesmodel.getproperty, hide=result
                               if result eq 0 then begin
                                (*pstate).axesmodel_msox->setproperty,hide=0
                                (*pstate).axesmodel_msoy->setproperty,hide=0
                                (*pstate).axesmodel_msoz->setproperty,hide=0
                                (*pstate).axesmodel->setproperty,hide=1
                               endif
                             ;UPDATE THE VECTOR WHISKERS, IF NECESSARY
                               (*pstate).vector_model.getProperty, hide=result
                               if result eq 0 then begin
                                  vec_data1 = vec_data
                                for i=0, n_elements((*pstate).insitu.spacecraft.mso_x)-1 do begin
                                  vec_data[0,i*2] = insitu_spec[i].spacecraft.mso_x/10000.0
                                  vec_data[1,i*2] = insitu_spec[i].spacecraft.mso_y/10000.0
                                  vec_data[2,i*2] = insitu_spec[i].spacecraft.mso_z/10000.0
                                  vec_data[0,(i*2)+1] = (vec_data1[0,(i*2)+1]*insitu_spec[i].spacecraft.t11)+$
                                                        (vec_data1[1,(i*2)+1]*insitu_spec[i].spacecraft.t21)+$
                                                        (vec_data1[2,(i*2)+1]*insitu_spec[i].spacecraft.t31)
                                  vec_data[1,(i*2)+1] = (vec_data1[0,(i*2)+1]*insitu_spec[i].spacecraft.t12)+$
                                                        (vec_data1[1,(i*2)+1]*insitu_spec[i].spacecraft.t22)+$
                                                        (vec_data1[2,(i*2)+1]*insitu_spec[i].spacecraft.t32)
                                  vec_data[2,(i*2)+1] = (vec_data1[0,(i*2)+1]*insitu_spec[i].spacecraft.t13)+$
                                                        (vec_data1[1,(i*2)+1]*insitu_spec[i].spacecraft.t23)+$
                                                        (vec_data1[2,(i*2)+1]*insitu_spec[i].spacecraft.t33)                      
                                endfor
                                (*pstate).vector_path->setproperty,data=vec_data
                               endif
                           endelse
        
                 
                              ;redraw the scene
                              (*pstate).orbit_path -> setproperty, data=data
                              (*pstate).window->draw,(*pstate).view
        
                           
                         end
           
          'corona_lo_disk': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                        
                              MVN_KP_3D_CORONA_COLORS, 'lo_disk', newval[index],t, (*pstate).iuvs 
                              
                            end
          'corona_lo_limb': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval

                              (*pstate).orbit_path -> getproperty, vert_color=vert_color

                              ;set reset flag if only need to erase other data

                              MVN_KP_3D_CORONA_COLORS, 'lo_limb', newval, index, vert_color, (*pstate).iuvs.corona_lo_limb, (*pstate).coronal_reset, (*pstate).insitu.time, (*pstate).insitu.spacecraft.altitude
                              
                              
;      temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2) 
;      MVN_KP_3D_PATH_COLOR, (*pstate).insitu, level0_index, level1_index, (*pstate).path_color_table, temp_vert,new_ticks,$
;                            (*pstate).colorbar_min, (*pstate).colorbar_max, (*pstate).colorbar_stretch
;      (*pstate).colorbar_ticks = new_ticks
;      plotted_parameter_name = tag_array[0]+':'+tag_array[1]
;      (*pstate).level0_index = level0_index
;      (*pstate).level1_index = level1_index
;      (*pstate).plottext1->setproperty,strings=plotted_parameter_name
                              (*pstate).orbit_path->SetProperty,vert_color=vert_color
                              (*pstate).window->draw,(*pstate).view   
                            end
          'corona_lo_high': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                              
                              (*pstate).orbit_path -> getproperty, vert_color=vert_color
                              MVN_KP_3D_CORONA_COLORS, 'lo_high', newval, index, vert_color, (*pstate).iuvs.corona_lo_high, (*pstate).coronal_reset, (*pstate).insitu.time, (*pstate).insitu.spacecraft.altitude
                              
                              
                              (*pstate).orbit_path->SetProperty,vert_color=vert_color
                              (*pstate).window->draw,(*pstate).view  
                            end
          'corona_e_disk': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                        
                              print,index, newval[index]
                           end
          'corona_e_limb': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                              
                              print,index, newval[index]
                           end
          'corona_e_high': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                              
                              print,index, newval[index]
                           end
                         
          'coronal_reset': begin
                            widget_control,event.id,get_value=newval
                            if newval eq 'Erase Orbit' then (*pstate).coronal_reset = 1
                            if newval eq 'Keep Orbit' then (*pstate).coronal_reset = 0 
                            print,'reset ',(*pstate).coronal_reset
                           end
         
         'apo_time': begin
                      widget_control,event.id, get_value=newval
                      if newval eq 'Nearest' then (*pstate).apo_time_blend = 1
                      if newval eq 'Exact' then (*pstate).apo_time_blend = 0
                     end
         
  endcase     ;END OF BUTTON CONTROL
  
end

