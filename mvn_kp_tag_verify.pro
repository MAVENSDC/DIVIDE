;+
; ROUNTINE THAT CHECKS THAT A REQUESTED TAG NAME OR INDEX IS INCLUDED IN THE DATA STRUCTURE
;
; :Params:
;    kp_data: in, required, type=structure  
;       the data structure to check out (why is this passed?)
;    parameter: in, required, type=integer/string
;       the tag name or number to check for the existence of 
;    base_tag_count: in, required, type=integer
;       the number of base level tags
;    first_level_count: in, required, type=integer
;       the number of first level tags
;    base_tags:in, required, type=strarr(base_tag_count)
;       the names of the base level tags
;    first_level_tags: in, required, type=strarr(first_level_count)
;       the names of the first level tags
;    check: out, required, type=integer
;       returned flag to indicate if a given tag name/index exists in the data structure
;    level0_index: out, required, type=integer
;       the integer index of the base level tag name for the requested parameter
;    level1_index: out, required, type=integer
;       the integer index of hte first level tag name for the requested parameter
;    tag_names: out, required, strarr(2)
;       the base and first level tag names for the requested parameter, for later routine use
;-
pro  MVN_KP_TAG_VERIFY, kp_data, parameter,base_tag_count, first_level_count, $
                        base_tags,  first_level_tags, check, level0_index, level1_index, tag_names

  tag_names = strarr(2)                 ;ARRAY TO HOLD THE PLOTTED PARAMETER NAMES

  if base_tags[0] eq 'TIME_STRING' then begin
    dataset = 'INSITU'
    count_begin = 4
    count_end = 1
  endif else begin
    dataset = 'IUVS'
    count_begin = 0
    count_end = 2
  endelse

  
  if size(parameter,/type) eq 2 then begin          ;LOOP TO CHECK INTEGER PARAMETER EXISTENCE
    if (parameter-1) le total(first_level_count) then begin
;     if base_tag_count eq 1 then begin
;      level0_index = 0
;      
      temp1 = 0                                                                           ;level1 calculation
      for i=0,n_elements(first_level_count)-1 do begin
        temp1 = temp1 + first_level_count[i]
        if (parameter-1 lt temp1) then begin
          level0_index = i
;         i = n_elements(first_level_count)
          break
        endif;
      endfor     
  ;    level0_index = level0_index
      level0_temp = level0_index 
                      
      
      level1_index = (parameter-1) - total(first_level_count[0:level0_temp-1])                                ;level2 calculation
      parameter_index = parameter-1 
      
;     endif else begin
;      
;      if (parameter-1) le total(second_level_count[0:first_level_count[0]-1]) then begin    ;level0 calculation
;        level0_index=0
;      endif else begin
;        level0_index=1
;      endelse 
;      
;;      temp1 = 0                                                                           ;level1 calculation
 ;     for i=0,n_elements(second_level_count)-1 do begin
 ;       temp1 = temp1 + second_level_count[i]
 ;       if (parameter-1 lt temp1) then begin
 ;         level1_index = i
 ;         i = n_elements(second_level_count)
 ;       endif
;      endfor
;      if base_tag_count eq 1 then begin
;        level1_index = level1_index
 ;       level1_temp = level1_index
 ;     endif else begin
;        level1_temp = level1_index
;        if level0_index eq 0 then begin
;          level1_index = level1_index
;        endif else begin
;          level1_index = level1_index - first_level_count[0]
;        endelse
;      endelse
;      
;      
;      level2_index = (parameter-1) - total(second_level_count[0:level1_temp-1])                                ;level2 calculation
;      parameter_index = parameter-1
;     endelse
    check = 0
   endif else begin                                 ;end of integer loop check
    check = 1
   endelse
  endif
  
  if size(parameter,/type) eq 7 then begin          ;LOOP TO CHECK STRING PARAMETER EXISTENCE
    tag_elements = strupcase(strsplit(parameter,'.',/extract))
    if n_elements(tag_elements) eq 2 then begin
      level0_index = where(base_tags eq tag_elements[0])
      level0_temp = level0_index
      if level0_index ne -1 then begin

        level1_index = where(first_level_tags[total(first_level_count(0:level0_temp-1)):total(first_level_count(0:level0_temp))-1] eq tag_elements[1])
        parameter_index = total(first_level_count(0:level0_temp-1))+where(first_level_tags[total(first_level_count(0:level0_temp-1)):total(first_level_count(0:level0_temp))-1] eq tag_elements[1])

;        if n_elements(parameter_index) gt 1 then begin
;          parameter_range = [total(first_level_count[0:level1_temp-1]),total(first_level_count[0:level1_temp])]
;            parameter_temp = where(parameter ge parameter_range[0] and parameter le parameter_range[1])
;            
;        
;        endif
        if level1_index ne -1 then begin
          check = 0
        endif else begin
          check=1
        endelse
      endif else begin
        check=1
      endelse 
    endif else begin
      check=1
    endelse
  endif
  
  if check eq 0 then begin
    tag_names[0] = base_tags[level0_index]
    tag_names[1] = first_level_tags[parameter_index]
  endif
stop
end