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
;       List out possible parameters names to search (& index identifiers associated with parameters). No
;       search performed.
;    parameter: in, optional, type=intarr/strarr
;       Required if /list keyword not supplied. The name, or names, of the INSITU data parameter
;       (or integer index) to search on. Use /list keyword to see possible names or index integers
;       to search on.
;    min: in, optional, type=fltarr
;       the minimum value of the parameter to be searched on (or array of values).
;       One or more minimum values. If multiple parameters input & multiple min values input, each min
;       value will correspond with each parameter (by array position). If multiple parameters & one min value,
;       the min value is used for all parameters. Cannot enter more min values than parameters.
;    max: in, optional, type=fltarr
;       the maximum value of the parameter to be searced on (or array of values)
;       One or more maximum values. If multiple parameters input & multiple max values input, each max
;       value will correspond with each parameter (by array position). If multiple parameters & one max value,
;       the max value is used for all parameters. Cannot enter more max values than parameters.
;    range: in, optional, type=boolean
;       Print out TIME_STRING for first and last element of input data structure. Also prints
;       corresponding orbit numbers.
;    debug:  in, optional, type=boolean
;       On error, - "Stop immediately at the statement that caused the error and print
;       the current program stack." If not specified, error message will be printed and
;       IDL with return to main program level and stop.
;       
;    help: in, optional, type=boolean
;       Prints the keyword descriptions to the screen.
;
;-



pro MVN_KP_INSITU_SEARCH,  insitu_in, insitu_out, parameter=parameter, min=min_value, max=max_value, list=list, $
                           range=range, debug=debug, help=help
                           
                           
  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    print,'MVN_KP_INSITU_SEARCH'
    print,'  Searches input in situ KP data structure based on min and/or max search parameters.'
    print,''
    print,'mvn_kp_insitu_search, insitu_in, insitu_out, parameter=parameter, min=min_value, max=max_value, list=list, $'
    print,'                      range=range, debug=debug, help=help'
    print,''
    print,'REQUIRED FIELDS'
    print,'***************'
    print,'  insitu_in: in situ KP data structure (data structure output from mvn_kp_read)'
    print,'  insitu_out: output KP data structure containing datat that met all search criteria'
    print,''
    print,'OPTIONAL FIELDS'
    print,'***************'
    print,'  list: List out possible parameters names to search (& index identifiers associated with parameters). No search performed.'
    print,'        parameter: Required if /list keyword not supplied. The name, or names, of the INSITU data parameter'
    print,'        (or integer index) to search on. Use /list keyword to see possible names or index integers to search on.'
    print,'  min: the minimum value of the parameter to be searched on (or array of values).'
    print,'       One or more minimum values. If multiple parameters input & multiple min values input, each min'
    print,'       value will correspond with each parameter (by array position). If multiple parameters & one min value,'
    print,'       the min value is used for all parameters. Cannot enter more min values than parameters.'
    print,'  max: the maximum value of the parameter to be searced on (or array of values)'
    print,'       One or more maximum values. If multiple parameters input & multiple max values input, each max'
    print,'       value will correspond with each parameter (by array position). If multiple parameters & one max value,'
    print,'       the max value is used for all parameters. Cannot enter more max values than parameters.'
    print,'  range: Print out TIME_STRING for first and last element of input data structure. Also prints corresponding orbit numbers.'
    print,'  debug: On error, - "Stop immediately at the statement that caused the error and print'
    print,'         the current program stack." If not specified, error message will be printed and'
    print,'         IDL with return to main program level and stop.'
    print,'  help: Invoke this list.'
    return
  endif

  
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
 if size(parameter,/dimensions) eq 0 then begin
  min_value = -!values.f_infinity
 endif else begin
  min_value = fltarr(n_elements(parameter))
  min_value[*] = -!values.f_infinity
 endelse
endif
if keyword_set(max_value) eq 0 then begin             ;IF THE MAXIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE INFINITY
 if size(parameter,/dimensions) eq 0 then begin
  max_value = !values.f_infinity
 endif else begin
  max_value = fltarr(n_elements(parameter))
  max_value[*] = !values.f_infinity
 endelse
endif


;; If multiple parameters input, check that correct number of min/max values present. If multiple parameters
;; and only one min and/or max, use that min/max for all parameters. If the number doesn't match
;; error out - don't know how to interpret that.
if (n_elements(parameter) ne n_elements(min_value)) then begin 
  if(n_elements(min_value) eq 1) then begin
    min_value = make_array(n_elements(parameter), value=min_value)
  endif else begin
    message, "If input multiple parameters, number of minimum values input must be either 1 or equal to number of parameters"
  endelse
endif

if (n_elements(parameter) ne n_elements(max_value)) then begin 
  if(n_elements(max_value) eq 1) then begin
    max_value = make_array(n_elements(parameter), value=max_value)
  endif else begin
    message, "If input multiple parameters, number of maximum values input must be either 1 or equal to number of parameters"
  endelse
endif  


if keyword_set(parameter) then begin                  ;IF A parameter NAME OR NUMBER IS SET, RUN A SEARCH ON THAT DATA FIELD BETWEEN MIN AND MAX

  kp_data_temp = insitu_in
  for i=0,n_elements(parameter) -1 do begin
  
    ;; If input is a number, make sure it's great than 0
    parameter_size = size(parameter[i],/type)
    if parameter_size eq 2 then begin
      if parameter[i] le 0 then begin
        message, "If input parameter is a number, it must be greater than 0."
      endif
    endif
    
    MVN_KP_TAG_VERIFY, insitu_in, parameter[i],base_tag_count, first_level_count, base_tags,  $
      first_level_tags, check, level0_index, level1_index, tag_array
      
    ;; If we didn't find the parameter in the input structure, exit now
    if check ne 0 then begin
      if not keyword_set(debug) then begin
        message, "The parameter: "+string(parameter)+" was not found in the input structure."
      endif else begin
        print, "**ERROR HANDLING - The parameter: ", string(parameter), " was not found in the input structure."
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
 