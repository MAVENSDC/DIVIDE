;+
; :Name: mvn_kp_get_help
;
; :Author: Kevin McGouldrick
;
; :Version: 
;   1.1 (2015-Jun-25) Utilize path_sep and limit vertical size 
;                     to 24 lines
;
; :Description:
;     Retrieve the help file associated with the current procedure and 
;     display it in a separate window to the screen.
;
; :Keywords:
;    proc_name: in, required, type=string
;       The name of the procedure from which help is requested
;
;-
pro mvn_kp_get_help, proc_name

;DETERMINE THE INSTALL DIRECTORY SO THE HELPFILE CAN BE FOUND
  install_result = routine_filepath(proc_name,/either)
  install_dir = strsplit(install_result, proc_name, /extract, /regex)

; Change the suffix to .txt to find the help file
  helpfile = install_dir[0] + 'help' + path_sep() + proc_name + '.txt'

; Display the help, provide a usefule title, and limit
;  vertical size to 24 lines to fit on small laptops with big fonts
  xdisplayfile, helpfile, height=24, Title='Help: '+proc_name, $
                done_button='Close'

end