


  ;; Get list of Insitu Files
function MVN_KP_LOCAL_INSITU_FILES, begin_jul, end_jul, insitu_dir, filename_spec, save_files=save_files, text_files=text_files

  ;; File pattern details
  insitu_pattern     = filename_spec.pattern
  insitu_year_index  = filename_spec.year_index
  insitu_month_index = filename_spec.month_index
  insitu_day_index   = filename_spec.day_index
  
  
  ;SET THE FILENAME PATTERN TO SEARCH THE DIRECTORY FOR    - FIXME Make below more consistent
  ;; Default is CDF format
  if keyword_set(save_files) then begin 
    ext = '.sav'
    insitu_pattern += ext 
  endif else if keyword_set(text_files) then begin
    ext = '.tab'
    insitu_pattern += ext 
  endif else begin
    ext = '.cdf'
    insitu_pattern += ext 
  endelse
  
  ;; - recursive search to look through year/month subdirs
  local_insitu = file_search(insitu_dir+path_sep(),insitu_pattern, count=count)

  if (count gt 0) then begin
    local_insitu_base  = file_basename(local_insitu)
    ;local_times_insitu = strmid(local_insitu_base, 20, 8, /reverse_offset) ;;FIXME - cleaner way to get this part of the string
    
    local_times_insitu_year =  fix(strmid(local_insitu_base, insitu_year_index, 4))
    local_times_insitu_month = fix(strmid(local_insitu_base, insitu_month_index, 2))
    local_times_insitu_day =   fix(strmid(local_insitu_base, insitu_day_index, 2))
     
    local_times_insitu_jul = julday(local_times_insitu_month, local_times_insitu_day, local_times_insitu_year)

    
    ;; Prune List to only be within time range (use floor of begin day, ceiling of end day
    ;; so as not to chop off half days we want)
    ind = where((local_times_insitu_jul ge (floor(begin_jul-.5)+.5)) and (local_times_insitu_jul le (ceil(end_jul-.5)+.5))) ;; FIXME ensure this floor/ceil math is good
    
    if(ind[0] lt 0) then begin
      print, "No local insitu files found in format: "+ext
      return, 'None'
    endif
    
    local_insitu      = local_insitu[ind]
    local_insitu_base = local_insitu_base[ind]
  endif else begin
    local_insitu = 'None'
  endelse

  return, local_insitu
  
end

  ;; Get list of Iuvs files
function MVN_KP_LOCAL_IUVS_FILES, begin_jul, end_jul, iuvs_dir, filename_spec, save_files=save_files, text_files=text_files

  ;; File pattern details 
  iuvs_pattern     = filename_spec.pattern
  iuvs_year_index  = filename_spec.year_index
  iuvs_month_index = filename_spec.month_index
  iuvs_day_index   = filename_spec.day_index
  iuvs_hour_index  = filename_spec.hour_index
  iuvs_min_index   = filename_spec.min_index
  iuvs_sec_index   = filename_spec.sec_index



  ;; SET THE PATTERN FOR THE IUVS KP FILENAME BASED ON THE BEGINNING DATE
  ;; Default is CDF format
  if keyword_set(save_files) then begin
    ext = '.sav' 
    iuvs_pattern += ext
  endif else if keyword_set(text_files) then begin
    ext = '.tab'
    iuvs_pattern += ext 
  endif else begin
    ext = '.cdf'
    iuvs_pattern += ext 
  endelse
 
  ;; - recursive search to look through year/month subdirs
  local_iuvs = file_search(iuvs_dir+path_sep(), iuvs_pattern, count=count)
  if (count gt 0) then begin
    local_iuvs_base = file_basename(local_iuvs)
    
    tiuvs_year  = fix(strmid(local_iuvs_base, iuvs_year_index,  4))
    tiuvs_month = fix(strmid(local_iuvs_base, iuvs_month_index,  2))
    tiuvs_day   = fix(strmid(local_iuvs_base, iuvs_day_index,  2))
    tiuvs_hour  = fix(strmid(local_iuvs_base, iuvs_hour_index,  2))
    tiuvs_min   = fix(strmid(local_iuvs_base, iuvs_min_index, 2))
    tiuvs_sec   = fix(strmid(local_iuvs_base, iuvs_sec_index, 2))
    
    times_iuvs_jul = julday(tiuvs_month,tiuvs_day,tiuvs_year,tiuvs_hour,tiuvs_min,tiuvs_sec)

    ;; Prune list to only be within time range (use ceiling of end day so as not to chop off
    ;; data we may want)
    ind = where((times_iuvs_jul ge begin_jul) and (times_iuvs_jul le (ceil(end_jul-.5)+.5)))
    if (ind[0] lt 0) then begin
      print, "No local IUVS files found in format: "+ext
      return, 'None'
    endif

    ;; Always want to check one orbit file earlier for observations that may be within
    ;; the input time range
    if ind[0] ne 0 then ind = [ind[0]-1, ind]
    
    local_iuvs      = local_iuvs[ind]
    local_iuvs_base = local_iuvs_base[ind]
  endif else begin
    local_iuvs = 'None'
  endelse
  
  return, local_iuvs
