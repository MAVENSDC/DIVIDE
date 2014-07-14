;+
; :Name: mvn_kp_insitu_search
;
; :Author: Kristopher Larsen & John Martin
;
;
; :Description:
;    Searches input in situ KP data structure based on min and/or max search parameters
;
; :Params:
;    insitu_in: in, required, type=array of structures
;       in situ KP data structure (data structure output from mvn_kp_read)
;    insitu_out: out, required, type=array of structures
;       output KP data structure containing datat that met all search criteria
;
; :Keywords:
;    list: in, optional, type=boolean
;       List out possible tags names to search (& index identifiers associated with tags). No
;       search performed.
;    tag: in, optional, type=intarr/strarr
;       Required if /list keyword not supplied. The name, or names, of the INSITU data parameter
;       (or integer index) to search on. Use /list keyword to see possible names or index integers
;       to search on.
;    min: in, optional, type=fltarr
;       the minimum value of the parameter to be searched on (or array of values).
;       One or more minimum values. If multiple tags input & multiple min values input, each min
;       value will correspond with each tag (by array position). If multiple tags & one min value,
;       the min value is used for all tags. Cannot enter more min values than tags.
;    max: in, optional, type=fltarr
;       the maximum value of the parameter to be searced on (or array of values)
;       One or more maximum values. If multiple tags input & multiple max values input, each max
;       value will correspond with each tag (by array position). If multiple tags & one max value,
;       the max value is used for all tags. Cannot enter more max values than tags.
;    range: in, optional, type=boolean
;       Print out TIME_STRING for first and last element of input data structure. Also prints
;       corresponding orbit numbers.
;    debug:  in, optional, type=boolean
;       On error, - "Stop immediately at the statement that caused the error and print
;       the current program stack." If not specified, error message will be printed and
;       IDL with return to main program level and stop.
;
;-

@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_tag_verify


pro MVN_KP_INSITU_SEARCH,  insitu_in, insitu_out, tag=tag, min=min_value, max=max_value, list=list, $
                           range=range, debug=debug
  
  ; IF NOT IN DEBUG, SETUP ERROR HANDLER
  if not keyword_set(debug) then begin
    ; Establish error handler. When errors occur, the index of the
    ; error is returned in the variable Error_status:
    CATCH, Error_status
    
    ;This statement begins the error handler:
    IF Error_status NE 0 THEN BEGIN
      ; Handle errors by returning to Main:
      PRINT, '**ERROR HANDLING - ', !ERROR_STATE.MSG
      PRINT, '**ERROR HANDLING - Cannot proceed. Returning to main'
      Error_status = 0
      CATCH, /CANCEL
      return
    ENDIF
  endif

  ; IF DEBUG SET, SET IT AS AN ENVIRONMENT VARIABLE SO ALL PROCEDURES/FUNCTIONS CALLED CAN CHECK FOR IT
  if keyword_set(debug) then begin
    setenv, 'MVNTOOLKIT_DEBUG=TRUE'
  endif

  
  
  MVN_KP_TAG_PARSER, insitu_in, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags


if keyword_set(list) then begin                              ;LIST ALL THE SUB-STRUCTURES INLUDED IN A GIVEN KP DATA STRUCTURE
    MVN_KP_TAG_LIST, insitu_in, base_tag_count, first_level_count, base_tags,  first_level_tags
    return
endif

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, insitu_in
    return
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


;; If multiple tags input, check that correct number of min/max values present. If multiple tags
;; and only one min and/or max, use that min/max for all tags. If the number doesn't match
;; error out - don't know how to interpret that.
if (n_elements(tag) ne n_elements(min_value)) then begin 
  if(n_elements(min_value) eq 1) then begin
    min_value = make_array(n_elements(tag), value=min_value)
  endif else begin
    message, "If input multiple tags, number of minimum values input must be either 1 or equal to number of tags"
  endelse
endif

if (n_elements(tag) ne n_elements(max_value)) then begin 
  if(n_elements(max_value) eq 1) then begin
    max_value = make_array(n_elements(tag), value=max_value)
  endif else begin
    message, "If input multiple tags, number of maximum values input must be either 1 or equal to number of tags"
  endelse
endif  


if keyword_set(tag) then begin                  ;IF A TAG NAME OR NUMBER IS SET, RUN A SEARCH ON THAT DATA FIELD BETWEEN MIN AND MAX

  kp_data_temp = insitu_in
  for i=0,n_elements(tag) -1 do begin
  
    ;; If input is a number, make sure it's great than 0
    tag_size = size(tag[i],/type)
    if tag_size eq 2 then begin
      if tag[i] le 0 then begin
        message, "If input tag is a number, it must be greater than 0."
      endif
    endif
    
    MVN_KP_TAG_VERIFY, insitu_in, tag[i],base_tag_count, first_level_count, base_tags,  $
      first_level_tags, check, level0_index, level1_index, tag_array
      
    ;; If we didn't find the tag in the input structure, exit now
    if check ne 0 then begin
      if not keyword_set(debug) then begin
        message, "The tag: "+string(tag)+" was not found in the input structure."
      endif else begin
        print, "**ERROR HANDLING - The tag: ", string(tag), " was not found in the input structure."
        print, "**ERROR HANDLING - Debug mode set: Stoping."
        stop
      endelse
    endif
    
    print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
    
    meets_criteria = where(kp_data_temp.(level0_index).(level1_index) ge min_value[i] and kp_data_temp.(level0_index).(level1_index) le max_value[i],counter)
    

    ;; If counter is zero, the final search will contain no elements. Break here
    if counter le 0 then begin
      kp_data_temp = 0
      break
    endif
    
    kp_data_temp = kp_data_temp[meets_criteria]
    
    
  endfor
  print,strtrim(string(counter),2),' records found that meet the search criteria.'
  insitu_out = kp_data_temp
  
endif       ;END OF ALL SEARCH ROUTINES


; UNSET DEBUG ENV VARIABLE
setenv, 'MVNTOOLKIT_DEBUG='

end
 