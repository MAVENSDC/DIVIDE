;;
;; Function to check if "check_time" is within begin_time and end_time
;;
;; check_time is assumed to be a string of format either YYYY-MM-DDTHH:MM:SS or YYYY-MM-DD/HH:MM:SS
;;
;; begin_time and end_time assumed to be structures contain a tag 'Jul' with a julday time
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
  MVN_KP_TIME_SPLIT_STRING, check_time, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
  check_time_jul = julday(mo, dy, yr, hr, min, sec)

  ;; Now do actual check for if check_time is between begin & end times. 1 if yes 0 if no
  check = 0
  if (check_time_jul ge begin_jul) and (check_time_jul le end_jul) then check = 1

  return,check
end
