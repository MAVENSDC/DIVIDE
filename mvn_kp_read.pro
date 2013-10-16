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
;       optional name of a text preferences file if the user wants to override the default name
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
;    iuvs: in, optional, type=boolean
;       optional keyword to return all IUVS KP data, regardless of observation type
;    insitu: in, optional, type=boolean
;       optional keyword that will return all of the INSITU data, regardless of observation type
;    iuvs_periapse:  in, optional, type=boolean
;       optional keyword that will return all of the IUVS PERIAPSE limb scan data 
;    iuvs_apoapse: in, optional, type=boolean
;       optional keyword that will return all of the IUVS APOAPSE data 
;    iuvs_coronaEchellehigh: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona Echelle high altitude data 
;    iuvs_coronaEchellelow: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona Echelle low altitude data 
;    iuvs_coronaLoreslimb: in, optional, type=boolean
;       optional keyword that will return all of the iuvs corona LoREs on disk data 
;    iuvs_coronaLoreshigh: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Corona LoRes high altitude data 
;    iuvs_stellarocc: in, optional, type=boolean
;       optional keyword that will return all of the IUVS Stellar Occulatation data 
;    inbound: in, optional, type=boolean
;       optional keyword that will return all of the data from the inbound leg of an orbit
;    outbound: in, optional, type=boolean
;       optional keyword that will return all of the data from the outbound leg of an orbit
;    binary: in, optional, type=boolean
;       optional keyword to force the KP data reader to use binary files instead of ASCII text
;-

@time_string
@mvn_time_convert
@mvn_kp_iuvs_filename
@mvn_kp_insitu_versions
@mvn_kp_structure_build
@mvn_loop_progress
@mvn_kp_time_bounds
@mvn_kp_insitu_assign
@mvn_kp_iuvs_timecheck
@mvn_kp_iuvs_binary_assign

