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

  ;; FIXME - Take care of sanitizing input, right now orbits can be decimals which can have weird behavior

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')

  ;; if not in debug mode, set action taken on error to be
  ;; print the current program stack, return to the main program level and stop
  if not keyword_set(debug) then begin
    on_error, 1
  endif

  ;; Path to orbit template and file
  install_result = routine_info('mvn_kp_orbit_time',/source)
  install_time_directory = strsplit(install_result.path,'mvn_kp_orbit_time.pro',/extract,/regex)
  install_directory = install_time_directory[0] + '..'+path_sep()

  ;; Get orbit file specs and set globals
  orbit_file_spec = mvn_kp_config(/orbit_number)
  orbit_file = orbit_file_spec.orbit_file
  orbit_file_template = orbit_file_spec.orbit_template
  
  ;; Ensure orbit # file exists
  result = file_search(install_directory+orbit_file)
  if result eq '' then begin
    print, "No local orbit file, maven_orb_rec.orb, found in root_data_dir"
    print, "Run mvn_kp_download_orbit_file to ensure you have latest orbit number file downloaded"
    message, "Cannot continue conversion of orbit number to time string"
  endif
  
  ;; read in orbit ascii template & then orbit file
  restore,install_time_directory+orbit_file_template
  orbits = read_ascii(install_directory+orbit_file ,template=orbit_template)

  ;; Find and create time string for start orbit
  ;; =======================
  begin_index = where(orbits.orbitnum eq begin_orbit, count)  
  if begin_index lt 0 then begin 
    print, "Couldn't find time for input begin orbit"
    print, "Try running mvn_kp_download_orbit_file to ensure you have the lastest orbit number file"
    print, "Current local orbit file contains orbit information from 2 through "+strtrim(string(orbits.orbitnum(n_elements(orbits.orbitnum)-1)),2)
    message, "Cannot convert obrit # into time string"
  endif

  if count gt 1 then message, "Matched more than one entry for a single orbit... orbit file corrupt?"

  bt_year = string(orbits.year(begin_index))
  bt_mo_string = string(orbits.month(begin_index))
  bt_day = string(orbits.day(begin_index))
  bt_hhmmss = string(orbits.hhmmss(begin_index))
 
  case bt_mo_string of
    'JAN': bt_month = '01'
    'FEB': bt_month = '02'
    'MAR': bt_month = '03'
    'APR': bt_month = '04'
    'MAY': bt_month = '05'
    'JUN': bt_month = '06'
    'JUL': bt_month = '07'
    'AUG': bt_month = '08'
    'SEP': bt_month = '09'
    'OCT': bt_month = '10'
    'NOV': bt_month = '11'
    'DEC': bt_month = '12'
  endcase
  
  begin_time = strtrim(bt_year,2)+'-'+strtrim(bt_month,2)+'-'+ strtrim(bt_day, 2)+'/'+strtrim(bt_hhmmss,2)


  ;; Find and create time string for end orbit
  ;; ========================
  end_index = where(orbits.orbitnum eq end_orbit, count)
  if end_index lt 0 then begin
    print, "Couldn't find time for input end orbit"
    print, "Try running mvn_kp_download_orbit_file to ensure you have the lastest orbit number file"
    print, "Current local orbit file contains orbit information from 2 through "+strtrim(string(orbits.orbitnum(n_elements(orbits.orbitnum)-1)),2)
    message, "Cannot convert obrit # into time string"
  endif

  if count gt 1 then message, "Matched more than one entry for a single orbit... orbit file corrupt?"
  
  et_year = string(orbits.year(end_index))
  et_mo_string = string(orbits.month(end_index))
  et_day = string(orbits.day(end_index))
  et_hhmmss = string(orbits.hhmmss(end_index))
  
  case et_mo_string of
    'JAN': et_month = '01'
    'FEB': et_month = '02'
    'MAR': et_month = '03'
    'APR': et_month = '04'
    'MAY': et_month = '05'
    'JUN': et_month = '06'
    'JUL': et_month = '07'
    'AUG': et_month = '08'
    'SEP': et_month = '09'
    'OCT': et_month = '10'
    'NOV': et_month = '11'
    'DEC': et_month = '12'
  endcase
  
  end_time = strtrim(et_year,2)+'-'+strtrim(et_month,2)+'-'+ strtrim(et_day, 2)+'/'+strtrim(et_hhmmss,2)

  print, "Converted input orbit times to utc time range: "+begin_time+" to "+end_time

end 