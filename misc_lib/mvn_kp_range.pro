;+
; Print out time and/or orbit range of input kp data structure for in situ or IUVS data
;
;
; :Keywords:
;     kp_data : in, required, type array
;       kp data to pull out time/orbit range for
;    
;-
pro MVN_KP_RANGE, kp_data

  base_tags = tag_names(kp_data)

  if base_tags[0] eq 'TIME_STRING' then begin
      print,'The loaded KP data set contains data between '+kp_data[0].time_string+' and '+kp_data[n_elements(kp_data.time_string)-1].time_string
      print,'Equivalently, this corresponds to orbits '+strtrim(string(kp_data[0].orbit),2)+' and '+strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit),2)
  endif
  if (base_tags[0] eq 'CORONA_LO_LIMB') OR  (base_tags[0] eq 'CORONA_LO_HIGH') or  (base_tags[0] eq 'STELLAR_OCC') or  (base_tags[0] eq 'CORONA_E_DISK') OR $
     (base_tags[0] eq 'CORONA_E_HIGH') OR  (base_tags[0] eq 'APOAPSE') OR  (base_tags[0] eq 'PERIAPSE') THEN BEGIN

     ;; IUVS too special and too much of a pain to try and parse otu the correct stand and end times for full data set
     ;; Show orbits at least
     ;; print,'The loaded KP data set contains data between '+kp_data[0].(0)[0].time_start+' and '+kp_data[n_elements(kp_data)-1].(0)[0].time_stop
      print,'The loaded KP data set contains data between orbits '+strtrim(string(kp_data[0].orbit),2)+' and '+strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit),2)     
  endif

end