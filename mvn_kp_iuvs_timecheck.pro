;+
; ROUTINE TO CHECK THAT A GIVEN IUVS DATA STRUCTURE FALLS WITHIN THE SEARCH TIMES
;
; :Params:
;    time: in, required, type=string
;       the time read from the IUVS file
;    begin_time: in, required, type=integer
;       julian time of the beginning of a given search period
;    end_time: in, required, type=integer
;       julian time of the end of a given search period
;    check: out, required, type=boolean
;       the flag to indicate whether the iuvs file time is within search bounds.
;

;-
pro MVN_KP_IUVS_TIMECHECK, time, begin_time, end_time, check
  
  
  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif

  ;PARSE THE INPUT TIME FROM IUVS FORMAT TO KP READER FORMAT

  data_year = strmid(time,0,4)
  data_month = strmid(time,5,2)
  data_day = strmid(time,8,2)
  data_hour = strmid(time,11,2)
  data_min = strmid(time,14,2)
  data_sec = strmid(time,17,6)
    
    case data_month of 
      'JAN': data_month=1
      'FEB': data_month=2
      'MAR': data_month=3
      'APR': data_month=4
      'MAY': data_month=5
      'JUN': data_month=6
      'JUL': data_month=7
      'AUG': data_month=8
      'SEP': data_month=9
      'OCT': data_month=10
      'NOV': data_month=11
      'DEC': data_month=12
      '01': data_month=1
      '02': data_month=2
      '03': data_month=3
      '04': data_month=4
      '05': data_month=5
      '06': data_month=6
      '07': data_month=7
      '08': data_month=8
      '09': data_month=9
      '10': data_month=10
      '11': data_month=11
      '12': data_month=12
    endcase
    
  ;CONVERT THE INPUT TIME TO JULIAN 

    time_jul = julday(data_month, data_day, data_year, data_hour, data_min, data_sec)

  ;CONVERT THE BEGINNING AND END TIMES TO JULIAN

  begin_year = strmid(begin_time,0,4)
  begin_month = strmid(begin_time,5,2)
  begin_day = strmid(begin_time,8,2)
  begin_hour = strmid(begin_time,11,2)
  begin_min = strmid(begin_time,14,2)
  begin_sec = strmid(begin_time,17,2)

  end_year = strmid(end_time,0,4)
  end_month = strmid(end_time,5,2)
  end_day = strmid(end_time,8,2)
  end_hour = strmid(end_time,11,2)
  end_min = strmid(end_time,14,2)
  end_sec = strmid(end_time,17,2)

    begin_jul = julday(begin_month,begin_day,begin_year,begin_hour,begin_min,begin_sec)
    end_jul = julday(end_month,end_day,end_year,end_hour,end_min,end_sec)

  ;COMPARE AND, IF WITHIN RANGE, RETURN CHECK=1

    if begin_jul le time_jul then begin
     if end_Jul ge time_jul then begin
      check=1
     endif else begin
      check=0
     endelse
    endif else begin
      check=0
    endelse
   
end