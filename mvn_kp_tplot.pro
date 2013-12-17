;+
; A WRAPPER ROUTINE TO INTERFACE WITH THE BERKELEY TPLOT CODE
;
; :Params:
;    kp_data: in, required, type=structure
;       the INSITU KP data structure from which to plot data
;    field: in, required, type=strarr,intarr
;       the INSITU kp data fields to plot, maybe an integer or string array for multiple choices
;
; :Keywords:
;    list: in, optional, type=boolean
;       if selected, will list the KP data fields included in kp_data
;    range: in, optional, type=boolean
;       if selected, will list the beginning and end times of kp_data
;    altitude: in, optional, type=boolean
;       if selected, will inclue altitude on the xaxis along with time
;    ytitles: in, optional, type=strarr
;       if included, this array allows the user to define the yaxis titles as they like
;    title: in, optional, type=string
;       if included, this provides an overall title to the plot window
;-


@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_range_select
@mvn_kp_tag_verify

pro MVN_KP_TPLOT, kp_data, field, time=time, altitude=altitude, list=list, ytitles=ytitles, title=top_title,range=range,noplot=noplot, zero=zero


  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags


  if keyword_set(list) then begin
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    goto,finish
  endif

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    goto,finish
  endif

  if keyword_set(top_title) then begin
    overall_title=top_title
  endif else begin
    overall_title=''
  endelse

  ;IF THE USER SUPPLIES A TIME RANGE, SET THE BEGINNING AND END INDICES
  
  if keyword_set(time) then begin     ;determine the start and end indices to plot
    MVN_KP_RANGE_SELECT, kp_data, time, kp_start_index, kp_end_index
  endif else begin                    ;otherwise plot all data within structure
   kp_start_index = 0
   kp_end_index = n_elements(kp_data.orbit)-1
  endelse


;SET DEFAULTS COLORS TO BLACK ON WHITE
    device,decompose=0
    !p.background='FFFFFF'x
    !p.color=0
    loadct,39,/silent

