
pro mvn_kp_3d_event, event

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  widget_control, event.top, get_uvalue=pstate
  uname = widget_info(event.id,/uname)
  
  case uname of 
    'draw': begin
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
                (*pstate).vector_model->getProperty,transform=vertTrans
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
                newVertTrans = vertTrans # rotTransform
                (*pstate).model->setProperty, transform=newTransform
                (*pstate).atmModel1->setProperty, transform=newatmtrans1
                (*pstate).atmModel2->setProperty, transform=newatmtrans2
                (*pstate).atmModel3->setProperty, transform=newatmtrans3
                (*pstate).atmModel4->setProperty, transform=newatmtrans4
                (*pstate).atmModel5->setProperty, transform=newatmtrans5
                (*pstate).atmModel6->setProperty, transform=newatmtrans6
                (*pstate).gridlines -> setProperty, transform=newTransform
                (*pstate).orbit_model -> setProperty, transform=newTransform
                (*pstate).maven_model -> setProperty, transform=newMavTrans
                (*pstate).sub_solar_model->setProperty,transform=newSsTrans
                (*pstate).sub_maven_model->setProperty,transform=newSmTrans
                (*pstate).vector_model->setProperty,transform=newVertTrans
                (*pstate).axesmodel -> setProperty, transform=newtransform
                if (*pstate).instrument_array[8] eq 1 then begin
                  (*pstate).periapse_limb_model->getProperty,transform=periTrans
                  newPeriTrans = periTrans # rotTransform
                  (*pstate).periapse_limb_model ->setproperty, transform=newPeriTrans
                endif
                (*pstate).window->draw, (*pstate).view          
              endif
            
              ; scale
              if (event.type eq 7) then begin
                s = 1.1 ^ event.clicks
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
                (*pstate).window->draw, (*pstate).view          
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
                  data = *(*pstate).orbit_path.data
                  (*pstate).orbit_model->GetProperty,transform=curtrans
                  cur_x = data[0,(*pstate).time_index]
                  cur_y = data[1,(*pstate).time_index]
                  cur_z = data[2,(*pstate).time_index]
                  new = fltarr(1,3)
                  new[0,0] = data[0,t_index]-cur_x
                  new[0,1] = data[1,t_index]-cur_y
                  new[0,2] = data[2,t_index]-cur_z
                  delta = new # curtrans[0:2,0:2]
                  (*pstate).maven_model -> translate, delta[0],delta[1],delta[2]
                  
                  
                ;UPDATE THE PARAMETERS ON SCREEN
                  (*pstate).paratext1->setProperty,strings='Distance to Sun:'+strtrim(string((*pstate).insitu(t_index).spacecraft.mars_sun_distance),2)+' AU'
                  (*pstate).paratext2->setProperty,strings='Mars Season:'+strtrim(string((*pstate).insitu(t_index).spacecraft.mars_season),2)
                  (*pstate).paratext3->setProperty,strings='MAVEN Altitude:'+strtrim(string((*pstate).insitu(t_index).spacecraft.altitude),2)
                  (*pstate).paratext4->setProperty,strings='Solar Zenith Angle:'+strtrim(string((*pstate).insitu(t_index).spacecraft.sza),2)
                  (*pstate).paratext5->setProperty,strings='Local Time:'+strtrim(string((*pstate).insitu(t_index).spacecraft.local_time),2)
                  (*pstate).timetext->setProperty,strings=time_string(newval,format=0)
                  (*pstate).plottext1->getproperty,strings=temp_string
                  if temp_string ne '' then begin
                    (*pstate).plottext2->setProperty, strings = strtrim(string((*pstate).insitu(t_index).((*pstate).level0_index).((*pstate).level1_index)),2)
                  endif
                  
                ;MOVE THE SUN'S LIGHT SOURCE TO THE PROPER LOCATION
                  (*pstate).dirlight->setProperty,location=[(*pstate).solar_x_coord(t_index),(*pstate).solar_y_coord(t_index),(*pstate).solar_z_coord(t_index)]
               
                ;UPDATE THE SUN VECTOR POINTING  
                
                ;UPDATE THE TERMINATOR LOCATION
                
                ;UPDATE THE SUBSOLAR POINT
                 (*pstate).sub_solar_line->setProperty,data=[(*pstate).subsolar_x_coord[t_index],(*pstate).subsolar_y_coord[t_index],(*pstate).subsolar_z_coord[t_index]]
                  
                ;UPDATE THE SUBMAVEN POINT  
                 (*pstate).sub_maven_line->setProperty,data=[(*pstate).submaven_x_coord[t_index],(*pstate).submaven_y_coord[t_index],(*pstate).submaven_z_coord[t_index]]
                  
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
                  
                ;FINALLY, REDRAW THE SCENE  
                (*pstate).time_index = t_index
                (*pstate).window->draw, (*pstate).view
             end                   
                 
     'basemap1': begin
              widget_control,event.id,get_value=newval
              
              case newval of 
                'BLANK': begin
                          ;START WITH A WHITE GLOBE
                            image = bytarr(3,2048,1024)
                            image[*,*,*] = 255
                            oImage = OBJ_NEW('IDLgrImage', image )
                            (*pstate).opolygons -> setproperty, texture_map=oimage
                            (*pstate).gridlines -> setProperty, hide=0
                            (*pstate).window ->draw,(*pstate).view
                        end
                'MDIM': begin 
                          read_jpeg,(*pstate).install_directory+'MDIM_2500x1250.jpg',image
                          oImage = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons -> setproperty, texture_map=oimage
                          (*pstate).window->draw, (*pstate).view 
                        end
                'MOLA': begin
                          read_jpeg,(*pstate).install_directory+'MOLA_color_2500x1250.jpg',image
                          oImage = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons -> setproperty, texture_map=oimage
                          (*pstate).window->draw, (*pstate).view 
                        end
                'MOLA_BW': begin
                             read_jpeg,(*pstate).install_directory+'MOLA_bw_2500x1250.jpg',image
                             oImage = OBJ_NEW('IDLgrImage', image )
                             (*pstate).opolygons -> setproperty, texture_map=oimage
                             (*pstate).window->draw, (*pstate).view 
                           end
                'MAG': begin
                         read_jpeg,(*pstate).install_directory+'Mars_Crustal_Magnetism_MGS.jpg',image
                         oImage = OBJ_NEW('IDLgrImage', image )
                         (*pstate).opolygons -> setproperty, texture_map=oimage
                         (*pstate).window->draw, (*pstate).view
                       end
                'User Defined': begin
                                  input_file = dialog_pickfile(path=(*pstate).install_directory,filter='*.jpg')
                                  read_jpeg,input_file,image
                                  oImage = OBJ_NEW('IDLgrImage', image )
                                  (*pstate).opolygons -> setproperty, texture_map=oimage
                                  (*pstate).window->draw, (*pstate).view
                                end
              
              endcase
             end 
       'grid': begin
                result = (*pstate).gridlines.hide
                if result eq 1 then (*pstate).gridlines -> setProperty,hide=0
                if result eq 0 then (*pstate).gridlines -> setProperty,hide=1
                (*pstate).window -> draw, (*pstate).view
               end
               
       'subsolar': begin
                    result = (*pstate).sub_solar_model.hide
                    if result eq 1 then (*pstate).sub_solar_model -> setProperty,hide=0
                    if result eq 0 then (*pstate).sub_solar_model -> setProperty,hide=1
                    (*pstate).window -> draw, (*pstate).view
                   end
                  
       'submaven': begin
                    result = (*pstate).sub_maven_model.hide
                    if result eq 1 then (*pstate).sub_maven_model -> setProperty,hide=0
                    if result eq 0 then (*pstate).sub_maven_model -> setProperty,hide=1
                    (*pstate).window -> draw, (*pstate).view
                   end
               
       'terminator': begin
                      t1 = dialog_message('Not yet implemented',/information)
