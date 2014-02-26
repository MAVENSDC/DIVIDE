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
;    debug: in, optional, type=boolean
;       optional keyword to execute in "debug" mode. On errors, IDL will halt in place so the user can
;       have a chance to see what's going on. By default this will not occur, instead error handlers
;       are setup and errors will return to main.

@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_tag_verify

pro MVN_KP_INSITU_SEARCH,  kp_data, kp_data_out, tag=tag, min=min_value, max=max_value, list=list, range=range, debug=debug
  
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

  
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags


if keyword_set(list) then begin                              ;LIST ALL THE SUB-STRUCTURES INLUDED IN A GIVEN KP DATA STRUCTURE
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    return
endif

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
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

if keyword_set(tag) then begin                  ;IF A TAG NAME OR NUMBER IS SET, RUN A SEARCH ON THAT DATA FIELD BETWEEN MIN AND MAX


  count = intarr(n_elements(tag))
  kp_data_temp = kp_data
  for i=0,n_elements(tag) -1 do begin
  
    ;; If input is a number, make sure it's great than 0
    tag_size = size(tag[i],/type)
    if tag_size eq 2 then begin
      if tag[i] le 0 then begin
        message, "If input tag is a number, it must be greater than 0."
      endif
    endif
    
    MVN_KP_TAG_VERIFY, kp_data, tag[i],base_tag_count, first_level_count, base_tags,  $
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
    count[i] = counter
    kp_data_temp = kp_data_temp[meets_criteria]
  endfor
  print,strtrim(string(counter),2),' records found that meet the search criteria.'
  kp_data_out = kp_data_temp
  
endif       ;END OF ALL SEARCH ROUTINES


; UNSET DEBUG ENV VARIABLE
setenv, 'MVNTOOLKIT_DEBUG='
e
end

 