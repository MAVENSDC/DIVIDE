;+
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
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
pro MVN_KP_TIME_FIND, time_match, orbit_match, time, time_out, orbit_index, max=max, min=min


  year_in = fix(strmid(time,0,4))
  mon_in = fix(strmid(time,5,2))
  day_in = fix(strmid(time,8,2))
  hour_in = fix(strmid(time,11,2))
  min_in = fix(strmid(time,14,2))
  sec_in = fix(strmid(time,17,2))

  time_jul = julday(mon_in, day_in, year_in, hour_in, min_in, sec_in)
  
  year_arr = fix(strmid(time_match,0,4))
  mon_arr = fix(strmid(time_match,5,2))
  day_arr = fix(strmid(time_match,8,2))
  hour_arr = fix(strmid(time_match,11,2))
  min_arr = fix(strmid(time_match,14,2))
  sec_arr = fix(strmid(time_match,17,2))
  
  arr_jul = julday(mon_arr, day_arr, year_arr, hour_arr, min_arr, sec_arr)
  
  temp = min(abs(arr_jul - time_jul),time_out)
  if keyword_set(min) then begin
    orbit_index = min(where(orbit_match eq orbit_match(time_out)))
  endif
  if keyword_set(max) then begin
    orbit_index = max(where(orbit_match eq orbit_match(time_out)))
  endif
  
end