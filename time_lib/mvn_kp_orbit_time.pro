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

function MVN_KP_CREATE_TIME_STRING, year, mo_abr, day, hhmmss
  
  ;; Convert month 3 letter string rep into #
  case mo_abr of
    'JAN': mo_num = '01'
    'FEB': mo_num = '02'
    'MAR': mo_num = '03'
    'APR': mo_num = '04'
    'MAY': mo_num = '05'
    'JUN': mo_num = '06'
    'JUL': mo_num = '07'
    'AUG': mo_num = '08'
    'SEP': mo_num = '09'
    'OCT': mo_num = '10'
    'NOV': mo_num = '11'
    'DEC': mo_num = '12'
    ELSE: message, "Unrecognized three letter month abbreviation "
  endcase
  
  return, year+'-'+mo_num+'-'+day+'/'+hhmmss  
end

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
    print, "Try running mvn_kp_download_orbit_file to ensure you have the latest orbit number file"
    print, "Current local orbit file contains orbit information from 2 through "+strtrim(string(orbits.orbitnum(n_elements(orbits.orbitnum)-1)),2)
    message, "Cannot convert orbit # into time string"
  endif

  if count gt 1 then message, "Matched more than one entry for a single orbit... orbit file corrupt?"

  bt_year = string(orbits.year(begin_index))
  bt_mo_string = string(orbits.month(begin_index))
  bt_day = string(orbits.day(begin_index))
  bt_hhmmss = string(orbits.hhmmss(begin_index))
 
  begin_time = mvn_kp_create_time_string(bt_year, bt_mo_string, bt_day, bt_hhmmss)


  ;; Find and create time string for end orbit
  ;; ========================
  end_index = where(orbits.orbitnum eq end_orbit, count)
  if end_index lt 0 then begin
    print, "Couldn't find time for input end orbit"
    print, "Try running mvn_kp_download_orbit_file to ensure you have the latest orbit number file"
    print, "Current local orbit file contains orbit information from 2 through "+strtrim(string(orbits.orbitnum(n_elements(orbits.orbitnum)-1)),2)
    message, "Cannot convert orbit # into time string"
  endif

  if count gt 1 then message, "Matched more than one entry for a single orbit... orbit file corrupt?"
  
  et_year = string(orbits.year(end_index))
  et_mo_string = string(orbits.month(end_index))
  et_day = string(orbits.day(end_index))
  et_hhmmss = string(orbits.hhmmss(end_index))
  
  end_time = mvn_kp_create_time_string(et_year, et_mo_string, et_day, et_hhmmss)

  print, "Converted input orbit times to utc time range: "+begin_time+" to "+end_time

end 