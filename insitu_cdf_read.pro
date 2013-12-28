;; Testing CDF Generation of insitu

pro insitu_cdf_read
  
  all_files = file_search('/Users/martin/repos/data_maven/insitu_cdf/mvn*cdf')
  overall_start_time_cdf = systime(1)


  foreach file , all_files do begin
    
  ;; Release insitu and iuvs
  cdfi_insitu=0
  kp_data=0
  
  ;; Load CDF Master file (empty) that we will fill in
  cdfi_insitu = cdf_load_vars(file, /ALL)
  
  ;; Create array of insitu records with the # of variables
  NV=(size(*cdfi_insitu.vars[1].dataptr))[1]
  instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
  MVN_KP_INSITU_STRUCT_INIT, insitu_record, instrument_array
  kp_data = replicate(insitu_record,NV)
  
  ;; Top level data
  kp_data.time_string = *cdfi_insitu.vars[1].dataptr
  kp_data.time        = *cdfi_insitu.vars[2].dataptr
  kp_data.orbit       = *cdfi_insitu.vars[3].dataptr
  kp_data.io_bound    = *cdfi_insitu.vars[4].dataptr

  
  ;; Loop through varialbes, create a pointer to a (copy) of a paramter
  ;; Number of variables
  j=5
  numVars=cdfi_insitu.nv
  inst=(strsplit(cdfi_insitu.vars[5].name, /extract, '_'))[0]

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

  i=0
  while(j lt numVars) do begin
  
    kp_data.static.(i) = *cdfi_insitu.vars[j].dataptr
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

  i=0
  while(j lt numVars) do begin

    kp_data.swia.(i) = *cdfi_insitu.vars[j].dataptr
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

  i=0
  while(j lt numVars) do begin

    kp_data.swea.(i) = *cdfi_insitu.vars[j].dataptr
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
  
  i=0
  while(j lt numVars) do begin

    kp_data.mag.(i) = *cdfi_insitu.vars[j].dataptr
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
  
   i=0
  while(j lt numVars) do begin

    kp_data.sep.(i) = *cdfi_insitu.vars[j].dataptr
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
  
  i=0
  while(j lt numVars) do begin

    kp_data.ngims.(i) = *cdfi_insitu.vars[j].dataptr
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
  
  
  i=0
  while(j lt numVars) do begin

    kp_data.spacecraft.(i) = *cdfi_insitu.vars[j].dataptr
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
  
  i=0
  while(j lt numVars) do begin

    kp_data.app.(i) = *cdfi_insitu.vars[j].dataptr
    i++
    j++
    ;; Break out if onto different instrument
    ;tmpInst = (strsplit(cdfi_insitu.vars[j].name, /extract, '_'))[0]
    ;if (tmpInst ne inst) then begin
    ;  print, "done"
    ;  inst=tmpInst
    ;  break
   ; endif   
  endwhile
  
endforeach
;TIME TO RUN ROUTINE
overall_end_time_cdf = systime(1)
print,'Your query took ', overall_end_time_cdf - overall_start_time_cdf,' seconds to complete.'


  
end
