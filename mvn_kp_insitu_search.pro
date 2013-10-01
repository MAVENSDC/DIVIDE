;+
; Searches the input line of INSITU kp data based on the search parameters
;
; :Params:
;    KP_data : in, required, type=structure
;       the named structure for the KP data 
;    kp_data_out: out, require, type=structure
;       the named structure with the data that meets search criteria
; :Keywords:
;    tag: in, required, type=intarr/strarr
;       the name, or names, of the INSITU data parameter (or integer index) to search on
;    min: in, optional, type=fltarr(ntags)
;       the minimum value of the parameter to be searched on (or array of values)
;    max: in, optional, type=fltarr(ntags)
;       the maximum value of the parameter to be searced on (or array of values)
;    range: in, optional, type=boolean
;       if present, will simply list the start and end times of the passed data structure
;    list: in, optional, type=boolean
;       if present, will simply list the available structure tags within the KP data structure
;       ;-

@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_tag_verify

pro MVN_KP_INSITU_SEARCH,  kp_data, kp_data_out, tag=tag, min=min_value, max=max_value, list=list, range=range


  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags


if keyword_set(list) then begin                              ;LIST ALL THE SUB-STRUCTURES INLUDED IN A GIVEN KP DATA STRUCTURE
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    goto,finish
endif

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    goto,finish
  endif

if keyword_set(min_value) eq 0 then begin             ;IF THE MINIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE -INFINITY
 if size(tag,/dimensions) eq 0 then begin
  min_value = -!values.f_infinity
 endif else begin
  min_value = fltarr(n_elements(tag))
  min_value[*] = -!values.f_infinity
 endelse
endif
if keyword_set(max_value) eq 0 then begin             ;IF THE MAXIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE INFINITY
 if size(tag,/dimensions) eq 0 then begin
  max_value = !values.f_infinity
 endif else begin
  max_value = fltarr(n_elements(tag))
  max_value[*] = !values.f_infinity
 endelse
endif
      
if keyword_set(tag) then begin                  ;IF A TAG NAME OR NUMBER IS SET, RUN A SEARCH ON THAT DATA FIELD BETWEEN MIN AND MAX

   tag_size = size(tag,/type)
   if tag_size eq 2 then begin 
    count = intarr(n_elements(tag))
    kp_data_temp = kp_data
    for i=0,n_elements(tag) -1 do begin
                 MVN_KP_TAG_VERIFY, kp_data, tag[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
            print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
                
             meets_criteria = where(kp_data_temp.(level0_index).(level1_index) ge min_value[i] and kp_data_temp.(level0_index).(level1_index) le max_value[i],counter)
             count[i] = counter
             kp_data_temp = kp_data_temp[meets_criteria]
    endfor            ;END THE LOOP OVER THE VARIOUS SEARHC PARAMETERS
    print,strtrim(string(counter),2),' records found that meet the search criteria.'      
    kp_data_out = kp_data_temp
   endif
   if tag_size eq 7 then begin
    count = intarr(n_elements(tag))
    kp_data_temp = kp_data
    for i=0,n_elements(tag)-1 do begin
                       MVN_KP_TAG_VERIFY, kp_data, tag[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
             print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
              ;SPLIT THE SEARCH TAG INTO UPPER AND LOWER LEVEL COMPONENTS
                
             meets_criteria = where(kp_data_temp.(level0_index).(level1_index) ge min_value[i] and kp_data_temp.(level0_index).(level1_index) le max_value[i], counter)
             count[i] = counter
             kp_data_temp = kp_data_temp[meets_criteria]             
    endfor
    print,strtrim(string(counter),2),' records found that meet the search criteria.'      
    kp_data_out = kp_data_temp
   endif

endif       ;END OF ALL SEARCH ROUTINES



finish: 
end

 