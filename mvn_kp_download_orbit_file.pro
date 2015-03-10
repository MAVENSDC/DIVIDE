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

function mvn_kp_get_temp_connection, host, port, username, password, url_scheme, authentication

  ; Construct the IDLnetURL object and set the login properties.
  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST = host
  netUrl->SetProperty, URL_PORT = port

  netUrl->SetProperty, URL_SCHEME = url_scheme
  netUrl->SetProperty, SSL_VERIFY_HOST = 0 ;don't worry about certificate
  netUrl->SetProperty, SSL_VERIFY_PEER = 0
  netUrl->SetProperty, AUTHENTICATION = authentication
  netUrl->SetProperty, SSL_CERTIFICATE_FILE=''
  netUrl->SetProperty, URL_USERNAME = username
  netUrl->SetProperty, URL_PASSWORD = password


  return, netURL
end

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
  
  file_and_path = install_directory[0] + spec.orbit_filename

  ;; Get connection & execute GET query for orbit file  
  netURL = mvn_kp_get_temp_connection(spec.host, spec.port, spec.username, spec.password, spec.url_scheme, spec.authentication)
  return_value = mvn_kp_execute_neturl_query(netURL, spec.url_path, '', filename=file_and_path, /not_sdc_connection)
  
  if size(return_value, /TYPE) ne 7 then begin
    print, "Problem downloading orbit file."
    print, "If not connected to the internet, then this is to be expected"
  endif else begin
    print, "Downloaded updated version of orbit number file: "+string(return_value)
  endelse

end