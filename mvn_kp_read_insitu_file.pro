;;
;; Read in one insitu file
;;
;;
;;


pro mvn_kp_read_insitu_file, filename, insitu_record_out, begin_time=begin_time, end_time=end_time, $
  instrument_array=instrument_array, savefiles=savefiles, textfiles=textfiles, instruments=instruments, io_flag=io_flag
  
  
  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  

  ;; Default to filing all instruments if not specified
  if not keyword_set(instrument_array) then begin
    instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
  endif
  
  ;; Default to filling all instruments if not specified
  if not keyword_set(instruments) then begin
    instruments = CREATE_STRUCT('lpw',      1, 'static',   1, 'swia',     1, $
                                'swea',     1, 'mag',      1, 'sep',      1, $
                                'ngims',    1, 'periapse', 1, 'c_e_disk', 1, $
                                'c_e_limb', 1, 'c_e_high', 1, 'c_l_disk', 1, $
                                'c_l_limb', 1, 'c_l_high', 1, 'apoapse' , 1, 'stellarocc', 1)
  endif

  if not keyword_set(begin_time) then begin
    begin_time='2000-01-01/12:00:00'
  endif
  
  if not keyword_set(end_time) then begin
    end_time='2200-01-01/12:00:00'
  endif
  
 if not keyword_set(io_flag) then begin
   io_flag = [1,1]
 endif
 
  ;; Init array of insitu structures big enough for one file
  MVN_KP_INSITU_STRUCT_INIT, insitu_record, instrument_array  
  kp_data_temp = replicate(insitu_record,21600L)
  
  
  if keyword_set(textfiles) then begin
    index=0L
    within_time_bounds = 0
    
    ;OPEN THE KP DATA FILE
    openr,lun,filename,/get_lun
    ;READ IN A LINE, EXTRACTING THE TIME
    while not eof(lun) do begin
      temp = ''
      readf,lun,temp
      data = strsplit(temp,' ',/extract)
      if data[0] ne '#' then begin
      
        ;KICK TO ROUTINE TO CHECK IF TIME FALLS WITHIN SEARCH BOUNDS
        within_time_bounds = MVN_KP_TIME_BOUNDS(data[0],begin_time,end_time)
        ;IF WITHIN BOUNDS, EXTRACT AND STORE DATA
        if within_time_bounds then begin
        
          ; TEMPLATE STRUCTURE TO READ DATA INTO
          orbit = {time_string:'', time: 0.0, orbit:0L, IO_bound:'', data:fltarr(212)}
          
          ;READ IN AND INIT TEMP STRUCTURE OF DATA
          orbit.time_string = data[0]
          orbit.time = time_double(data[0])
          orbit.orbit = data[198]
          orbit.IO_bound = data[199]
          orbit.data[0:196] = data[1:197]
          orbit.data[197:211] = data[200:214]
          
          ;CHECK time_string FORMAT FOR A SLASH DELIMITER INSTEAD OF A "T" AND SWITCH IF NECESSARY
          ts_split=strsplit(orbit.time_string, '/', COUNT=ts_count, /EXTRACT)
          if ts_count gt 1 then orbit.time_string = ts_split[0]+'T'+ts_split[1]
          
          if ((io_flag[0] eq 1) and (orbit.io_bound eq 'I')) or ((io_flag[1] eq 1) and (orbit.io_bound eq 'O')) then begin
            MVN_KP_INSITU_ASSIGN, insitu_record, orbit, instrument_array
            kp_data_temp[index] = insitu_record
            index=index+1
          endif
        endif
      endif
    endwhile
    
    free_lun,lun
    
    start_index=0
    stop_index=index-1
    
  endif else if keyword_set(savefiles) then begin
    index=0L
    within_time_bounds=0
    
    restore,filename
    ;LOAD THE NEEDED IN-SITU DATA FILES FOR EACH INSTRUMENT
    for saved_records = 0, n_elements(orbit) -1 do begin
      within_time_bounds = MVN_KP_TIME_BOUNDS(orbit[saved_records].time_string, begin_time, end_time)
      if within_time_bounds then begin            ;IF WITHIN TIME RANGE, EXTRACT AND STORE DATA
      
        if ((io_flag[0] eq 1) and (orbit[saved_records].io_bound eq 'I')) or ((io_flag[1] eq 1) and (orbit[saved_records].io_bound eq 'O')) then begin
        
          MVN_KP_INSITU_ASSIGN, insitu_record, orbit[saved_records], instrument_array
          kp_data_temp[index] = insitu_record
          index=index+1
          
        endif
      endif
    endfor
    
    
    start_index=0
    stop_index=index-1
    
  endif else begin
  
    index=0L
    ;; Default behavior of reading in CDF files.
    
    
    MVN_KP_INSITU_CDF_READ, insitu_record, filename, instruments=instruments, instrument_array=instrument_array ;; FIXME
    kp_data_temp[index] = insitu_record
    index+= n_elements(insitu_record)
    
    
    
    ;; ----------FIXME Maybe make more efficent/
    ;; ------------more testing of edge cases - Re think make sure this is grabbing correct time range
    ;
    ;; Strip out times not in range
    start_index=-1L
    stop_index=index-1L
    
    for i=0, index-1 do begin
      within_time_bounds = MVN_KP_TIME_BOUNDS(kp_data_temp[i].time_string, begin_time, end_time)
      if within_time_bounds then begin
        start_index=i
        i++
        break
      endif
    endfor
    
    ;; Search backwards from end
    j = index-1
    while (j ge 0 ) do begin
      within_time_bounds = MVN_KP_TIME_BOUNDS(kp_data_temp[j].time_string, begin_time, end_time)
      if within_time_bounds eq 1 then begin
        stop_index=j
        break
      endif
      j--
    endwhile
    
  endelse
  
  
  ;OUTPUT INSITU DATA STRUCTURE
  insitu_record_out = kp_data_temp[start_index:stop_index]

end