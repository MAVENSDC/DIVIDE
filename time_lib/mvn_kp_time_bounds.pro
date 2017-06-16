;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; 
;;
;; Function to check if "check_time" is within begin_time and end_time
;;
;; check_time is assumed to be a scalar or vector string of format either 
;;   YYYY-MM-DDTHH:MM:SS or YYYY-MM-DD/HH:MM:SS
;;
;; begin_time and end_time assumed to be structures contain a tag 'Jul' 
;;   with a julday time
;;



function MVN_KP_TIME_BOUNDS, check_time, begin_time, end_time

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  ;; Get julian day versions of input begin & end times
  begin_jul = begin_time.Jul
  end_jul   = end_time.Jul

  ;; Take input time string, split it up, and create a jul day version
  MVN_KP_TIME_SPLIT_STRING, check_time, year=yr, month=mo, day=dy, hour=hr, $
                            min=min, sec=sec, /FIX
  check_time_jul = julday(mo, dy, yr, hr, min, sec)

  ;; Now do actual check for if check_time is between begin & end times. 1 if yes 0 if no
  check = bytarr(n_elements(checK_time))
  in_bounds = where( check_time_jul ge begin_time.jul and $
                     check_time_jul le end_time.jul, count )
  if count gt 0 then check[in_bounds] = 1B

  return,check
end
