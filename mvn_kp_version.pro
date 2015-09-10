;+
; A routine for printing package version number
;
;-



PRO MVN_KP_VERSION,version=version

  install_result = routine_info('mvn_kp_check_version',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_check_version.pro',/extract,/regex)
  ;; Read the current version from the Version History file
  line =''
  openr,lun,install_directory+'Version History.txt',/get_lun
  readf,lun,line
  free_lun, lun
  temp = strsplit(line, /EXTRACT)

  current_version = temp[n_elements(temp)-1]
  
  if arg_present(version) then begin
    version = current_version
  endif else begin
    suf = keyword_set(mvn_kp_config_file(/check_access)) ? 't' : 'p'
    print, 'Maven KP Toolkit Version: '+current_version+suf
  endelse
end