pro MVN_KP_READ, time, insitu_output, iuvs_output, DURATION=DURATION, PREFERENCES=PREFERENCES,$
                   lpw=lpw, static=static, swia=swia, swea=swea, mag=mag, sep=sep, ngims=ngims, $
                   iuvs_all=iuvs_all, iuvs_periapse=iuvs_periapse, iuvs_apoapse=iuvs_apoapse, $
                   iuvs_coronaEchellehigh=iuvscoronaEchellehigh,iuvs_coronaEchellelow=iuvs_coronaEchellelow,$
                   iuvs_coronaLoreshigh=iuvs_coronaLoreshigh, iuvs_coronaLoreslimb=iuvs_coronaLoreslimb, $
                   iuvs_stellarocc=iuvs_stellarocc, insitu=insitu, $
                   inbound=inbound, outbound=outbound, binary=binary


  overall_start_time = systime(1)


  ;CHECK IF ANY OF THE OPTIONAL PARAMETERS ARE SET AND SET THEM IF THEY ARE NOT


    if keyword_set(binary) eq 0 then begin
      binary_flag = 0
    endif else begin
      binary_flag = 1
    endelse
    if keyword_set(duration) eq 0 then begin
     if size(time,/type) eq 7 then begin
      duration = 86400    ;SET THE DEFAULT RETRIEVAL PERIOD TO 1 DAY IF TIME BASED RETRIEVAL IS SET
     endif
     if size(time,/type) eq 2 then begin
      duration = 1        ;SET THE DEFAULT RETRIEVAL PERIOD TO 1 ORBIT IF ORBIT BASED RETRIEVAL IS SET
     endif
    endif
    if keyword_set(lpw) or keyword_set(static) or keyword_set(swia) or keyword_set(swea) or keyword_set(mag) or keyword_set(sep) or $
      keyword_set(ngims) or keyword_set(iuvs_all) or keyword_set(iuvs_periapse) or keyword_set(iuvs_apoapse) or $
      keyword_set(iuvs_coronaEchellehigh) or keyword_set(iuvs_coronaEchelleLow) or keyword_set(iuvs_coronaLoresHigh) or $
      keyword_set(iuvs_coronaloreslimb) or keyword_set(iuvs_stellarocc) or keyword_set(insitu) then begin
      ;FOR EACH INSTRUMENT KEYWORD, SET RETURN FLAGS AND INDEX ARRAY FOR STRUCTURE CREATION
      instrument_array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
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
      if keyword_set(iuvs_coronaEchellelow) then begin
        instrument_array[10] = 1
        print,'Returning All IUVS Instrument Corona Echelle Low Altitude KP Data.'
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
    endif else begin
      instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1]    ;SET INSTRUMENT FLAGS TO 1 TO CREATE FULL STRUCTURE TO CONTAIN ALL DATA
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
    
    
  ;Check the contents of input variable and set-up any needed default parameters

    install_result = routine_info('mvn_kp_read',/source)
    install_directory = strsplit(install_result.path,'mvn_kp_read.pro',/extract,/regex)
    if keyword_set(preferences) eq 0 then begin
    ;CHECK IF THE PREFERENCES FILE EXISTS
      preference_exists = file_search(install_directory,'kp_preferences.txt',count=kp_pref_exists)    
    ;IF IT EXISTS, READ IN THE BASE PREFERENCES AS THIS ISN'T THE FIRST TIME A USER HAS RUN THE CODE  
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
      endif
    ;IF IT DOESN'T EXIST, SET DEFAULT STRINGS AND VARIABLES, WHILE CREATING KP_PREFERENCES.TXT FOR FUTURE USE
      if kp_pref_exists eq 0 then begin
        ;ASK THE USER TO DEFINE THE DIRECTORY WHERE THE KP DATA FILES ARE STORED
        kp_insitu_data_directory = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing insitu KP data files')
        kp_iuvs_data_directory = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing IUVS KP data files')
        openw,lun,install_directory+'kp_preferences.txt',/get_lun
        printf,lun,'; IDL Toolkit KP Reader Preferences File'
        printf,lun,'kp_insitu_data_directory: '+kp_insitu_data_directory
        printf,lun,'kp_iuvs_data_directory: '+kp_iuvs_data_directory
        free_lun,lun
      endif
    endif else begin        ;loop if preferences keyword is undefined
        ;ASK THE USER TO DEFINE THE DIRECTORY WHERE THE KP DATA FILES ARE STORED
        kp_insitu_data_directory = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing insitu KP data files')
        kp_iuvs_data_directory = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing IUVS KP data files')
        openw,lun,install_directory+'kp_preferences.txt',/get_lun
        printf,lun,'; IDL Toolkit KP Reader Preferences File'
        printf,lun,'kp_data_directory: '+kp_insitu_data_directory
        printf,lun,'kp_iuvs_data_directory: '+kp_iuvs_data_directory
        free_lun,lun
    endelse


  ;CONVERT TIME VARIABLE TO MATCH THAT OF THE KP FILES
  
   ;ALLOW THE USER TO SET A RANGE OF ORBITS FROM WHICH TO RETRIEVE DATA
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
   if size(time, /type) eq 7 then begin 
   ;IF THE USER SUPPLIED ONLY 1 TIME, ASSUME START TIME AND DEFINE ENDTIME BASED ON DEFAULT OR DEFINED RETRIEVAL PERIOD
    if n_elements(time) eq 1 then begin 
      begin_time = MVN_TIME_CONVERT(time,1)
     ;CHECK DEFAULT/DEFINED RETRIEVAL TIME AND SET END TIME APPROPRIATELY
      end_time = MVN_TIME_MATH(begin_time,duration)
    endif else begin     ;IF THE USER SUPPLIES A 2-VALUE ARRAY OF TIMES, CONVERT TO START AND END TIMES
     begin_time = mvn_time_convert(time[0],1)
     end_time = MVN_TIME_convert(time[1],1)
    endelse
   endif
   if size(time,/type) eq 3 then begin        ;LONG INTEGER TIMES
    if n_elements(time) eq 1 then begin
      begin_time = MVN_TIME_CONVERT(time,3)
      end_time = MVN_TIME_CONVERT((time+86400),3)
    endif else begin
      begin_time = MVN_TIME_CONVERT(time[0],3)
      end_time = MVN_TIME_CONVERT(time[1],3)
    endelse
   endif
   
   
  ;PARSE THE KP FILE NAMES TO DETERMINE HOW MANY FILES TO READ
    ;DETERMINE HOW MANY DAYS OF FILES WILL BE OPENED AND READ FOR THE SEARCH ROUTINE
    
      MVN_KP_FILENAME_PARSER, begin_time, end_time, total_KP_file_count, target_KP_filenames, iuvs_filenames, kp_insitu_data_directory, kp_iuvs_data_directory, binary_flag

    ;CREATE OUTPUT STRUCTURE BASED ON SEARCH PARAMETERS 
    
      MVN_KP_STRUCTURE_BUILD, record, iuvs_record, instrument_array
      
    kp_data_temp = replicate(record,21600L*total_KP_file_count)
    iuvs_data_temp = replicate(iuvs_record, n_elements(iuvs_filenames))
   
    
    ;VARIABLES TO HOLD THE COUNT OF VARIOUS OBSERVATION TYPES (IE. HIGH VS. LOW ALTITUDE)
    high_count = 0
    low_count = 0 
     
    
    ;LOOP OVER TOTAL NUMBER OF DAYS WITHIN READ/SEARCH
     ; IF WORKING WITH ASCII KP FILES< THEN THIS ROUTINE
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
                  MVN_KP_INSITU_ASSIGN, record, a, instrument_array
                  kp_data_temp[index] = record
                  index=index+1
                endif
              endif
             endwhile
      
            free_lun,lun
          endfor                  ;file loop, open/read each KP file
       endif else begin
        index=0L
        within_time_bounds=0
        for file=0,total_KP_file_count[0]-1 do begin
         ;UPDATE THE READ STATUS BAR
          MVN_LOOP_PROGRESS,file,0,total_kp_file_count-1,message='In-situ KP File Read Progress'
          restore,kp_insitu_data_directory+target_kp_filenames[file]
           ;LOAD THE NEEDED IN-SITU DATA FILES FOR EACH INSTRUMENT
   ;         if instrument_array[0] eq 1 then begin
   ;           restore,kp_data_directory+'LPW/'+target_kp_filenames[1,file]
   ;         endif
   ;         if instrument_array[1] eq 1 then begin
   ;           restore,kp_data_directory+'STATIC/'+target_kp_filenames[3,file]
   ;         endif
   ;         if instrument_array[2] eq 1 then begin
   ;           restore,kp_data_directory+'SWIA/'+target_kp_filenames[7,file]
   ;         endif
   ;         if instrument_array[3] eq 1 then begin
   ;           restore,kp_data_directory+'SWEA/'+target_kp_filenames[2,file]
   ;         endif
   ;         if instrument_array[4] eq 1 then begin
   ;           restore,kp_data_directory+'MAG/'+target_kp_filenames[4,file]
   ;         endif
   ;         if instrument_array[5] eq 1 then begin
   ;           restore,kp_data_directory+'SEP/'+target_kp_filenames[5,file]
   ;         endif
  ;          if instrument_array[6] eq 1 then begin
   ;           restore,kp_data_directory+'NGIMS/'+target_kp_filenames[6,file]
   ;         endif
          for saved_records = 0, n_elements(orbit) -1 do begin
            within_time_bounds = mvn_kp_time_bounds(orbit[saved_records].time_string, begin_time, end_time)
              if within_time_bounds then begin            ;IF WITHIN TIME RANGE, EXTRACT AND STORE DATA 
               
                if ((io_flag[0] eq 1) and (orbit[saved_records].io_bound eq 'I')) or ((io_flag[1] eq 1) and (orbit[saved_records].io_bound eq 'O')) then begin
  
                  MVN_KP_INSITU_ASSIGN, record, orbit[saved_records], instrument_array
