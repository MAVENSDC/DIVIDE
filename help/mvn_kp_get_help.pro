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

;DETERMINE THE INSTALL DIRECTORY SO THE HELPFILE CAN BE FOUND
    install_result = routine_info(proc_name,/source)
    install_dir = strsplit(install_result.path, proc_name, /extract, /regex)
; Change the suffix to .txt to find the help file, using proper path 
; designators as a function of OS
    if !version.os_family eq 'unix' then begin
      helpfile = install_dir[0] + 'help/' + proc_name + '.txt'
    endif else begin
      helpfile = install_dir[0] + 'help\' + proc_name + '.txt'
    endelse

    xdisplayfile, helpfile, /grow_to_screen, Title='Help', done_button='Close'

    end