;                      result = (*pstate).terminator.hide
;                      if result eq 1 then (*pstate).terminator -> setProperty,hide=0
;                      if result eq 0 then (*pstate).terminator -> setProperty,hide=1
                      (*pstate).window -> draw, (*pstate).view
                     end

       'sunvector': begin
                      result = (*pstate).sun_model.hide
                      if result eq 1 then (*pstate).sun_model -> setProperty,hide=0
                      if result eq 0 then (*pstate).sun_model -> setProperty,hide=1
                      (*pstate).window -> draw, (*pstate).view
                     end

       'axes': begin
                      result = (*pstate).axesmodel.hide
                      if result eq 1 then (*pstate).axesmodel -> setProperty,hide=0
                      if result eq 0 then (*pstate).axesmodel -> setProperty,hide=1
                      (*pstate).window -> draw, (*pstate).view
                     end      

       'parameters': begin
                      result = (*pstate).parameterModel.hide
                      if result eq 1 then (*pstate).parameterModel->setProperty,hide=0
                      if result eq 0 then (*pstate).parameterModel->setProperty,hide=1
                      (*pstate).window ->draw,(*pstate).view
                     end          

       'background_color': begin
                                widget_control, event.id, get_value=newval
                                (*pstate).view->setProperty,color=newval
                                (*pstate).window ->draw,(*pstate).view
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
                          input_file = dialog_pickfile(path='/Users/klarsen/Desktop/',filter='*.png')
                          read_png,input_file,image
                          oImage1 = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons1 -> setproperty, texture_map=oimage1
                          (*pstate).opolygons1 -> setProperty, alpha_channel=((*pstate).atmLevel1alpha)/100.0
                          (*pstate).window->draw,(*pstate).view
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
                          input_file = dialog_pickfile(path='/Users/klarsen/Desktop/',filter='*.png')
                          read_png,input_file,image
                          oImage2 = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons2 -> setproperty, texture_map=oimage2
                          (*pstate).opolygons2 -> setProperty, alpha_channel=((*pstate).atmLevel2alpha)/100.0
                          (*pstate).window->draw,(*pstate).view
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
                          input_file = dialog_pickfile(path='/Users/klarsen/Desktop/',filter='*.png')
                          read_png,input_file,image
                          oImage3 = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons3 -> setproperty, texture_map=oimage3
                          (*pstate).opolygons3 -> setProperty, alpha_channel=((*pstate).atmLevel3alpha)/100.0
                          (*pstate).window->draw,(*pstate).view
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
                          input_file = dialog_pickfile(path='/Users/klarsen/Desktop/',filter='*.png')
                          read_png,input_file,image
                          oImage4 = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons4 -> setproperty, texture_map=oimage4
                          (*pstate).opolygons4 -> setProperty, alpha_channel=((*pstate).atmLevel4alpha)/100.0
                          (*pstate).window->draw,(*pstate).view
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
                          input_file = dialog_pickfile(path='/Users/klarsen/Desktop/',filter='*.png')
                          read_png,input_file,image
                          oImage5 = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons5 -> setproperty, texture_map=oimage5
                          (*pstate).opolygons5 -> setProperty, alpha_channel=((*pstate).atmLevel5alpha)/100.0
                          (*pstate).window->draw,(*pstate).view
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
                          input_file = dialog_pickfile(path='/Users/klarsen/Desktop/',filter='*.png')
                          read_png,input_file,image
                          oImage6 = OBJ_NEW('IDLgrImage', image )
                          (*pstate).opolygons6 -> setproperty, texture_map=oimage6
                          (*pstate).opolygons6 -> setProperty, alpha_channel=((*pstate).atmLevel6alpha)/100.0
                          (*pstate).window->draw,(*pstate).view
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
                          t1 = dialog_message('Coming Soon . . . .',/information)
                      end
                    
       'config_load': begin
                          t1 = dialog_message('Coming Soon . . . .',/information)
                      end
                      
       'save_view': begin
                      outfile = dialog_pickfile(default_extension='png',/write)                                     
                      buffer = Obj_New('IDLgrBuffer', DIMENSIONS=[800,800])
                      buffer -> Draw, (*pstate).view
                      buffer -> GetProperty, Image_Data=snapshot
                      Obj_Destroy, buffer
                      write_png, outfile,snapshot
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
                          xc = mg_linear_function(xr, [-1.7,1.4])
                          yc = mg_linear_function(yr, [-1.9,-1.5])
                          (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
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
                          xc = mg_linear_function(xr, [-1.7,1.4])
                          yc = mg_linear_function(yr, [-1.9,-1.5])
                          (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
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
                          xc = mg_linear_function(xr, [-1.7,1.4])
                          yc = mg_linear_function(yr, [-1.9,-1.5])
                          (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
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
                          xc = mg_linear_function(xr, [-1.7,1.4])
                          yc = mg_linear_function(yr, [-1.9,-1.5])
                          (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
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
                          xc = mg_linear_function(xr, [-1.7,1.4])
                          yc = mg_linear_function(yr, [-1.9,-1.5])
                          (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
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
                          xc = mg_linear_function(xr, [-1.7,1.4])
                          yc = mg_linear_function(yr, [-1.9,-1.5])
                          (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
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
                          xc = mg_linear_function(xr, [-1.7,1.4])
                          yc = mg_linear_function(yr, [-1.9,-1.5])
                          (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
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
                           result = (*pstate).colorbarmodel.hide
                           if result eq 1 then (*pstate).colorbarmodel->setProperty,hide=0
                           if result eq 0 then (*pstate).colorbarmodel->setProperty,hide=1
                           (*pstate).window ->draw,(*pstate).view
                        end
             
        'orbitPlotName': begin
                           result = (*pstate).plottednamemodel.hide
                           if result eq 1 then (*pstate).plottednamemodel->setProperty,hide=0
                           if result eq 0 then (*pstate).plottednamemodel->setProperty,hide=1
                           (*pstate).window ->draw,(*pstate).view
                         end
                         
        'vector_field': begin
                          widget_control, event.id, get_value=newval
                          case newval of
                            'Magnetic Field': begin
                                                 (*pstate).vector_path->getproperty,data=old_data
                                                 for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                  old_data[0,(i*2)+1] = (*pstate).insitu[i].mag.mso_x
                                                  old_data[1,(i*2)+1] = (*pstate).insitu[i].mag.mso_y
                                                  old_data[2,(i*2)+1] = (*pstate).insitu[i].mag.mso_z
                                                 endfor
                                                 (*pstate).vector_path->setproperty,data=old_data
                                                 (*pstate).window->draw,(*pstate).view
                                              end
                            'SWIA H+ Flow Velocity': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                        old_data[0,(i*2)+1] = (*pstate).insitu[i].swia.hplus_flow_v_msox
                                                        old_data[1,(i*2)+1] = (*pstate).insitu[i].swia.hplus_flow_v_msoy
                                                        old_data[2,(i*2)+1] = (*pstate).insitu[i].swia.hplus_flow_v_msoz
                                                      endfor
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view
                                                     end
                            'STATIC H+ Flow Velocity': begin
                                                        (*pstate).vector_path->getproperty,data=old_data
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = (*pstate).insitu[i].static.hplus_flow_v_msox
                                                          old_data[1,(i*2)+1] = (*pstate).insitu[i].static.hplus_flow_v_msoy
                                                          old_data[2,(i*2)+1] = (*pstate).insitu[i].static.hplus_flow_v_msoz
                                                        endfor
                                                        (*pstate).vector_path->setproperty,data=old_data
                                                        (*pstate).window->draw,(*pstate).view
                                                       end
                            'STATIC O+ Flow Velocity': begin
                                                        (*pstate).vector_path->getproperty,data=old_data
                                                        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                          old_data[0,(i*2)+1] = (*pstate).insitu[i].static.oplus_flow_v_msox
                                                          old_data[1,(i*2)+1] = (*pstate).insitu[i].static.oplus_flow_v_msoy
                                                          old_data[2,(i*2)+1] = (*pstate).insitu[i].static.oplus_flow_v_msoz
                                                        endfor
                                                        (*pstate).vector_path->setproperty,data=old_data
                                                        (*pstate).window->draw,(*pstate).view
                                                       end
                            'STATIC O2+ Flow Velocity': begin
                                                          (*pstate).vector_path->getproperty,data=old_data
                                                          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                            old_data[0,(i*2)+1] = (*pstate).insitu[i].static.o2plus_flow_v_msox
                                                            old_data[1,(i*2)+1] = (*pstate).insitu[i].static.o2plus_flow_v_msoy
                                                            old_data[2,(i*2)+1] = (*pstate).insitu[i].static.o2plus_flow_v_msoz
                                                          endfor
                                                          (*pstate).vector_path->setproperty,data=old_data
                                                          (*pstate).window->draw,(*pstate).view
                                                        end  
                            'STATIC H+/He++ Characteristic Direction': begin
                                                                          (*pstate).vector_path->getproperty,data=old_data
                                                                          for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                                            old_data[0,(i*2)+1] = (*pstate).insitu[i].static.hhe_char_dir_msox
                                                                            old_data[1,(i*2)+1] = (*pstate).insitu[i].static.hhe_char_dir_msoy
                                                                            old_data[2,(i*2)+1] = (*pstate).insitu[i].static.hhe_char_dir_msoz
                                                                          endfor
                                                                          (*pstate).vector_path->setproperty,data=old_data
                                                                          (*pstate).window->draw,(*pstate).view
                                                                       end
                            'STATIC Pickup Ion Characteristic Direction': begin
                                                                            (*pstate).vector_path->getproperty,data=old_data
                                                                            for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                                              old_data[0,(i*2)+1] = (*pstate).insitu[i].static.pickup_ion_char_dir_msox
                                                                              old_data[1,(i*2)+1] = (*pstate).insitu[i].static.pickup_ion_char_dir_msoy
                                                                              old_data[2,(i*2)+1] = (*pstate).insitu[i].static.pickup_ion_char_dir_msoz
                                                                            endfor
                                                                            (*pstate).vector_path->setproperty,data=old_data
                                                                            (*pstate).window->draw,(*pstate).view 
                                                                          end
                            'SEP Look Direction 1': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                        old_data[0,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_1_msox
                                                        old_data[1,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_1_msoy
                                                        old_data[2,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_1_msoz
                                                      endfor
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view 
                                                    end     
                            'SEP Look Direction 2': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                        old_data[0,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_2_msox
                                                        old_data[1,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_2_msoy
                                                        old_data[2,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_2_msoz
                                                      endfor
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view
                                                    end
                            'SEP Look Direction 3': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                        old_data[0,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_3_msox
                                                        old_data[1,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_3_msoy
                                                        old_data[2,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_3_msoz
                                                      endfor
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view
                                                    end
                            'SEP Look Direction 4': begin
                                                      (*pstate).vector_path->getproperty,data=old_data
                                                      for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
                                                        old_data[0,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_4_msox
                                                        old_data[1,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_4_msoy
                                                        old_data[2,(i*2)+1] = (*pstate).insitu[i].sep.look_direction_4_msoz
                                                      endfor
                                                      (*pstate).vector_path->setproperty,data=old_data
                                                      (*pstate).window->draw,(*pstate).view
                                                    end                                                                                                                                                                                   
                          endcase
                          
                                
                        end
        
        'vector_display': begin
                           result = (*pstate).vector_model.hide
                           if result eq 1 then (*pstate).vector_model->setProperty,hide=0
                           if result eq 0 then (*pstate).vector_model->setProperty,hide=1
                           (*pstate).window ->draw,(*pstate).view
                          end
          
        'overplots': begin
                       result = (*pstate).plot_model.hide
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
                        result = (*pstate).orbit_model.hide
                        if result eq 1 then (*pstate).orbit_model->setProperty,hide=0
                        if result eq 0 then (*pstate).orbit_model->setProperty,hide=1
                        (*pstate).window ->draw,(*pstate).view
                       end
                         
        'periapse_all': begin
                          result = (*pstate).periapse_limb_model.hide
                          if result eq 1 then begin
                            (*pstate).periapse_limb_model->setProperty,hide=0
                            widget_control,(*pstate).subbaseR8b, sensitive=1
                          endif
                          if result eq 0 then begin
                             (*pstate).periapse_limb_model->setProperty,hide=1
                             widget_control,(*pstate).subbaseR8b, sensitive=0
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
                            result = (*pstate).alt_plot_model.hide
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
                         
  endcase     ;END OF BUTTON CONTROL
  
end

