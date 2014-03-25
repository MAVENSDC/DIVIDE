pro mvn_kp_time_split_one_string, time_in, year=year, month=month, day=day, hour=hour, min=min, sec=sec
  ;; Copy time input
  time_string = time_in
  
  ;; If String contains a 'T' Then split assuming time "YYYY-MM-DDTHH:MM:SS'
  if strmatch(time_string, '*T*') then begin
    first_split = strsplit(time_string, 'T', /EXTRACT)
  
  ;; Otherwise assume string format "YYYY-MM-DD/HH:MM:SS'
  endif else begin
    first_split = strsplit(time_string, '/', /EXTRACT)
  endelse


  date_string = first_split[0]
  
  ;; Split date
  date_split = strsplit(date_string, '-', /EXTRACT)
  year  = date_split[0]
  month = date_split[1]
  day   = date_split[2]
  
  
  ;; Split time (if it exists)
  if size(first_split, /N_ELEMENTS) gt 1 then begin
    time_string = first_split[1]
    time_split = strsplit(time_string, ':', /EXTRACT)
    hour = time_split[0]
    min  = time_split[1]
    sec  = time_split[2]

    
  ;; If no time, then fill in hour,min,sec with zeros
  endif else begin
    hour = '00'
    min  = '00'
    sec  = '00'
  endelse

end

;; Routine to take a time string and split it apart and return the individual parts
;;
;;
;;  time_in: input, required. 
;;              string: format 'yyyy-mm-ddThh:mm:ss'
;;             or array of strings of same format  
;;  FIX : input, optional
;;          Return integers instead of strings
;;
;;
;;  FIXME - Need to pad strings with zeros if necessary
;;  FIXME - Not effecient procedure for dealing with array of strings
;;


pro mvn_kp_time_split_string, time_in, year=year, month=month, day=day, hour=hour, min=min, sec=sec, FIX=FIX

  ;; Validate inputs
  if size(time_in, /TYPE) ne 7 then message, "Input time must be a string"
  
  ;; Copy input  
  time_string = time_in
   
  ;; If size is greater than 1 we have a list of strings
  if size(time_string, /n_elements) gt 1 then begin

    ;; Number of inputs
    num = size(time_string, /n_elements)

    year_array  = make_array(num, type=7)
    month_array = make_array(num, type=7)
    day_array   = make_array(num, type=7)
    hour_array  = make_array(num, type=7)
    min_array   = make_array(num, type=7)
    sec_array   = make_array(num, type=7)
     
    ;; Loop through each string 
    for i = 0, num-1 do begin
      mvn_kp_time_split_one_string, time_string[i], year=year, month=month, day=day, hour=hour, min=min, sec=sec
      year_array[i]  = year
      month_array[i] = month
      day_array[i]   = day
      hour_array[i]  = hour
      min_array[i]   = min
      sec_array[i]   = sec
    endfor
    
    ;; Copy arrays to output variables
    year  = year_array
    month = month_array
    day   = day_array
    hour  = hour_array
    min   = min_array
    sec   = sec_array


  ;; If one element
  endif else if size(time_string, /n_elements) eq 1 then begin
    mvn_kp_time_split_one_string, time_string, year=year, month=month, day=day, hour=hour, min=min, sec=sec
    
  endif else begin
    message, "Must input a string of non zero length for time_in (or array of strings).
  endelse
    
  
  ;; If keyword set 'FIX', convert all values to integers
  if keyword_set(FIX) then begin
    year  = fix(year)
    month = fix(month)
    day   = fix(day)
    hour  = fix(hour)
    min   = fix(min)
    sec   = fix(sec)
  endif
  
end