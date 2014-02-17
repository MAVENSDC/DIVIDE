;;
;; CDF Generation of IUVS data
;;
;; Infiles : Input array of files with paths of iuvs save files to convert to cdf files
;;
;; Outdir : Output path where created cdf files should go.
;;
;; FIXME - Needs better header
;;

pro mvn_kp_iuvs_cdf_write, infiles, outpath

  ;PATH TO MASTER CDF FILE, NECESSARY FOR cdf_load_vars TO WORK.
  cdf_tools_result = routine_info('mvn_kp_iuvs_cdf_write',/source)
  cdf_tools_directory = strsplit(cdf_tools_result.path,'mvn_kp_iuvs_cdf_write.pro',/extract,/regex)
  masterCDFlores   = cdf_tools_directory+'/mvn_kp_iuvs_lores_master.cdf'    
  masterCDFechelle = cdf_tools_directory+'/mvn_kp_iuvs_echelle_master.cdf'  
  
  ;; Global that defines the number of common variables amongst all observation modes
  N_common = 23

  ;LOOP THROUGH ALL INPUT FILES AND CREATE A CDF VERSION OF EACH IN THE OUTPATH
  foreach file , infiles do begin
  
    ;; Strip out the date from input filenames.
    base = file_basename(file, '.sav')                    ;; FIXME - Currently only works with save files.
    
    ;; Output file
    outcdffile = outpath+'/'+base+'.cdf'
    
    ;; Read the file into an iuvs structure in memory
    mvn_kp_read_iuvs_file, file, iuvs, /savefiles
    
    iuvs_cut = iuvs[0]                ;; FIXME, I don't think this is necessary anymore because mvn_kp_read_iuvs_file should only return one item.
    ;; Release insitu and iuvs
    insitu=0
    iuvs=0

    ;; Seperate all observation mode substructures
    periapse1 = iuvs_cut.periapse[0]
    periapse2 = iuvs_cut.periapse[1]
    periapse3 = iuvs_cut.periapse[2]
    c_e_disk  = iuvs_cut.CORONA_E_DISK
    c_e_limb  = iuvs_cut.CORONA_E_LIMB
    c_e_high  = iuvs_cut.CORONA_E_HIGH
    c_l_disk  = iuvs_cut.CORONA_LO_DISK
    c_l_limb  = iuvs_cut.CORONA_LO_LIMB
    c_l_high  = iuvs_cut.CORONA_LO_HIGH
    apoapse   = iuvs_cut.APOAPSE
    
    
    ;; Determine mode of this observation (echelle or lores)
    if strlen(c_e_limb.time_start) ne 0 then begin
      file_mode = 'echelle'
    endif else if strlen(c_l_limb.time_start) ne 0 then begin
      file_mode = 'lores'
    endif else begin
      message, 'Problem with IUVS file mode. Can not determine if echelle or lores mode for cdf creation'
    endelse
    
    
    if file_mode eq 'echelle' then begin

      ;; Load CDF Master file (empty) that we will fill in
      cdfi_p = cdf_load_vars(masterCDFechelle, /ALL)
      
      ;; Set time variable and obs mode
      ptr = PTR_NEW([0]) ; FIXME
      cdfi_p.vars[0].dataptr = ptr
      ptr = PTR_NEW(["periapse1", "periapse2", "periapse3", "c_e_disk", "c_e_limb", "c_e_high", "apoapse"])
      cdfi_p.vars[1].dataptr = ptr
      
      ptr = PTR_NEW([periapse1.time_start, periapse2.time_start, periapse3.time_start, $
                     c_e_disk.time_start, c_e_limb.time_start, c_e_high.time_start, apoapse.time_start])
      cdfi_p.vars[2].dataptr = ptr
      ptr = PTR_NEW([periapse1.time_stop, periapse2.time_stop, periapse3.time_stop, $
                     c_e_disk.time_stop, c_e_limb.time_stop, c_e_high.time_stop, apoapse.time_stop])
      cdfi_p.vars[3].dataptr = ptr
      
      
      ;; Index for traversing through the cdfi_p structure
      cdfi_index = 4
      
      ;; Create arrays of common data
      for i=2, N_common-1 Do begin
        ptr = PTR_NEW([[periapse1.(i)], [periapse2.(i)], [periapse3.(i)], $
                       [c_e_disk.(i)], [c_e_limb.(i)], [c_e_high.(i)], [apoapse.(i)]])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
         
      
      ;; Create and add arrays of periapse1, periapse2, periapse3 data
      last_index=n_tags(periapse1)
      for i=N_common, last_index-1 Do begin
        ;; Depending on dimension, need to creat ptr array differently
        if (size(periapse1.(i)))[0] le 1 then begin
          ptr = PTR_NEW([[periapse1.(i)], [periapse2.(i)], [periapse3.(i)]])
        endif else begin
          ptr = PTR_NEW([[[periapse1.(i)]], [[periapse2.(i)]], [[periapse3.(i)]]])
        endelse
        
        ;
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of c_e_disk data
      last_index = n_tags(c_e_disk)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([c_e_disk.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of C_E_limb data
      last_index = n_tags(c_e_limb)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([c_e_limb.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of C_E_high data
      last_index = n_tags(c_e_high)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([c_e_high.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of apoapse data
      last_index = n_tags(apoapse)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([apoapse.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      
      
    endif else if file_mode eq 'lores' then begin
      
      ;; Load CDF Master file (empty) that we will fill in
      cdfi_p = cdf_load_vars(masterCDFlores, /ALL)
      
      ;; Set time variable and obs mode
      ptr = PTR_NEW([0]) ; FIXME
      cdfi_p.vars[0].dataptr = ptr
      ptr = PTR_NEW(["periapse1", "periapse2", "periapse3", "c_l_disk", "c_l_limb", "c_l_high", "apoapse"])
      cdfi_p.vars[1].dataptr = ptr
      
      ptr = PTR_NEW([periapse1.time_start, periapse2.time_start, periapse3.time_start, $
                     c_l_disk.time_start, c_l_limb.time_start, c_l_high.time_start, apoapse.time_start])
      cdfi_p.vars[2].dataptr = ptr
      ptr = PTR_NEW([periapse1.time_stop, periapse2.time_stop, periapse3.time_stop, $
                     c_l_disk.time_stop, c_l_limb.time_stop, c_l_high.time_stop, apoapse.time_stop])
      cdfi_p.vars[3].dataptr = ptr
      
      
      ;; Index for traversing through the cdfi_p structure
      cdfi_index = 4
      
      ;; Create arrays of common data
      for i=2, N_common-1 Do begin
        ptr = PTR_NEW([[periapse1.(i)], [periapse2.(i)], [periapse3.(i)], $
                       [c_l_disk.(i)], [c_l_limb.(i)], [c_l_high.(i)], [apoapse.(i)]])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of periapse1, periapse2, periapse3 data
      last_index=n_tags(periapse1)
      for i=N_common, last_index-1 Do begin
        ;; Depending on dimension, need to creat ptr array differently
        if (size(periapse1.(i)))[0] le 1 then begin
          ptr = PTR_NEW([[periapse1.(i)], [periapse2.(i)], [periapse3.(i)]])
        endif else begin
          ptr = PTR_NEW([[[periapse1.(i)]], [[periapse2.(i)]], [[periapse3.(i)]]])
        endelse
        ;
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of c_l_disk data
      last_index = n_tags(c_l_disk)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([c_l_disk.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of c_l_limb data
      last_index = n_tags(c_l_limb)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([c_l_limb.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of c_l_high data
      last_index = n_tags(c_l_high)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([c_l_high.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
      ;; Create and add arrays of apoapse data
      last_index = n_tags(apoapse)
      for i=N_common, last_index-1 Do begin
        ptr = PTR_NEW([apoapse.(i)])
        
        ;; Point Cdfi pointer to new copied memory of variable
        cdfi_p.vars[cdfi_index].dataptr = ptr
        cdfi_index++
      endfor
      
    endif
    
    
    ;;Write CDF
    dummy = mvn_kp_cdf_save_vars(cdfi_p, outcdffile)
    

  endforeach
  
  
end