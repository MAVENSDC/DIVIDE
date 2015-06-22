;+
; A routine for printing package version number
;
;-



PRO MVN_KP_VERSION,version=version
  if arg_present(version) then begin
    version = 1.031
  endif else begin
    print, 'Maven KP Toolkit Version: 1.03p'
  endelse
end
