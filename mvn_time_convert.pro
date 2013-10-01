function MVN_TIME_CONVERT,time_in,format


if format eq 1 then begin
  time_out=time_in
endif

if format eq 2 then begin
    ;EXTRACT THE VARIOUS TIME/DATE COMPONENTS
      begin_year = fix(strmid(time_in,0,4))
      begin_month = fix(strmid(time_in,5,2))
      begin_day = fix(strmid(time_in,8,2))
      begin_hour = fix(strmid(time_in,11,2))
      begin_minute = fix(strmid(time_in,14,2))
      begin_second = fix(strmid(time_in,17,2))
  
     ;CALCULATE THE DAY OF YEAR
     case begin_month of
      1: begin_day1 = ((begin_year-2013)*365)+begin_day
      2: begin_day1 = ((begin_year-2013)*365)+(31 + begin_day)
      3: begin_day1 = ((begin_year-2013)*365)+(59 +begin_day)
      4: begin_day1 = ((begin_year-2013)*365)+(90 + begin_day)
      5: begin_day1 = ((begin_year-2013)*365)+(120 + begin_day)
      6: begin_day1 = ((begin_year-2013)*365)+(151 + begin_day)
      7: begin_day1 = ((begin_year-2013)*365)+(181 + begin_day)
      8: begin_day1 = ((begin_year-2013)*365)+(212 + begin_day)
      9: begin_day1 = ((begin_year-2013)*365)+(243 + begin_day)
      10: begin_day1 = ((begin_year-2013)*365)+(273 + begin_day)
      11: begin_day1 = ((begin_year-2013)*365)+(304 + begin_day)
      12: begin_day1 = ((begin_year-2013)*365)+(334 + begin_day)
    endcase
  
    day_fraction = ((begin_hour * 3600.) + (begin_minute * 60.) + (begin_second))/86400.
    
    time_out = ((begin_year-2013)*365) + begin_day1 + day_fraction
  
endif


if format eq 3 then begin      ;CONVERT FROM POSIX TO STRING TIME 
  time_out = time_string(time_in, format=0)
endif

return, time_out
end