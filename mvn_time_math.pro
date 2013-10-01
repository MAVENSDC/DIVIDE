function MVN_TIME_MATH, time, delta

 
      begin_year = fix(strmid(time,0,4))
      begin_month = fix(strmid(time,5,2))
      begin_day = fix(strmid(time,8,2))
      begin_hour = fix(strmid(time,11,2))
      begin_minute = fix(strmid(time,14,2))
      begin_second = fix(strmid(time,17,2))
           
      day_increase = floor(delta/86400)
      hour_increase = floor((delta - (day_increase*86400))/3600)
      min_increase = floor((delta - (day_increase*86400) - (hour_increase*3600))/60)
      sec_increase = floor((delta - (day_increase*86400) - (hour_increase*3600) - (min_increase*60)))
      
      end_year = string(begin_year)
      if begin_month lt 10 then begin
        end_month = '0'+strtrim(string(begin_month),2)
      endif else begin
        end_month = string(begin_month)
      endelse
      end_day = begin_day + day_increase
      end_hour = begin_hour + hour_increase
      end_minute = begin_minute + min_increase
      end_second = begin_second + sec_increase
      
      if end_second gt 60 then begin
        end_minute = end_minute + floor(end_second/60)
        end_second = end_second mod 60
      endif
      if end_minute gt 60 then begin
        end_hour = end_hour + floor(end_minute/60)
        end_minute = end_minute mod 60
      endif
      if end_hour gt 24 then begin
        end_day = end_day + floor(end_hour/24)
        end_hour = end_hour mod 24
      endif
      
      if end_day ge 10 then begin
        end_day = string(end_day)
      endif else begin
        end_day = '0'+strtrim(string(end_day),2)
      endelse
      if end_minute ge 10 then begin
        end_minute = string(end_minute)
      endif else begin
        end_minute = '0'+strtrim(string(end_minute),2)
      endelse
      if end_second ge 10 then begin
        end_second = string(end_second)
      endif else begin
        end_second = '0'+strtrim(string(end_second),2)
      endelse
 
      time_out = strtrim(end_year,2)+'-'+strtrim(end_month,2)+'-'+strtrim(end_day,2)+'/'+strtrim(end_hour,2)+':'+strtrim(end_minute,2)+':'+strtrim(end_second,2)

return,time_out
end