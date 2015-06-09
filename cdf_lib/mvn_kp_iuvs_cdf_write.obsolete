;;
;; CDF Generation of IUVS data
;;
;; Infiles : Input array of files with paths of iuvs save files to 
;;           convert to cdf files
;;
;; Outdir : Output path where created cdf files should go.
;;
;; FIXME - Needs better header
;;

pro mvn_kp_iuvs_cdf_write, infiles, outpath, save_files=save_files, $
                           debug=debug

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
  cdf_tools_result = routine_info('mvn_kp_iuvs_cdf_write',/source)
  cdf_tools_directory = strsplit(cdf_tools_result.path,$
                                 'mvn_kp_iuvs_cdf_write.pro',/extract,/regex)
  masterCDFlores   = cdf_tools_directory+'/mvn_kp_iuvs_lores_master.cdf'    
  masterCDFechelle = cdf_tools_directory+'/mvn_kp_iuvs_echelle_master.cdf'  
  
  ;; Global that defines the number of common variables among all 
  ;; observation modes
  iuvs_data_spec = mvn_kp_config(/iuvs_data)
  N_common = iuvs_data_spec.num_common

  ;LOOP THROUGH ALL INPUT FILES AND CREATE A CDF VERSION OF EACH IN THE OUTPATH
  foreach file , infiles do begin
  
    ;; If keyword set save_files, read in save_files, 
    ;;  otherwise read in text_files
    if not keyword_set(save_files) then begin
      ;; Strip out the date from input filenames.
      base = file_basename(file, '.tab')
      ;; Read the file into an iuvs structure in memory
      mvn_kp_read_iuvs_file, file, iuvs, /text_files
    endif else begin
      ;; Strip out the date from input filenames.
      base = file_basename(file, '.sav')
      ;; Read the file into an iuvs structure in memory
      mvn_kp_read_iuvs_file, file, iuvs, /save_files
    endelse
    ;; Output file
    outcdffile = outpath+'/'+base+'.cdf'
    
    
    iuvs_cut = iuvs[0] ;; FIXME, I don't think this is necessary anymore 
                       ;;  because mvn_kp_read_iuvs_file should only 
                       ;;  return one item.
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

; Unsure whether this is a hack.  Extending the check over all echelle 
; and all limb possibilities.  Presumably periapse and apoapse
;  get colleted regardless?
;
    if strlen(c_e_limb.time_start) ne 0 or $
       strlen(c_e_disk.time_start) ne 0 or $
       strlen(c_e_high.time_start) ne 0 then begin
       file_mode = 'echelle'
    endif else if strlen(c_l_limb.time_start) ne 0 or $
                  strlen(c_l_disk.time_start) ne 0 or $
                  strlen(c_l_high.time_start) ne 0 then begin
       file_mode = 'lores'
    endif else begin
      message, 'Problem with IUVS file mode. Can not determine if ' $
        +'echelle or lores mode for cdf creation'
    endelse
      
;-orig
;    if strlen(c_e_limb.time_start) ne 0 then begin
;      file_mode = 'echelle'
;    endif else if strlen(c_l_limb.time_start) ne 0 then begin
;      file_mode = 'lores'
;    endif else begin
;      message, 'Problem with IUVS file mode. Can not determine if ' $
;              +'echelle or lores mode for cdf creation'
;    endelse
;-/orig    
    
    if file_mode eq 'echelle' then begin

      ;; Load CDF Master file (empty) that we will fill in
      cdfi_p = cdf_load_vars(masterCDFechelle, /ALL)

      ;; Set time variable and obs mode
      mvn_kp_time_split_string, periapse1.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, periapse1_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, periapse2.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, periapse2_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, periapse3.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, periapse3_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, c_e_disk.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, c_e_disk_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, c_e_limb.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, c_e_limb_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, c_e_high.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, c_e_high_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, apoapse.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, apoapse_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      
      ;; Fill var[0] with tt2000 version of time_start 
      ptr = PTR_NEW([periapse1_tt2000_start, periapse2_tt2000_start, $
                     periapse3_tt2000_start, c_e_disk_tt2000_start, $
                     c_e_limb_tt2000_start, c_e_high_tt2000_start, $
                     apoapse_tt2000_start])

      cdfi_p.vars[0].dataptr = ptr 
      
      ;; Set time variables and obs mode
      ptr = PTR_NEW(["periapse1", "periapse2", "periapse3", $
                     "Corona Echelle disk", "Corona Echelle limb", $
                     "Corona Echelle high", "apoapse"])
      cdfi_p.vars[1].dataptr = ptr
          
      ptr = PTR_NEW([periapse1.time_start, periapse2.time_start, $
                     periapse3.time_start, c_e_disk.time_start, $
                     c_e_limb.time_start, c_e_high.time_start, $
                     apoapse.time_start])
      cdfi_p.vars[2].dataptr = ptr
      ptr = PTR_NEW([periapse1.time_stop, periapse2.time_stop, $
                     periapse3.time_stop, c_e_disk.time_stop, $
                     c_e_limb.time_stop, c_e_high.time_stop, $
                     apoapse.time_stop])
      cdfi_p.vars[3].dataptr = ptr
      
      
      ;; Index for traversing through the cdfi_p structure
      cdfi_index = 4
      
      ;; Create arrays of common data
      for i=2, N_common-1 Do begin
        ptr = PTR_NEW([[periapse1.(i)], [periapse2.(i)], [periapse3.(i)], $
                       [c_e_disk.(i)], [c_e_limb.(i)], [c_e_high.(i)], $
                       [apoapse.(i)]])
        
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
          ptr = PTR_NEW([[[periapse1.(i)]], [[periapse2.(i)]], $
                         [[periapse3.(i)]]])
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
      mvn_kp_time_split_string, periapse1.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, periapse1_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, periapse2.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, periapse2_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      mvn_kp_time_split_string, periapse3.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, periapse3_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
