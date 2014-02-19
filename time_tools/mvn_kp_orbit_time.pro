;+
; A helper routine that converts from orbit number to date and time for the purpose of reading KP data.
;
; :Params:
;    begin_orbit : in, required, type=integer
;       variable holding the beginning orbit number to convert
;    end_orbit : in, required, type=integer
;       variable holding the ending orbit number to convert
;    begin_time : out, required, type=integer
;       variable returned holding the beginning time equivalent to the start orbit
;    end_time : out, required, type=integer
;       variable returned holding the end time equivalent to the end orbit
;
; :Keywords:
;-
pro MVN_KP_ORBIT_TIME, begin_orbit, end_orbit, begin_time, end_time


  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')

  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif

  ; Path to orbit template and file
  install_result = routine_info('mvn_kp_orbit_time',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_orbit_time.pro',/extract,/regex)

  ; Get orbit file specs and set globals
  orbit_file_spec = mvn_kp_config(/orbit_number)
  orbit_file = orbit_file_spec.orbit_file
  orbit_file_template = orbit_file_spec.orbit_template
  

  ;READ IN THE ORBIT TEXT FILE FOR COMPARISON PURPOSES
  restore,install_directory+orbit_file_template
  orbits = read_ascii(install_directory+orbit_file ,template=orbit_template)

  ;FIND THE TIME FOR THE BEGINNING ORBIT
  begin_index = where(orbits.orbitnum eq begin_orbit)  
  if begin_index lt 0 then message, "Couldn't find time range for input begin orbit"
  begin_time = orbits.time(begin_index) 

  bt_split = strsplit(begin_time, ' ', /extract)
  

  case bt_split[1] of
    'JAN': month_tag = '01'
    'FEB': month_tag = '02'
    'MAR': month_tag = '03'
    'APR': month_tag = '04'
    'MAY': month_tag = '05'
    'JUN': month_tag = '06'
    'JUL': month_tag = '07'
    'AUG': month_tag = '08'
    'SEP': month_tag = '09'
    'OCT': month_tag = '10'
    'NOV': month_tag = '11'
    'DEC': month_tag = '12'
  endcase
  
  begin_time = strtrim(string(bt_split[0]),2)+'-'+strtrim(string(month_tag),2)+'-'+$
    strtrim(string(bt_split[2]), 2)+'/'+strtrim(string(bt_split[3]),2)

  ;ADD THE LEADING ZERO TO THE DAY, IF NEEDED
;  if orbits.day(begin_index) lt 10 then begin
;   day_tag = '0'+ strtrim(string(orbits.day(begin_index)),2)                                                 ;; FIXME ONCE KNOW TIME INPUT
;  endif else begin
;   day_tag = strtrim(string(orbits.day(begin_index)),2)
;  endelse
  
;  begin_time = strtrim(string(orbits.year(begin_index)),2)+'-'+strtrim(string(month_tag),2)+'-'+day_tag+$
;               '/'+strtrim(string(orbits.time(begin_index)),2)
               


  ;FIND THE TIME FOR THE ENDING ORBIT

  end_index = where(orbits.orbitnum eq end_orbit) + 1        ;ADD ONE TO GET THE END TIME OF THE END ORBIT
  if begin_index lt 0 then message, "Couldn't find time range for end orbit"
  end_time = orbits.time(end_index)  
  
  et_split = strsplit(end_time, ' ', /extract)
 
  case et_split[1] of
    'JAN': month_tag = '01'
    'FEB': month_tag = '02'
    'MAR': month_tag = '03'
    'APR': month_tag = '04'
    'MAY': month_tag = '05'
    'JUN': month_tag = '06'
    'JUL': month_tag = '07'
    'AUG': month_tag = '08'
    'SEP': month_tag = '09'
    'OCT': month_tag = '10'
    'NOV': month_tag = '11'
    'DEC': month_tag = '12'
  endcase
  
 
  end_time = strtrim(string(et_split[0]),2)+'-'+strtrim(string(month_tag),2)+'-'+$
    strtrim(string(et_split[2]), 2)+'/'+strtrim(string(et_split[3]),2)


;  if orbits.day(end_index) lt 10 then begin
;   day_tag = '0'+ strtrim(string(orbits.day(end_index)),2)
;  endif else begin                                                                                      ;; FIXME ONCE KNOW TIME INPUT
;   day_tag = strtrim(string(orbits.day(end_index)),2)
;  endelse
;  
;  end_time = strtrim(string(orbits.year(end_index)),2)+'-'+strtrim(string(month_tag),2)+'-'+day_tag+$
;               '/'+strtrim(string(orbits.time(end_index)),2)




end 