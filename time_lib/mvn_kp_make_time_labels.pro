;+
;
; :Name:
;  mvn_kp_make_time_labels
;
; :Description:
;  Create legible time stamp labels for mvn_kp_plot and *_altplot.
;
; :Params:
;  time: in, strarr()
;   - An array containing all times in the plottable data
;
;  time_labels: out, strarr(5)
;   - A five-element array containing the string labels for the five
;     quartile (zero-th, first, second, thurd, fourth) times.
;
; :Author:
;   McGouldrick (2015-May-28)
;
; :Version:
;  1.0
;  
;-
pro mvn_kp_make_time_labels, time, time_labels, tick_locations
  ;
  ;  Create an empty string array for the labels
  ;  And a zero filled array for the their locations
  ;
  time_labels=replicate('',5)
  tick_locations = dblarr(5)
  ;
  ; First, identify the five time elements to be used
  ; Need to assign as long integers in case number of records
  ; exceeds 32767
  ; 
  itimes = fix( ( n_elements(time)-1 ) * 0.25 * indgen(5), type=3 )
  ;
  ;  Define the string format for these time stamps
  ;
  date_time_str = strsplit( time_string(time[itimes]), $
                            '[T/]', /regex, /extract )
  ;
  ;  Now, cycle through the time stamps
  ;
  for i = 0,4 do begin
    ;
    ;  break out the date and time strings
    ;
    date_str = date_time_str[i,0] & time_str = date_time_str[i,1]
    ;
    ;  Only update date string when it changes
    ;
    if i gt 0 then begin
      if date_str eq date_time_str[i-1,0] then date_str = ''
    endif
    ;
    ;  Assign the numerical values to the tick locations so they 
    ;  are placed in the right position by the plot function
    ;
    tick_locations[i] = time[itimes[i]]
    ;
    ; Re-attach time and date with a carriage return between them
    ;
    time_labels[i] = strjoin([time_str,date_str], '!C')
  endfor
  return
end