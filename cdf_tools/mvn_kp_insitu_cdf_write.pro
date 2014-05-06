;; CDF Generation of insitu from ascii files
;;
;
;; infiles : Input array of insitu ascii file(s) (and paths) to convert to cdf files
;;
;; outpath : Output path where created cdf files should go.
;;
;;


pro mvn_kp_insitu_cdf_write, infiles, outpath


  
  ;PATH TO MASTER CDF FILE, NECESSARY FOR cdf_load_vars TO WORK.
  cdf_tools_result = routine_info('mvn_kp_insitu_cdf_write',/source)
  cdf_tools_directory = strsplit(cdf_tools_result.path,'mvn_kp_insitu_cdf_write.pro',/extract,/regex)
  masterCDF = cdf_tools_directory+'/mvn_kp_insitu_master.cdf'

  
  foreach file , infiles do begin
    
    ; =============================================================================================
    ;; Read in insitu data from textfile
    ;; Init array of insitu structures big enough for one file
    ; =============================================================================================
    MVN_KP_INSITU_STRUCT_INIT, insitu_record, instruments=instruments
    insitu_data_temp = replicate(insitu_record,21600L)
    index=0L
    
    ;OPEN THE KP DATA FILE
    openr,ascii_file_lun,file,/get_lun
    print, "Reading in file: "+string(file)
    
    ;; Read in a line at a time
    while not eof(ascii_file_lun) do begin
      temp = ''
      readf,ascii_file_lun,temp
      data = strsplit(temp,' ',/extract)
      if data[0] ne '#' then begin
      
        ; TEMPLATE STRUCTURE TO READ DATA INTO
        orbit = {time_string:'', time: 0.0, orbit:0L, IO_bound:'', data:fltarr(211)}
                
        ;READ IN AND INIT TEMP STRUCTURE OF DATA
        orbit.time_string = data[0]
        orbit.time = time_double(data[0], tformat='YYYY-MM-DDThh:mm:ss')
        orbit.orbit = data[194]
        orbit.IO_bound = data[195]
        
        ;; Disclude data[0], data[194], data[195] - Strings won't go in data arry nicely,
        ;; and we've extracted these three points just above into the top level structure.
        orbit.data[1:193] = data[1:193]
        orbit.data[196:210] = data[196:210]
        
        MVN_KP_INSITU_ASSIGN, insitu_record, orbit, instruments
        insitu_data_temp[index] = insitu_record
        index++

      endif
    endwhile
    
    ;; Copy range of insitu_data_temp that was filled with data from file
    insitu_data = insitu_data_temp[0:index-1]
    
    free_lun,ascii_file_lun
    

    ; =============================================================================================
    ;; Split up data by instrument/catagory
    ; =============================================================================================
    ; 
    ;; Top level data
    time        = insitu_data.time
    time_string = insitu_data.time_string
    orbit       = insitu_data.orbit
    io_bound    = insitu_data.io_bound
    
    ;; Instruments/catagory
    ngims      = insitu_data.ngims
    sep        = insitu_data.sep
    mag        = insitu_data.mag
    swea       = insitu_data.swea
    swia       = insitu_data.swia
    static     = insitu_data.static
    lpw        = insitu_data.lpw
    spacecraft = insitu_data.spacecraft
    app        = insitu_data.app
    
    
    ;; Instrument index ranges in CDF file
    lpw_start = 2
    lpw_end   = 22 
       
    swea_start = 23
    swea_end   = 40   
     
    swia_start = 41
    swia_end   = 52
    
    static_start = 53
    static_end   = 99
    
    sep_start = 100
    sep_end   = 127
    
    mag_start = 128
    mag_end   = 141
    
    ngims_start = 142
    ngims_end   = 171
    
    spacecraft_part1_start = 172
    spacecraft_part1_end   = 188
    
    app_start = 189
    app_end   = 194
    
    orbit_number_index = 195
    io_bound_index     = 196
    
    spacecraft_part2_start = 197
    spacecraft_part2_end   = 211
    
    
    ; =============================================================================================
    ;; Load master skeleton, and proceed to fill in each vars[] dataptr
    ; =============================================================================================
    
    ;; Load CDF Master file (empty) that we will fill in
    cdfi_insitu=0
    cdfi_insitu = cdf_load_vars(masterCDF, /ALL)
    
    ;; Set top level variables
    mvn_kp_time_split_string, time_string, year=yr, month=mo, day=dy, hour=hr, min=min, sec=sec, /FIX
    cdf_tt2000, tt2000_time, yr, mo, dy, hr, min, sec, /COMPUTE_EPOCH
    ptr = PTR_NEW(tt2000_time)
    cdfi_insitu.vars[0].dataptr = ptr
    
    ptr = PTR_NEW(time_string)
    cdfi_insitu.vars[1].dataptr = ptr

    
    ;; LPW
    ;; --------------------------------
    NV=n_tags(lpw)
    if (lpw_end-lpw_start ne NV-1) then message, "Discprenecy between number of LPW variables and LPW index range"
    
    j=0
    for i=lpw_start, lpw_end Do begin
      ptr = PTR_NEW(lpw.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor
    
    
    ;; SWEA
    ;; --------------------------------
    NV=n_tags(swea)
    if (swea_end-swea_start ne NV-1) then message, "Discprenecy between number of SWEA variables and SWEA index range"
    
    j=0
    for i=swea_start, swea_end Do begin
      ptr = PTR_NEW(swea.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor

    
    ;; SWIA
    ;; --------------------------------
    NV=n_tags(swia)
    if (swia_end-swia_start ne NV-1) then message, "Discprenecy between number of SWIA variables and SWIA index range"
    
    j=0
    for i=swia_start, swia_end Do begin
      ptr = PTR_NEW(swia.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor
    
    
    ;; STATIC
    ;; --------------------------------
    NV=n_tags(static)
    if (static_end-static_start ne NV-1) then message, "Discprenecy between number of STATIC variables and STATIC index range"
    
    j=0
    for i=static_start, static_end Do begin
      ptr = PTR_NEW(static.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor


    ;; SEP
    ;; --------------------------------
    NV=n_tags(sep)
    if (sep_end-sep_start ne NV-1) then message, "Discprenecy between number of SEP variables and SEP index range"
    
    j=0
    for i=sep_start, sep_end Do begin
      ptr = PTR_NEW(sep.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor
    
    
    ;; MAG
    ;; --------------------------------
    NV=n_tags(mag)
    if (mag_end-mag_start ne NV-1) then message, "Discprenecy between number of MAG variables and MAG index range"
    
    j=0
    for i=mag_start, mag_end Do begin
      ptr = PTR_NEW(mag.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor
   
   
    ;; NGIMS
    ;; --------------------------------
    NV=n_tags(ngims)
    if (ngims_end-ngims_start ne NV-1) then message, "Discprenecy between number of NGIMS variables and NGIMS index range"
    
    j=0
    for i=ngims_start, ngims_end Do begin
      ptr = PTR_NEW(ngims.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor
    
     
    ;; Spacecraft data - split into two parts because APP data in the middle of spacecraft data
    ;; --------------------------------
    NV=n_tags(spacecraft)
    if ((spacecraft_part1_end-spacecraft_part1_start)+(spacecraft_part2_end-spacecraft_part2_start) ne NV-2) then $
      message, "Discprenecy between number of SPACECRAFT variables and SPACECRAFT index range"
    
    spacecraft_j=0
    for i=spacecraft_part1_start, spacecraft_part1_end Do begin
      ptr = PTR_NEW(spacecraft.(spacecraft_j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      spacecraft_j++
    endfor
    for i=spacecraft_part2_start, spacecraft_part2_end Do begin
      ptr = PTR_NEW(spacecraft.(spacecraft_j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      spacecraft_j++
    endfor

    
    ;; APP
    ;; --------------------------------
    NV=n_tags(app)
    if (app_end-app_start ne NV-1) then message, "Discprenecy between number of APP variables and APP index range"
    
    j=0
    for i=app_start, app_end Do begin
      ptr = PTR_NEW(app.(j))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[i].dataptr = ptr
      j++
    endfor


    ;; Orbit number & IO_Bound fields 
    ;; --------------------------------
    ptr = PTR_NEW(orbit)
    cdfi_insitu.vars[orbit_number_index].dataptr = ptr
    ptr = PTR_NEW(io_bound)
    cdfi_insitu.vars[io_bound_index].dataptr = ptr
    
    
    
    
    ; Now actually write output CDF file containing all data.
    base = file_basename(file, '.txt')
    dummy = mvn_kp_cdf_save_vars(cdfi_insitu,outpath+'/'+base+'.cdf')
    
    ;; Release insitu_data
    insitu_data=0
    
  endforeach
  
  
end
