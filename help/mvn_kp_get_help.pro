;+
; :Name: mvn_kp_get_help
;
; :Author: Kevin McGouldrick
;
;
; :Description:
;     Retrieve the help file associated with the current procedure and 
;     display it in a separate window to the screen.
;
;
;
; :Keywords:
;    proc_name: in, required, type=string
;       The name of the procedure from which help is requested
;
;-
pro mvn_kp_get_help, proc_name
  
  ;Error handler
  CATCH, Error_status
  IF Error_status EQ -94 THEN BEGIN
    PRINT, 'Procedure not found, please check procedure name'
    RETURN
    CATCH, /CANCEL
  endif
  
  
;DETERMINE THE INSTALL DIRECTORY SO THE HELPFILE CAN BE FOUND
  install_result = routine_filepath(proc_name,/either)
  install_dir = strsplit(install_result, proc_name, /extract, /regex)
  
  if (install_dir[0] eq '') then begin
    RESOLVE_ROUTINE, proc_name, /EITHER, /NO_RECOMPILE 
    install_result = routine_filepath(proc_name,/either)
    install_dir = strsplit(install_result, proc_name, /extract, /regex)
  endif
; Change the suffix to .txt to find the help file, using proper path 
; designators as a function of OS
  if !version.os_family eq 'unix' then begin
    helpfile = install_dir[0] + 'help/' + proc_name + '.txt'
  endif else begin
    helpfile = install_dir[0] + 'help\' + proc_name + '.txt'
  endelse

  xdisplayfile, helpfile, height=50, Title='Help', done_button='Close'

end