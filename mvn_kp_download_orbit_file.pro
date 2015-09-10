;+
; :Name: mvn_kp_download_orbit_file
;
; :Author: John Martin
;
;
; :Description:
;     Download orbit number file from jpl into toolkit installation directory.
;     If orbit file already exists, overwite it.
;
; :Keywords:
;
;    debug: in, optional, type=boolean
;       On error, - "Stop immediately at the statement that caused the error and print
;       the current program stack." If not specified, error message will be printed and
;       IDL with return to main program level and stop.
;
;    help: in, optional, type=boolean
;       Prints keyword descriptions to screen.
;
;-

pro mvn_kp_download_orbit_file, debug=debug, help=help
  
  ;; provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_download_orbit_file'
;    print,'MVN_KP_DOWNLOAD_ORBIT_FILE'
;    print, ' Download orbit number file from jpl into toolkit installation directory.'
;    print, ' If orbit file already exists, overwrite it.'
;    print,''
;    print,'mvn_kp_download_orbit_file, debug=debug, help=help
;    print,''
;    print,'OPTIONAL FIELDS'
;    print,'***************'
;    print,'  debug: On error, - "Stop immediately at the statement that caused the error and print '
;    print,'         the current program stack." If not specified, error message will be printed and '
;    print,'         IDL with return to main program level and stop.'
;    print,'  help: Invoke this list.'

    return
  endif
  
  ;; Check if debug keyword set, otherwise check for environment variable
  ;; which could be set by another procedure calling this procedure.
  if not keyword_set(debug) then begin
    debug = getenv('MVNTOOLKIT_DEBUG')
  endif
  
  ;; if not in debug mode, set action taken on error to be
  ;; print the current program stack, return to the main program level and stop
  if not keyword_set(debug) then begin
    on_error, 1
  endif

  ;; Get JPL Naif connection information
  spec = mvn_kp_config(/orbit_file_location)

  ;; Get location to safe file locally
  install_result = routine_info('mvn_kp_download_orbit_file',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_download_orbit_file.pro',/extract,/regex)
  if !version.os_family eq 'unix' then begin
  install_directory = install_directory+'orbitfiles/'
  endif else begin
    install_directory = install_directory+'orbitfiles\'
  endelse
  file_and_path = install_directory[0] + spec.orbit_filename

  ;; Get connection & execute GET query for orbit file  
  netURL = mvn_kp_get_temp_connection(spec.host, spec.port, spec.username, spec.password, spec.url_scheme, spec.authentication)
  for i = 0,n_elements(spec.orbit_filename)-1 do begin
    return_value = mvn_kp_execute_neturl_query(netURL, spec.url_path[i], '', filename=file_and_path[i], /not_sdc_connection)
  endfor
  
  if size(return_value, /TYPE) ne 7 then begin
    print, "Problem downloading orbit file."
    print, "If not connected to the internet, then this is to be expected"
  endif else begin
    print, "Downloaded updated version of orbit number files: "
    for i=0,n_elements(file_and_path)-1 do begin
      print, file_and_path[i]
    endfor
  endelse

  ;; Merge the orbit files into a master file
  mvn_kp_merge_orbit_files, file_and_path

end