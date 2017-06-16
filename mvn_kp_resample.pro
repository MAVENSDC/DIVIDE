;+
;
; :Name: mvn_kp_resample
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: Kristopher Larsen
; 
; :Description:
;   This routine enables the user to resample an MAVEN insitu KP data 
;   structure to an arbitrary time cadence.
;   Used in conjunction with mvn_kp_add_data, this enables the user to 
;   modify and extend the KP data (with additional Level-2 data, for 
;   example), yet still use the plotting and visualization components of 
;   the Toolkit.
;
; :Params:
;    kp_data: in, required, type=structure
;      This is the original insitu KP data structure from the rest of the 
;      toolkit that is to be resampled.
;    time: in, required, type=intarr, strarr
;      An array of times to which the input data structure is to be 
;      resampled. This routine does not extrapolate,
;      so the time array must be completely within the time range of the 
;      input data structure.
;    data_out: out, required, type=structure
;      The KP data structure resampled to the given time cadence.
;
; :Keywords:
;    sc_only: in, optional, type=boolean
;     By default, this routine will resample all the KP data within the 
;     input structure. Using this keyword, the user can force the routine 
;     to only resample the SPACECRAFT substructure.  Mostly this would be 
;     useful for using the visualization routines with arbitrary non-KP data.
;    help: in, optional, type=boolean
;     Display the help contents on the screen.
;       
;
; :Version:   1.0     July 8, 2014
;-
pro mvn_kp_resample, kp_data, time, data_out, sc_only=sc_only, help=help


  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_resample'
    return
  endif


  ;check that inputs make sense
    
    time = time_double(time)
    new_total = n_elements(time)

    ;define the subset of the input structure based on times
    
    start_time = time[0]
    end_time = time[n_elements(time)-1]
  
    if start_time lt kp_data[0].time then begin
      print,'The requested start time is before the earliest data point ' $
            +'in the input data structure.'
      print,'This routine DOES NOT extrapolate. Please read in more KP ' $
            +'data that covers the requested time span.'
      return
    endif
  
    if end_time gt kp_data[n_elements(kp_data)-1].time then begin
      print,'The requested end time is after the latest data point in ' $
            +'the input data structure.'
      print,'This routine DOES NOT extrapolate. Please read in more KP ' $
            +'data that covers the requested time span.'
      return
    endif
    
    
    t1 = min(abs(kp_data.time - start_time), start_index, /NAN)
    t2 = min(abs(kp_data.time - end_time), end_index, /NAN)
    
    kp_temp = kp_data[start_index:end_index]
    
    ;Closest values (needed for the several nearest neighbor interpolations)
    closest_time_indexes = value_locate(kp_temp.Time, time)
    
  ;determine if all data fields to be filled, or only some
  
    instruments = CREATE_STRUCT('lpw',      0, 'euv',    0, 'static',   0, $
                                'swia',     0, $
                                'swea',     0, 'mag',      0, 'sep',      0, $
                                'ngims',    0, 'periapse', 0, 'c_e_disk', 0, $
                                'c_e_limb', 0, 'c_e_high', 0, 'c_l_disk', 0, $
                                'c_l_limb', 0, 'c_l_high', 0, 'apoapse' , 0, $
                                'stellarocc', 0)
  
  if keyword_set(sc_only) then begin
    print,'RETURNING ONLY A RESAMPLED SPACECRAFT DATA STRUCTURE.'
    PRINT,'NO MAVEN KP DATA WILL BE RESAMPLED AND RETURNED!'
  endif else begin
  
      old_tags = tag_names(kp_data)
      
      a = where(old_tags eq 'LPW')
        if a ne -1 then instruments.lpw = 1
      a = where(old_tags eq 'EUV')
        if a ne -1 then instruments.euv = 1 
      a = where(old_tags eq 'STATIC')
        if a ne -1 then instruments.static = 1
      a = where(old_tags eq 'SWIA')
        if a ne -1 then instruments.swia = 1  
      a = where(old_tags eq 'SWEA')
        if a ne -1 then instruments.swea = 1
      a = where(old_tags eq 'MAG')
        if a ne -1 then instruments.mag = 1  
      a = where(old_tags eq 'SEP')
        if a ne -1 then instruments.sep = 1  
      a = where(old_tags eq 'NGIMS')
        if a ne -1 then instruments.ngims = 1  

   endelse
  
  ;initialize the output data structure
  
    ;Commented out because this procedure now needs a file name
    ;mvn_kp_insitu_struct_init, insitu_record, instruments=instruments
    
    ;Just initialize the insitu struct based on the input kp structure.  All the values are going to be replaced anyway.  
    insitu_record = kp_temp[0]
    insitu_temp = replicate(insitu_record, new_total)
    
  ;fill the output using a spline fit
  
     insitu_temp.time = time
     insitu_temp.time_string = time_string(time)
     old_time = kp_temp.time
     
     ;Fill orbit
     insitu_temp.orbit = kp_temp[closest_time_indexes].orbit
     
     ;Fill IOflag (nearest neighbor)
     insitu_temp.IO_bound = kp_temp[closest_time_indexes].IO_bound
     
  
      if instruments.lpw eq 1 then begin
        tag_loop = tag_names(kp_temp.lpw)
        for i=0, n_elements(tag_loop) - 1 do begin
          insitu_temp.lpw.(i) = interpol(kp_temp.lpw.(i), old_time, $
                                       time, /spline)
        endfor
      endif
      if instruments.euv eq 1 then begin
        tag_loop = tag_names(kp_temp.euv)
        for i=0, n_elements(tag_loop) - 1 do begin
          insitu_temp.euv.(i) = interpol(kp_temp.euv.(i), old_time, $
                                       time, /spline)
        endfor
      endif
      if instruments.static eq 1 then begin
        tag_loop = tag_names(kp_temp.static)
        for i=0, n_elements(tag_loop) - 1 do begin
          insitu_temp.static.(i) = interpol(kp_temp.static.(i), old_time, $
                                          time, /spline)
        endfor
      endif
      if instruments.swia eq 1 then begin
        tag_loop = tag_names(kp_temp.swia)
        for i=0, n_elements(tag_loop) - 1 do begin
          insitu_temp.swia.(i) = interpol(kp_temp.swia.(i), old_time, $
                                        time, /spline)
        endfor
      endif
      if instruments.swea eq 1 then begin
        tag_loop = tag_names(kp_temp.swea)
        for i=0, n_elements(tag_loop) - 1 do begin
          insitu_temp.swea.(i) = interpol(kp_temp.swea.(i), old_time, $
                                        time, /spline)
        endfor
      endif
      if instruments.mag eq 1 then begin
        tag_loop = tag_names(kp_temp.mag)
        for i=0, n_elements(tag_loop) - 1 do begin
          insitu_temp.mag.(i) = interpol(kp_temp.mag.(i), old_time, $
                                       time, /spline)
        endfor
      endif
      if instruments.sep eq 1 then begin
        tag_loop = tag_names(kp_temp.sep)
        for i=0, n_elements(tag_loop) - 1 do begin
          insitu_temp.sep.(i) = interpol(kp_temp.sep.(i), old_time, $
                                       time, /spline)
        endfor
      endif
      
      if instruments.ngims eq 1 then begin
        tag_loop = tag_names(kp_temp.ngims)
        for i=0, n_elements(tag_loop) - 1 do begin
          if ISA(kp_temp[0].ngims.(i), /STRING) then begin
            insitu_temp.ngims.(i) = kp_temp[closest_time_indexes].ngims.(i)
          endif else begin
          insitu_temp.ngims.(i) = interpol(kp_temp.ngims.(i), old_time, $
            time, /spline)
          endelse 
        endfor
      endif
 
    ;fill the spacecraft and app structures
    
      tag_loop = tag_names(kp_temp.spacecraft)
      for i=0, n_elements(tag_loop) - 1 do begin
        insitu_temp.spacecraft.(i) = interpol(kp_temp.spacecraft.(i), old_time, $
                                            time, /spline)
      endfor
  
      tag_loop = tag_names(kp_temp.app)
      for i=0, n_elements(tag_loop) - 1 do begin
        insitu_temp.app.(i) = interpol(kp_temp.app.(i), old_time, time, /spline)
      endfor
  
  ;export the final resampled structure
  
      data_out = insitu_temp

end