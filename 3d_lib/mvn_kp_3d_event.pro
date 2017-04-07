
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
              mvn_kp_3d_event_draw,event
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
               mvn_kp_3d_event_time,event
             end

     'timestep_define': begin
                          widget_control, event.id, get_value=newval
                          (*pstate).time_step_size = fix(newval)
                        end

     'timeminusone': $
      begin
        mvn_kp_3d_time_increment, (*pstate), -(*pstate).time_step_size
        (*pstate).window->draw, (*pstate).view
        widget_control,(*pstate).timeline,$
                       set_value=(*pstate).insitu[(*pstate).time_index].time
      end

     'timeplusone': $
      begin
        mvn_kp_3d_time_increment, (*pstate), (*pstate).time_step_size
        (*pstate).window->draw, (*pstate).view
        widget_control,(*pstate).timeline,$
                        set_value=(*pstate).insitu[(*pstate).time_index].time
      end
                 
     'basemap1': $
      begin
        mvn_kp_3d_event_basemap, event
      end

     'grid': $
      begin
        (*pstate).gridlines.getProperty, HIDE=result
        if result eq 1 then (*pstate).gridlines -> setProperty,hide=0
        if result eq 0 then (*pstate).gridlines -> setProperty,hide=1
        (*pstate).window -> draw, (*pstate).view
      end
               
     'subsolar': $
      begin
        (*pstate).sub_solar_model.getProperty, HIDE=result
        if result eq 1 then (*pstate).sub_solar_model -> setProperty,hide=0
        if result eq 0 then (*pstate).sub_solar_model -> setProperty,hide=1
        (*pstate).window -> draw, (*pstate).view
      end
                  
     'submaven': $
      begin
        (*pstate).sub_maven_model.getProperty, HIDE=result
        if (*pstate).coord_sys eq 0 then begin
          if result eq 1 then (*pstate).sub_maven_model->setProperty,hide=0
          if result eq 0 then (*pstate).sub_maven_model->setProperty,hide=1
        endif 
        if (*pstate).coord_sys eq 1 then begin
          if result eq 1 then (*pstate).sub_maven_model_mso->setProperty,hide=0
          if result eq 0 then (*pstate).sub_maven_model_mso->setProperty,hide=1
        endif
        (*pstate).window -> draw, (*pstate).view
      end
               
     'terminator': $
      begin
        t1 = dialog_message('Not yet implemented',/information)
