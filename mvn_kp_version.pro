;+
; A routine for printing package version number
;
;-



PRO MVN_KP_VERSION,version=version
  if arg_present(version) then begin
    version = 1.04
  endif else begin
    suf = keyword_set(mvn_kp_config_file(/check_access)) ? 't' : 'p'
    print, 'Maven KP Toolkit Version: 1.04'+suf
  endelse
end
