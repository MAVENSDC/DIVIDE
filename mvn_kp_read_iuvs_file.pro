pro mvn_kp_read_iuvs_return_substruct, iuvs_record_temp, begin_time, end_time, instruments


  ;;
  ;;;    FIXME - Clean up this whole time checking stuff
  ;;


  ;; Init new structure with only instruments in instruments struct
  MVN_KP_IUVS_STRUCT_INIT, iuvs_record_time_temp, instruments=instruments
  any_within_bounds = 0
  
  if instruments.periapse then begin
    for peri_index = 0, n_elements(iuvs_record_temp.periapse.time_start)-1 do begin
      if (iuvs_record_temp.periapse[peri_index].time_start ne '') then begin
        check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.periapse[peri_index].time_start, begin_time, end_time)
        
        if check then begin 
          iuvs_record_time_temp.periapse[peri_index] = iuvs_record_temp.periapse[peri_index]
          any_within_bounds = 1
        endif
      endif
    endfor
  endif
  
  ;; Check Echelle Observation Modes
  if instruments.c_e_limb then begin
    if (iuvs_record_temp.corona_e_limb.time_start ne '') then begin
      check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.corona_e_limb.time_start, begin_time, end_time)
      if check then iuvs_record_time_temp.corona_e_limb = iuvs_record_temp.corona_e_limb
    endif
  endif
  if instruments.c_e_disk then begin
    if (iuvs_record_temp.corona_e_disk.time_start ne '') then begin
      check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.corona_e_disk.time_start, begin_time, end_time)
      if check then begin 
        iuvs_record_time_temp.corona_e_disk = iuvs_record_temp.corona_e_disk
        any_within_bounds = 1
      endif    
    endif
  endif
  if instruments.c_e_high then begin
    if (iuvs_record_temp.corona_e_high.time_start ne '') then begin
      check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.corona_e_high.time_start, begin_time, end_time)
      if check then begin
        iuvs_record_time_temp.corona_e_high = iuvs_record_temp.corona_e_high
        any_within_bounds = 1
      endif 
    endif
  endif
  
  ;; Check LORES Observation modes
  if instruments.c_l_limb then begin
    if (iuvs_record_temp.corona_lo_limb.time_start ne '') then begin
      check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.corona_lo_limb.time_start, begin_time, end_time)
      if check then begin 
        iuvs_record_time_temp.corona_lo_limb = iuvs_record_temp.corona_lo_limb
        any_within_bounds = 1
      endif    
    endif
  endif
  if instruments.c_l_disk then begin
    if (iuvs_record_temp.corona_lo_disk.time_start ne '') then begin
      check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.corona_lo_disk.time_start, begin_time, end_time)
      if check then begin 
        iuvs_record_time_temp.corona_lo_disk = iuvs_record_temp.corona_lo_disk
        any_within_bounds = 1
      endif      
    endif
  endif
  if instruments.c_l_high then begin
    if (iuvs_record_temp.corona_lo_high.time_start ne '') then begin
      check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.corona_lo_high.time_start, begin_time, end_time)
      if check then begin
        iuvs_record_time_temp.corona_lo_high = iuvs_record_temp.corona_lo_high
        any_within_bounds = 1
      endif
    endif
  endif
  
  ;; Check apoapse observation mode
  if instruments.apoapse then begin
    if (iuvs_record_temp.apoapse.time_start ne '') then begin
      check = MVN_KP_TIME_BOUNDS(iuvs_record_temp.apoapse.time_start, begin_time, end_time)
      if check then begin
        iuvs_record_time_temp.apoapse = iuvs_record_temp.apoapse
        any_within_bounds = 1
      endif
    endif
  endif
  
  ;; If any observations within time bounds, return structure. Otherwise, set to -1
  if any_within_bounds then begin
    iuvs_record_time_temp.orbit = iuvs_record_temp.orbit
    iuvs_record_temp = iuvs_record_time_temp
  endif else begin
    iuvs_record_temp = -1
  endelse
  
  return
end



