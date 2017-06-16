;+
; :Name: mvn_kp_date_subdir
;
; :Author: John Martin
;
; :Description:
;     Extract year and month from filename, return string YYYY/DD for path creation
;
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
;
;; Extract year and month from input filename, and return YYYY/MM/ string
;; for path generation
function mvn_kp_date_subdir, filename

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif


  ;; Determine yearh & month from filename
  date_string = ''
  date_string = stregex(filename, '[0|1|2|3|4|5|6|7|8|9]{8}', /extract)
  
  if date_string ne '' then begin
    year  = strmid(date_string, 0, 4)
    month = strmid(date_string, 4, 2)
    day   = strmid(date_string, 6, 2)
    
    path_date_portion = year + path_sep() + month + path_sep()
    
  endif else begin
    message, "Couldn't find date (8 numbers YYYYMMDD) in filename: "+string(filename)
  endelse
  
  return, path_date_portion
end