;+
;FUNCTION: time_double(time)
;NAME:
;  time_double
;PURPOSE:
; A fast, vectorized routine that returns the number of seconds since 1970.
;INPUT:  input can be any of the following types:
;  double(s)      seconds since 1970   (returns the input)
;  string(s)      format:  YYYY-MM-DD/hh:mm:ss  see "time_string"
;  structure(s)   format returned in "time_struct"
;  long array     (MUST be 2 dimensional!)  PB5 time  (req. by CDF)
;
;OUTPUT:
;  double, number of seconds since 1970  (UNIX time)
;KEYWORDS:
;  EPOCH:  if set, it implies the input is double precision EPOCH or
;          complex double precision EPOCH16 time.
;
;SEE ALSO:  "time_string", "time_struct", "time_epoch", "time_pb5"
;
;NOTE:
;  This routine works on vectors and is designed to be fast.
;  Output will have the same dimensions as the input
;  Out of range values are interpreted correctly.
;  ie.  1994-13-1/12:61:00  will be treated as:  1995-1-1/13:01:00
;
;CREATED BY:    Davin Larson  Oct 1996
;FILE:  time_double.pro
;VERSION:  1.9
;LAST MODIFICATION:  01/07/12
;-
function time_double,time,epoch=epoch,dim=dim,pb5=pb5,MMDDYYYY=MMDDYYYY,timezone=timezone,is_local_time=is_local_time

;dprint,dlevel=9,time[0]
case size(/type,time) of
8: begin                                                     ; structures
   dn1970 = 1969l*365 + 1969/4 - 1969/100 + 1969/400 ; day number of 1970-1-1
   mdt = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
          [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]
   month = time.month-1
   date  = time.date-1
   dy = floor(month/12.)
   year = time.year + dy
   month = month - dy*12
   isleap = ((year mod 4) eq 0) - ((year mod 100) eq 0) +  $
         ((year mod 400) eq 0) - ((year mod 4000) eq 0)
   doy = mdt[month,isleap] + date
   seconds = (time.hour * 60.d + time.min) * 60.d + time.sec + time.fsec
   ;seconds = seconds+ time.tdiff * 3600d
   y = year-1
   daynum = (y*365l + y/4 - y/100 + y/400 - y/4000) + doy
   seconds = (daynum-dn1970) *3600.d*24 + seconds
   if size(/n_dimen,dim) eq 1 then if dim[0] eq 1 then seconds=[seconds]  ;!!! IDL BUG
   return,seconds
   end
7: return,time_double(time_struct(time,/no_clean,MMDDYYYY=MMDDYYYY,timezone=timezone,is_local_time=is_local_time),dim=size(/dimension,time)) ;   strings
5: begin                                                    ;   doubles
   if keyword_set(epoch) then return, time/1000.d - 719528.d * 24.* 3600.
   return,time
   end
9: begin  ; handle CDF_EPOCH16
   if keyword_set(epoch) then return, real_part(time) - 719528.d * 24. * $
      3600. + imaginary(time) * 1d-12
   message,/info,'Improper time input'
   end
4: return, double(time)
14:return, double(time)
2: return, double(time)
3: begin
;   if keyword_set(pb5) then return, pb5_to_time(time)
   return, double(time)
   end
0: return, time_double(time_string(time,prec=6))
else: message,/info,'Improper time input'
endcase

end



