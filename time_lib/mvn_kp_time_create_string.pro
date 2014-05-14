;;
;; Create time string of format "YYYY-MM-DD/HH:MM:SS" from input jul day
;;
;;


function MVN_KP_TIME_CREATE_STRING, time_jul

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
  ;; Take jul date and use caldat to create time string parts
  caldat, time_jul, month, day, year, hour, mn, sec
  
  ;; Add leading zeros if necessary
  if month ge 10 then begin
    month = string(month)
  endif else begin
    month = '0'+strtrim(string(month),2)
  endelse
  
  if day ge 10 then begin
    day = string(day)
  endif else begin
    day = '0'+strtrim(string(day),2)
  endelse
  
  if hour ge 10 then begin
    hour = string(hour)
  endif else begin
    hour = '0'+strtrim(string(hour),2)
  endelse
  
  if mn ge 10 then begin
    mn = string(mn) 
  endif else begin
    mn = '0'+strtrim(string(mn),2)
  endelse
  
  if sec ge 10 then begin
    sec = string(fix(sec))
  endif else begin
    sec = '0'+strtrim(string(fix(sec)),2)
  endelse
  

  time_out = strtrim(year,2)+'-'+strtrim(month,2)+'-'+strtrim(day,2)+'/'+strtrim(hour,2)+':'+strtrim(mn,2)+':'+strtrim(sec,2)

  return,time_out
end