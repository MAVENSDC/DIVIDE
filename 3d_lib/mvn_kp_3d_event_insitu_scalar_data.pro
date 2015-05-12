;+
; :Name:
;   mvn_kp_3d_get_insitu_data
; 
; :Description:
;   Procedure to respond to widget events selecting data from the in-situ
;   instruments and adjusting the parameter plot acordingly.
;
; :Author:
;   Kevin McGouldrick (2015-May-08)
;
; :Parameters:
;   event: in, required
;     widget event
;   inst_code: in, required, string
;     short string indicating instrument code begin selected.  There
;     might be a more elegant way of doing this.
;     
; :Version:
;  1.0
;
;-
pro mvn_kp_3d_event_insitu_scalar_data,event,inst_code
;
;  This is required to be able to update pstate
;
  widget_control, event.top, get_uvalue=pstate
  mag_index = widget_info(event.id, /droplist_select)
;
;  This captures the current widget event
;
  widget_control, event.id, get_value=newval
  insitu_spec = (*pstate).insitu
          
;
;  Parse the given requested parameter, verify its existence, and
;  set some useful variables
;
  parameter = inst_code+strtrim(string(newval[mag_index]))                      
  MVN_KP_TAG_PARSER, insitu_spec, base_tag_count, $
                     first_level_count, second_level_count, $
                     base_tags,  first_level_tags, second_level_tags

  MVN_KP_TAG_VERIFY, insitu_spec, parameter,base_tag_count, $
                     first_level_count, base_tags,  $
                     first_level_tags, check, level0_index, $
                     level1_index, tag_array
                                            

;
;UPDATE THE PARAMETER PLOT 
;
  plot_y = insitu_spec.(level0_index).(level1_index)
  if (*pstate).colorbar_stretch then begin
    temp = where( ~finite(plot_y) or plot_y lt 0, num_nan )
    if num_nan gt 0 then plot_y[temp] = (*pstate).colorbar_min
  endif else begin
    temp = where( ~finite(plot_y), num_nan )
    if num_nan gt 0 then plot_y[temp] = -1.e-40
  endelse

; UPDATE AXIS RANGES
  if (*pstate).colorbar_stretch then begin
    (*pstate).parameter_plot->setproperty, datay=alog10(plot_y)
  endif else begin
    (*pstate).parameter_plot->setproperty, datay=plot_y
  endelse
  (*pstate).parameter_plot->getproperty, xrange=xr, yrange=yr

;CHECK FOR ALL NAN VALUE DEGENERATE CASE
  nan_error_check = 0
  for i=0,n_elements(insitu_spec.(level0_index).(level1_index))-1 do begin
     var1 = finite(insitu_spec[i].(level0_index).(level1_index))
     if var1 eq 1 then nan_error_check=1 
  endfor
  if nan_error_check eq 1 then begin           
     xc = mg_linear_function(xr, [-1.7,1.4])
     yc = mg_linear_function(yr, [-1.9,-1.5])

     if finite(yc[0]) and finite(yc[1])  then begin
        (*pstate).parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
     endif
  endif else begin
     print,'ALL DATA WITHIN THE REQUESTED KEY PARAMETER IS NaN.'
     print,'No data to display.'
  endelse
  ya = keyword_Set((*pstate).colorbar_stretch) $
     ? strtrim(string(10.^yr, format='(e7.0)'),2) $
     : strtrim(string(yr,format='(e7.0)'),2)
  (*pstate).parameter_yaxis_ticktext->setproperty,strings=ya

;
;  Update the color bar parameters
;
  if (*pstate).colorbar_stretch then begin
    (*pstate).colorbar_min = 10.^yr[0]
    (*pstate).colorbar_max = 10.^yr[1]
  endif else begin
    (*pstate).colorbar_min = yr[0]
    (*pstate).colorbar_min = yr[1]
  endelse
;
; UPDATE THE ORBIT PATH
;
  temp_vert = intarr(3,n_elements(insitu_spec.spacecraft.geo_x)*2)

  MVN_KP_3D_PATH_COLOR, insitu_spec, level0_index, level1_index, $
                        (*pstate).path_color_table, temp_vert, $
                        new_ticks, (*pstate).colorbar_min, $
                        (*pstate).colorbar_max, (*pstate).colorbar_stretch

  (*pstate).colorbar_ticks = new_ticks
  plotted_parameter_name = tag_array[0]+':'+tag_array[1]
  (*pstate).level0_index = level0_index
  (*pstate).level1_index = level1_index
  (*pstate).plottext1->setproperty,strings=plotted_parameter_name
  (*pstate).orbit_path->SetProperty,vert_color=temp_vert
;
; UPDATE THE COLOR BAR ITSELF
;
  (*pstate).colorbar_ticktext->setproperty,$
            strings=string((*pstate).colorbar_ticks, format='(e7.0)')
  (*pstate).orbit_path->SetProperty,vert_color=temp_vert
  (*pstate).colorbar1->setproperty,red_Values=r_curr
  (*pstate).colorbar1->setproperty,green_Values=g_curr
  (*pstate).colorbar1->setproperty,blue_Values=b_curr
;
;  Now draw the new object(s)
;
  (*pstate).window->draw,(*pstate).view   

end
