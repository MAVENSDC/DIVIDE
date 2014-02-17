
pro mvn_kp_read_iuvs_file, filename, iuvs_record, begin_time=begin_time, end_time=end_time, $
                           instrument_array=instrument_array, savefiles=savefiles, textfiles=textfiles, instruments=instruments

  ;; Default to filing all instruments if not specified
  if not keyword_set(instrument_array) then begin
    instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
  endif
  
  if keyword_set(begin_time) and keyword_set(end_time) then begin
    time_bounds=1
  endif else begin
    time_bounds=0
  endelse
  

  if keyword_set(savefiles) then begin
    
    ;INITIALIZE IUVS_RECORD TO CONTAIN DEFAULT VALUES
    MVN_KP_IUVS_STRUCT_INIT, iuvs_record, instrument_array
  
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
    
    if instrument_array[7] eq 1 then begin                                    ;READ AND PARSE PERIAPSE DATA
      if size(periapse,/type) eq 8 then begin
        for peri_index = 0,n_elements(periapse.time_start)-1 do begin
          if time_bounds eq 1 then begin
            MVN_KP_IUVS_TIMECHECK, periapse[peri_index].time_start, begin_time, end_time, check
          endif else begin
            check=1
          endelse
          
          if check eq 1 then begin
            MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, periapse[peri_index], 'PERIAPSE',index=peri_index
          endif
        endfor
      endif
    endif
    
    if instrument_array[8] eq 1 then begin                                    ;READ AND PARSE APOAPSE DATA
      if size(apoapse,/type) eq 8 then begin                                    ;ONLY EXECUTE IF THIS DATA TYPE IS AVAILABLE IN THE READ FILE
        if time_bounds eq 1 then begin
          MVN_KP_IUVS_TIMECHECK, apoapse.time_start, begin_time, end_time, check
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, apoapse, 'APOAPSE',index=0
        endif
      endif
    endif
    
    if instrument_array[9] eq 1 then begin                                    ;READ AND PARSE CORONA ECHELLE HIGH ALTITUDE DATA
      if size(corona_echelle_high,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          MVN_KP_IUVS_TIMECHECK, corona_echelle_high.time_start, begin_time, end_time, check
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_high, 'CORONA_ECHELLE_HIGH'
        endif
      endif
    endif
    if instrument_array[10] eq 1 then begin                                    ;READ AND PARSE CORONA ECHELLE LIMB DATA
      if size(corona_echelle_limb,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          MVN_KP_IUVS_TIMECHECK, corona_echelle_limb.time_start, begin_time, end_time, check
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_limb, 'CORONA_ECHELLE_LIMB'
        endif
      endif
    endif
    ;          if instrument_array[11] eq 1 then begin                                    ;READ AND PARSE STELLAR OCCULTATION DATA
    ;
    ;          endif
    if instrument_array[12] eq 1 then begin                                    ;READ AND PARSE CORONA LORES HIGH ALT DATA
      if size(corona_lores_high,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          MVN_KP_IUVS_TIMECHECK, corona_lores_high.time_start, begin_time, end_time, check
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_high, 'CORONA_LORES_HIGH'
        endif
      endif
    endif
    if instrument_array[13] eq 1 then begin                                    ;READ AND PARSE CORONA LORES LIMB DATA
      if size(corona_lores_limb,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          MVN_KP_IUVS_TIMECHECK, corona_lores_limb.time_start, begin_time, end_time, check
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_limb, 'CORONA_LORES_LIMB'
        endif
      endif
    endif
    if instrument_array[14] eq 1 then begin                                    ;READ AND PARSE CORONA LORES DISK DATA
      if size(corona_lores_disk,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          MVN_KP_IUVS_TIMECHECK, corona_lores_disk.time_start, begin_time, end_time, check
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_disk, 'CORONA_LORES_DISK'
        endif
      endif
    endif
    if instrument_array[15] eq 1 then begin                                    ;READ AND PARSE CORONA Echelle DISK DATA
      if size(corona_echelle_disk,/type) eq 8 then begin
        if time_bounds eq 1 then begin
          MVN_KP_IUVS_TIMECHECK, corona_echelle_disk.time_start, begin_time, end_time, check
        endif else begin
          check=1
        endelse
        
        if check eq 1 then begin
          MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_disk, 'CORONA_ECHELLE_DISK'
        endif
      endif
    endif
    
    ;; Add in orbit number
    iuvs_record.orbit = periapse[0].orbit_number
    
  endif else if keyword_set(textfiles) then begin
   
    ;READ IUVS DATA FROM ASCII FILES
    message,'These files do not exist as yet, so go back and use savefiles or the default CDF'

  endif else begin

    ;; Default is to read CDF files
    
    ;; Read in CDF version of file
    MVN_KP_IUVS_CDF_READ, iuvs_record_temp, filename, instruments=instruments, instrument_array=instrument_array
    
    
    ;;
    ;;;    FIXME - Clean up this whole time checking stuff
    ;;

    ;; If checking time bounds 
    if time_bounds then begin
      MVN_KP_IUVS_STRUCT_INIT, iuvs_record_time_temp, instrument_array

      if instruments.periapse then begin
        for peri_index = 0, n_elements(iuvs_record_temp.periapse.time_start)-1 do begin
          MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.periapse[peri_index].time_start, begin_time, end_time, check
          
          if check then iuvs_record_time_temp.periapse[peri_index] = iuvs_record_temp.periapse[peri_index]
        endfor
      endif
  
      ;; Check Echelle Observation Modes
      if instruments.c_e_limb and (iuvs_record_temp.corona_e_limb.time_start ne '') then begin
        MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.corona_e_limb.time_start, begin_time, end_time, check
        if check then iuvs_record_time_temp.corona_e_limb = iuvs_record_temp.corona_e_limb
      endif
      if instruments.c_e_disk and (iuvs_record_temp.corona_e_disk.time_start ne '') then begin
        MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.corona_e_disk.time_start, begin_time, end_time, check
        if check then iuvs_record_time_temp.corona_e_disk = iuvs_record_temp.corona_e_disk
      endif
      if instruments.c_e_high and (iuvs_record_temp.corona_e_high.time_start ne '') then begin
        MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.corona_e_high.time_start, begin_time, end_time, check
        if check then iuvs_record_time_temp.corona_e_high = iuvs_record_temp.corona_e_high
      endif

      ;; Check LORES Observation modes
      if instruments.c_l_limb and (iuvs_record_temp.corona_lo_limb.time_start ne '') then begin
        MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.corona_lo_limb.time_start, begin_time, end_time, check
        if check then iuvs_record_time_temp.corona_lo_limb = iuvs_record_temp.corona_lo_limb
      endif      
      if instruments.c_l_disk and (iuvs_record_temp.corona_lo_disk.time_start ne '') then begin
        MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.corona_lo_disk.time_start, begin_time, end_time, check     
        if check then iuvs_record_time_temp.corona_lo_disk = iuvs_record_temp.corona_lo_disk
      endif  
      if instruments.c_l_high and (iuvs_record_temp.corona_lo_high.time_start ne '') then begin
        MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.corona_lo_high.time_start, begin_time, end_time, check
        if check then iuvs_record_time_temp.corona_lo_high = iuvs_record_temp.corona_lo_high
      endif

      ;; Check apoapse observation mode
      if instruments.apoapse then begin      
        MVN_KP_IUVS_TIMECHECK, iuvs_record_temp.apoapse.time_start, begin_time, end_time, check
        if check then iuvs_record_time_temp.apoapse = iuvs_record_temp.apoapse
      endif  

    
      iuvs_record = iuvs_record_time_temp
      ;; Add in orbit number
      iuvs_record.orbit = iuvs_record_temp.orbit
    
    endif else begin
      ;; NO time check
      iuvs_record = iuvs_record_temp
    endelse

  endelse
  
end
