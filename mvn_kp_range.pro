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
pro MVN_KP_RANGE, kp_data

  base_tags = tag_names(kp_data)

  if base_tags[0] eq 'TIME_STRING' then begin
      print,'The loaded KP data set contains data between '+kp_data[0].time_string+' and '+kp_data[n_elements(kp_data.time_string)-1].time_string
      print,'Equivalently, this corresponds to orbits '+strtrim(string(kp_data[0].orbit),2)+' and '+strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit),2)
  endif
  if (base_tags[0] eq 'CORONA_LO_LIMB') OR  (base_tags[0] eq 'CORONA_LO_HIGH') or  (base_tags[0] eq 'STELLAR_OCC') or  (base_tags[0] eq 'CORONA_E_DISK') OR $
     (base_tags[0] eq 'CORONA_E_HIGH') OR  (base_tags[0] eq 'APOAPSE') OR  (base_tags[0] eq 'PERIAPSE ') THEN BEGIN
      print,'The loaded KP data set contains data between '+kp_data[1].(0).time_start+' and '+kp_data[n_elements(kp_data.(0).time_stop)-1].(0).time_stop
      print,'Equivalently, this corresponds to orbits '+strtrim(string(kp_data[0].orbit),2)+' and '+strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit),2)     
  endif


end