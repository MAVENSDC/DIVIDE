;; CDF Generation of insitu

pro mvn_insitu_cdf_write, infiles, outpath

  ;PATH TO MASTER CDF FILE, NECESSARY FOR cdf_load_vars TO WORK.
  masterCDF = '/Users/martin/repos/maventoolkit/cdf_work/full_maven_insitu_master.cdf'
  
  
  ;LOOP THROUGH ALL INPUT FILES AND CREATE A CDF VERSION OF EACH IN THE OUTPATH
  foreach file , infiles do begin
  
  
  
    ;; Strip out the date from input filenames.
    base = file_basename(file, '.sav')
    year=strmid(base, 13, 4)
    month=strmid(base, 17, 2)
    day=strmid(base, 19, 2)
    
    ;; Read in data files for exactly 1 day range
    startdate = year+'-'+month+'-'+day+'/00:00:00'
    enddate = year+'-'+month+'-'+day+'/23:59:59'
    mvn_kp_read, [startdate, enddate] , insitu, /binary, /insitu_only
    
    
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
    ptr = PTR_NEW(time_string)
    cdfi_insitu.vars[1].dataptr = ptr
    ptr = PTR_NEW(time)
    cdfi_insitu.vars[2].dataptr = ptr
    ptr = PTR_NEW(orbit)
    cdfi_insitu.vars[3].dataptr = ptr
    ptr = PTR_NEW(io_bound)
    cdfi_insitu.vars[4].dataptr = ptr
    
    
    ;; Loop through varialbes, create a pointer to a (copy) of a paramter
    j=5
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
    dummy = cdf_save_vars(cdfi_insitu,outpath+base+'.cdf')
    
    ;; Release insitu
    insitu=0
    
  endforeach
  
end