end


;;
;; Functiont that takes in a list of filenames, and returns the list of filenames
;; with only the latest (by version & revision) version of each file.
;;
function MVN_KP_LATEST_VERSION_FILE, in_files, vpos, rpos
  ;; Copy input
  files = in_files  
  
  ;; If only one file, it is the latest version
  if n_elements(files) le 1 then return, files
  
  versions  = intarr(n_elements(files))
  revisions = intarr(n_elements(files))
  
  i = 0
  foreach file, files do begin
    split_suffix = strsplit(file, '.', /extract)
    split = strsplit(split_suffix[0], '_', /extract)
    
    ;; If filename split up has less than 7 items, there is a problem
    if (n_elements(split) lt rpos) then return, -1
    
    versions[i]  = strmid(split[vpos], 1) ; strip off leading v
    revisions[i] = strmid(split[rpos], 1) ; strip off leading r
    i++
  endforeach
  
  ;; Find max version and discard others
  
;; HACK HACK HACK
;; km
;; Due to changes in in-situ KP file stricture in v02, reader code will fail
;;  because the hard-wired default structure will not match the data.
;;  We are ignoring this until after the workshop.  But since the data have
;;  been released, we need to accommodate.  Check the version number.
;;  In version 1.03, we will force reading of the v01 data; in version 1.04
;;  we will re-enable reading of the most recent data.
;; Ultimately, this hack will be removed entirely.
;;
  mvn_kp_version,version=divide_version
  max_v = ( divide_version lt 1.04 ) $
        ? where(versions eq (max(versions)<1)) $
        : where(versions eq max(versions))
;-old-code max_v = where( versions eq max(versions) )
;; END HACK

  revisions = revisions[max_v]
  files = files[max_v]
  
  ;; Find max revisio and discard others
  max_r = where(revisions eq max(revisions))
  files = files[max_r]
  
  ;; If more than one remaining, we assume they are duplicates, return first
  if (n_elements(files) gt 1) then files = files[0]
  
  return, files
end


function MVN_KP_LATEST_VERSIONS, in_files, filename_spec
  ; Prune out files that have multiple coppies, but just different versions/revisoinos
  ; leave the highest version, then revision
  
  vpos=filename_spec.vpos
  rpos=filename_spec.rpos   ;: FIXME Don't need this part, replace variables below
  basetrim=filename_spec.basetrim
  
  
  basenames=file_basename(in_files)
  base_trim=strmid(basenames,0,basetrim)
  uniq_base_trim = base_trim[uniq(base_trim)]
  latest_files = strarr(1)
  j=0

  foreach trim, uniq_base_trim do begin
    candidates = basenames[where(strmatch(basenames, trim+"*", /fold_case) eq 1)]
    final = MVN_KP_LATEST_VERSION_FILE(candidates, vpos, rpos)
    
    ;; If final is not a string, there has been a problem
    if (size(final, /type) ne 7) then begin
      message, "Problem with filenames in mvn_kp_latest_version_file"
    endif
    
    ;;Ignore version 0 files
    if (strmid(final,basetrim+2,2) ne '00') then begin
      if (j eq 0) then begin
        latest_files = final
        j++        
      endif else begin
        latest_files = [latest_files, final]
      endelse
    endif

  endforeach

  return, latest_files
