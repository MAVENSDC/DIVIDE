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

pro MVN_KP_TPLOT, kp_data, field, time=time, list=list, ytitles=ytitles,range=range,$
                  createall=createall, quiet=quiet


  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags


  if keyword_set(list) then begin
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    return
  endif
  

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    return
  endif


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
    
;IF USER CHOOSES CREATEALL, BUILD TPLOT VARIABLES FROM ALL PARAMETERS AND THEN QUIT

  if keyword_set(createall) then begin
    print,'**** Creating Tplot variables from all available KP Parameters ****'
    index=0
    for i=0, n_elements(first_level_count)-1 do begin
      if first_level_count[i] gt 0 then begin
        for j=0, first_level_count[i]-1 do begin
          tplot_name = strtrim(base_tags[i],2)+':'+strtrim(first_level_tags[index])
          store_data,tplot_name, data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].(i).(j)},verbose=0
          index=index+1
        endfor
      endif
    endfor
    if (keyword_set(quiet) ne 1) then tplot_names
    return
  endif
    
;OTHERWISE CREAT ONLY THE TPLOT VARIABLES REQUESTED
  ;CREATE THE PLOT VECTORS
  
  for i=0, n_elements(field)-1 do begin                                   
          MVN_KP_TAG_VERIFY, kp_data, field[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array

       if check eq 0 then begin            ;CHECK THAT THE REQUESTED PARAMETER EXISTS

          tplot_name = strtrim(tag_array[0],2)+':'+strtrim(tag_array[1],2)
          store_data,tplot_name, data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)}
        
       endif else begin
         print,'Requested plot parameter is not included in the data. Try /LIST to confirm your parameter choice.'
         return
       endelse
 endfor
 if (keyword_set(quiet) ne 1) then tplot_names
  


end