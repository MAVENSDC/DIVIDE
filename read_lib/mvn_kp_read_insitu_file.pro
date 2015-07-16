;;
;; Read in one insitu file
;;
;;
;;


pro mvn_kp_read_insitu_file, filename, insitu_record_out, $
                             begin_time=begin_time, end_time=end_time, $
                             save_files=save_files, text_files=text_files, $
                             instruments=instruments, io_flag=io_flag
  
  
  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  

  if not keyword_set(begin_time) then begin ;; FIXME is this necessary ?
    begin_time_string = '2000-01-01/12:00:00'
    begin_time_jul    = julday(1, 1, 2000, 12, 0, 0)
    begin_time        = create_struct('string', begin_time_string, $
                                      'jul',  begin_time_jul) 
  endif
  
  if not keyword_set(end_time) then begin
    end_time_string = '2200-01-01/12:00:00'
    end_time_jul    = julday(1, 1, 2200, 12, 0, 0)
    end_time        = create_struct('string', end_time_string,$
                                    'jul', end_time_jul)
  endif
  
 if not keyword_set(io_flag) then begin
   io_flag = [1,1]
 endif
 
  ;; Init array of insitu structures big enough for one file
  MVN_KP_INSITU_STRUCT_INIT, filename, insitu_record, col_map, formats, $
                             ncol, nrec, vnum=vnum, rnum=rnum, $
                             instruments=instruments
  kp_data_temp = replicate(insitu_record,fix(nrec,type=3))
  
  if keyword_set(text_files) then begin
    
    ;OPEN THE KP DATA FILE
    install_result = routine_info( 'mvn_kp_read_insitu_file',/source )
    install_dir = strsplit( install_result.path, $
                            'mvn_kp_read_insitu_file.pro', $
                            /extract, /regex )
    ascii_template = install_dir + path_sep() + 'insitu_ascii_template' $
                   + '_v' + string( vnum, format='(i02)') $
                   + '_r' + string( rnum, format='(i02)') + '.sav'
    restore,ascii_template
    
    ;The data doesn't start in the same place in every file.
    ;If you set it to zero, the read_ascii function will automatically
    ;skip over all the header files and go straight to the data    
    template.datastart= 0
    orbit = read_ascii( filename, template=template )

    ;  Fill the kp_data array with the requested data structures

    MVN_KP_INSITU_ASSIGN, kp_data_temp, orbit, instruments, col_map

    ;  Down-select the read array according to given start and end times
    
    check = mvn_kp_time_bounds( kp_data_temp.time_string, $
                                begin_time, end_time )
    if total( check ) gt 0 then begin
      start_index = min( where( check eq 1 ) )
      stop_index = max( where( check eq 1 ) )
    endif else begin
      start_index = 0
      stop_index = -1
    endelse
    
  endif else if keyword_set(save_files) then begin
    index=0L
    within_time_bounds=0
    
    restore,filename
    ;LOAD THE NEEDED IN-SITU DATA FILES FOR EACH INSTRUMENT
    for saved_records = 0, n_elements(orbit) -1 do begin
      within_time_bounds $
         = MVN_KP_TIME_BOUNDS(orbit[saved_records].time_string, $
                              begin_time, end_time)
      if within_time_bounds then begin
        ;IF WITHIN TIME RANGE, EXTRACT AND STORE DATA
      
        ;; If io_bound is not [1,1], need to loop through and keep 
        ;;  only what is desired (either inbound or outbound)
        if (io_flag[0] ne 1) or (io_flag[1] ne 1) then begin
          if ( (io_flag[0] eq 1) and $
               (orbit[saved_records].io_bound eq 'I')) or $
             ( (io_flag[1] eq 1) and $
               (orbit[saved_records].io_bound eq 'O')) then begin
                 
            MVN_KP_INSITU_ASSIGN, insitu_record, orbit[saved_records], $
                                  instruments
            kp_data_temp[index] = insitu_record
            index=index+1
          endif
        endif else begin
          MVN_KP_INSITU_ASSIGN, insitu_record, orbit[saved_records], $
                                instruments
          kp_data_temp[index] = insitu_record
          index=index+1     
        endelse
      endif
    endfor
       
    ;; If index eq 0, no records fell within time range or passed IO 
    ;; check, set start_index equal to -1 so below the code will return 0 .
    if index eq 0l then begin
      start_index=-1
    endif else begin
      start_index=0
      stop_index=index-1
    endelse
    
  endif else begin
  
    index=0L
    ;; Default behavior of reading in CDF files.
    
    
    MVN_KP_INSITU_CDF_READ, insitu_record, filename, $
                            instruments=instruments 
    ;; FIXME ? not sure what this fixme was for
    kp_data_temp[index] = insitu_record
    index+= n_elements(insitu_record)
    
    
    ;; ----------FIXME Maybe make more efficent/
    ;; ------------more testing of edge cases - Re think make sure
    ;;             this is grabbing correct time range
    ;
    ;; Strip out times not in range
    start_index=-1L
    stop_index=index-1L
    
    for i=0, index-1 do begin
      within_time_bounds = MVN_KP_TIME_BOUNDS(kp_data_temp[i].time_string, $
                                              begin_time, end_time)
      if within_time_bounds then begin
        start_index=i
        i++
        break
      endif
    endfor
    
    ;; Search backwards from end
    j = index-1
    while (j ge 0 ) do begin
      within_time_bounds = MVN_KP_TIME_BOUNDS(kp_data_temp[j].time_string, $
                                              begin_time, end_time)
      if within_time_bounds eq 1 then begin
        stop_index=j
        break
      endif
      j--
    endwhile
    
    
  endelse
  
  ;; if start_index eq -1, then didn't find any data falling within 
  ;;  time bounds, return 0
  if (start_index lt 0) then begin
    insitu_record_out = 0
    
    
    ;; Otherwise, set insitu_record_out to matching index range 
    ;;  (falls within input time bounds
  endif else begin
  
    ;OUTPUT INSITU DATA STRUCTURE
    insitu_record_out = kp_data_temp[start_index:stop_index]
    
    ;; If io_bound is not [1,1], need to loop through and keep only
    ;; what is desired (either inbound or outbound)
    if (io_flag[0] ne 1) or (io_flag[1] ne 1) then begin
    
      ;; Set search criteria
      if io_flag[0] eq 1 then bound = 'I'
      if io_flag[1] eq 1 then bound = 'O'
      if not keyword_set(bound) then $
         message, "Problem with io_bound array. Cannot proceed. "
      
      results = where(insitu_record_out.IO_BOUND eq bound, count)
      
      ;; If no results found, return zero. Otherwise return only matches
      if count eq 0 then begin
        insitu_record_out = 0
      endif else begin
        insitu_record_out = insitu_record_out[results]
      endelse
      
    endif
    
  endelse


end
