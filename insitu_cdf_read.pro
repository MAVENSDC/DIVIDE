;; Testing CDF Generation of insitu

pro insitu_cdf_read
  
  inputCDF = 'cdf_work/insitu_out.cdf'
  
  
  ;; Release insitu and iuvs
  insitu=0
  iuvs=0
  
  ;; Load CDF Master file (empty) that we will fill in
  cdfi_insitu = cdf_load_vars(inputCDF, /ALL)
  
  ;; Create array of insitu records with the # of variables
  NV=(size(*cdfi_insitu.vars[1].dataptr))[1]
  instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
  MVN_KP_INSITU_STRUCT_INIT, insitu_record, instrument_array
  kp_data = replicate(insitu_record,NV)
  
  ;; Top level data
  kp_data.time      = *cdfi_insitu.vars[1].dataptr
  kp_data.orbit     = *cdfi_insitu.vars[2].dataptr
  kp_data.io_bound  = *cdfi_insitu.vars[3].dataptr
  stop
  
  ;; Loop through varialbes, create a pointer to a (copy) of a paramter
  ;; Number of variables
  j=4
  numVars=cdfi_insitu.nv
  inst=(strsplit(cdfi_insitu.vars[4].name, /extract, '_'))[0]
  i=0
  while(j lt numVars) do begin

    kp_data.lpw.(i) = *cdfi_insitu.vars[j].dataptr

    i++
    j++
        
    ;; Break out if onto different instrument
    tmpInst = (strsplit(cdfi_insitu.vars[j].name, /extract, '_'))[0]
    if (tmpInst ne inst) then begin
      print, "done"
      inst=tmpInst
      break
    endif
    
  endwhile
  stop

  NV=n_tags(static)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(static.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  NV=n_tags(swia)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(swia.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  NV=n_tags(swea)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(swea.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  NV=n_tags(mag)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(mag.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  NV=n_tags(sep)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(sep.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  NV=n_tags(ngims)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(ngims.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  NV=n_tags(spacecraft)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(spacecraft.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  NV=n_tags(app)
  for i=0, NV-1 Do begin
    ptr = PTR_NEW(app.(i))
    
    ;; Point Cdfi.swia pointer to new copied memory of variable
    cdfi_insitu.vars[j].dataptr = ptr
    j++
  endfor
  
  
  dummy = cdf_save_vars(cdfi_insitu, outputCDF)
  
  
end