end


;+
; A routine to produce the total number and names of the KP files that will be read/searched
;
; :Params:
;    begin_time : in, required, type="string"
;       The time to begin the read/search procedure
;    end_time : in, required, type="string"
;       The time to end the read/search procedure
;    file_count : out, required, type="integer"
;       A returned variable holding the total number of KP files to read
;    insitu_filenames : out, required, type="strarr(file_count)"
;       A returned array the holds the names of the relevant INSITU KP files
;    iuvs_filenames: out, required, type="strarr(file_count)"
;       A returned array holding the names of the relevant IUVS KP data files
;    data_dir: in, required, type="string"
;       The directory in which KP data files are held.
;
;    FXIME - HEADER NEEDS TO BE UPDATED
;-

pro MVN_KP_FILE_SEARCH, begin_time, end_time, insitu_filenames, insitu_dir, iuvs_filenames, iuvs_dir, $
  save_files=save_files, text_files=text_files, insitu_only=insitu_only, download_new=download_new
  
  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  

  ;; Globals Describing the filenames and where dates & versions are located
  insitu_filename_spec = mvn_kp_config(/insitu_file_spec)
  iuvs_filename_spec   = mvn_kp_config(/iuvs_file_spec)
  

  ;; Variables containing just the date, not the time
  begin_date = strmid(begin_time.string,0,10)
  end_date   = strmid(end_time.string, 0,10)


  ;; If user wants the SDC server to be queried for udpated files or to fill in files
  ;; needed to complete the time range
  if keyword_set(download_new) then begin
  
  input = ''
  ;Ask user if they want to go to the team site or the public site
  READ, input, PROMPT="Are you a MAVEn team member? (y/n): "
  if (input eq 'y' || input eq 'Y') then begin
    private = 1
  endif else begin
    private = 0
  endelse
  
     ;; If text_files not set, set  cdf_files for call to mvn_kp_download_files
     if not keyword_set(text_files) then cdf_files = 1
  
     ;; Check for insitu files
     if (private) then begin
       mvn_kp_download_files, start_date=begin_date, end_date=end_date, /insitu, /new_files, $
       text_files=text_files, cdf_files=cdf_files, debug=debug, /team  
     endif else begin
       mvn_kp_download_files, start_date=begin_date, end_date=end_date, /insitu, /new_files, $
       text_files=text_files, cdf_files=cdf_files, debug=debug     
     endelse

  
    ;; Check for IUVS files
    if not keyword_set(insitu_only) then begin
      if (private) then begin
        mvn_kp_download_files, start_date=begin_date, end_date=end_date, /iuvs, /new_files, $ 
        text_files=text_files, cdf_files=cdf_files, debug=debug, /team
      endif else begin
        mvn_kp_download_files, start_date=begin_date, end_date=end_date, /iuvs, /new_files, $
        text_files=text_files, cdf_files=cdf_files, debug=debug
      endelse
    endif
  endif


  ;; Get list of files now (some may have been downloaded)
  ;; And trim list to only have highest versions/revisions of each file
  insitu_filenames = MVN_KP_LOCAL_INSITU_FILES(begin_time.Jul, end_time.Jul, insitu_dir, insitu_filename_spec, $
                                               save_files=save_files, text_files=text_files)
  insitu_filenames = MVN_KP_LATEST_VERSIONS(insitu_filenames, insitu_filename_spec) 

  if not keyword_set(insitu_only) then begin
    iuvs_filenames = MVN_KP_LOCAL_IUVS_FILES(begin_time.Jul, end_time.Jul, iuvs_dir, iuvs_filename_spec, $ 
                                             save_files=save_files, text_files=text_files)
    iuvs_filenames = MVN_KP_LATEST_VERSIONS(iuvs_filenames, iuvs_filename_spec)
  endif

end