;        (*pstate).terminator.getProperty, HIDE=result
;        if result eq 1 then (*pstate).terminator -> setProperty,hide=0
;        if result eq 0 then (*pstate).terminator -> setProperty,hide=1
        (*pstate).window -> draw, (*pstate).view
      end

     'sunvector': $
      begin
        (*pstate).sun_model.getProperty, HIDE=result
        if result eq 1 then (*pstate).sun_model -> setProperty,hide=0
        if result eq 0 then (*pstate).sun_model -> setProperty,hide=1
        (*pstate).window -> draw, (*pstate).view
      end

     'axes': $
      begin
        if (*pstate).coord_sys eq 0 then begin
          (*pstate).axesmodel.getProperty, HIDE=result
          if result eq 1 then (*pstate).axesmodel -> setProperty,hide=0
          if result eq 0 then (*pstate).axesmodel -> setProperty,hide=1
        endif
        if (*pstate).coord_sys eq 1 then begin
          (*pstate).axesmodel_mso.getProperty, HIDE=result
          if result eq 1 then (*pstate).axesmodel_mso->setproperty,hide=0
          if result eq 0 then (*pstate).axesmodel_mso->setproperty,hide=1
        endif
        (*pstate).window -> draw, (*pstate).view
      end      

     'parameters': $
      begin
        (*pstate).parameterModel.getProperty, HIDE=result
        if result eq 1 then (*pstate).parameterModel->setProperty,hide=0
        if result eq 0 then (*pstate).parameterModel->setProperty,hide=1
        (*pstate).window ->draw,(*pstate).view
      end          

     'background_color': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).view->setProperty,color=newval
        (*pstate).window ->draw,(*pstate).view
      end

     'ambient': $
      begin
        widget_control,event.id, get_value=newval
        (*pstate).ambientlight->setProperty,intensity=newval/100.0
        (*pstate).window->draw,(*pstate).view
      end
                       
     'views': $
      begin
        widget_control,(*pstate).subbaseR1, map=0
        widget_control,(*pstate).subbaseR3, map=1
      end
       
     'view_return': $
      begin
        widget_control, (*pstate).subbaseR3, map=0
        widget_control, (*pstate).subbaseR1, map=1
      end
               
     'models': $
      begin
        widget_control,(*pstate).subbaseR1, map=0
        widget_control,(*pstate).subbaseR4, map=1
      end

     'model_return': $
      begin
        widget_control, (*pstate).subbaseR4, map=0
        widget_control, (*pstate).subbaseR1, map=1
      end
       
     'atmLevel1': $
      begin
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
                    
     'atmLevel1Load': $
      begin
        input_file = dialog_pickfile(path=(*pstate).install_directory,$
                                     filter='*.png')
        if input_file ne '' then begin
          read_png,input_file,image
          oImage1 = OBJ_NEW('IDLgrImage', image )
          (*pstate).opolygons1 -> setproperty, texture_map=oimage1
          (*pstate).opolygons1 -> setProperty, $
                      alpha_channel=((*pstate).atmLevel1alpha)/100.0
          (*pstate).window->draw,(*pstate).view
        endif
      end
                        
     'atmLevel1alpha': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).atmLevel1alpha = newval
        (*pstate).opolygons1 -> setProperty, $
                    alpha_channel=((*pstate).atmLevel1alpha)/100.0
        (*pstate).window->draw, (*pstate).view                           
      end
                         
     'atmLevel1height': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).atmModel1->GetProperty,transform=curtrans
        new_scale = (3396.+float(newval))$
                  / (3396.+float((*pstate).atmLevel1height))
        (*pstate).atmLevel1height=newval
        (*pstate).atmModel1->scale,new_scale,new_scale,new_scale
        (*pstate).window->draw,(*pstate).view
      end
       
     'atmLevel2': $
      begin
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
                    
     'atmLevel2Load': $
      begin
        input_file = dialog_pickfile(path=(*pstate).install_directory,$
                                     filter='*.png')
        if input_file ne '' then begin
          read_png,input_file,image
          oImage2 = OBJ_NEW('IDLgrImage', image )
          (*pstate).opolygons2 -> setproperty, texture_map=oimage2
          (*pstate).opolygons2 -> setProperty, $
                      alpha_channel=((*pstate).atmLevel2alpha)/100.0
          (*pstate).window->draw,(*pstate).view
        endif
      end
                        
     'atmLevel2alpha': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).atmLevel2alpha = newval
        (*pstate).opolygons2 -> setProperty, $
                    alpha_channel=((*pstate).atmLevel2alpha)/100.0
        (*pstate).window->draw, (*pstate).view                           
      end    
                         
     'atmLevel2height': $
      begin
        widget_control, event.id, get_value=newval
        new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel2height))
        (*pstate).atmLevel2height=fix(newval)
        (*pstate).atmModel2->scale,new_scale,new_scale,new_scale
        (*pstate).window->draw,(*pstate).view
      end                  
                         
     'atmLevel3': $
      begin
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
                    
     'atmLevel3Load': $
      begin
        input_file = dialog_pickfile(path=(*pstate).install_directory,$
                                     filter='*.png')
        if input_file ne '' then begin
          read_png,input_file,image
          oImage3 = OBJ_NEW('IDLgrImage', image )
          (*pstate).opolygons3 -> setproperty, texture_map=oimage3
          (*pstate).opolygons3 -> setProperty, $
                      alpha_channel=((*pstate).atmLevel3alpha)/100.0
          (*pstate).window->draw,(*pstate).view
        endif
      end
                        
     'atmLevel3alpha': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).atmLevel3alpha = newval
        (*pstate).opolygons3 -> setProperty, $
                    alpha_channel=((*pstate).atmLevel3alpha)/100.0
        (*pstate).window->draw, (*pstate).view                           
      end  

     'atmLevel3height': $
      begin
        widget_control, event.id, get_value=newval
        new_scale = (3396.+float(newval))$
                  / (3396.+float((*pstate).atmLevel3height))
        (*pstate).atmLevel3height=fix(newval)
        (*pstate).atmModel3->scale,new_scale,new_scale,new_scale
        (*pstate).window->draw,(*pstate).view
      end
                         
     'atmLevel4': $
      begin
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
                    
     'atmLevel4Load': $
      begin
        input_file = dialog_pickfile(path=(*pstate).install_directory,$
                                     filter='*.png')
        if input_file ne '' then begin
          read_png,input_file,image
          oImage4 = OBJ_NEW('IDLgrImage', image )
          (*pstate).opolygons4 -> setproperty, texture_map=oimage4
          (*pstate).opolygons4 -> setProperty, $
                      alpha_channel=((*pstate).atmLevel4alpha)/100.0
          (*pstate).window->draw,(*pstate).view
        endif
      end
                        
     'atmLevel4alpha': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).atmLevel4alpha = newval
        (*pstate).opolygons4 -> setProperty, alpha_channel=((*pstate).atmLevel4alpha)/100.0
        (*pstate).window->draw, (*pstate).view                           
      end  

     'atmLevel4height': $
      begin
        widget_control, event.id, get_value=newval
        new_scale = (3396.+float(newval))/(3396.+float((*pstate).atmLevel4height))
        (*pstate).atmLevel4height=fix(newval)
        (*pstate).atmModel4->scale,new_scale,new_scale,new_scale
        (*pstate).window->draw,(*pstate).view
      end
                         
     'atmLevel5': $
      begin
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
                    
     'atmLevel5Load': $
      begin
        input_file = dialog_pickfile(path=(*pstate).install_directory,$
                                     filter='*.png')
        if input_file ne '' then begin
          read_png,input_file,image
          oImage5 = OBJ_NEW('IDLgrImage', image )
          (*pstate).opolygons5 -> setproperty, texture_map=oimage5
          (*pstate).opolygons5 -> setProperty, $
                      alpha_channel=((*pstate).atmLevel5alpha)/100.0
          (*pstate).window->draw,(*pstate).view
        endif
      end
                        
     'atmLevel5alpha': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).atmLevel5alpha = newval
        (*pstate).opolygons5 -> setProperty, $
                    alpha_channel=((*pstate).atmLevel5alpha)/100.0
        (*pstate).window->draw, (*pstate).view                           
      end

     'atmLevel5height': $
      begin
        widget_control, event.id, get_value=newval
        new_scale = (3396.+float(newval))$
                  / (3396.+float((*pstate).atmLevel5height))
        (*pstate).atmLevel5height=fix(newval)
        (*pstate).atmModel5->scale,new_scale,new_scale,new_scale
        (*pstate).window->draw,(*pstate).view
      end
                         
     'atmLevel6': $
      begin
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
                    
     'atmLevel6Load': $
      begin
        input_file = dialog_pickfile(path=(*pstate).install_directory,$
                                     filter='*.png')
        if input_file ne '' then begin
          read_png,input_file,image
          oImage6 = OBJ_NEW('IDLgrImage', image )
          (*pstate).opolygons6 -> setproperty, texture_map=oimage6
          (*pstate).opolygons6 -> setProperty, $
                      alpha_channel=((*pstate).atmLevel6alpha)/100.0
          (*pstate).window->draw,(*pstate).view
        endif
      end
                        
     'atmLevel6alpha': $
      begin
        widget_control, event.id, get_value=newval
        (*pstate).atmLevel6alpha = newval
        (*pstate).opolygons6 -> setProperty, alpha_channel=((*pstate).atmLevel6alpha)/100.0
        (*pstate).window->draw, (*pstate).view                           
      end             
                         
     'atmLevel6height': $
      begin
        widget_control, event.id, get_value=newval
        new_scale = (3396.+float(newval))$
                  / (3396.+float((*pstate).atmLevel6height))
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
                        
     'vec_scale': $
      begin
        widget_control,event.id, get_value=newval
        scale_factor=newval/100.0
        ;RESCALE THE DISPLAYED VECTOR FIELD
        old_vec_data = (*pstate).vector_data
                      
        MVN_KP_3D_VECTOR_SCALE, old_vec_data, (*pstate).vector_scale, scale_factor
        (*pstate).vector_data = old_vec_data     
        (*pstate).vector_path->getproperty,data=old_data
        for i=0,(n_elements((*pstate).x_orbit)/2)-1 do begin
          old_data[0,(i*2)+1] = old_vec_data[0, i] + old_data[0,(i*2)]
          old_data[1,(i*2)+1] = old_vec_data[1, i] + old_data[1,(i*2)]
          old_data[2,(i*2)+1] = old_vec_data[2, i] + old_data[2,(i*2)]
        endfor
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

     'help': $
      begin
        widget_control,(*pstate).subbaseR1, map=0
        widget_control,(*pstate).subbaseR6, map=1

        widget_control,(*pstate).text,set_value='Fear not, help is on the way.'
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
       
     'config_save': $
      begin
        file = dialog_pickfile(/write, $
          title="Pick a file to save your viz configuration",filter='*.sav')
        if file ne '' then begin
          (*pstate).model->getproperty,transform=model_trans
          config_struct = {config, model_trans:model_trans}              
          save,config_struct,filename=file
        endif
      end
                    
     'config_load': $
      begin
        file = dialog_pickfile(/read, $
          title="Restore a vizualization configuration", filter='*.sav')
        if file ne '' then begin
          restore,file              
          (*pstate).model->setproperty,transform = config_struct.model_trans
          (*pstate).window->draw,(*pstate).view              
        endif
      end
                      
     'save_view': begin
                    outfile = dialog_pickfile(default_extension='png',/write)  
                    if outfile ne '' then begin                                   
                      buffer = Obj_New('IDLgrBuffer', DIMENSIONS=[800,800])
                      buffer -> Draw, (*pstate).view
                      buffer -> GetProperty, Image_Data=snapshot
                      Obj_Destroy, buffer
                      write_png, outfile,snapshot
                    endif
                  end
        
      'orbit_reset': $
        begin
          temp_vert = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)
          temp_vert[0,*] = 255
          (*pstate).orbit_path->setProperty,vert_color=temp_vert
          (*pstate).window->draw,(*pstate).view
        end
        
      'lpw_list': begin
                    mvn_kp_3d_event_insitu_scalar_data,event,'LPW.'
                  end           

      'euv_list': begin
                    mvn_kp_3d_event_insitu_scalar_data,event,'EUV.'
                  end   
                             
      'static_list': begin
                       mvn_kp_3d_event_insitu_scalar_data,event,'STATIC.'
                     end
                       
      'swia_list': begin
                     mvn_kp_3d_event_insitu_scalar_data,event,'SWIA.'
                   end
                     
      'swea_list': begin
                     mvn_kp_3d_event_insitu_scalar_data,event,'SWEA.'
                   end
                     
      'mag_list': begin
                    mvn_kp_3d_event_insitu_scalar_data,event,'MAG.'
                  end
                    
      'sep_list': begin
                    mvn_kp_3d_event_insitu_scalar_data,event,'SEP.'
                  end

      'ngims_list': begin
                      mvn_kp_3d_event_insitu_scalar_data, event, 'NGIMS.'
                    end

      'user_list': begin
                     mvn_kp_3d_event_insitu_scalar_data,event,'USER.'
                   end
                   
      'colortable': $
        begin
          xloadct,/silent,/use_current,group=(*pstate).base ,/modal
          (*pstate).orbit_path->getproperty,vert_color=temp_vert
          insitu_spec = (*pstate).insitu
          MVN_KP_3D_PATH_COLOR, insitu_spec, (*pstate).level0_index, $
                                (*pstate).level1_index, $
                                (*pstate).path_color_table, temp_vert,$
                                (*pstate).colorbar_ticks, $
                                (*pstate).colorbar_min, $
                                (*pstate).colorbar_max, $
                                (*pstate).colorbar_stretch
          (*pstate).orbit_path->SetProperty,vert_color=temp_vert
          ;CHANGE THE COLOR BAR SETTINGS
          (*pstate).colorbar1->setproperty,red_Values=r_curr
          (*pstate).colorbar1->setproperty,green_Values=g_curr
          (*pstate).colorbar1->setproperty,blue_Values=b_curr
          (*pstate).colorbar_ticktext->setproperty,$
                strings=string((*pstate).colorbar_ticks)
          (*pstate).window ->draw,(*pstate).view
        end   
                      
      'ColorBarPlot': $
          begin
            (*pstate).colorbarmodel.getProperty, HIDE=result
            if result eq 1 then (*pstate).colorbarmodel->setProperty,hide=0
            if result eq 0 then (*pstate).colorbarmodel->setProperty,hide=1
            (*pstate).window ->draw,(*pstate).view
          end
             
      'orbitPlotName': $
        begin
          (*pstate).plottednamemodel.getProperty, HIDE=result
          if result eq 1 then (*pstate).plottednamemodel->setProperty,hide=0
          if result eq 0 then (*pstate).plottednamemodel->setProperty,hide=1
          (*pstate).window ->draw,(*pstate).view
        end

      'vector_field': $
        begin
          mvn_kp_3d_event_insitu_vector_field,event
        end

      'vector_display': $
        begin
          (*pstate).vector_model.getProperty, HIDE=result
          if result eq 1 then begin
            (*pstate).vector_model->setProperty,hide=0
            widget_control,(*pstate).subbaseR10a, sensitive=1
            widget_control,(*pstate).subbaseR10c, sensitive=1
            widget_control,(*pstate).subbaseR10d, sensitive=1
            widget_control,(*pstate).button10, set_value='Hide Vector Data'
          endif
          if result eq 0 then begin
            (*pstate).vector_model->setProperty,hide=1
            widget_control,(*pstate).subbaseR10a, sensitive=0
            widget_control,(*pstate).subbaseR10c, sensitive=0
            widget_control,(*pstate).subbaseR10d, sensitive=0
            widget_control,(*pstate).button10, set_value='Display Vector Data'
          endif
          (*pstate).window ->draw,(*pstate).view
        end
          
      'vector_color_method': $
        begin
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
                          mvn_kp_3d_event_insitu_vec_list,event,'LPW'
                        end
                        
        'euv_list_vec': begin
                          mvn_kp_3d_event_insitu_vec_list,event,'EUV'
                        end
                        
        'static_list_vec': begin
                             mvn_kp_3d_event_insitu_vec_list,event,'STATIC'
                           end
        
        'swia_list_vec': begin
                           mvn_kp_3d_event_insitu_vec_list,event,'SWIA'
                         end
                        
        'swea_list_vec': begin
                           mvn_kp_3d_event_insitu_vec_list,event,'SWEA'
                         end
                        
        'mag_list_vec': begin
                          mvn_kp_3d_event_insitu_vec_list,event,'MAG'
                        end                               
        
        'sep_list_vec': begin
                          mvn_kp_3d_event_insitu_vec_list,event,'SEP'
                        end
                        
        'ngims_list_vec': begin
                            mvn_kp_3d_event_insitu_vec_list,event,'NGIMS'
                          end               
                        
                                        
        'overplots': $
          begin
            (*pstate).plot_model.getProperty, HIDE=result
            if result eq 1 then (*pstate).plot_model->setProperty,hide=0
            if result eq 0 then (*pstate).plot_model->setProperty,hide=1
            (*pstate).window ->draw,(*pstate).view
          end
                     
        'colorbar_stretch': $
          begin
            widget_control,event.id,get_value=newval
            if newval eq 'Linear' then temp_stretch = 0
            if newval eq 'Log' then temp_stretch = 1
            (*pstate).colorbar_stretch = temp_stretch
            insitu_spec = (*pstate).insitu
            temp_vert = intarr(3,n_elements(insitu_spec.spacecraft.geo_x)*2)

            MVN_KP_3D_PATH_COLOR, insitu_spec, (*pstate).level0_index, $
                                  (*pstate).level1_index, $
                                  (*pstate).path_color_table, temp_vert,$
                                  temp_ticks, (*pstate).colorbar_min, $
                                  (*pstate).colorbar_max, temp_stretch

            (*pstate).orbit_path->SetProperty,vert_color=temp_vert
            ;CHANGE THE COLOR BAR SETTINGS
            (*pstate).colorbar1->setproperty,red_Values=r_curr
            (*pstate).colorbar1->setproperty,green_Values=g_curr
            (*pstate).colorbar1->setproperty,blue_Values=b_curr
            (*pstate).colorbar_ticktext->setproperty,$
                      strings=strtrim(string(temp_ticks),2)
            (*pstate).window ->draw,(*pstate).view
            ; UPDATE THE PARAMETER PLOT
            plot_y $
              = insitu_spec.((*pstate).level0_index).((*pstate).level1_index)

            if( keyword_set(temp_stretch) )then begin
              temp = where( ~finite(plot_y) or plot_y lt 0, num_nan )
              if( num_nan gt 0 )then plot_y[temp] = (*pstate).colorbar_min
              (*pstate).parameter_plot->setproperty,datay=alog10(plot_y)
            endif else begin
              temp = where( ~finite(plot_y), num_nan )
              ; Is there a better min value to use here?
              if( num_nan gt 0 )then plot_y[temp] = -1e-40
              (*pstate).parameter_plot->setproperty,datay=plot_y
            endelse

            ; UPDATE THE PARAMETER PLOT AXES
            (*pstate).parameter_plot->getproperty,yrange=yr,xrange=xr
            yc=mg_linear_function(yr,[-1.9,-1.5])
            (*pstate).parameter_plot->setproperty,xcoord_conv=xc,ycoord_conv=yc
            (*pstate).window->draw,(*pstate).view
          end
                          
        'colorbar_min': $
          begin
            widget_control,event.id,get_value=newval
            (*pstate).colorbar_min = newval[0]
            insitu_spec = (*pstate).insitu
            temp_vert $
              = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)

            MVN_KP_3D_PATH_COLOR, insitu_spec, (*pstate).level0_index, $
                                  (*pstate).level1_index, $
                                  (*pstate).path_color_table, temp_vert,$
                                  temp_ticks, (*pstate).colorbar_min, $
                                  (*pstate).colorbar_max, $
                                  (*pstate).colorbar_stretch

            (*pstate).orbit_path->SetProperty,vert_color=temp_vert
            ;CHANGE THE COLOR BAR SETTINGS
            (*pstate).colorbar1->setproperty,red_Values=r_curr
            (*pstate).colorbar1->setproperty,green_Values=g_curr
            (*pstate).colorbar1->setproperty,blue_Values=b_curr
            (*pstate).colorbar_ticktext->setproperty,$
                      strings=strtrim(string(temp_ticks),2)
            (*pstate).window ->draw,(*pstate).view
          end
                        
        'colorbar_max': $
          begin
            widget_control,event.id,get_value=newval
            (*pstate).colorbar_max = newval[0]
            insitu_spec = (*pstate).insitu
            temp_vert $
              = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)

            MVN_KP_3D_PATH_COLOR, insitu_spec, (*pstate).level0_index, $
                                  (*pstate).level1_index, $
                                  (*pstate).path_color_table, temp_vert,$
                                  temp_ticks, (*pstate).colorbar_min, $
                                  (*pstate).colorbar_max, $
                                  (*pstate).colorbar_stretch

            (*pstate).orbit_path->SetProperty,vert_color=temp_vert
            ;CHANGE THE COLOR BAR SETTINGS
            (*pstate).colorbar1->setproperty,red_Values=r_curr
            (*pstate).colorbar1->setproperty,green_Values=g_curr
            (*pstate).colorbar1->setproperty,blue_Values=b_curr
            (*pstate).colorbar_ticktext->setproperty,$
                      strings=strtrim(string(temp_ticks),2)
            (*pstate).window ->draw,(*pstate).view
          end
        'colorbar_title': $
            begin
            widget_control,event.id,get_value=newval
            (*pstate).colorbar_title->setproperty,strings=newval[0]
            (*pstate).window ->draw,(*pstate).view
          end                
        'colorbar_reset': $
          begin
            temp_vert $
              = intarr(3,n_elements((*pstate).insitu.spacecraft.geo_x)*2)
            colorbar_min = (*pstate).colorbar_min
            colorbar_max = (*pstate).colorbar_max
            insitu_spec = (*pstate).insitu

            MVN_KP_3D_PATH_COLOR, insitu_spec, (*pstate).level0_index, $
                                  (*pstate).level1_index, $
                                  (*pstate).path_color_table, temp_vert,$
                                  temp_ticks, colorbar_min, colorbar_max, $
                                  (*pstate).colorbar_stretch, /reset

            (*pstate).colorbar_min = colorbar_min
            (*pstate).colorbar_max = colorbar_max                       
            (*pstate).orbit_path->SetProperty,vert_color=temp_vert
            ;CHANGE THE COLOR BAR SETTINGS
            (*pstate).colorbar1->setproperty,red_Values=r_curr
            (*pstate).colorbar1->setproperty,green_Values=g_curr
            (*pstate).colorbar1->setproperty,blue_Values=b_curr
            (*pstate).colorbar_ticktext->setproperty,$
                      strings=strtrim(string(temp_ticks),2)
            (*pstate).window ->draw,(*pstate).view
          end
                         
        'orbit_onoff': $
          begin
            (*pstate).orbit_model.getProperty, HIDE=result
            if result eq 1 then (*pstate).orbit_model->setProperty,hide=0
            if result eq 0 then (*pstate).orbit_model->setProperty,hide=1
            (*pstate).window ->draw,(*pstate).view
          end
                         
        'periapse_all': $
          begin
            (*pstate).periapse_limb_model.getProperty, HIDE=result
            if result eq 1 then begin
              (*pstate).periapse_limb_model->setProperty,hide=0
              widget_control,(*pstate).subbaseR8b, sensitive=1
              widget_control,(*pstate).button8b, $
                             set_value='Hide All Profiles'
            endif
            if result eq 0 then begin
              (*pstate).periapse_limb_model->setProperty,hide=1
              widget_control,(*pstate).subbaseR8b, sensitive=0
              widget_control,(*pstate).button8b, $
                             set_value='Display All Profiles'
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
                         (*pstate).alt_plot->setproperty,xrange=[min(peri_data[1,*], /NAN),max(peri_data[1,*], /NAN)]
                         (*pstate).alt_plot->getproperty, xrange=xr, yrange=yr
                          xc = mg_linear_function([min(peri_data[1,*], /NAN),max(peri_data[1,*], /NAN)], [-1.75,-1.5])
                          yc = mg_linear_function(yr, [-1.3,1.0])
                          (*pstate).alt_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                          (*pstate).alt_xaxis_ticks->setproperty,strings=strtrim(string([min(peri_data[1,*], /NAN),max(peri_data[1,*], /NAN)], format='(E8.2)'),2)
                         
                          
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
                              (*pstate).orb_projection -> rotate,axis,-angle
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
                           (*pstate).vector_path -> getproperty, data=vec_path
                           vec_data = (*pstate).vector_data
                           
                           ;; Make idl 8.2.2 happy - We found that dereferencing the pointer to the struct in each
                           ;; iteration of the for loop was very slow in 8.2.2
                           insitu_spec = (*pstate).insitu

                           if choice eq 'Planetocentric' then begin
                            ;UPDATE THE ORBITAL PATH
                              for i=0L,n_elements((*pstate).insitu.spacecraft.geo_x)-1 do begin
                                data[0,i*2] = insitu_spec[i].spacecraft.geo_x/10000.0
                                data[0,(i*2)+1] = insitu_spec[i].spacecraft.geo_x/10000.0+(*pstate).orbit_offset
                                data[1,i*2] = insitu_spec[i].spacecraft.geo_y/10000.0
                                data[1,(i*2)+1] = (insitu_spec[i].spacecraft.geo_y/10000.0)+(*pstate).orbit_offset
                                data[2,i*2] = (insitu_spec[i].spacecraft.geo_z/10000.0)
                                data[2,(i*2)+1] = (insitu_spec[i].spacecraft.geo_z/10000.0)+(*pstate).orbit_offset
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
                              ;UPDATE THE VECTOR WHISKERS
                                vec_data1 = vec_data
                                for i=0, n_elements((*pstate).insitu.spacecraft.geo_x)-1 do begin
                                  vec_path[0,i*2] = insitu_spec[i].spacecraft.geo_x/10000.0
                                  vec_path[1,i*2] = insitu_spec[i].spacecraft.geo_y/10000.0
                                  vec_path[2,i*2] = insitu_spec[i].spacecraft.geo_z/10000.0
                                  vec_data[0, i] = (vec_data1[0, i]*insitu_spec[i].spacecraft.t11)+$
                                                        (vec_data1[1, i]*insitu_spec[i].spacecraft.t21)+$
                                                        (vec_data1[2, i]*insitu_spec[i].spacecraft.t31)
                                  vec_data[1, i] = (vec_data1[0, i]*insitu_spec[i].spacecraft.t12)+$
                                                        (vec_data1[1, i]*insitu_spec[i].spacecraft.t22)+$
                                                        (vec_data1[2, i]*insitu_spec[i].spacecraft.t32)
                                  vec_data[2, i] = (vec_data1[0, i]*insitu_spec[i].spacecraft.t13)+$
                                                        (vec_data1[1, i]*insitu_spec[i].spacecraft.t23)+$
                                                        (vec_data1[2, i]*insitu_spec[i].spacecraft.t33)                                                          
                                  vec_path[0,(i*2)+1] = vec_data[0, i] + vec_path[0,(i*2)]
                                  vec_path[1,(i*2)+1] = vec_data[1, i] + vec_path[1,(i*2)]
                                  vec_path[2,(i*2)+1] = vec_data[2, i] + vec_path[2,(i*2)]                                
                                endfor                                
                                (*pstate).vector_path->setproperty,data=vec_path
                                (*pstate).vector_data = vec_data
                               
                               ;Undo the mars globe rotation from MSO coordinate system
                               (*pstate).mars_globe -> rotate, [-1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               (*pstate).mars_globe -> rotate, [0,-1,0], (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_latitude
                               (*pstate).mars_globe -> rotate, [0,0,-1], -(*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude
                               
                               ;Undo the axes model rotation from MSO coordinate system
                               (*pstate).axesmodel -> rotate, [-1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               (*pstate).axesmodel -> rotate, [0,-1,0], (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_latitude
                               (*pstate).axesmodel -> rotate, [0,0,-1], -(*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude
                               
                               ;Undo the orbit projection rotation from MSO coordinate system
                               (*pstate).orb_projection -> rotate, [-1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               (*pstate).orb_projection -> rotate, [0,-1,0], (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_latitude
                               (*pstate).orb_projection -> rotate, [0,0,-1], -(*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude

                               ;Undo the grid rotation from MSO coordinate system
                               (*pstate).gridlines -> rotate, [-1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               (*pstate).gridlines -> rotate, [0,-1,0], (*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_latitude
                               (*pstate).gridlines-> rotate, [0,0,-1], -(*pstate).insitu((*pstate).time_index).spacecraft.subsolar_point_geo_longitude
                                                              
                               ;Change the sun vector back to GEO coordinates
                               (*pstate).sun_vector -> getproperty, data=data1
                               data1[0,1] = (*pstate).solar_x_coord((*pstate).time_index)
                               data1[1,1] = (*pstate).solar_y_coord((*pstate).time_index)
                               data1[2,1] = (*pstate).solar_z_coord((*pstate).time_index)
                               (*pstate).sun_vector->setProperty,data=data1

                               ;Change light source back to GEO coordinates
                               (*pstate).dirlight->setProperty, $
                               location=[(*pstate).solar_x_coord((*pstate).time_index),$
                                 (*pstate).solar_y_coord((*pstate).time_index),$
                                 (*pstate).solar_z_coord((*pstate).time_index)]

                               ;Change subsolar point back to GEO coordinatess
                               (*pstate).sub_solar_line->setProperty, $
                               data=[(*pstate).subsolar_x_coord[(*pstate).time_index],$
                               (*pstate).subsolar_y_coord[(*pstate).time_index],$
                               (*pstate).subsolar_z_coord[(*pstate).time_index]]
                               
                               
                           endif else begin ;MSO Coordinate System
                            ;UPDATE THE ORBITAL PATH 
                              for i=0L,n_elements((*pstate).insitu.spacecraft.mso_x)-1 do begin
                                data[0,i*2] = insitu_spec[i].spacecraft.mso_x/10000.0
                                data[0,(i*2)+1] = insitu_spec[i].spacecraft.mso_x/10000.0+(*pstate).orbit_offset
                                data[1,i*2] = insitu_spec[i].spacecraft.mso_y/10000.0
                                data[1,(i*2)+1] = (insitu_spec[i].spacecraft.mso_y/10000.0)+(*pstate).orbit_offset
                                data[2,i*2] = (insitu_spec[i].spacecraft.mso_z/10000.0)
                                data[2,(i*2)+1] = (insitu_spec[i].spacecraft.mso_z/10000.0)+(*pstate).orbit_offset
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
                                  vec_data1 = vec_data
                                for i=0, n_elements((*pstate).insitu.spacecraft.mso_x)-1 do begin
                                  vec_path[0,i*2] = insitu_spec[i].spacecraft.mso_x/10000.0
                                  vec_path[1,i*2] = insitu_spec[i].spacecraft.mso_y/10000.0
                                  vec_path[2,i*2] = insitu_spec[i].spacecraft.mso_z/10000.0
                                  vec_data[0, i] = (vec_data1[0, i]*insitu_spec[i].spacecraft.t11)+$
                                                        (vec_data1[1, i]*insitu_spec[i].spacecraft.t12)+$
                                                        (vec_data1[2, i]*insitu_spec[i].spacecraft.t13)
                                  vec_data[1, i] = (vec_data1[0, i]*insitu_spec[i].spacecraft.t21)+$
                                                        (vec_data1[1, i]*insitu_spec[i].spacecraft.t22)+$
                                                        (vec_data1[2, i]*insitu_spec[i].spacecraft.t23)
                                  vec_data[2, i] = (vec_data1[0, i]*insitu_spec[i].spacecraft.t31)+$
                                                        (vec_data1[1, i]*insitu_spec[i].spacecraft.t32)+$
                                                        (vec_data1[2, i]*insitu_spec[i].spacecraft.t33)                      
                                  vec_path[0,(i*2)+1] = vec_data[0, i] + vec_path[0,(i*2)]
                                  vec_path[1,(i*2)+1] = vec_data[1, i] + vec_path[1,(i*2)]
                                  vec_path[2,(i*2)+1] = vec_data[2, i] + vec_path[2,(i*2)]                                
                                endfor                                
                                (*pstate).vector_path->setproperty,data=vec_path
                                (*pstate).vector_data = vec_data
                               
                               ;turn off the corona plotting because they can't be easily converted to MSO coordinates
                               ; (*pstate).corona_lo_disk_model.getProperty, hide=result
                               ;  if result eq 0 then (*pstate).corona_lo_disk_model.setproperty, hide=1
                               
                               if (*pstate).instrument_array[14] eq 1 then begin
                                (*pstate).corona_lo_limb_model.getProperty, hide=result
                                 if result eq 0 then (*pstate).corona_lo_limb_model.setproperty, hide=1
                               endif
                               if (*pstate).instrument_array[13] eq 1 then begin
                                (*pstate).corona_lo_high_model.getProperty, hide=result
                                 if result eq 0 then (*pstate).corona_lo_high_model.setproperty, hide=1 
                               endif
                             ;   (*pstate).corona_e_disk_model.getProperty, hide=result
                             ;    if result eq 0 then (*pstate).corona_e_disk_model.setproperty, hide=1
                               if (*pstate).instrument_array[15] eq 1 then begin
                                (*pstate).corona_e_limb_model.getProperty, hide=result
                                 if result eq 0 then (*pstate).corona_e_limb_model.setproperty, hide=1  
                               endif
                               if (*pstate).instrument_array[10] eq 1 then begin
                                 (*pstate).corona_e_high_model.getProperty, hide=result
                                 if result eq 0 then (*pstate).corona_e_high_model.setproperty, hide=1 
                               endif 
                               
                               ;Rotate the planet to be under the sun                          
                               (*pstate).mars_globe -> rotate, [0,0,1], -(*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_longitude
                               (*pstate).mars_globe -> rotate, [0,1,0], (*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_latitude
                               (*pstate).mars_globe -> rotate, [1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               
                               ;Rotate the axes to align with the planet's new rotation
                               (*pstate).axesmodel -> rotate, [0,0,1], -(*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_longitude
                               (*pstate).axesmodel -> rotate, [0,1,0], (*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_latitude                               
                               (*pstate).axesmodel -> rotate, [1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               
                               ;Rotate the orbit projection to align with the planet's new rotation
                               (*pstate).orb_projection -> rotate, [0,0,1], -(*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_longitude
                               (*pstate).orb_projection -> rotate, [0,1,0], (*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_latitude
                               (*pstate).orb_projection -> rotate, [1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               
                               ;Rotate the grid to align with the planet's new rotation
                               (*pstate).gridlines -> rotate, [0,0,1], -(*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_longitude
                               (*pstate).gridlines -> rotate, [0,1,0], (*pstate).insitu[(*pstate).time_index].spacecraft.subsolar_point_geo_latitude
                               (*pstate).gridlines -> rotate, [1,0,0], 25.19 * (-cos((*pstate).insitu[(*pstate).time_index].spacecraft.mars_season*!dtor))
                               
                               ;Change the sun vector to the x-axis
                               (*pstate).sun_vector -> getproperty, data=data1
                               data1[0,1] = 10000.0
                               data1[1,1] = 0.0
                               data1[2,1] = 0.0
                               (*pstate).sun_vector->setProperty,data=data1

                               ;Change light source to sit on the x-axis
                              (*pstate).dirlight->setProperty, location=[10000,0,0]
    
                              ;Change subsolar point to the x-axis
                              (*pstate).sub_solar_line->setProperty, data=[10000.0,0,0]
                               
                           endelse
        
                 
                              ;redraw the scene
                              (*pstate).orbit_path -> setproperty, data=data
                              (*pstate).window->draw,(*pstate).view
        
                           
                         end
           
          'corona_lo_disk': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                        
                              if newval[index] ne 'LoRes Disk' then begin
                                min_val = min((*pstate).iuvs.corona_lo_disk.radiance[index-1], /NAN)
                                max_val = max((*pstate).iuvs.corona_lo_disk.radiance[index-1], /NAN)
                                
                                disk_index = 0
                                for i=0, n_elements((*pstate).iuvs.corona_lo_disk.lat) - 1 do begin
                                 if finite((*pstate).iuvs[i].corona_lo_disk.lat) then begin
                                  (*pstate).corona_lo_disk_poly[disk_index]->getproperty,color=d_color
                                  MVN_KP_3D_CORONA_DISK_COLORS,  (*pstate).iuvs[i].corona_lo_disk.radiance[index-1], min_val, max_val, d_color
                                  (*pstate).corona_lo_disk_poly[disk_index]->setproperty, color=d_color
                                  disk_index = disk_index+1
                                 endif
                                endfor
                                                              
                                (*pstate).corona_lo_disk_model->setproperty,hide=0
                              endif else begin
                                (*pstate).corona_lo_disk_model->setproperty,hide=1
                              endelse
                              (*pstate).window->draw,(*pstate).view
                            end
          'corona_lo_limb': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval

                              if newval[index] ne 'LoRes Limb' then begin                          
                                  (*pstate).corona_lo_limb_poly -> getproperty, vert_color=vert_color
  
                                  MVN_KP_3D_CORONA_COLORS, 'lo_limb', newval, index, vert_color, (*pstate).iuvs.corona_lo_limb    
                                 
                                  (*pstate).corona_lo_limb_poly->SetProperty,vert_color=vert_color
                                  (*pstate).corona_lo_limb_model->setproperty,hide=0
                              endif else begin
                                (*pstate).corona_lo_limb_model -> setproperty,hide=1
                              endelse
                              (*pstate).window->draw,(*pstate).view   
                            end
          'corona_lo_high': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                              
                              if newval[index] ne 'LoRes High' then begin
                                (*pstate).corona_lo_high_poly -> getproperty, vert_color=vert_color
                                MVN_KP_3D_CORONA_COLORS, 'lo_high', newval, index, vert_color, (*pstate).iuvs.corona_lo_high
                   
                                (*pstate).corona_lo_high_poly->SetProperty,vert_color=vert_color
                                (*pstate).corona_lo_high_model->SetProperty,hide=0
                              endif else begin
                                (*pstate).corona_lo_high_model->SetProperty,hide=1
                              endelse
                                
                              (*pstate).window->draw,(*pstate).view  
                            end
          'corona_e_disk': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                        
                              if newval[index] ne 'Echelle Disk' then begin
                                min_val = min((*pstate).iuvs.corona_e_disk.radiance[index-1], /NAN)
                                max_val = max((*pstate).iuvs.corona_e_disk.radiance[index-1], /NAN)
                                
                                disk_index = 0
                                for i=0, n_elements((*pstate).iuvs.corona_e_disk.lat) - 1 do begin
                                 if finite((*pstate).iuvs[i].corona_e_disk.lat) then begin
                                  (*pstate).corona_e_disk_poly[disk_index]->getproperty,color=d_color
                                  MVN_KP_3D_CORONA_DISK_COLORS,  (*pstate).iuvs[i].corona_e_disk.radiance[index-1], min_val, max_val, d_color
                                  (*pstate).corona_e_disk_poly[disk_index]->setproperty, color=d_color
                                  disk_index = disk_index+1
                                 endif
                                endfor
                              
                                (*pstate).corona_e_disk_model->setproperty,hide=0
                              endif else begin
                                (*pstate).corona_e_disk_model->setproperty,hide=1
                              endelse
                              (*pstate).window->draw,(*pstate).view          
                           end
          'corona_e_limb': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                              
                              if newval[index] ne 'Echelle Limb' then begin
                                (*pstate).corona_e_limb_poly -> getproperty, vert_color=vert_color
                                MVN_KP_3D_CORONA_COLORS, 'e_limb', newval, index, vert_color, (*pstate).iuvs.corona_e_limb
                                
                                (*pstate).corona_e_limb_poly->SetProperty,vert_color=vert_color
                                (*pstate).corona_e_limb_model->Setproperty,hide=0
                              endif else begin
                                (*pstate).corona_e_limb_model->setproperty, hide=1
                              endelse
                              (*pstate).window->draw,(*pstate).view
                           end
          'corona_e_high': begin
                              index = widget_info(event.id, /droplist_select)
                              widget_control, event.id, get_value=newval
                              
                              if newval[index] ne 'Echelle High' then begin
                                (*pstate).corona_e_high_poly -> getproperty, vert_color=vert_color
                                MVN_KP_3D_CORONA_COLORS, 'e_high', newval, index, vert_color, (*pstate).iuvs.corona_e_high

                                (*pstate).corona_e_high_poly->SetProperty,vert_color=vert_color
                                (*pstate).corona_e_high_model->SetProperty, hide=0
                              endif else begin
                                (*pstate).corona_e_high_model->SetProperty, hide=1
                              endelse
                              (*pstate).window->draw,(*pstate).view
                           end
                         
         
         'apo_time': begin
                      widget_control,event.id, get_value=newval
                      if newval eq 'Nearest' then (*pstate).apo_time_blend = 1
                      if newval eq 'Exact' then (*pstate).apo_time_blend = 0
                     end
         
         'loadct_cld': begin
                        xloadct,/silent,/use_current,group=(*pstate).base ,/modal
                       end
         
         'loadct_cll': begin
                        xloadct,/silent,/use_current,group=(*pstate).base ,/modal
                       end
         
         'loadct_clh': begin
                        xloadct,/silent,/use_current,group=(*pstate).base ,/modal
                       end
         
         'loadct_ced': begin  
                        xloadct,/silent,/use_current,group=(*pstate).base ,/modal
                       end  
                       
         'loadct_cel': begin
                        xloadct,/silent,/use_current,group=(*pstate).base ,/modal
                       end
                       
         'loadct_ceh': begin  
                        xloadct,/silent,/use_current,group=(*pstate).base ,/modal
                       end  
         
         'alpha_cld': begin
                        widget_control, event.id, get_value=newval
                        (*pstate).corona_lo_disk_alpha = newval
                        for i= 0,n_elements((*pstate).corona_lo_disk_poly)-1 do begin
                          (*pstate).corona_lo_disk_poly[i] -> setProperty, alpha_channel=((*pstate).corona_lo_disk_alpha)/100.0
                        endfor
                        (*pstate).window->draw, (*pstate).view
                      end
         
         'alpha_cll': begin
                        widget_control, event.id, get_value=newval
                        (*pstate).corona_lo_limb_alpha = newval
                        for i=0, n_elements((*pstate).corona_lo_limb_poly)-1 do begin
                          (*pstate).corona_lo_limb_poly[i] -> setProperty, alpha_channel=((*pstate).corona_lo_limb_alpha)/100.0
                        endfor
                        (*pstate).window->draw, (*pstate).view
                      end
         
         'alpha_clh': begin
                        widget_control, event.id, get_value=newval
                        (*pstate).corona_lo_high_alpha = newval
                          (*pstate).corona_lo_high_poly -> setProperty, alpha_channel=newval/100.0
                        (*pstate).window->draw, (*pstate).view
                      end
         
         'alpha_ced': begin
                        widget_control, event.id, get_value=newval
                        (*pstate).corona_e_disk_alpha = newval
                        for i=0, n_elements((*pstate).corona_e_disk_poly)-1 do begin
                          (*pstate).corona_e_disk_poly[i] -> setProperty, alpha_channel=((*pstate).corona_e_disk_alpha)/100.0
                        endfor
                        (*pstate).window->draw, (*pstate).view
                      end
         
         'alpha_cel': begin
                        widget_control, event.id, get_value=newval
                        (*pstate).corona_e_limb_alpha = newval
                        (*pstate).corona_e_limb_poly -> setProperty, alpha_channel=((*pstate).corona_e_limb_alpha)/100.0
                        (*pstate).window->draw, (*pstate).view
                      end
         
         'alpha_ceh': begin
                        widget_control, event.id, get_value=newval
                        (*pstate).corona_e_high_alpha = newval
                        (*pstate).corona_e_high_poly -> setProperty, alpha_channel=((*pstate).corona_e_high_alpha)/100.0
                        (*pstate).window->draw, (*pstate).view
                      end
         
         
         
                       
  endcase     ;END OF BUTTON CONTROL
  
end