;DETEMINE THE TOTAL NUMBER OF PLOTS AND VARIABLES TO DEFINE ARRAYS.
    
    plot_count =intarr(n_elements(field))
    total_lines = 0
    true_index = strarr(50)
    merged_plots = 0
    
    for i=0,n_elements(field)-1 do begin
      check = strmatch(field[i],'*,*')
      if check eq 1 then begin
          merged_plots=merged_plots+1
          pos = 0
          pos1=0
        total_lines = total_lines+1
        while pos1 ne -1 do begin
          pos1 = strpos(field[i],',',pos)
          if pos1 ne -1 then begin
            true_index[total_lines-1] = strmid(field[i],pos,(pos1-pos))
            total_lines = total_lines+1
            pos=pos1+1
            plot_count[i]=plot_count[i]+1
          endif
        endwhile
        true_index[total_lines-1] = strmid(field[i],pos,(strlen(field[i])-pos))
        plot_count[i]=plot_count[i]+1
      endif else begin
        true_index[total_lines] = field[i]
        total_lines = total_lines+1
        plot_count[i] = 1
      endelse
    endfor
 
    true_index = true_index[0:total_lines-1]
  
  
  
  ;LOOP OVER EACH REQUESTED PLOT VARIABLE, CHECK IT'S VALIDITY, AND STORE THE DATA IN A TPLOT VARIABLE
  ; also calculate the min/max ranges for overplot uses
  
  tplot_variable_array = strarr(n_elements(true_index))
  temp_variable_names = strarr(n_elements(true_index))
  ymin = fltarr(n_elements(true_index))
  ymax = fltarr(n_elements(true_index))
  for i=0,n_elements(true_index) - 1 do begin
   if strmid(true_index[i],0,1) eq 't' then begin                                                                 ;IF THE USER REQUESTS A TPLOT VARIABLE INDEX
     tplot_names, names=tplot_available
     temp_variable_names[i] = tplot_available[fix(strmid(true_index[i],1))-1]
     tplot_variable_array[i] = temp_variable_names[i]
     get_data, tplot_available[fix(strmid(true_index[i],1))-1], data=data
     ymin[i] = min(data.y)
     ymax[i] = max(data.y)
   endif else begin                                                                                               ;IF THE USER REQUESTS A NON-TPLOT VARIABLE      
     MVN_KP_TAG_VERIFY, kp_data, fix(true_index[i]),base_tag_count, first_level_count, base_tags,  $
                        first_level_tags, check, level0_index, level1_index, tag_array
     temp_variable_names[i] = strtrim(tag_array[0],2)+'.'+strtrim(tag_array[1],2) 
   
       if check eq 1 then begin
                   print,'Whoops, ',strupcase(field[i]),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
                   goto,finish
       endif else begin
         tplot_variable_name = strtrim('mvn'+strtrim(string(i+1),2))
         tplot_variable_array[i] = tplot_variable_name
         time_data = kp_data[kp_start_index:kp_end_index].time
         store_data,tplot_variable_name, data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)},verbose=0
         ymin[i] = min(kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index))
         ymax[i] = max(kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index))
       endelse
   endelse
  endfor
  if keyword_set(altitude) then begin
    store_data,'alt',data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].spacecraft.altitude},verbose=0
  endif
  
  if keyword_set(zero) then begin
    get_data,'mvn1' , data = data
    zero_line = fltarr(n_elements(data.x))
    zero_line[*] =  0.0
    store_data,'zero',data={x:data.x, y:zero_line},verbose=0
  endif
  
  
  ;DEFINE A DEFAULT COLOR ARRAY FOR MULTI-PLOTS
  
  multi_colors = [0,240,50,210,180,128,30,80,100]
  
  ;MERGE ANY TPLOT VARIABLES TO ALLOW FOR OVERPLOTTING
  tplot_2plot = strarr(n_elements(plot_count))
  starter = 0
  ender = 0
  for i=0,n_elements(plot_count)-1 do begin
    starter = fix(total(plot_count[0:i]) - plot_count[i])
    ender = fix(total(plot_count[0:i])-1.)
    if keyword_set(ytitles) then begin                              ;CREATE THE STRING ARRAY OF Y-AXIS TITLES
      tplot_2plot[i] = ytitles[i]
    endif else begin   
      if starter eq ender then begin
        tplot_2plot[i] = temp_variable_names[starter:ender]
      endif else begin
        for j=starter,ender do begin
          tplot_2plot[i] = tplot_2plot[i]+temp_variable_names[j]
          if j lt ender then tplot_2plot[i] = tplot_2plot[i]+':'
        endfor
      endelse
    endelse    
    if keyword_set(zero) then begin
      store_data,tplot_2plot[i],data=['zero',tplot_variable_array[starter:ender]],verbose=0
    endif else begin
      store_data,tplot_2plot[i],data=tplot_variable_array[starter:ender],verbose=0
    endelse
  endfor
  
 
  ;PLOT THE SINGLE AND MERGED TPLOT VARIABLES

  temp_index=0
  if keyword_set(noplot) eq 0 then begin
      tplot,tplot_2plot,title=overall_title,verbose=0
    if keyword_set(altitude) then begin
      tplot,var_label=['alt'],verbose=0
      options,'alt','ytitle','Alt (km)'
      options,'alt','format','(f8.0)'
      tplot,verbose=0
    endif else begin
      tplot,var_label=[''],verbose=0
    endelse
    for i=0,n_elements(plot_count)-1 do begin
      for j=0, plot_count[i] -1 do begin
        options,tplot_variable_array[temp_index],color=multi_colors[j]
        temp_index = temp_index + 1
      endfor
    endfor
    
  endif else begin
    print, 'Tplot window suppresed. Tplot variables created and stored only.'
    tplot_names
  endelse


tplot,verbose=0
finish:
end