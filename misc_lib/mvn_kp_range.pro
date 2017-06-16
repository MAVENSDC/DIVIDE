;+
; Print out time and/or orbit range of input kp data structure for in situ or IUVS data
;
; :Params:
;     kp_data : in, required, type array
;       kp data to pull out time/orbit range for.  
;       Can be either in-situ or IUVS
;   
; :Keywords:
;    iuvs: in, optional, type=structure
;      If provided, along with the required insitu parameter, the code will
;      output the range of times and orbits for in-situ, and range of orbits
;      for IUVS.  It will then check whether there is overlap between the
;      two.
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
pro MVN_KP_RANGE, kp_data, iuvs=iuvs

  base_tags = tag_names(kp_data)

  if base_tags[0] eq 'TIME_STRING' then begin
      print,'The loaded IN-SITU KP data set contains data between: '
      print,'   '+kp_data[0].time_string+' and '$
            +kp_data[n_elements(kp_data.time_string)-1].time_string
      print,'Equivalently, this corresponds to orbits '$
            +strtrim(string(kp_data[0].orbit),2)+' and '$
            +strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit),2)
  endif
  if (base_tags[0] eq 'CORONA_LO_LIMB') OR  $
     (base_tags[0] eq 'CORONA_LO_HIGH') or  $
     (base_tags[0] eq 'STELLAR_OCC') or  $
     (base_tags[0] eq 'CORONA_E_DISK') OR $
     (base_tags[0] eq 'CORONA_E_HIGH') OR  $
     (base_tags[0] eq 'APOAPSE') OR  $
     (base_tags[0] eq 'PERIAPSE') THEN BEGIN

     ;; IUVS too special and too much of a pain to try and parse the 
     ;; correct start and end times for full data set
     ;; Show orbits at least

      print,'The loaded IUVS KP data set contains data between orbits '$
            +strtrim(string(kp_data[0].orbit),2)+' and '$
            +strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit),2)     
  endif

  if( keyword_set(iuvs) )then begin
    print,'The loaded IUVS KP data set contains data between orbits '$
          +strtrim(string(iuvs[0].orbit),2)+' and '$
          +strtrim(string(iuvs[n_elements(iuvs.orbit)-1].orbit),2)
    insitu_orbits = kp_data[uniq(kp_data.orbit)].orbit
    if( max(iuvs.orbit, /NAN) lt min(insitu_orbits, /NAN) or $
        min(iuvs.orbit, /NAN) gt max(insitu_orbits, /NAN) )then begin
      print,'****WARNING****'
      print,'There is NO overlap between the supplied in-situ and IUVS'
      print,'  data structures.  I cannot guarantee your safety if you'
      print,'  should choose to attmept to display the IUVS data against'
      print,'  the in-situ-supplied ephemeris.'
    endif  ; test the range of IUVS and in-situ orbits
  endif    ; if both IUVS and in-situ structures have been passed
  
end