;stop
;-km-hack
; place a check on existence of each sub mode of data
;  should do the same for echelle (if it is needed at all)
;  but since current test data does not include echelle.....
;
;-unhack      if( strlen(c_l_disk.time_start) ne 0 )then begin
        mvn_kp_time_split_string, c_l_disk.time_start, year=yr, month=mo, $
                                  day=dy, hour=hr, min=min, sec=sec, /FIX
        cdf_tt2000, c_l_disk_tt2000_start, yr, mo, dy, hr, min, sec, $
                    /COMPUTE_EPOCH
;-unhack      endif else c_l_disk_tt2000_start = long64(0)
      
;-unhack      if( strlen(c_l_limb.time_start) ne 0)then begin
        mvn_kp_time_split_string, c_l_limb.time_start, year=yr, month=mo, $
                                  day=dy, hour=hr, min=min, sec=sec, /FIX
        cdf_tt2000, c_l_limb_tt2000_start, yr, mo, dy, hr, min, sec, $
                    /COMPUTE_EPOCH
;-unhack      endif else c_l_limb_tt2000_start = long64(0)
      
;-unhack      if( strlen(c_l_high.time_start) ne 0)then begin
        mvn_kp_time_split_string, c_l_high.time_start, year=yr, month=mo, $
                                  day=dy, hour=hr, min=min, sec=sec, /FIX
        cdf_tt2000, c_l_high_tt2000_start, yr, mo, dy, hr, min, sec, $
                    /COMPUTE_EPOCH
;-unhack      endif else c_l_high_tt2000_start = long64(0)
;-/km-hack
      mvn_kp_time_split_string, apoapse.time_start, year=yr, month=mo, $
                                day=dy, hour=hr, min=min, sec=sec, /FIX
      cdf_tt2000, apoapse_tt2000_start, yr, mo, dy, hr, min, sec, $
                  /COMPUTE_EPOCH
      
      ;; Fill var[0] with tt2000 version of time_start
      ptr = PTR_NEW([periapse1_tt2000_start, periapse2_tt2000_start, $
                     periapse3_tt2000_start, c_l_disk_tt2000_start, $
                     c_l_limb_tt2000_start, c_l_high_tt2000_start, $
                     apoapse_tt2000_start])
      cdfi_p.vars[0].dataptr = ptr
      
      ;; Set time variables and obs mode
      ptr = PTR_NEW(["periapse1", "periapse2", "periapse3", $
                     "Corona Lores disk", "Corona Lores limb", $
                     "Corona Lores high", "apoapse"])
      cdfi_p.vars[1].dataptr = ptr
      
      ptr = PTR_NEW([periapse1.time_start, periapse2.time_start, $
                     periapse3.time_start, c_l_disk.time_start, $
                     c_l_limb.time_start, c_l_high.time_start, $
                     apoapse.time_start])
      cdfi_p.vars[2].dataptr = ptr
      ptr = PTR_NEW([periapse1.time_stop, periapse2.time_stop, $
                     periapse3.time_stop, c_l_disk.time_stop, $
                     c_l_limb.time_stop, c_l_high.time_stop, $
                     apoapse.time_stop])
      cdfi_p.vars[3].dataptr = ptr
      
      
      ;; Index for traversing through the cdfi_p structure
      cdfi_index = 4
      
      ;; Create arrays of common data
      for i=2, N_common-1 Do begin
        ptr = PTR_NEW([[periapse1.(i)], [periapse2.(i)], [periapse3.(i)], $
                       [c_l_disk.(i)], [c_l_limb.(i)], [c_l_high.(i)], $
                       [apoapse.(i)]])
        
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
          ptr = PTR_NEW([[[periapse1.(i)]], [[periapse2.(i)]], $
                         [[periapse3.(i)]]])
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
  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
end
