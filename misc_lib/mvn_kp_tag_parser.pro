;+
; A ROUTINE TO DYNAMICALLY RETURN WHICH TAGS ARE INCLUDED IN THE 
;   KP DATA STRUCTURE
;
; :Params:
;    kp_data : in, required, type=structure
;       the kp data structure from which to extract tag names
;    base_tag_count: out, required, type=integer
;       the number of tags in the base level of the structure 
;       (will be instrument names of observational modes)
;    first_level_count: out, required, type=integer
;       the number of tags in the first level of the structure 
;    second_level_count: out, required, type=integer
;       the number of tags in the second level of the structure
;    base_tags: out, required, type=strarr(base_tag_count)
;       the names of the base level tags
;    first_level_tags: out, required, type=strarr(first_level_count)
;       the names of the first level tags
;    second_level_tags: out, requried, type=strarr(second_level_count)
;       the names of hte second level tags
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;
;-
pro MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, $
                       second_level_count, base_tags,  $
                       first_level_tags, second_level_tags

  ;DETERMINE WHETHER THE DATA INCLUDES IUVS DATA AS WELL AS INSITU

    base_tags = tag_names(kp_data)
    base_tag_count = n_elements(base_tags)

    if base_tags[0] eq 'TIME_STRING' then begin
       dataset='insitu'
    endif else begin
       dataset='iuvs'
    endelse


  ;DETERMINE WHICH FIRST LEVEL TAGS ARE INCLUDED IN THE DATA SET
  ;   THESE TAGS ARE GENERALLY INSTRUMENT NAMES
  ;   EXCEPT FOR IUVS WHERE IT IS OBSERVATION TYPES
  
;    if dataset eq 'insitu' then begin
      first_level_count = intarr(n_elements(base_tags))
      for i=0,base_tag_count-1 do begin
        tag_count = n_tags(kp_data.(i))
        if tag_count eq 0 then begin
          first_level_count[i] = tag_count
        endif else begin
         temp1 = tag_names(kp_data.(i))
         first_level_count[i] = n_elements(temp1)
        endelse
      endfor
      first_level_tags = strarr(total(first_level_count))
      count1 = 0 
      count2 = 0
      for i=0,base_tag_count-1 do begin
        tag_count = n_tags(kp_data.(i))
        if tag_count ne 0 then begin
         temp1 = tag_names(kp_data.(i))
         count2 = count1 + n_elements(temp1)-1
         first_level_tags[count1:count2] = temp1
         count1 = count2+1
        endif
      endfor
      
;    endif
;    if dataset eq 'iuvs' then begin
;      first_level_count = intarr(n_elements(base_tags)-1)
;      for i=0,base_tag_count-2 do begin
;        temp1 = tag_names(kp_data.(i))
;        first_level_count[i] = n_elements(temp1)
;      endfor
 ;     first_level_tags = strarr(total(first_level_count))
 ;     count1 = 0 
 ;;     count2 = 0
 ;     for i=0,base_tag_count-2 do begin
 ;       temp1 = tag_names(kp_data.(i))
 ;       count2 = count1 + n_elements(temp1)-1
 ;       first_level_tags[count1:count2] = temp1
 ;       count1 = count2+1
 ;     endfor
 ;   endif 

  ;DETERMINE THE SECOND LEVEL TAGS THAT ARE PRESENT
  ;  THESE TAGS ARE GENERALLY THE DATA FIELDS BUT ALSO GEOMETRIC PARAMETERS
  
;  second_level_count = intarr(n_elements(first_level_tags))
;  index1=0
;  for i=0,base_tag_count-1 do begin
;    for j=0,first_level_count[i]-1 do begin
;      temp_count = n_tags(kp_data.(i).(j))
;      if temp_count gt 0 then begin
;        temp1 = tag_names(kp_data.(i).(j))
;        second_level_count[index1] = n_elements(temp1)
;      endif
;      index1=index1+1
;    endfor
;  endfor
;  second_level_tags = strarr(total(second_level_count))
;  count1= 0
;  count2= 0
 ; for i=0,base_tag_count-1 do begin
 ;   for j=0,first_level_count[i]-1 do begin
 ;     temp_count = n_tags(kp_data.(i).(j))
 ;     if temp_count gt 0 then begin
 ;       temp1 = tag_names(kp_data.(i).(j))
 ;       count2 = count1 + n_elements(temp1)-1
 ;       second_level_tags[count1:count2] = temp1
 ;       count1 = count2+1
 ;     endif
 ;;   endfor
 ; endfor
  
end
