;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds 
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;       input for start argument to H5S_SELECT_HYPERSLAB
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to H5S_SELECT_HYPERSLAB
;    block : out, optional, type=lonarr(ndims)
;       input for block keyword to H5S_SELECT_HYPERSLAB
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to H5S_SELECT_HYPERSLAB
;-
pro MVN_KP_RANGE_SELECT, kp_data, time, begin_index, end_index


  if size(time,/type) eq 2 then begin         ;IF USER SUPPIED ORBIT NUMBER (IE INTEGERS)
    if size(time,/dimensions) eq 0 then begin               ;user gives only 1 integer, then default to plotting 1 orbit
      begin_index = where(kp_data.orbit eq time)
      begin_index = begin_index[0]
      end_index = where(kp_data.orbit eq (time+1))
      end_index = end_index[n_elements(end_index)-1]
    endif
    if size(time,/dimensions) eq 2 then begin               ;user gives 2 integers, so find indices that match start/end orbits
      begin_index = where(kp_data.orbit eq time[0])
      begin_index = begin_index[0]
      end_index = where(kp_data.orbit eq (time[1]))
      end_index = end_index[n_elements(end_index)-1]     
    endif
  endif 
  
  if size(time,/type) eq 7 then begin         ;IF USER SUPPLIED STRING BASED TIME
    if size(time,/dimensions) eq 0 then begin
      time = time_double(time, tformat="YYYY-MM-DDThh:mm:ss")
      t1 = min((kp_data.time - time),begin_index,/absolute)
      t2 = min((kp_data.time - (time + 86400l)),end_index,/absolute)
    endif
    if size(time,/dimensions) eq 2 then begin
      time1 = time_double(time[0], tformat="YYYY-MM-DDThh:mm:ss")
      time2 = time_double(time[1], tformat="YYYY-MM-DDThh:mm:ss")
      t1 = min((kp_data.time - time1),begin_index,/absolute)
      t2 = min((kp_data.time - time2),end_index,/absolute) 
    endif
  endif
  
  if size(time,/type) eq 3 then begin         ;IF USER SUPPLIED POSIX TIME (IE LONG INTEGERS)
    if size(time,/dimensions) eq 0 then begin   ;user gives only 1 integer, then default to 1 day of plotting
      t1 = min((kp_data.time - time),begin_index,/absolute)
      t2 = min((kp_data.time - (time + 86400l)),end_index,/absolute)
    endif 
    if size(time,/dimensions) eq 2 then begin   ;user gives 2 integers, so find indices that match start/end times
      t1 = min((kp_data.time - time[0]),begin_index,/absolute)
      t2 = min((kp_data.time - time[1]),end_index,/absolute)      
    endif
  endif 


end