;                  if instrument_array[0] eq 1 then begin
;                    MVN_KP_INSITU_ASSIGN,record, lpw_data[saved_records], 'lpw'
;                  endif
;                  if instrument_array[1] eq 1 then begin
;                    MVN_KP_INSITU_ASSIGN,record, static_data[saved_records], 'static'
;                  endif
;                  if instrument_array[2] eq 1 then begin
;                    MVN_KP_INSITU_ASSIGN,record, swia_data[saved_records], 'swia'
;                  endif
;                  if instrument_array[3] eq 1 then begin
;                    MVN_KP_INSITU_ASSIGN,record, swea_data[saved_records], 'swea'
;                  endif
;                  if instrument_array[4] eq 1 then begin
;                    MVN_KP_INSITU_ASSIGN,record, mag_data[saved_records], 'mag'
;                  endif
;                  if instrument_array[5] eq 1 then begin
;                    MVN_KP_INSITU_ASSIGN,record, sep_data[saved_records], 'sep'
;                  endif
;                  if instrument_array[6] eq 1 then begin
;                    MVN_KP_INSITU_ASSIGN,record, ngims_data[saved_records], 'ngims
;                  endif
                  kp_data_temp[index] = record             
                  index=index+1
     
               endif
              endif
          endfor
        endfor
       endelse

     
     ;OPEN AND STORE THE DESIRED IUVS DATA RECORDS IN IT'S OWN STRUCTURE
     
       if (instrument_array[7] eq 1) or (instrument_array[8] eq 1) or (instrument_array[9] eq 1) or (instrument_array[10] eq 1) or $    ;IF ANY IUVS DATA IS REQUESTED
          (instrument_array[11] eq 1) then begin
         iuvs_index=0
         for file=0,n_elements(iuvs_filenames)-1 do begin
          if keyword_set(binary) then begin                                           ;READ IUVS DATA FROM BINARY FILES
            MVN_LOOP_PROGRESS,file,0,n_elements(iuvs_filenames)-1,message='IUVS KP File Read Progress'
            ;SET EACH IUVS OBSERVATION DATA TYPE TO 0 BEFORE READING
            periapse = 0
            apoapse = 0
            corona_echelle_above_limb = 0
            corona_echelle_disk = 0
  ;          stellar_occ = 0
            corona_lores_high_alt = 0
            corona_lores_limb = 0
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
             if size(corona_echelle_above_limb,/type) eq 8 then begin
              MVN_KP_IUVS_TIMECHECK, corona_echelle_above_limb.time_start, begin_time, end_time, check
              if check eq 1 then begin
                MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_above_limb, 'CORONA_ECHELLE_HIGH'
              endif
             endif
            endif
            if instrument_array[10] eq 1 then begin                                    ;READ AND PARSE CORONA ECHELLE DISK DATA
             if size(corona_echelle_disk,/type) eq 8 then begin
              MVN_KP_IUVS_TIMECHECK, corona_echelle_disk.time_start, begin_time, end_time, check
              if check eq 1 then begin
                MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_echelle_disk, 'CORONA_ECHELLE_DISK'
              endif            
             endif
            endif
  ;          if instrument_array[11] eq 1 then begin                                    ;READ AND PARSE STELLAR OCCULTATION DATA
  ;          
  ;          endif
            if instrument_array[12] eq 1 then begin                                    ;READ AND PARSE CORONA LORES HIGH ALT DATA
             if size(corona_lores_high_alt,/type) eq 8 then begin
              MVN_KP_IUVS_TIMECHECK, corona_lores_high_alt.time_start, begin_time, end_time, check
              if check eq 1 then begin
                MVN_KP_IUVS_BINARY_ASSIGN, iuvs_record, corona_lores_high_alt, 'CORONA_LORES_HIGH'
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
  
            iuvs_data_temp[iuvs_index] = iuvs_record     
            iuvs_data_temp[iuvs_index].orbit = periapse[0].orbit_number        
            iuvs_index=iuvs_index+1
          endif else begin                                                             ;READ IUVS DATA FROM ASCII FILES 
            print,'These files do not exist as yet, so go back and use binary'
          endelse
         endfor
       endif

 ;OUTPUT THE REDUCED STRUCTURE TO THE NAMED OR DEFAULT OUTPUT VARIABLE


    insitu_output = kp_data_temp[0:index-1]
      if (instrument_array[7] eq 1) or (instrument_array[8] eq 1) or (instrument_array[9] eq 1) or (instrument_array[10] eq 1) or $    ;IF ANY IUVS DATA IS REQUESTED
        (instrument_array[11] eq 1) then begin
          iuvs_output = iuvs_data_temp[0:iuvs_index-1]
      endif
  
  overall_end_time = systime(1)
  
   
print,'A total of ',strtrim(string(index-1),2),' KP data records were found that met the search criteria.'
  if (instrument_array[7] eq 1) or (instrument_array[8] eq 1) or (instrument_array[9] eq 1) or (instrument_array[10] eq 1) or $    ;IF ANY IUVS DATA IS REQUESTED
        (instrument_array[11] eq 1) then begin
        print,'including ',strtrim(string(iuvs_index),2),' IUVS data records'
  endif
print,'Your query took ', overall_end_time - overall_start_time,' seconds to complete.'


break1:
end



