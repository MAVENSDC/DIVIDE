;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    time : in, required, type="lonarr(2)"
;       A time parameter that maybe of any type (string, float, or int) 
;    insitu_output : out, required, type=lonarr(ndims)
;       required named structure for the output INSITU kp data
;    iuvs_output: out, required, type=lonarr(ndims)
;       required named structure for the output IUVS kp data
;       
; :Keywords:
;    kp_criteria : in, optional, type=lonarr(ndims)
;       optional named search criteria structure (set by MAVEN_KP_PARAM_SET)
;    duration : in, optional, type=integer
;       optional length of time to return data, in seconds, only used if input time is a single value
;    preferences: in, optional, type=string
;       optional name of a text preferences file if the user wants to override the default name ; FIXME THIS IS WRONG
;    update_prefs: in, optional, type=boolean
;       option to use dialog boxes and re-define your data paths in preferences.txt
;    lpw: in, optional, type=boolean
;       optional keyword that will return all of the LPW data 
;    static: in, optional, type=boolean
;       optional keyword that will return all of the STATIC data 
;    swia: in, optional, type=boolean
;       optional keyword that will return all of the SWIA data 
;    swea: in, optional, type=boolean
;       optional keyword that will return all of the SWEA data 
;    mag: in, optional, type=boolean
;       optional keyword that will return all of the MAG data 
;    sep: in, optional, type=boolean
;       optional keyword that will return all of the SEP data 
;    ngims: in, optional, type=boolean
;       optional keyword that will return all of the NGIMS data 
;    iuvs_all: in, optional, type=boolean
;       optional keyword to return all IUVS KP data, regardless of observation type
;    insitu_all: in, optional, type=boolean
;       optional keyword that will return all of the INSITU data, regardless of observation type
;    insitu_only: in, optional, type=boolean
;       optinal keyword to specify that you only want to read in insitu data (ignore IUVS)
;    iuvs_periapse:  in, optional, type=boolean
;       optional keyword that will return all of the IUVS PERIAPSE limb scan data 
;    iuvs_apoapse: in, optional, type=boolean
;       optional keyword that will return all of the IUVS APOAPSE data 
;    iuvs_coronaEchellehigh: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona Echelle high altitude data 
;    iuvs_coronaEchelledisk: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona Echelle disk data 
;    iuvs_coronaEchelleLimb: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona Echelle limb data 
;    iuvs_coronaLoreslimb: in, optional, type=boolean
;       optional keyword that will return all of the iuvs corona LoREs on limb data 
;    iuvs_coronaLoreshigh: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona LoRes high altitude data 
;    iuvs_coronaLoresdisk: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona LoRes disk data 
;    iuvs_stellarocc: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Stellar Occulatation data 
;    inbound: in, optional, type=boolean
;       optional keyword that will return all of the data from the inbound leg of an orbit
;    outbound: in, optional, type=boolean
;       optional keyword that will return all of the data from the outbound leg of an orbit
;
;;    Need to update
;;
;    download_new: in, optional, type=boolean
;       optional keyword to instruct IDL to query the SDC server to look for any new files to download
;       over the input timerange.
;    debug: in, optional, type=boolean
;       optional keyword to execute in "debug" mode. On errors, IDL will halt in place so the user can
;       have a chance to see what's going on. By default this will not occur, instead error handlers
;       are setup and errors will return to main.   
;       
;-

@time_string
@mvn_time_convert
@mvn_kp_download_files
@mvn_kp_file_search
@mvn_kp_insitu_struct_init
@mvn_kp_iuvs_struct_init
@mvn_loop_progress
@mvn_kp_time_bounds
@mvn_kp_insitu_assign
@mvn_kp_iuvs_timecheck
@mvn_kp_iuvs_binary_assign
@mvn_kp_read_iuvs_file
@mvn_kp_iuvs_cdf_read
@mvn_kp_insitu_cdf_read


