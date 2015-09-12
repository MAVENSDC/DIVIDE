;+
; A routine for checking if you have the latest version
;
;-



PRO MVN_KP_CHECK_VERSION
  common mvn_kp_update, last_asked_user_to_update

    if (n_elements(last_asked_user_to_update) eq 1) then begin
      if (systime(/seconds) lt last_asked_user_to_update + 7200) then begin
        return
      endif
    endif

  ;; Get SDC source file location
  spec = mvn_kp_config(/source_files_location)

  ;; Get location to save the source code files
  install_result = routine_info('mvn_kp_check_version',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_check_version.pro',/extract,/regex)
  
  ;; Read the current version from the Version History file
  line =''
  openr,lun,install_directory+'Version_History.txt',/get_lun
  readf,lun,line
  free_lun, lun
  temp = strsplit(line, /EXTRACT) 
  
  current_version = temp[n_elements(temp)-1]
  
  ;; Read the version on the website
  netURL = mvn_kp_get_temp_connection(spec.host, spec.port, spec.username, spec.password, spec.url_scheme, spec.authentication)
  version_history_txt = mvn_kp_execute_neturl_query(netURL, spec.url_path+'/Version_History.txt', '', /not_sdc_connection)
  if size(version_history_txt, /TYPE) ne 7 then begin
    print, "Problem checking for latest toolkit versions."
    print, "If not connected to the internet, then this is to be expected"
    return
  endif

  answer = ''
  temp = strsplit(version_history_txt[0], /EXTRACT) 
  latest_version = temp[n_elements(temp)-1]
  
  if (latest_version ne current_version) then begin
    last_asked_user_to_update = systime(/seconds)
    read, answer, prompt='There is a new version of the software.  Would you like to download it now (y/n)? : '
    if (answer eq 'y' || answer eq 'Y') then begin
      mvn_kp_download_latest_version
      print, "Latest version downloaded.  A description of recents changes can be found in 'Version_History.txt'"
    endif else begin
      print, ""
      print, "You can download the latest version at any time by typing 'mvn_kp_download_latest_version'."
      print, "Patch notes can be found at: "
      print, "https://lasp.colorado.edu/maven/sdc/public/data/sdc/software/idl_toolkit/Source/Version%20History.txt"
    endelse
  endif 
  
  return


end
