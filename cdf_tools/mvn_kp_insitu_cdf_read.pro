;; Testing CDF Generation of insitu

pro mvn_kp_insitu_cdf_read, insitu, infiles, instrument_array=instrument_array, instruments=instruments

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif

  insitu = []  ; Fixme won't work on idl 7
  lpw_start        = 5
  static_start     = 23
  swia_start       = 77
  swea_start       = 89
  mag_start        = 107
  sep_start        = 121
  ngims_start      = 149
  spacecraft_start = 179
  app_start        = 202
  
  lpw_total        = 18
  static_total     = 51
  swia_total       = 12
  swea_total       = 18
  mag_total        = 14
  sep_total        = 28
  ngims_total      = 30
  spacecraft_total = 23
  app_total        = 6
  
  if not keyword_set(instruments) then message, "Need to specify instruments option right now." ;; FIXME 
  
  ;;FOR EAC FILE INPUT, READ INTO MEMORY
  foreach file , infiles do begin

    ;; Release insitu array and cdfi_insitu array
    cdfi_insitu=0
    kp_data=0
    
    ;; Load CDF data file
    cdfi_insitu = cdf_load_vars(file, /ALL)
    
    ;; Create array of insitu records with the # of variables
    NV=(size(*cdfi_insitu.vars[1].dataptr))[1]
    if not keyword_set(instrument_array) then instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    
    
    MVN_KP_INSITU_STRUCT_INIT, insitu_record, instrument_array
    kp_data = replicate(insitu_record,NV)
    
    ;; Top level data
    kp_data.time_string = *cdfi_insitu.vars[1].dataptr
    kp_data.time        = *cdfi_insitu.vars[2].dataptr
    kp_data.orbit       = *cdfi_insitu.vars[3].dataptr
    kp_data.io_bound    = *cdfi_insitu.vars[4].dataptr
    
    
    ;; Read in LPW data
    if instruments.lpw eq 1 then begin
      j = lpw_start    
      for i=0, lpw_total-1 do begin
        kp_data.lpw.(i) = *cdfi_insitu.vars[j].dataptr
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
    
    ;; Always read in SPACECRAFT data
    j = spacecraft_start
    for i=0, spacecraft_total-1 do begin
      kp_data.spacecraft.(i) = *cdfi_insitu.vars[j].dataptr
      j++
    endfor

    ;; Always read in APP data
    j = app_start
    for i=0, app_total-1 do begin
      kp_data.app.(i) = *cdfi_insitu.vars[j].dataptr
      j++
    endfor

    ;; Append kp_data into insitu output structure
    insitu=[insitu, kp_data]
    
  endforeach
  
end
