pro_temp_ngims

  'ngims_list': $
     begin
       mag_index = widget_info(event.id, /droplist_select)
       widget_control, event.id, get_value=newval
       insitu_spec = (*pstate).insitu
       parameter = 'NGIMS.'+strtrim(string(newval[mag_index]))
       MVN_KP_TAG_PARSER, insitu_spec, base_tag_count, first_level_count, $
                          second_level_count, base_tags, $
                          first_level_tags, second_level_tags
       MVN_KP_TAG_VERIFY, insitu_spec, parameter,base_tag_count, $
                          first_level_count, base_tags,  $
                          first_level_tags, check, level0_index, $
                          level1_index, tag_array             
       temp_vert = intarr(3,n_elements(insitu_spec.spacecraft.geo_x)*2) 

       MVN_KP_3D_PATH_COLOR, insitu_spec, level0_index, level1_index, $
                             (*pstate).path_color_table, temp_vert,new_ticks,$
                             (*pstate).colorbar_min, (*pstate).colorbar_max, $
                             (*pstate).colorbar_stretch
       (*pstate).colorbar_ticks = new_ticks
       plotted_parameter_name = tag_array[0]+':'+tag_array[1]
       (*pstate).level0_index = level0_index
       (*pstate).level1_index = level1_index
       (*pstate).plottext1->setproperty,strings=plotted_parameter_name
       (*pstate).orbit_path->SetProperty,vert_color=temp_vert
    ;CHANGE THE COLOR BAR SETTINGS
       (*pstate).colorbar_ticktext->setproperty,$
          strings=string((*pstate).colorbar_ticks,format='(e7.0)')

    ;UPDATE THE PARAMETER PLOT 
       plot_y = insitu_spec.(level0_index).(level1_index)
       if( keyword_set((*pstate).colorbar_stretch) )then begin
          temp = where( ~finite(plot_y) or plot_y lt 0, num_nan )
          if num_nan gt 0 then plot_y[temp] = (*pstate).colorbar_min
       endif else begin
          temp = where( ~finite(plot_y), num_nan )
          if num_nan gt 0 then plot_y[temp] = -1e-40
       endelse
       ;-orig-(*pstate).parameter_plot->setproperty,datay=insitu_spec.(level0_index).(level1_index)
       if keyword_set((*pstate).colorbar_stretch) then begin
          (*pstate).parameter_plot->setproperty,datay=alog10(plot_y)
       endif else begin
          (*pstate).parameter_plot->setproperty,datay=plot_y
       endelse
       ;(*pstate).parameter_plot->setproperty,datay=plot_y
       (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr 
       print,'xr=',xr
       print,'yr=',yr

     ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
       nan_error_check = 0
       for i=0,n_elements(insitu_spec.(level0_index).(level1_index))-1 do begin
          var1 = finite(insitu_spec[i].(level0_index).(level1_index))
          if var1 eq 1 then nan_error_check=1 
       endfor
       if nan_error_check eq 1 then begin              
          xc = mg_linear_function(xr, [-1.7,1.4])
          ;-orig yc = mg_linear_function(yr, [-1.9,-1.5])
          print,(*pstate).colorbar_stretch
          yc = keyword_set((*pstate).colorbar_stretch) $
             ? mg_linear_function(alog10(yr), [-1.9,-1.5]) $
             : mg_linear_function(yr, [-1.9,-1.5])
          if finite(yc[0]) and finite(yc[1])  then begin
             (*pstate).parameter_plot->setproperty,$
                xcoord_conv=xc, ycoord_conv=yc
          endif
       endif else begin
          print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS NaN.'
          print,'No data to display.'
       endelse
       ya = [strtrim(string(min(insitu_spec.(level0_index).(level1_index),/NaN),format='(e7.0)'),2),strtrim(string(max(insitu_spec.(level0_index).(level1_index),/NaN),format='(e7.0)'),2)]
       (*pstate).parameter_yaxis_ticktext->setproperty,strings=ya
       ;[strtrim(string(fix(min(insitu_spec.(level0_index).(level1_index)))),2),strtrim(string(fix(max(insitu_spec.(level0_index).(level1_index)))),2)]
       (*pstate).window->draw,(*pstate).view   
    end
