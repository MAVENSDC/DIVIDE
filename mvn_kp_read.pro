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
;    insitu: in, optional, type=boolean
;       optional keyword that will return all of the INSITU data, regardless of observation type
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
;    binary: in, optional, type=boolean
;       optional keyword to force the KP data reader to use binary files instead of ASCII text
;    debug: in, optional, type=boolean
;       optional keyword to execute in "debug" mode. On errors, IDL will halt in place so the user can
;       have a chance to see what's going on. By default this will not occur, instead error handlers
;       are setup and errors will return to main.   
;       
;-

@time_string
@mvn_time_convert
@mvn_kp_iuvs_filename
@mvn_kp_insitu_versions
@mvn_kp_insitu_struct_init
@mvn_kp_iuvs_struct_init
@mvn_loop_progress
@mvn_kp_time_bounds
@mvn_kp_insitu_assign
@mvn_kp_iuvs_timecheck
@mvn_kp_iuvs_binary_assign

pro MVN_KP_READ, time, insitu_output, iuvs_output, DURATION=DURATION, PREFERENCES=PREFERENCES,$
                   lpw=lpw, static=static, swia=swia, swea=swea, mag=mag, sep=sep, ngims=ngims, $
                   iuvs_all=iuvs_all, iuvs_periapse=iuvs_periapse, iuvs_apoapse=iuvs_apoapse, $
                   iuvs_coronaEchellehigh=iuvs_coronaEchellehigh,iuvs_coronaEchelleDisk=iuvs_coronaEchelleDisk,$
                   iuvs_coronaEchelleLimb=iuvs_coronaEchelleLimb, iuvs_coronaLoresDisk=iuvs_coronaLoresDisk, $
                   iuvs_coronaLoreshigh=iuvs_coronaLoreshigh, iuvs_coronaLoreslimb=iuvs_coronaLoreslimb, $
                   iuvs_stellarocc=iuvs_stellarocc, insitu=insitu, $
                   inbound=inbound, outbound=outbound, binary=binary, debug=debug

  
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

  ;BINARY FLAG  
  if keyword_set(binary) eq 0 then binary_flag = 0 else binary_flag = 1

  ; DEFAULT RETRIEVAL PERIOD TO 1 DAY OR 1 ORBIT 
  if keyword_set(duration) eq 0 then begin
    if size(time,/type) eq 7 then duration = 86400
    if size(time,/type) eq 2 then duration = 1
  endif
  
  ;SET UP instrument_array WHICH IS USED FOR CREATING DATA STRUCTURE & CONTROLLING WHICH INSTRUMENTS DATA TO READ
  if keyword_set(lpw) or keyword_set(static) or keyword_set(swia) or keyword_set(swea) or keyword_set(mag) or keyword_set(sep) or $
    keyword_set(ngims) or keyword_set(iuvs_all) or keyword_set(iuvs_periapse) or keyword_set(iuvs_apoapse) or $
    keyword_set(iuvs_coronaEchellehigh) or keyword_set(iuvs_coronaEchelleLimb) or keyword_set(iuvs_coronaEchelleHigh) or keyword_set(iuvs_coronaLoresHigh) or $
    keyword_set(iuvs_coronaloreslimb) or keyword_set(iuvs_coronaloresdisk) or keyword_set(iuvs_stellarocc) or keyword_set(insitu) then begin
   
    instrument_array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
   
    if keyword_set(lpw) then begin
      instrument_array[0] = 1
      print,'Returning All LPW Instrument KP Data.'
    endif
    if keyword_set(static) then begin
      instrument_array[1] = 1
      print,'Returning All STATIC Instrument KP Data.'
    endif
    if keyword_set(swia) then begin
      instrument_array[2] = 1
      print,'Returning All SWIA Instrument KP Data.'
    endif
    if keyword_set(swea) then begin
      instrument_array[3] = 1
      print,'Returning All SWEA Instrument KP Data.'
    endif
    if keyword_set(mag) then begin
      instrument_array[4] = 1
      print,'Returning All MAG Instrument KP Data.'
    endif
    if keyword_set(sep) then begin
      instrument_array[5] = 1
      print,'Returning All SEP Instrument KP Data.'
    endif
    if keyword_set(ngims) then begin
      instrument_array[6] = 1
      print,'Returning All NGIMS Instrument KP Data.'
    endif
    if keyword_set(insitu) then begin
      instrument_array[0] = 1
      instrument_array[1] = 1
      instrument_array[2] = 1
      instrument_array[3] = 1
      instrument_array[4] = 1
      instrument_array[5] = 1
      instrument_array[6] = 1
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
      print,'Returning All IUVS Instrument KP Data.'
    endif
    if keyword_set(iuvs_periapse) then begin
      instrument_array[7] = 1
      print,'Returning All IUVS Instrument Periapse KP Data.'
    endif
    if keyword_set(iuvs_apoapse) then begin
      instrument_array[8] = 1
      print,'Returning All IUVS Instrument Apoapse KP Data.'
    endif
    if keyword_set(iuvs_coronaEchellehigh) then begin
      instrument_array[9] = 1
      print,'Returning All IUVS Instrument Corona Echelle High Altitude KP Data.'
    endif
    if keyword_set(iuvs_coronaEchellelimb) then begin
      instrument_array[10] = 1
      print,'Returning All IUVS Instrument Corona Echelle Limb KP Data.'
    endif
    if keyword_set(iuvs_stellarocc) then begin
      instrument_array[11] = 1
      print,'Returning All IUVS Instrument Stellar Occultation KP Data.'
    endif
    if keyword_set(iuvs_coronaLoreshigh) then begin
      instrument_array[12] = 1
      print,'Returning All IUVS Instrument Corona Lores High Altitude KP Data.'
    endif
    if keyword_set(iuvs_coronaLoreslimb) then begin
      instrument_array[13] = 1
      print,'Returning All IUVS Instrument Corona Lores Limb KP Data.'
    endif
    if keyword_set(iuvs_coronaLoresdisk) then begin
      instrument_array[14] = 1
      print,'Returning All IUVS Instrument Corona Lores Disk KP Data.'
    endif
    if keyword_set(iuvs_coronaechelledisk) then begin
      instrument_array[15] = 1
      print,'Returning All IUVS Instrument Corona Echelle Disk KP Data.'
    endif
  endif else begin
    ;SET ALL INSTRUMENT FLAGS TO 1 TO CREATE FULL STRUCTURE FOR ALL INSTRUMENT DATA
    instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]    
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
  

  install_result = routine_info('mvn_kp_read',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_read.pro',/extract,/regex)
  if keyword_set(preferences) eq 0 then begin
    
    ;CHECK IF THE PREFERENCES FILE EXISTS & READ IF IT DOES
    preference_exists = file_search(install_directory,'kp_preferences.txt',count=kp_pref_exists)
    if kp_pref_exists ne 0 then begin
      ;READ IN THE KP_PREFERENCES FILE AND SET VARIABLES
      temp=''
      kp_insitu_data_directory = ''
      kp_iuvs_data_directory = ''
      openr,lun,install_directory+'kp_preferences.txt',/get_lun
      readf,lun,temp
      readf,lun,kp_insitu_data_directory
      readf,lun,kp_iuvs_data_directory
      free_lun,lun
      kp_insitu_data_directory = strmid(kp_insitu_data_directory,strpos(kp_insitu_data_directory,'/'))
      kp_iuvs_data_directory = strmid(kp_iuvs_data_directory,strpos(kp_iuvs_data_directory,'/'))
    endif else begin
      ;ASK THE USER TO DEFINE THE DIRECTORY WHERE THE KP DATA FILES ARE STORED
      kp_insitu_data_directory = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing insitu KP data files')
      kp_iuvs_data_directory = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing IUVS KP data files')
      
      ;CREATE KP_PREFERENCES.TXT FOR FUTURE USE
      openw,lun,install_directory+'kp_preferences.txt',/get_lun
      printf,lun,'; IDL Toolkit KP Reader Preferences File'
      printf,lun,'kp_insitu_data_directory: '+kp_insitu_data_directory
      printf,lun,'kp_iuvs_data_directory: '+kp_iuvs_data_directory
      free_lun,lun
    endelse
    
  endif else begin
    ;FIXME THIS WAS NOT IMPLEMENTED AS DESCRIBED IN THE HEADER. NEED TO DECIDE HOW WE WANT TO
    ;HANDLE THIS SITUATION
    stop

  endelse

  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Process input time/orbit range  ---------------------------- ;;

  ;IF ORBIT(s) SUPPLIED - FIXME I DON"T THINK THIS IS WORKING AND DURATION IS ALWAYS DEFINED BY THIS POINT
  if size(time, /type) eq 2 then begin
    if n_elements(time) eq 1 then begin
      if keyword_set(duration) then begin
        print,'Retrieving KP data for ',strtrim(string(duration),2),' orbits beginning at #',strtrim(string(time),2)
        begin_orbit = time
        end_orbit = time + duration
        MVN_KP_ORBIT_TIME, begin_orbit, end_orbit, begin_time, end_time
      endif
    endif else begin
      print,'Retrieving KP data between orbits ',strtrim(string(time(0)),2),' and ',strtrim(string(time(1)),2)
      begin_orbit = time(0)
      end_orbit = time(1)
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
  
  ;DETERMINE WHICH FILES TO READ TO COVER INPUT TIME RANGE
  MVN_KP_FILENAME_PARSER, begin_time, end_time, total_KP_file_count, target_KP_filenames, iuvs_filenames, $
                          kp_insitu_data_directory, kp_iuvs_data_directory, binary_flag

  ;CREATE OUTPUT STRUCTURES BASED ON SEARCH PARAMETERS
  MVN_KP_INSITU_STRUCT_INIT, insitu_record, instrument_array
  MVN_KP_IUVS_STRUCT_INIT,   iuvs_record,   instrument_array

  ; INITIALIZE ARRAY OF DATA STRUTURES 
  kp_data_temp   = replicate(insitu_record,21600L*total_KP_file_count)
  iuvs_data_temp = replicate(iuvs_record, n_elements(iuvs_filenames))
  
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Main read loop: In situ data    ---------------------------- ;;
  
  
  ; FIXME: These variables aren't being used?
  ;VARIABLES TO HOLD THE COUNT OF VARIOUS OBSERVATION TYPES (IE. HIGH VS. LOW ALTITUDE)
  ; high_count = 0
  ; low_count = 0
   
  if binary_flag eq 0 then begin
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
        a = strsplit(temp,' ',/extract)
        if a[0] ne '#' then begin
          ;KICK TO ROUTINE TO CHECK IF TIME FALLS WITHIN SEARCH BOUNDS
          within_time_bounds = MVN_KP_TIME_BOUNDS(a[0],begin_time,end_time)
          ;IF WITHIN BOUNDS, EXTRACT AND STORE DATA
          if within_time_bounds then begin
            MVN_KP_INSITU_ASSIGN, insitu_record, a, instrument_array
            kp_data_temp[index] = insitu_record
            index=index+1
          endif
        endif
      endwhile
      
      free_lun,lun
    endfor      ;file loop, open/read each KP file
  endif else begin
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
  endelse

  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Main read loop: IUVS  data   ------------------------------- ;;
 
  if (instrument_array[7] eq 1) or (instrument_array[8] eq 1) or (instrument_array[9] eq 1) or (instrument_array[10] eq 1) or $    ;IF ANY IUVS DATA IS REQUESTED
    (instrument_array[11] eq 1) or (instrument_array[12] eq 1)  or (instrument_array[13] eq 1)  or (instrument_array[14] eq 1)  or (instrument_array[15] eq 1) then begin
    iuvs_index=0
    for file=0,n_elements(iuvs_filenames)-1 do begin
      ;INITIALIZE IUVS_RECORD TO CONTAIN DEFAULT VALUES
      MVN_KP_IUVS_STRUCT_INIT, iuvs_record, instrument_array
      
      if keyword_set(binary) then begin                                           ;READ IUVS DATA FROM BINARY FILES
        MVN_LOOP_PROGRESS,file,0,n_elements(iuvs_filenames)-1,message='IUVS KP File Read Progress'
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
        
        restore,iuvs_filenames[file]
        if instrument_array[7] eq 1 then begin                                    ;READ AND PARSE PERIAPSE DATA
          if size(periapse,/type) eq 8 then begin
            for peri_index = 0,n_elements(periapse.time_start)-1 do begin
              MVN_KP_IUVS_TIMECHECK, periapse[peri_index].time_start, begin_time, end_time, check
              if check eq 1 then begin
                MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, periapse[peri_index], 'PERIAPSE',index=peri_index
              endif
            endfor
          endif
        endif
        
        if instrument_array[8] eq 1 then begin                                    ;READ AND PARSE APOAPSE DATA
          if size(apoapse,/type) eq 8 then begin                                    ;ONLY EXECUTE IF THIS DATA TYPE IS AVAILABLE IN THE READ FILE
            MVN_KP_IUVS_TIMECHECK, apoapse.time_start, begin_time, end_time, check
            if check eq 1 then begin
              MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, apoapse, 'APOAPSE',index=0
            endif
          endif
        endif
        
        if instrument_array[9] eq 1 then begin                                    ;READ AND PARSE CORONA ECHELLE HIGH ALTITUDE DATA
          if size(corona_echelle_high,/type) eq 8 then begin
            MVN_KP_IUVS_TIMECHECK, corona_echelle_high.time_start, begin_time, end_time, check
            if check eq 1 then begin
              MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_high, 'CORONA_ECHELLE_HIGH'
            endif
          endif
        endif
        if instrument_array[10] eq 1 then begin                                    ;READ AND PARSE CORONA ECHELLE LIMB DATA
          if size(corona_echelle_limb,/type) eq 8 then begin
            MVN_KP_IUVS_TIMECHECK, corona_echelle_limb.time_start, begin_time, end_time, check
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
            MVN_KP_IUVS_TIMECHECK, corona_lores_high.time_start, begin_time, end_time, check
            if check eq 1 then begin
              MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_high, 'CORONA_LORES_HIGH'
            endif
          endif
        endif
        if instrument_array[13] eq 1 then begin                                    ;READ AND PARSE CORONA LORES LIMB DATA
          if size(corona_lores_limb,/type) eq 8 then begin
            MVN_KP_IUVS_TIMECHECK, corona_lores_limb.time_start, begin_time, end_time, check
            if check eq 1 then begin
              MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_limb, 'CORONA_LORES_LIMB'
            endif
          endif
        endif
        if instrument_array[14] eq 1 then begin                                    ;READ AND PARSE CORONA LORES DISK DATA
          if size(corona_lores_disk,/type) eq 8 then begin
            MVN_KP_IUVS_TIMECHECK, corona_lores_disk.time_start, begin_time, end_time, check
            if check eq 1 then begin
              MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_disk, 'CORONA_LORES_DISK'
            endif
          endif
        endif
        if instrument_array[15] eq 1 then begin                                    ;READ AND PARSE CORONA Echelle DISK DATA
          if size(corona_echelle_disk,/type) eq 8 then begin
            MVN_KP_IUVS_TIMECHECK, corona_echelle_disk.time_start, begin_time, end_time, check
            if check eq 1 then begin
              MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_disk, 'CORONA_ECHELLE_DISK'
            endif
          endif
        endif
        
        iuvs_data_temp[iuvs_index] = iuvs_record
        iuvs_data_temp[iuvs_index].orbit = periapse[0].orbit_number
        iuvs_index=iuvs_index+1
      endif else begin                                                             ;READ IUVS DATA FROM ASCII FILES
        print,'These files do not exist as yet, so go back and use binary'
      endelse
    endfor
  endif
  
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ------------------- Copy data into input data structures  -------------------------- ;;

  insitu_output = kp_data_temp[0:index-1]
  if (instrument_array[7] eq 1) or (instrument_array[8] eq 1) or (instrument_array[9] eq 1) or (instrument_array[10] eq 1) or $    ;IF ANY IUVS DATA IS REQUESTED
    (instrument_array[11] eq 1)  or (instrument_array[12] eq 1)  or (instrument_array[13] eq 1)  or (instrument_array[14] eq 1)  or (instrument_array[15] eq 1) then begin
    iuvs_output = iuvs_data_temp[0:iuvs_index-1]
  endif
  
  overall_end_time = systime(1)

  print,'A total of ',strtrim(string(index-1),2),' KP data records were found that met the search criteria.'
  if (instrument_array[7] eq 1) or (instrument_array[8] eq 1) or (instrument_array[9] eq 1) or (instrument_array[10] eq 1) or $    ;IF ANY IUVS DATA IS REQUESTED
    (instrument_array[11] eq 1)  or (instrument_array[12] eq 1)  or (instrument_array[13] eq 1)  or (instrument_array[14] eq 1)  or (instrument_array[15] eq 1) then begin
    print,'including ',strtrim(string(iuvs_index),2),' IUVS data records'
  endif
  print,'Your query took ', overall_end_time - overall_start_time,' seconds to complete.'
  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
  break1: ; FIXME - Why break?
end