pro mvn_kp_read_iuvs_file, filename, iuvs_record, begin_time=begin_time, end_time=end_time, $
                           savefiles=savefiles, textfiles=textfiles, instruments=instruments
  
  
  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  if keyword_set(begin_time) and keyword_set(end_time) then begin
    time_bounds=1
    any_within_bounds = 0
  endif else begin
    time_bounds=0
    any_within_bounds = 1
  endelse
  

  if keyword_set(savefiles) then begin
    
    ;INITIALIZE IUVS_RECORD TO CONTAIN DEFAULT VALUES
    MVN_KP_IUVS_STRUCT_INIT, iuvs_record, instruments=instruments
  
    ;SET EACH IUVS OBSERVATION DATA TYPE TO 0 BEFORE READING
    periapse = 0
    apoapse = 0
    corona_echelle_limb = 0
    corona_echelle_disk = 0
    corona_echelle_high = 0
    ;          stellar_occ = 0
    corona_lores_high = 0
    corona_lores_limb = 0
    corona_lores_disk = 0
    
    restore,filename
    
    
    if instruments.periapse then begin                                    ;READ AND PARSE PERIAPSE DATA
      if size(periapse,/type) eq 8 then begin
        for peri_index = 0,n_elements(periapse.time_start)-1 do begin
          if time_bounds eq 1 then begin
            check = MVN_KP_TIME_BOUNDS(periapse[peri_index].time_start, begin_time, end_time)
          endif else begin
            check=1
          endelse
          
          if check eq 1 then begin
            MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, periapse[peri_index], 'PERIAPSE',index=peri_index
            any_within_bounds = 1
          endif
        endfor
      endif
    endif
    
    if instruments.apoapse then begin                                      ;READ AND PARSE APOAPSE DATA
      if size(apoapse,/type) eq 8 then begin                                    ;ONLY EXECUTE IF THIS DATA TYPE IS AVAILABLE IN THE READ FILE
        if time_bounds eq 1 then begin
          check = MVN_KP_TIME_BOUNDS(apoapse.time_start, begin_time, end_time)
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, apoapse, 'APOAPSE',index=0
          any_within_bounds = 1
        endif
      endif
    endif
    
    if instruments.c_e_high then begin                                    ;READ AND PARSE CORONA ECHELLE HIGH ALTITUDE DATA
      if size(corona_echelle_high,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          check = MVN_KP_TIME_BOUNDS(corona_echelle_high.time_start, begin_time, end_time)
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_high, 'CORONA_ECHELLE_HIGH'
          any_within_bounds = 1
        endif
      endif
    endif
    if instruments.c_e_limb then begin                                    ;READ AND PARSE CORONA ECHELLE LIMB DATA
      if size(corona_echelle_limb,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          check = MVN_KP_TIME_BOUNDS(corona_echelle_limb.time_start, begin_time, end_time)
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_limb, 'CORONA_ECHELLE_LIMB'
          any_within_bounds = 1
        endif
      endif
    endif
    ;          if instruments.stellarocc eq 1 then begin                                    ;READ AND PARSE STELLAR OCCULTATION DATA
    ;
    ;          endif
    if instruments.c_l_high then begin                                    ;READ AND PARSE CORONA LORES HIGH ALT DATA
      if size(corona_lores_high,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          check = MVN_KP_TIME_BOUNDS(corona_lores_high.time_start, begin_time, end_time)
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_high, 'CORONA_LORES_HIGH'
          any_within_bounds = 1
        endif
      endif
    endif
    if instruments.c_l_limb then begin                                    ;READ AND PARSE CORONA LORES LIMB DATA
      if size(corona_lores_limb,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          check = MVN_KP_TIME_BOUNDS(corona_lores_limb.time_start, begin_time, end_time)
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_limb, 'CORONA_LORES_LIMB'
          any_within_bounds = 1
        endif
      endif
    endif
    if instruments.c_l_disk then begin                                    ;READ AND PARSE CORONA LORES DISK DATA
      if size(corona_lores_disk,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          check = MVN_KP_TIME_BOUNDS(corona_lores_disk.time_start, begin_time, end_time)
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_disk, 'CORONA_LORES_DISK'
          any_within_bounds = 1
        endif
      endif
    endif
    if instruments.c_e_disk then begin                                    ;READ AND PARSE CORONA Echelle DISK DATA
      if size(corona_echelle_disk,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          check = MVN_KP_TIME_BOUNDS(corona_echelle_disk.time_start, begin_time, end_time)
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_disk, 'CORONA_ECHELLE_DISK'
          any_within_bounds = 1
        endif
      endif
    endif
    
    ;; Add in orbit number
    iuvs_record.orbit = periapse[0].orbit_number
    
    ;; If not observations within the timebounds, return -1
    if not any_within_bounds then begin
      iuvs_record = -1
    endif
    
  endif else if keyword_set(textfiles) then begin  
    ;READ IUVS DATA FROM ASCII FILES

    ;; Call IUVS ASCII reader to read one iuvs file in ascii format
    MVN_KP_READ_IUVS_ASCII, filename, iuvs_record
      
    ;; If timebounds or instrument array - FIXME 
    if time_bounds then begin
      mvn_kp_read_iuvs_return_substruct, iuvs_record, begin_time, end_time, instruments
    endif
    
  
  endif else begin
    ;; Default is to read CDF files

    ;; Read in CDF version of file
    MVN_KP_IUVS_CDF_READ, iuvs_record, filename, instruments=instruments
   
    ;; If checking time bounds or instrument array - FIXME
    if time_bounds then begin
      MVN_KP_READ_IUVS_RETURN_SUBSTRUCT, iuvs_record, begin_time, end_time, instruments
    endif

  endelse
  
end