pro MVN_KP_READ, time, insitu_output, iuvs_output, DURATION=DURATION, PREFERENCES=PREFERENCES,$
                   lpw=lpw, static=static, swia=swia, swea=swea, mag=mag, sep=sep, ngims=ngims, $
                   iuvs_all=iuvs_all, iuvs_periapse=iuvs_periapse, iuvs_apoapse=iuvs_apoapse, $
                   iuvs_coronaEchellehigh=iuvs_coronaEchellehigh,iuvs_coronaEchelleDisk=iuvs_coronaEchelleDisk,$
                   iuvs_coronaEchelleLimb=iuvs_coronaEchelleLimb, iuvs_coronaLoresDisk=iuvs_coronaLoresDisk, $
                   iuvs_coronaLoreshigh=iuvs_coronaLoreshigh, iuvs_coronaLoreslimb=iuvs_coronaLoreslimb, $
                   iuvs_stellarocc=iuvs_stellarocc, insitu_all=insitu_all, $
                   inbound=inbound, outbound=outbound, debug=debug, insitu_only=insitu_only, $
                   update_prefs=update_prefs, download_new=download_new, savefiles=savefiles, textfiles=textfiles

  
  overall_start_time = systime(1)
  
  ;IF NOT IN DEBUG, SETUP ERROR HANDLER
  if not keyword_set(debug) then begin
    ;ESTABLISH ERROR HANDLER. WHEN ERRORS OCCUR, THE INDEX OF THE
    ;ERROR IS RETURNED IN THE VARIABLE ERROR_STATUS:
    catch, Error_status
    
    ;THIS STATEMENT BEGINS THE ERROR HANDLER:
    if Error_status ne 0 then begin
      ;HANDLE ERRORS BY RETURNING TO MAIN:
      print, '**ERROR HANDLING - ', !ERROR_STATE.MSG
      print, '**ERROR HANDLING - Cannot proceed. Returning to main'
      Error_status = 0
      catch, /CANCEL
      return
    endif
  endif
  
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ---------------------------- Check input options ----------------------------------- ;;
  
  
  ; IF DEBUG SET, CREATE ENVIRONMENT VARIABLE SO ALL PROCEDURES/FUNCTIONS CALLED CAN CHECK FOR IT
  if keyword_set(debug) then begin
    setenv, 'MVNTOOLKIT_DEBUG=TRUE'
  endif

  ; DEFAULT RETRIEVAL PERIOD TO 1 DAY OR 1 ORBIT 
  if keyword_set(duration) eq 0 then begin
    if size(time,/type) eq 7 then duration = 86400
    if size(time,/type) eq 2 then duration = 1
  endif
  
  ;SET UP instrument_array WHICH IS USED FOR CREATING DATA STRUCTURE & CONTROLLING WHICH INSTRUMENTS DATA TO READ
  if keyword_set(lpw) or keyword_set(static) or keyword_set(swia) or keyword_set(swea) or keyword_set(mag) or keyword_set(sep) or $
    keyword_set(ngims) or keyword_set(iuvs_all) or keyword_set(iuvs_periapse) or keyword_set(iuvs_apoapse) or $
    keyword_set(iuvs_coronaEchelleDisk) or keyword_set(iuvs_coronaEchelleLimb) or keyword_set(iuvs_coronaEchelleHigh) or keyword_set(iuvs_coronaLoresHigh) or $
    keyword_set(iuvs_coronaloreslimb) or keyword_set(iuvs_coronaloresdisk) or keyword_set(iuvs_stellarocc) or keyword_set(insitu_all) then begin
   
    instrument_array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    

    instruments = CREATE_STRUCT('lpw',      0, 'static',   0, 'swia',     0, $
                                'swea',     0, 'mag',      0, 'sep',      0, $
                                'ngims',    0, 'periapse', 0, 'c_e_disk', 0, $
                                'c_e_limb', 0, 'c_e_high', 0, 'c_l_disk', 0, $
                                'c_l_limb', 0, 'c_l_high', 0, 'apoapse' , 0, 'stellarocc', 0)                            
   

    
    if keyword_set(lpw) then begin
      instrument_array[0] = 1
      instruments.lpw = 1
      print,'Returning All LPW Instrument KP Data.'
    endif
    if keyword_set(static) then begin
      instrument_array[1] = 1
      instruments.static = 1
      print,'Returning All STATIC Instrument KP Data.'
    endif
    if keyword_set(swia) then begin
      instrument_array[2] = 1
      instruments.swia = 1
      print,'Returning All SWIA Instrument KP Data.'
    endif
    if keyword_set(swea) then begin
      instrument_array[3] = 1
      instruments.swea = 1
      print,'Returning All SWEA Instrument KP Data.'
    endif
    if keyword_set(mag) then begin
      instrument_array[4] = 1
      instruments.mag = 1
      print,'Returning All MAG Instrument KP Data.'
    endif
    if keyword_set(sep) then begin
      instrument_array[5] = 1
      instruments.sep = 1
      print,'Returning All SEP Instrument KP Data.'
    endif
    if keyword_set(ngims) then begin
      instrument_array[6] = 1
      instruments.ngims = 1
      print,'Returning All NGIMS Instrument KP Data.'
    endif
    if keyword_set(insitu_all) then begin
      instrument_array[0] = 1
      instrument_array[1] = 1
      instrument_array[2] = 1
      instrument_array[3] = 1
      instrument_array[4] = 1
      instrument_array[5] = 1
      instrument_array[6] = 1
      instruments.lpw    = 1
      instruments.static = 1
      instruments.swia   = 1
      instruments.swea   = 1
      instruments.mag    = 1
      instruments.sep    = 1
      instruments.ngims  = 1
      print, 'Returning all INSITU Instrument KP Data.'
    endif
    if keyword_set(iuvs_all) then begin
      instrument_array[7] = 1
      instrument_array[8] = 1
      instrument_array[9] = 1
      instrument_array[10] = 1
      instrument_array[11] = 1
      instrument_array[12] = 1
      instrument_array[13] = 1
      instrument_array[14] = 1
      instrument_array[15] = 1
      instruments.periapse   = 1
      instruments.c_e_disk   = 1
      instruments.c_e_limb   = 1
      instruments.c_e_high   = 1
      instruments.c_l_disk   = 1
      instruments.c_l_limb   = 1
      instruments.c_l_high   = 1
      instruments.apoapse    = 1
      instruments.stellarocc = 1
      print,'Returning All IUVS Instrument KP Data.'
    endif
    if keyword_set(iuvs_periapse) then begin
      instrument_array[7] = 1
      instruments.periapse = 1
      print,'Returning All IUVS Instrument Periapse KP Data.'
    endif
    if keyword_set(iuvs_apoapse) then begin
      instrument_array[8] = 1
      instruments.apoapse = 1
      print,'Returning All IUVS Instrument Apoapse KP Data.'
    endif
    if keyword_set(iuvs_coronaEchellehigh) then begin
      instrument_array[9] = 1
      instruments.c_e_high = 1
      print,'Returning All IUVS Instrument Corona Echelle High Altitude KP Data.'
    endif
    if keyword_set(iuvs_coronaEchellelimb) then begin
      instrument_array[10] = 1
      instruments.c_e_limb = 1
      print,'Returning All IUVS Instrument Corona Echelle Limb KP Data.'
    endif
    if keyword_set(iuvs_stellarocc) then begin
      instrument_array[11] = 1
      instruments.stellarocc = 1
      print,'Returning All IUVS Instrument Stellar Occultation KP Data.'
    endif
    if keyword_set(iuvs_coronaLoreshigh) then begin
      instrument_array[12] = 1
      instruments.c_l_high = 1
      print,'Returning All IUVS Instrument Corona Lores High Altitude KP Data.'
    endif
    if keyword_set(iuvs_coronaLoreslimb) then begin
      instrument_array[13] = 1
      instruments.c_l_limb = 1
      print,'Returning All IUVS Instrument Corona Lores Limb KP Data.'
    endif
    if keyword_set(iuvs_coronaLoresdisk) then begin
      instrument_array[14] = 1
      instruments.c_l_disk = 1
      print,'Returning All IUVS Instrument Corona Lores Disk KP Data.'
    endif
    if keyword_set(iuvs_coronaechelledisk) then begin
      instrument_array[15] = 1
      instruments.c_e_disk = 1
      print,'Returning All IUVS Instrument Corona Echelle Disk KP Data.'
    endif
  endif else begin
    ;SET ALL INSTRUMENT FLAGS TO 1 TO CREATE FULL STRUCTURE FOR ALL INSTRUMENT DATA
    instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1] 
    
    instruments = CREATE_STRUCT('lpw',      1, 'static',   1, 'swia',     1, $
                                'swea',     1, 'mag',      1, 'sep',      1, $
                                'ngims',    1, 'periapse', 1, 'c_e_disk', 1, $
                                'c_e_limb', 1, 'c_e_high', 1, 'c_l_disk', 1, $
                                'c_l_limb', 1, 'c_l_high', 1, 'apoapse' , 1, 'stellarocc', 1)   
  endelse
  
  
  ;SET INBOUND/OUTBOUND KEYWORDS IF NEEDED
  io_flag = intarr(2)
  if keyword_set(inbound) eq 1 then begin
    io_flag[0] = 1
    io_flag[1] = 0
  endif
  if keyword_set(outbound) eq 1 then begin
    io_flag[0] = 0
    io_flag[1] = 1
  endif
  if (keyword_set(inbound) eq 0) and (keyword_set(outbound) eq 0) then begin
    io_flag[0] = 1
    io_flag[1] = 1
  endif
    
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Read or create preferences file ---------------------------- ;;

  MVN_KP_CONFIG_FILE, insitu_data_dir=kp_insitu_data_directory, iuvs_data_dir=kp_iuvs_data_directory, update_prefs=update_prefs


  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Process input time/orbit range  ---------------------------- ;;

  ;IF ORBIT(s) SUPPLIED - FIXME I DON"T THINK THIS IS WORKING AND DURATION IS ALWAYS DEFINED BY THIS POINT
  if size(time, /type) eq 2 then begin
    if n_elements(time) eq 1 then begin
      if keyword_set(duration) then begin
        print,'Retrieving KP data for ',strtrim(string(duration),2),' orbits beginning at orbit #',strtrim(string(time),2)
        begin_orbit = time[0]
        end_orbit = time[0] + duration
        MVN_KP_ORBIT_TIME, begin_orbit, end_orbit, begin_time, end_time
      endif
    endif else begin
      print,'Retrieving KP data between orbits ',strtrim(string(time(0)),2),' and ',strtrim(string(time(1)),2)
      begin_orbit = time[0]
      end_orbit   = time[1]
      MVN_KP_ORBIT_TIME, begin_orbit, end_orbit, begin_time, end_time
    endelse
  endif
  
  ;IF TIME STRING(s) SUPPLIED
  if size(time, /type) eq 7 then begin 
    if n_elements(time) eq 1 then begin 
      ; IF ONE TIME SUPPLIED USE IT AS START. DETERMINE END TIME BASED ON duration (DEFAULT 1 DAY OR USER SUPPLIED)
      begin_time = MVN_TIME_CONVERT(time,1)
      end_time   = MVN_TIME_MATH(begin_time,duration)
    endif else begin
      ;IF THE USER SUPPLIES A 2-VALUE ARRAY OF TIMES, CONVERT TO START AND END TIMES
      begin_time = MVN_TIME_CONVERT(time[0],1)
      end_time   = MVN_TIME_convert(time[1],1)
    endelse
  endif
  
  ;IF LONG INTEGER TIME SUPPLIED (FIXME: SECONDS?)
  if size(time,/type) eq 3 then begin
    if n_elements(time) eq 1 then begin
      begin_time = MVN_TIME_CONVERT(time,3)
      end_time   = MVN_TIME_CONVERT((time+86400),3)
    endif else begin
      begin_time = MVN_TIME_CONVERT(time[0],3)
      end_time   = MVN_TIME_CONVERT(time[1],3)
    endelse
  endif
   
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; -------------- Find files which contain data in input time range ------------------- ;;
  ;; -------------- and initialize data structures for holding data --------------------- ;;

  ;; FIXME variable names
  MVN_KP_FILE_SEARCH, begin_time, end_time, target_KP_filenames, kp_insitu_data_directory, iuvs_filenames, $
     kp_iuvs_data_directory, savefiles=savefiles, textfiles=textfiles, insitu_only=insitu_only, download_new=download_new

  
  total_KP_file_count = n_elements(target_KP_filenames) ; FIXME shouldn't need this here
 

  ;CREATE OUTPUT STRUCTURES BASED ON SEARCH PARAMETERS & INITIALIZE ARRAY OF DATA STRUTURES 
  MVN_KP_INSITU_STRUCT_INIT, insitu_record, instrument_array
  kp_data_temp = replicate(insitu_record,21600L*total_KP_file_count)
    
  if not keyword_set(insitu_only) then begin  
    MVN_KP_IUVS_STRUCT_INIT, iuvs_record,   instrument_array
    iuvs_data_temp = replicate(iuvs_record, n_elements(iuvs_filenames))
  endif

 

  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Main read loop: In situ data    ---------------------------- ;;
  
  
  ; FIXME: These variables aren't being used?
  ;VARIABLES TO HOLD THE COUNT OF VARIOUS OBSERVATION TYPES (IE. HIGH VS. LOW ALTITUDE)
  ; high_count = 0
  ; low_count = 0
  if target_kp_filenames[0] ne 'None' then begin
    if keyword_set(textfiles) then begin
      index=0L
      within_time_bounds = 0
      for file=0,total_KP_file_count[0]-1 do begin
      
        ;UPDATE THE READ STATUS BAR
        MVN_LOOP_PROGRESS,file,0,total_kp_file_count-1,message='In-situ KP File Read Progress'
        ;OPEN THE KP DATA FILE
        openr,lun,kp_insitu_data_directory+target_KP_filenames[file,0],/get_lun
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
              orbit = {time_string:'', time: 0.0, orbit:0L, IO_bound:'', data:fltarr(203)}
              
              ;READ IN AND INIT TEMP STRUCTURE OF DATA
              orbit.time_string = data[0]
              orbit.time = time_double(data[0])
              orbit.orbit = data[198]
              orbit.IO_bound = data[199]
              orbit.data[0:196] = data[1:197]
              orbit.data[197:202] = data[200:205]
              
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
      endfor      ;file loop, open/read each KP file
      
      start_index=0
      stop_index=index-1
      
    endif else if keyword_set(savefiles) then begin
      index=0L
      within_time_bounds=0
      for file=0,total_KP_file_count[0]-1 do begin
        ;UPDATE THE READ STATUS BAR
        MVN_LOOP_PROGRESS,file,0,total_kp_file_count-1,message='In-situ KP File Read Progress'
        restore,kp_insitu_data_directory+target_kp_filenames[file]
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
      endfor
  
      start_index=0
      stop_index=index-1
      
    endif else begin
      
      index=0L
      ;; Default behavior of reading in CDF files. 
      for file=0, total_kp_file_count[0]-1 do begin
        ;UPDATE THE READ STATUS BAR
        MVN_LOOP_PROGRESS,file,0,total_kp_file_count-1,message='In-situ KP File Read Progress'
        
        filename = kp_insitu_data_directory+target_kp_filenames[file]
        MVN_KP_INSITU_CDF_READ, insitu_record, filename, instruments=instruments, instrument_array=instrument_array ;; FIXME
        kp_data_temp[index] = insitu_record
        index+= n_elements(insitu_record)
        
      endfor
      
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
    insitu_output = kp_data_temp[start_index:stop_index]
    print,'A total of ',strtrim(string(stop_index-start_index),2),' INSITU KP data records were found that met the search criteria.'
    
  endif else begin
    printf,-2, "Warning: No Insitu files found for input timerange."
  endelse

  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Main read loop: IUVS  data   ------------------------------- ;;
 
  
  ;IF ANY IUVS DATA IS REQUESTED & NOT IN INSITU ONLY MODE
  if not keyword_set (insitu_only) and ((instrument_array[7] eq 1) or (instrument_array[8] eq 1) or (instrument_array[9] eq 1) or (instrument_array[10] eq 1) or $
    (instrument_array[11] eq 1) or (instrument_array[12] eq 1)  or (instrument_array[13] eq 1)  or (instrument_array[14] eq 1)  or (instrument_array[15] eq 1)) then begin
    iuvs_index=0
    if iuvs_filenames[0] ne 'None' then begin
    
      if keyword_set(savefiles) then begin
        for file=0,n_elements(iuvs_filenames)-1 do begin
        
          MVN_LOOP_PROGRESS,file,0,n_elements(iuvs_filenames)-1,message='IUVS KP File Read Progress'
          
          fileAndPath = kp_iuvs_data_directory+iuvs_filenames[file]
          MVN_KP_READ_IUVS_FILE, fileAndPath, iuvs_record, begin_time=begin_time, end_time=end_time, $
            instrument_array=instrument_array, /savefiles
            
          ;; Add single iuvs_record to array of iuvs records
          iuvs_data_temp[iuvs_index] = iuvs_record
          iuvs_index++
          
        endfor
      endif else if keyword_set(textfiles) then begin
        print, "No TEXT reader for IUVS yet."   ;; FIXME NEED TO DO 
        iuvs_data_temp = 0
        iuvs_index = 1
      
      endif else begin
        
        ;; DEFAULT BEHAVIOR IS TO READ CDF FILES
        for file=0,n_elements(iuvs_filenames)-1 do begin
        
          MVN_LOOP_PROGRESS,file,0,n_elements(iuvs_filenames)-1,message='IUVS KP File Read Progress'
          
          fileAndPath = kp_iuvs_data_directory+iuvs_filenames[file]
          MVN_KP_READ_IUVS_FILE, fileAndPath, iuvs_record, begin_time=begin_time, end_time=end_time, $
            instrument_array=instrument_array, instruments=instruments
            
          ;; Add single iuvs_record to array of iuvs records
          iuvs_data_temp[iuvs_index] = iuvs_record
          iuvs_index++
          
        endfor
        
      endelse
      
      
      ;OUTPUT IUVS DATA STRUCTURE IF ANY IUVS DATA IS REQUESTED
      iuvs_output = iuvs_data_temp[0:iuvs_index-1]
      print,'including ',strtrim(string(iuvs_index),2),' IUVS data records'
      
    endif else begin
      printf, -2, "Warning: No IUVS files found for input timerange"
    endelse
  endif

  
  
  ;TIME TO RUN ROUTINE 
  overall_end_time = systime(1)
  print,'Your query took ', overall_end_time - overall_start_time,' seconds to complete.'
  
  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
  break1: ; FIXME - Why break?
end



