function MVN_KP_TIME_BOUNDS, time, begin_time, end_time

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
    begin_long = MVN_TIME_CONVERT(begin_time,2)
    end_long = MVN_TIME_CONVERT(end_time,2)
    time_long = MVN_TIME_CONVERT(time,2)

    check = 0
    if time_long ge begin_long then begin
      if time_long le end_long then begin
        check=1
      endif
    endif 

return,check
end
