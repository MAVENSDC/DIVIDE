;; CDF Generation of insitu
;;
;
;; Infiles : Input array of files with paths of insitu save files to convert to cdf files
;;
;; Outdir : Output path where created cdf files should go.
;;
;; Currently only reating from Save files.


pro mvn_kp_insitu_cdf_write, infiles, outpath,  savefiles=savefiles, debug=debug

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

  ;PATH TO MASTER CDF FILE, NECESSARY FOR cdf_load_vars TO WORK.
  cdf_tools_result = routine_info('mvn_kp_insitu_cdf_write',/source)
  cdf_tools_directory = strsplit(cdf_tools_result.path,'mvn_kp_insitu_cdf_write.pro',/extract,/regex)
  masterCDF = cdf_tools_directory+'/mvn_kp_insitu_master.cdf'

  
  ;LOOP THROUGH ALL INPUT FILES AND CREATE A CDF VERSION OF EACH IN THE OUTPATH
  foreach file , infiles do begin
    
    ;; Read in insitu data from either textfile or savefile 
    if not keyword_set(savefiles) then begin
      base = file_basename(file, '.txt')
      MVN_KP_READ_INSITU_FILE, file, insitu, /textfiles
    endif else begin
      base = file_basename(file, '.sav')
      MVN_KP_READ_INSITU_FILE, file, insitu, /savefiles
    endelse
    
    
    ;; Top level data
    time        = insitu.time
    time_string = insitu.time_string
    orbit       = insitu.orbit
    io_bound    = insitu.io_bound
    
    ;; Instruments
    ngims      = insitu.ngims
    sep        = insitu.sep
    mag        = insitu.mag
    swea       = insitu.swea
    swia       = insitu.swia
    static     = insitu.static
    lpw        = insitu.lpw
    spacecraft = insitu.spacecraft
    app        = insitu.app


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
    ptr = PTR_NEW(orbit)
    cdfi_insitu.vars[2].dataptr = ptr
    ptr = PTR_NEW(io_bound)
    cdfi_insitu.vars[3].dataptr = ptr
    
    
    ;; Loop through varialbes, create a pointer to a (copy) of a paramter
    j=4
    NV=n_tags(lpw)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(lpw.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(static)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(static.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(swia)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(swia.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(swea)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(swea.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(mag)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(mag.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(sep)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(sep.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(ngims)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(ngims.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(spacecraft)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(spacecraft.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    
    NV=n_tags(app)
    for i=0, NV-1 Do begin
      ptr = PTR_NEW(app.(i))
      
      ;; Point cdfi_insitu.vars pointer to new copied memory of variable array
      cdfi_insitu.vars[j].dataptr = ptr
      j++
    endfor
    

    ; Now actually write output CDF file containing all data.
    dummy = mvn_kp_cdf_save_vars(cdfi_insitu,outpath+'/'+base+'.cdf')
    
    ;; Release insitu
    insitu=0
    
  endforeach
  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
end
