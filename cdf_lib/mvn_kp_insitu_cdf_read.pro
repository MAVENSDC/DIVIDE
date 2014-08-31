;; Read in a CDF file of insitu data

pro mvn_kp_insitu_cdf_read, insitu, infiles, instruments=instruments

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif

  
  lpw_start              = 2   ;  lpw_end                = 16
  euv_start              = 17  ;  euv_end                = 22
  swea_start             = 23  ;  swea_end               = 40
  swia_start             = 41  ;  swia_end               = 52
  static_start           = 53  ;  static_end             = 99
  sep_start              = 100 ;  sep_end                = 127
  mag_start              = 128 ;  mag_end                = 141
  ngims_start            = 142 ;  ngims_end              = 171
  spacecraft_part1_start = 172 ;  spacecraft_part1_end   = 188
  app_start              = 189 ;  app_end                = 194
  orbit_number_index     = 195
  io_bound_index         = 196
  spacecraft_part2_start = 197 ;  spacecraft_part2_end   = 211
  
  
  lpw_total              = 15
  euv_total              = 6
  static_total           = 47
  swia_total             = 12
  swea_total             = 18
  mag_total              = 14
  sep_total              = 28
  ngims_total            = 30
  spacecraft_part1_total = 17
  spacecraft_total       = 32
  app_total              = 6
  
   ;; Cannot init empty array in IDL before version 8
  insitu = 'hack' 
  
  
  ;;FOR EAC FILE INPUT, READ INTO MEMORY
  foreach file , infiles do begin

    ;; Release insitu array and cdfi_insitu array
    cdfi_insitu=0
    kp_data=0
    
    ;; Load CDF data file
    cdfi_insitu = cdf_load_vars(file, /ALL)
    
    ;; Create array of insitu records with the # of variables
    NV=(size(*cdfi_insitu.vars[1].dataptr))[1]
    
    
    MVN_KP_INSITU_STRUCT_INIT, insitu_record, instruments=instruments
    kp_data = replicate(insitu_record,NV)
    
    ;; Top level data
    ;; time_tt2000      = *cdfi_insitu.vars[0].dataptr      ;; Ignore vars[0].
    kp_data.time        = time_double(*cdfi_insitu.vars[1].dataptr, tformat='YYYY-MM-DDThh:mm:ss')
    kp_data.time_string = *cdfi_insitu.vars[1].dataptr
    kp_data.orbit       = *cdfi_insitu.vars[orbit_number_index].dataptr
    kp_data.io_bound    = *cdfi_insitu.vars[io_bound_index].dataptr
    

    ;; Read in LPW data
    if instruments.lpw eq 1 then begin
      j = lpw_start    
      for i=0, lpw_total-1 do begin
        kp_data.lpw.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif
    
    ;; Read in EUV data
    if instruments.euv eq 1 then begin
      j = euv_start
      for i=0, euv_total-1 do begin
        kp_data.euv.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif

    ;; Read in STATIC data
    if instruments.static eq 1 then begin
      j = static_start
      for i=0, static_total-1 do begin
        kp_data.static.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif

    ;; Read in SWIA data
    if instruments.swia eq 1 then begin
      j = swia_start
      for i=0, swia_total-1 do begin
        kp_data.swia.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif
     
        ;; Read in SWEA data 
    if instruments.swea eq 1 then begin  
      j = swea_start
      for i=0, swea_total-1 do begin
        kp_data.swea.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif
  
     ;; Read in MAG data
     if instruments.mag eq 1 then begin 
      j = mag_start
      for i=0, mag_total-1 do begin
        kp_data.mag.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif
  
    ;; Read in SEP data  
    if instruments.sep eq 1 then begin  
      j = sep_start
      for i = 0, sep_total-1 do begin
        kp_data.sep.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif
 
    ;; Read in NGIMS data
    if instruments.ngims eq 1 then begin  
      j = ngims_start
      for i=0, ngims_total-1 do begin
        kp_data.ngims.(i) = *cdfi_insitu.vars[j].dataptr
        j++
      endfor
    endif
    
    ;; Always read in SPACECRAFT data - (split into two parts because APP in middle)
    j = spacecraft_part1_start
    for i=0, spacecraft_part1_total-1 do begin
      kp_data.spacecraft.(i) = *cdfi_insitu.vars[j].dataptr
      j++
    endfor
    
    j = spacecraft_part2_start
    for i=i, spacecraft_total-1 do begin
      kp_data.spacecraft.(i) = *cdfi_insitu.vars[j].dataptr
      j++
    endfor

    ;; Always read in APP data
    j = app_start
    for i=0, app_total-1 do begin
      kp_data.app.(i) = *cdfi_insitu.vars[j].dataptr
      j++
    endfor


    ;; If insitu is a string, 'hack', then this is the first pass through loop
    if size(insitu, /TYPE) eq 7 then begin
      ;IDL doesn't allow empty arrays before version 8.
      insitu = kp_data
    endif else begin
      ;; Append kp_data into insitu output structure
      insitu = [insitu, kp_data]
    endelse
    
  endforeach
  
end
