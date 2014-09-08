;+
; :Name: mvn_kp_read
;
; :Author: Kris Larsen & John Martin
;
;
; :Description:
;     Read local Maven KP data files into memory. Capable of reading both in situ KP data files
;     and IUVS KP data files. Capable of reading in either CDF or ASCII formated data files. 
;     By default, CDF files are read. There are also hooks in place, using /download_new keyword, 
;     to query the SDC web server and download missing or updated KP data files.  
;
; :Params:
;    time: in, required, can be a scalar or a two item array of type:
;         long(s)        orbit number
;         string(s)      format:  YYYY-MM-DD/hh:mm:ss       
;       A start or start & stop time (or orbit #) range for reading kp data. 
;       
;    insitu_output: output, required, type=array of structures
;       This paramater will contain the in situ KP data that is read into memory. It will
;       be structured as an array of structures. Each array entry corresponds to each time. 
;       
;    iuvs_output: output, optional, type=array of structures
;       This parameter will contain the IUVS KP data that is read into memory. It will be
;       structured as an array of structures. Each array entry corresponds to one orbit of data. 
;
; :Keywords:
;    download_new: in, optional, type=boolean
;       optional keyword to instruct IDL to query the SDC server to look for any new or missing
;       files to download over the input timerange.
;    update_prefs: in, optional, type=boolean
;       Before reading in data, allow user to update kp_preferences.txt - which contains paths
;       to the in situ data and IUVS data. After selecting new paths to data folders, read will
;       continue. 
;    only_update_prefs: in, optional, type=boolean
;       Allow user to update kp_preferences.txt - which contains paths to the in situ data and 
;       IUVS data. After selecting new paths to data folders, procedure will return - not reading
;       in any data. 
;    debug:  in, optional, type=boolean
;       On error, - "Stop immediately at the statement that caused the error and print 
;       the current program stack." If not specified, error message will be printed and 
;       IDL with return to main program level and stop.
;    duration: in, optional, type=integer
;       Length of time range for data read, only used if input time parameter is a single value.
;       If input time is a string, duration is interpreted as seconds. If input time is an integer
;       (orbit), duration is interpreted as orbits. 
;    text_files: in optional, type=boolean
;       Read in ASCII files instead of the default of reading CDF files. 
;    save_files: in optional, type=boolean
;       Read in .sav files instead of the default of reading CDF files. This option exists primarily
;       for the developers and debugging. 
;    insitu_only: in optional, type=boolean
;       Read in only in situ data. If this is supplied, the iuvs_output paramater will be ignored if 
;       input. Because insitu spacecraft time series ephemeris data is necessary for the visulization
;       procedures to work, there is no iuvs_only option. 

;    lpw: in, optional, type=boolean
;       return all of the LPW data
;    euv: in, optional, type=boolean
;       return all of the EUV data
;    static: in, optional, type=boolean
;       return all of the STATIC data
;    swia: in, optional, type=boolean
;       return all of the SWIA data
;    swea: in, optional, type=boolean
;       return all of the SWEA data
;    mag: in, optional, type=boolean
;       return all of the MAG data
;    sep: in, optional, type=boolean
;       return all of the SEP data
;    ngims: in, optional, type=boolean
;       return all of the NGIMS data
;    inbound: in, optional, type=boolean
;       return only the data from the inbound leg of an orbit
;    outbound: in, optional, type=boolean
;       return only the data from the outbound leg of an orbit 
;    insitu_all: in, optional, type=boolean
;       return all in situ data. This keyword is necessary if an IUVS observation mode keyword
;       is specified and you want to still read in all in situ data. If no in situ instrument 
;       or IUVS observation keyword specified, default behavior is to read in all in situ data. 
;       
;    iuvs_periapse: in, optional, type=boolean
;       return all of the IUVS PERIAPSE limb scan data 
;    iuvs_apoapse: in, optional, type=boolean
;       return all of the IUVS APOAPSE data 
;    iuvs_coronaEchellehigh: in, optional, type=boolean
;       return all of the IUVS Corona Echelle high altitude data 
;    iuvs_coronaEchelleDisk: in, optional, type=boolean
;       return all of the IUVS Corona Echelle disk data 
;    iuvs_coronaEchelleLimb: in, optional, type=boolean
;       return all of the IUVS Corona Echelle limb data 
;    iuvs_coronaLoresDisk: in, optional, type=boolean
;       return all of the IUVS Corona LoRes disk data
;    iuvs_coronaLoreshigh: in, optional, type=boolean
;       return all of the IUVS Corona LoRes high altitude data
;    iuvs_coronaLoreslimb: in, optional, type=boolean
;       return all of the iuvs corona LoREs on limb data 
;    iuvs_stellarocc: in, optional, type=boolean
;       return all of the IUVS Stellar Occulatation data
;    iuvs_all: in, optional, type=boolean
;       return all IUVS observation modes. This keyword is necessary if an in situ instrument 
;       keyword is specified and you want to still read in all IUVS data. If no in situ instrument
;       or IUVS observation keyword specified, default behavior is to read in all IUVS data. 
;
;-

@mvn_kp_file_search
@mvn_kp_time_bounds
@mvn_kp_loop_progress
@mvn_kp_config_file
@mvn_kp_config
@mvn_kp_insitu_struct_init
@mvn_kp_iuvs_struct_init
@mvn_kp_insitu_assign
@mvn_kp_iuvs_binary_assign
@mvn_kp_read_insitu_file
@mvn_kp_read_iuvs_file
@mvn_kp_iuvs_cdf_read
@mvn_kp_insitu_cdf_read


pro MVN_KP_READ, time, insitu_output, iuvs_output, download_new=download_new, update_prefs=update_prefs, $
                 debug=debug, duration=duration, text_files=text_files, save_files=save_files, $
                 insitu_only=insitu_only, insitu_all=insitu_all, inbound=inbound, outbound=outbound, $
                 lpw=lpw, euv=euv, static=static, swia=swia, swea=swea, mag=mag, sep=sep, ngims=ngims, $    
                 iuvs_all=iuvs_all, iuvs_periapse=iuvs_periapse, iuvs_apoapse=iuvs_apoapse, $
                 iuvs_coronaEchellehigh=iuvs_coronaEchellehigh,iuvs_coronaEchelleDisk=iuvs_coronaEchelleDisk,$
                 iuvs_coronaEchelleLimb=iuvs_coronaEchelleLimb, iuvs_coronaLoresDisk=iuvs_coronaLoresDisk, $
                 iuvs_coronaLoreshigh=iuvs_coronaLoreshigh, iuvs_coronaLoreslimb=iuvs_coronaLoreslimb, $
                 iuvs_stellarocc=iuvs_stellarocc, only_update_prefs=only_update_prefs, help=help
                      
  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    print,'MVN_KP_READ'
    print,'  Read local Maven KP data files into memory. Capable of reading both in situ KP data files'
    print,'  and IUVS KP data files. Capable of reading in either CDF or ASCII formated data files. '
    print,'  By default, CDF files are read. There are also hooks in place, using /download_new keyword, '
    print,'  to query the SDC web server and download missing or updated KP data files. '
    print,''
    print,'mvn_kp_read, time, insitu_output, iuvs_output, download_new=download_new, update_prefs=update_prefs, $'
    print,'             debug=debug, duration=duration, text_files=text_files, save_files=save_files, $'
    print,'             insitu_only=insitu_only, insitu_all=insitu_all, inbound=inbound, outbound=outbound, $'
    print,'             lpw=lpw, static=static, swia=swia, swea=swea, mag=mag, sep=sep, ngims=ngims, $    '
    print,'             iuvs_all=iuvs_all, iuvs_periapse=iuvs_periapse, iuvs_apoapse=iuvs_apoapse, $'
    print,'             iuvs_coronaEchellehigh=iuvs_coronaEchellehigh,iuvs_coronaEchelleDisk=iuvs_coronaEchelleDisk,$'
    print,'             iuvs_coronaEchelleLimb=iuvs_coronaEchelleLimb, iuvs_coronaLoresDisk=iuvs_coronaLoresDisk, $'
    print,'             iuvs_coronaLoreshigh=iuvs_coronaLoreshigh, iuvs_coronaLoreslimb=iuvs_coronaLoreslimb, $'
    print,'             iuvs_stellarocc=iuvs_stellarocc, only_update_prefs=only_update_prefs, help=help'
    print,''
    print,'REQUIRED FIELDS'
    print,'***************'
    print,'  time: A start or start & stop time (or orbit #) range for reading kp data.
    print,'        long(s)        orbit number
    print,'        string(s)      format:  YYYY-MM-DD/hh:mm:ss       
    print,'  insitu_output: This paramater will contain the in situ KP data that is read into memory. It will
    print,'                 be structured as an array of structures. Each array entry corresponds to each time. 
    print,'  iuvs_output: This parameter will contain the IUVS KP data that is read into memory. It will be
    print,'               structured as an array of structures. Each array entry corresponds to one orbit of data.
    print,'OPTIONAL FIELDS'
    print,'***************'
    print,'  download_new: optional keyword to instruct IDL to query the SDC server to look for any new or missing
    print,'                files to download over the input timerange.
    print,'  update_prefs: Before reading in data, allow user to update kp_preferences.txt - which contains paths
    print,'                to the in situ data and IUVS data. After selecting new paths to data folders, read will continue. 
    print,'  only_update_prefs: Allow user to update kp_preferences.txt - which contains paths to the in situ data and 
    print,'                     IUVS data. After selecting new paths to data folders, procedure will return - not reading in any data. 
    print,'  debug:  On error, - "Stop immediately at the statement that caused the error and print 
    print,'          the current program stack." If not specified, error message will be printed and 
    print,'          IDL with return to main program level and stop.
    print,'  duration: Length of time range for data read, only used if input time parameter is a single value.
    print,'            If input time is a string, duration is interpreted as seconds. If input time is an integer
    print,'            (orbit), duration is interpreted as orbits. 
    print,'  text_files: Read in ASCII files instead of the default of reading CDF files. 
    print,'  save_files: Read in .sav files instead of the default of reading CDF files. This option exists primarily
    print,'              for the developers and debugging. 
    print,'  insitu_only: Read in only in situ data. If this is supplied, the iuvs_output paramater will be ignored if 
    print,'               input. Because insitu spacecraft time series ephemeris data is necessary for the visulization
    print,'               procedures to work, there is no iuvs_only option. 

    print,'  lpw: return all of the LPW data
    print,'  euv: return all of the EUV data
    print,'  static: return all of the STATIC data
    print,'  swia: return all of the SWIA data
    print,'  swea: return all of the SWEA data
    print,'  mag: return all of the MAG data
    print,'  sep: return all of the SEP data
    print,'  ngims: return all of the NGIMS data
    print,'  inbound: return only the data from the inbound leg of an orbit
    print,'  outbound:  return only the data from the outbound leg of an orbit 
    print,'  insitu_all: return all in situ data. This keyword is necessary if an IUVS observation mode keyword
    print,'              is specified and you want to still read in all in situ data. If no in situ instrument 
    print,'              or IUVS observation keyword specified, default behavior is to read in all in situ data. 
;       
    print,'  iuvs_periapse: return all of the IUVS PERIAPSE limb scan data 
    print,'  iuvs_apoapse: return all of the IUVS APOAPSE data 
    print,'  iuvs_coronaEchellehigh: return all of the IUVS Corona Echelle high altitude data 
    print,'  iuvs_coronaEchelleDisk: return all of the IUVS Corona Echelle disk data 
    print,'  iuvs_coronaEchelleLimb: return all of the IUVS Corona Echelle limb data 
    print,'  iuvs_coronaLoresDisk: return all of the IUVS Corona LoRes disk data
    print,'  iuvs_coronaLoreshigh: return all of the IUVS Corona LoRes high altitude data
    print,'  iuvs_coronaLoreslimb: return all of the iuvs corona LoREs on limb data 
    print,'  iuvs_stellarocc: return all of the IUVS Stellar Occulatation data
    print,'  iuvs_all: return all IUVS observation modes. This keyword is necessary if an in situ instrument 
    print,'            keyword is specified and you want to still read in all IUVS data. If no in situ instrument
    print,'            or IUVS observation keyword specified, default behavior is to read in all IUVS data. 
    print,'  help: Invoke this list.'
    return
  endif



  
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

  ;; Read from and/or update preferences file 
  if keyword_set(only_update_prefs) then begin
    MVN_KP_CONFIG_FILE, /update_prefs, insitu_only=insitu_only
    
    ;; Warn user if other parameters supplied
    if keyword_set(time) or keyword_set(insitu) or keyword_set(iuvs) then begin
      print, "Warning. /ONLY_UPDATE_PREFS option supplied, not reading any data." 
      print, "If you want to update the preferences file & read data, use /UPDATE_PREFS instead"
    endif
    
    ;; Only update prefs option, return now. 
    return
  endif else begin

    ;; Read or create preferences file 
    MVN_KP_CONFIG_FILE, insitu_data_dir=kp_insitu_data_directory, iuvs_data_dir=kp_iuvs_data_directory, $
      update_prefs=update_prefs, insitu_only=insitu_only
  endelse
    

  ;SET UP instruments struct WHICH IS USED FOR CREATING DATA STRUCTURE & CONTROLLING WHICH INSTRUMENTS DATA TO READ
  if keyword_set(lpw) or keyword_set(euv) or keyword_set(static) or keyword_set(swia) or keyword_set(swea) or keyword_set(mag) or keyword_set(sep) or $
    keyword_set(ngims) or keyword_set(iuvs_all) or keyword_set(iuvs_periapse) or keyword_set(iuvs_apoapse) or $
    keyword_set(iuvs_coronaEchelleDisk) or keyword_set(iuvs_coronaEchelleLimb) or keyword_set(iuvs_coronaEchelleHigh) or keyword_set(iuvs_coronaLoresHigh) or $
    keyword_set(iuvs_coronaloreslimb) or keyword_set(iuvs_coronaloresdisk) or keyword_set(iuvs_stellarocc) or keyword_set(insitu_all) then begin


  ;; Setup instrument struct which is used for creating data structure & controlling which instruments to read
    instruments = CREATE_STRUCT('lpw',      0, 'euv',      0, 'static',   0, 'swia',     0, $
                                'swea',     0, 'mag',      0, 'sep',      0, $
                                'ngims',    0, 'periapse', 0, 'c_e_disk', 0, $
                                'c_e_limb', 0, 'c_e_high', 0, 'c_l_disk', 0, $
                                'c_l_limb', 0, 'c_l_high', 0, 'apoapse' , 0, 'stellarocc', 0)                            
   
    if keyword_set(lpw)    then begin
      instruments.lpw    = 1 & print,'Returning All LPW Instrument KP Data.'  
    endif
    if keyword_set(euv)    then begin
      instruments.euv    = 1 & print,'Returning All EUV Instrument KP Data.'
    endif
    if keyword_set(static) then begin
      instruments.static = 1 & print,'Returning All STATIC Instrument KP Data.'
    endif
    if keyword_set(swia)   then begin
      instruments.swia   = 1 & print,'Returning All SWIA Instrument KP Data.'
    endif
    if keyword_set(swea)   then begin
      instruments.swea   = 1 & print,'Returning All SWEA Instrument KP Data.'
    endif
    if keyword_set(mag)    then begin
      instruments.mag    = 1 & print,'Returning All MAG Instrument KP Data.'
    endif
    if keyword_set(sep)    then begin
      instruments.sep    = 1 & print,'Returning All SEP Instrument KP Data.'
    endif
    if keyword_set(ngims)  then begin
      instruments.ngims  = 1 & print,'Returning All NGIMS Instrument KP Data.'
    endif
    if keyword_set(inbound) then begin
                               print,'Returning only inbound in situ data'
    endif
    if keyword_set(outbound) then begin
                               print,'Returning only outbound in situ data'
    endif
    
    if keyword_set(iuvs_periapse)          then begin
      instruments.periapse   = 1 & print,'Returning All IUVS Instrument Periapse KP Data.'  
    endif
    if keyword_set(iuvs_apoapse)           then begin
      instruments.apoapse    = 1 & print,'Returning All IUVS Instrument Apoapse KP Data.'
    endif
    if keyword_set(iuvs_coronaEchellehigh) then begin
      instruments.c_e_high   = 1 & print,'Returning All IUVS Instrument Corona Echelle High Altitude KP Data.'
    endif
    if keyword_set(iuvs_coronaEchellelimb) then begin
      instruments.c_e_limb   = 1 & print,'Returning All IUVS Instrument Corona Echelle Limb KP Data.'
    endif
    if keyword_set(iuvs_stellarocc)        then begin
      instruments.stellarocc = 1 & print,'Returning All IUVS Instrument Stellar Occultation KP Data.'
    endif
    if keyword_set(iuvs_coronaLoreshigh)   then begin
      instruments.c_l_high   = 1 & print,'Returning All IUVS Instrument Corona Lores High Altitude KP Data.'
    endif
    if keyword_set(iuvs_coronaLoreslimb)   then begin
      instruments.c_l_limb   = 1 & print,'Returning All IUVS Instrument Corona Lores Limb KP Data.'
    endif
    if keyword_set(iuvs_coronaLoresdisk)   then begin
      instruments.c_l_disk   = 1 & print,'Returning All IUVS Instrument Corona Lores Disk KP Data.'
    endif
    if keyword_set(iuvs_coronaechelledisk) then begin
      instruments.c_e_disk   = 1 & print,'Returning All IUVS Instrument Corona Echelle Disk KP Data.'
    endif
    
    if keyword_set(insitu_all) then begin
      instruments.lpw    = 1
      instruments.euv    = 1
      instruments.static = 1
      instruments.swia   = 1
      instruments.swea   = 1
      instruments.mag    = 1
      instruments.sep    = 1
      instruments.ngims  = 1
      print, 'Returning all INSITU Instrument KP Data.'
    endif
    if keyword_set(iuvs_all) then begin
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


  endif else begin
    
    ;SET ALL INSTRUMENT FLAGS TO 1 TO CREATE FULL STRUCTURE FOR ALL INSTRUMENT DATA
    instruments = CREATE_STRUCT('lpw',      1, 'euv',      1, 'static',   1, 'swia',     1, $
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
  ;; ----------------------- Process input time/orbit range  ---------------------------- ;;

  
  ; DEFAULT RETRIEVAL PERIOD TO 1 DAY OR 1 ORBIT
  if keyword_set(duration) eq 0 then begin
    if size(time,/type) eq 7 then duration = 86399
    if size(time,/type) eq 2 then duration = 1
  endif

  ;IF ORBIT(s) SUPPLIED 
  ;;============================
  if size(time, /type) eq 2 then begin
  
    ;; If only one orbit supplied, add duration to first orbit to created end_orbit  
    if n_elements(time) eq 1 then begin
        print,'Retrieving KP data for ',strtrim(string(duration),2),' orbits beginning at orbit #',strtrim(string(time),2)
        begin_orbit = time[0]
        end_orbit = time[0] + duration
    endif else begin
      begin_orbit = time[0]
      end_orbit   = time[1]
    endelse
    
    ;; Use orbit file look up to get time strings for each orbit       -- FIXME check output of this to ensure we found orbits.
    MVN_KP_ORBIT_TIME, begin_orbit, end_orbit, begin_time_string, end_time_string
    
    ;; Create Jul day versions
    mvn_kp_time_split_string, begin_time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
    begin_time_jul = julday(mo, dy, yr, hr, min, sec)
    mvn_kp_time_split_string, end_time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
    end_time_jul = julday(mo, dy, yr, hr, min, sec) 
  endif
  
  ;IF TIME STRING(s) SUPPLIED
  ;;============================
  if size(time, /type) eq 7 then begin 
    if n_elements(time) eq 1 then begin 
      ; IF ONE TIME SUPPLIED USE IT AS START. DETERMINE END TIME BASED ON duration (DEFAULT 1 DAY OR USER SUPPLIED)
      begin_time_string = time[0]
      mvn_kp_time_split_string, begin_time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
      begin_time_jul = julday(mo, dy, yr, hr, min, sec)

      ;; Add seconds onto begin jul date to get end jul date
      end_time_jul = begin_time_jul + (duration/86400.0D)
      end_time_string = MVN_KP_TIME_CREATE_STRING(end_time_jul)
      
    endif else begin
      ;IF THE USER SUPPLIES A 2-VALUE ARRAY OF TIMES, USE THESE AS TIME STRINGS   - FIXME VALIDATE TIMES HERE?
      begin_time_string = time[0]
      end_time_string   = time[1]
      
      ;; Create Jul day versions
      mvn_kp_time_split_string, begin_time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
      begin_time_jul = julday(mo, dy, yr, hr, min, sec)
      mvn_kp_time_split_string, end_time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
      end_time_jul = julday(mo, dy, yr, hr, min, sec)
    endelse
  endif
  
  ;IF LONG INTEGER TIME SUPPLIED CONVERT FROM UNIX TIME TO TIME STRING (FIXME: SECONDS?)
  ;;============================
  if size(time,/type) eq 3 then begin
    if n_elements(time) eq 1 then begin
      begin_time_string = time_string(time, format=0)
      end_time_string   = time_string((time+duration), format=0)
    endif else begin
      begin_time_string = time_string(time[0],format=0)
      end_time_string   = time_string(time[1],format=0)
    endelse
    
    ;; Create Jul day versions
    mvn_kp_time_split_string, begin_time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
    begin_time_jul = julday(mo, dy, yr, hr, min, sec)
    mvn_kp_time_split_string, end_time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
    end_time_jul = julday(mo, dy, yr, hr, min, sec)
  endif
  
  
  ;; Create structs for both begin/end times containing string versions and jul days
  begin_time_struct = create_struct('string', begin_time_string, 'jul', begin_time_jul)
  end_time_struct   = create_struct('string', end_time_string,   'jul', end_time_jul)


  ;; ------------------------------------------------------------------------------------ ;;
  ;; -------------- Find files which contain data in input time range ------------------- ;;
  ;; -------------- and initialize data structures for holding data --------------------- ;;

  ;; FIXME variable names
  MVN_KP_FILE_SEARCH, begin_time_struct, end_time_struct, target_KP_filenames, kp_insitu_data_directory, iuvs_filenames, $
     kp_iuvs_data_directory, save_files=save_files, text_files=text_files, insitu_only=insitu_only, download_new=download_new
 

  ;CREATE OUTPUT STRUCTURES BASED ON SEARCH PARAMETERS & INITIALIZE ARRAY OF DATA STRUTURES 
  MVN_KP_INSITU_STRUCT_INIT, insitu_record, instruments=instruments
  kp_data_temp = replicate(insitu_record,21600L*n_elements(target_KP_filenames))
    
  if not keyword_set(insitu_only) then begin  
    MVN_KP_IUVS_STRUCT_INIT, iuvs_record, instruments=instruments
    iuvs_data_temp = replicate(iuvs_record, n_elements(iuvs_filenames))
  endif

 
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Main read loop: In situ data    ---------------------------- ;;
  
  

  if target_kp_filenames[0] ne 'None' then begin
    totalEntries=0L
    start_index=0L
    for file=0,n_elements(target_KP_filenames)-1 do begin
    
      ;UPDATE THE READ STATUS BAR
      MVN_KP_LOOP_PROGRESS,file,0,n_elements(target_KP_filenames)-1,message='In-situ KP File Read Progress'
      
      ;; Construct path to file
      date_path = mvn_kp_date_subdir(target_kp_filenames[file])
      fileAndPath = kp_insitu_data_directory+date_path+target_kp_filenames[file]
      
      MVN_KP_READ_INSITU_FILE, fileAndPath, kp_data, begin_time=begin_time_struct, end_time=end_time_struct, io_flag=io_flag, $
        instruments=instruments, save_files=save_files, text_files=text_files
        
    
      ;; Ensure what was returned is a structure, (and not int 0 indicating no matches)
      if size(kp_data, /TYPE) eq 8 then begin
        kp_data_temp[start_index:(start_index+n_elements(kp_data)-1)] = kp_data
        start_index += n_elements(kp_data)
        totalEntries += n_elements(kp_data)
      endif
    endfor
    
    
    ;OUTPUT INSITU DATA STRUCTURE
    insitu_output = kp_data_temp[0:totalEntries-1]
    print,'A total of ',strtrim(n_elements(insitu_output),2),' INSITU KP data records were found that met the search criteria.'
    
  endif else begin
    printf,-2, "Warning: No Insitu files found for input timerange."
  endelse
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Main read loop: IUVS  data   ------------------------------- ;;
  
  
  ;IF ANY IUVS DATA IS REQUESTED & NOT IN INSITU ONLY MODE
  if not keyword_set(insitu_only) and (instruments.periapse or instruments.c_e_disk or instruments.c_e_limb or instruments.c_e_high or $
                                      instruments.apoapse  or instruments.c_l_disk or instruments.c_l_limb or instruments.c_l_high or $ 
                                      instruments.stellarocc) then begin
    iuvs_index=0
    if iuvs_filenames[0] ne 'None' then begin
    
      ;; Loop through each file
      for file=0,n_elements(iuvs_filenames)-1 do begin
      
        MVN_KP_LOOP_PROGRESS,file,0,n_elements(iuvs_filenames)-1,message='IUVS KP File Read Progress'
        
        ;; Construct path to file
        date_path = mvn_kp_date_subdir(iuvs_filenames[file])
        fileAndPath = kp_iuvs_data_directory+date_path+iuvs_filenames[file]
        
        MVN_KP_READ_IUVS_FILE, fileAndPath, iuvs_record, begin_time=begin_time_struct, end_time=end_time_struct, $
          instruments=instruments, save_files=save_files, text_files=text_files
          
        ;; If iuvs_record not eq -1 (Indicating some observation within time range) add to temp array
        if size(iuvs_record, /type) eq 8 then begin
          ;; Add single iuvs_record to array of iuvs records
          iuvs_data_temp[iuvs_index] = iuvs_record
          iuvs_index++
        endif
        
      endfor

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
  
end
