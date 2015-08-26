;+
; :Name: mvn_kp_download_template_file
;
; :Author: Bryan Harter
;
;
; :Description:
;     Download KP data template file from the SDC into 
;     toolkit installation directory.
;


function mvn_kp_get_temp_connection2, host, port, username, password, url_scheme, authentication

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

pro mvn_kp_download_template_file

  ;; Get JPL Naif connection information
  spec = mvn_kp_config(/template_file_location)

  ;; Get location to safe file locally
  install_result = routine_info('mvn_kp_download_template_file',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_download_template_file.pro',/extract,/regex)
  if !version.os_family eq 'unix' then begin
    install_directory = install_directory+'read_lib/'
  endif else begin
    install_directory = install_directory+'read_lib\'
  endelse

  ;; Get connection & execute GET query for template file list
  netURL = mvn_kp_get_temp_connection2(spec.host, spec.port, spec.username, spec.password, spec.url_scheme, spec.authentication)
  file_names = mvn_kp_execute_neturl_query(netURL, spec.url_path+'/TemplateList', '', /not_sdc_connection)
  if size(file_names, /TYPE) ne 7 then begin
    print, "Problem downloading template file."
    print, "If not connected to the internet, then this is to be expected"
    return
  endif

  for i = 0,n_elements(file_names)-1 do begin
    file_and_path = install_directory[0] + file_names[i]
    return_value = mvn_kp_execute_neturl_query(netURL, spec.url_path+'/'+file_names[i], '', filename=file_and_path, /not_sdc_connection)
  endfor

  if size(return_value, /TYPE) ne 7 then begin
    print, "Problem downloading template file."
    print, "If not connected to the internet, then this is to be expected"
  endif else begin
    print, "Downloaded updated version of template files: "
    for i=0,n_elements(file_names)-1 do begin
      print, file_names[i]
    endfor
  endelse 

end