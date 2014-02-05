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
;    binary: in, required, type=boolean
;       A flag that creates filesnames with the binary extension instead of ascii default.
;-


function MVN_KP_LOCAL_INSITU_FILES, begin_jul, end_jul, insitu_dir, binary=binary

  ;; Get list of Insitu Files
  ;SET THE FILENAME PATTERN TO SEARCH THE DIRECTORY FOR    - FIXME Make below more consistent
  insitu_pattern = 'mvn_KP_l2_pf*'
  if keyword_set(binary) then insitu_pattern += '.sav' else file_pattern += '.txt'
  
  local_insitu = file_search(insitu_dir, insitu_pattern, count=count)
  if (count gt 0) then begin
    local_insitu_base  = file_basename(local_insitu)
    local_times_insitu = strmid(local_insitu_base, 20, 8, /reverse_offset) ;;FIXME - cleaner way to get this part of the string
    local_times_insitu_year = fix(strmid(local_times_insitu, 0, 4))
    local_times_insitu_month = fix(strmid(local_times_insitu, 4, 2))
    local_times_insitu_day = fix(strmid(local_times_insitu, 6, 2))
    
    local_times_insitu_jul = julday(local_times_insitu_month, local_times_insitu_day, local_times_insitu_year)
    
    
    
    ;; Prune List to only be within time range (use floor of begin day, ceiling of end day
    ;; so as not to chop off half days we want)
    ind = where((local_times_insitu_jul ge floor(begin_jul)) and (local_times_insitu_jul le ceil(end_jul)))
    
    if(ind[0] lt 0) then begin
      print, "No Local Files Found"
      return, 'None'
    endif
    
    local_insitu      = local_insitu[ind]
    local_insitu_base = local_insitu_base[ind]
  endif else begin
    local_insitu = 'None'
  endelse
  
  return, local_insitu
  
end

function MVN_KP_LOCAL_IUVS_FILES, begin_jul, end_jul, iuvs_dir, binary=binary
  ;; Get list of Iuvs files
  ;SET THE PATTERN FOR THE IUVS KP FILENAME BASED ON THE BEGINNING DATE
  iuvs_pattern = 'mvn_rs_kp_*T*'
  if keyword_set(binary) then iuvs_pattern += '.sav' else iuvs_pattern += '.txt'
  
  local_iuvs = file_search(iuvs_dir, iuvs_pattern, count=count)
  if (count gt 0) then begin
    local_iuvs_base = file_basename(local_iuvs)
    times_iuvs      = strmid(local_iuvs_base, 10, 15)
    
    tiuvs_year  = fix(strmid(times_iuvs, 0,  4))
    tiuvs_month = fix(strmid(times_iuvs, 4,  2))
    tiuvs_day   = fix(strmid(times_iuvs, 6,  2))
    tiuvs_hour  = fix(strmid(times_iuvs, 9,  2))
    tiuvs_min   = fix(strmid(times_iuvs, 11, 2))
    tiuvs_sec   = fix(strmid(times_iuvs, 13, 2))
    
    times_iuvs_jul = julday(tiuvs_month,tiuvs_day,tiuvs_year,tiuvs_hour,tiuvs_min,tiuvs_sec)
    
    ;; Prune list to only be within time range (use ceiling of end day so as not to chop off
    ;; data we may want)
    ind = where((times_iuvs_jul ge begin_jul) and (times_iuvs_jul le ceil(end_jul)))
    if (ind[0] lt 0) then begin
      print, "no Files found"
      return, 'None'
    endif
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
  max_v = where(versions eq max(versions))
  revisions = revisions[max_v]
  files = files[max_v]
  
  ;; Find max revisio and discard others
  max_r = where(revisions eq max(revisions))
  files = files[max_r]
  
  ;; If more than one remaining, we assume they are duplicates, return first
  if (n_elements(files) gt 1) then files = files[0]
  
  return, files
end


function MVN_KP_LATEST_VERSIONS, in_files, vpos, rpos, basetrim
  ; Prune out files that have multiple coppies, but just different versions/revisoinos
  ; leave the highest version, then revision
  
  basenames=file_basename(in_files)
  base_trim=strmid(basenames,0,basetrim)
  uniq_base_trim = base_trim[UNIQ(base_trim)]
  latest_files = strarr(n_elements(uniq_base_trim))
  
  j=0
  foreach trim, uniq_base_trim do begin
    candidates = basenames[where(strmatch(basenames, trim+"*", /fold_case) eq 1)]
    final = MVN_KP_LATEST_VERSION_FILE(candidates, vpos, rpos)
    
    ;; If final is not a string, there has been a problem
    if (size(final, /type) ne 7) then begin
      message, "Problem with filenames in " ;#FIXME
    endif
    
    latest_files[j] = final
    j++
    
  endforeach
  
  return, latest_files
end



pro MVN_KP_FILE_SEARCH, begin_time, end_time, insitu_filenames, insitu_dir, iuvs_filenames, iuvs_dir, $
  binary=binary, insitu_only=insitu_only, download_new=download_new
  
  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
  ;EXTRACT THE VARIOUS TIME/DATE COMPONENTS
  begin_year   = fix(strmid(begin_time,0,4))
  begin_month  = fix(strmid(begin_time,5,2))
  begin_day    = fix(strmid(begin_time,8,2))
  begin_hour   = fix(strmid(begin_time,11,2))
  begin_minute = fix(strmid(begin_time,14,2))
  begin_second = fix(strmid(begin_time,17,2))
  
  end_year     = fix(strmid(end_time,0,4))
  end_month    = fix(strmid(end_time,5,2))
  end_day      = fix(strmid(end_time,8,2))
  end_hour     = fix(strmid(end_time,11,2))
  end_minute   = fix(strmid(end_time,14,2))
  end_second   = fix(strmid(end_time,17,2))

;; Variables containing just the date, not the time
begin_date = strmid(begin_time,0,10)
end_date   = strmid(end_time, 0,10)


;CALCULATE THE JULIAN DATES FOR BEGIN AND END

begin_jul = julday(begin_month,begin_day,begin_year, begin_hour)
end_jul = julday(end_month, end_day, end_year, end_hour)



;; If user wants the SDC server to be queried for udpated files or to fill in files
;; needed to complete the time range
if keyword_set(download_new) then begin
  
  ;; Check for insitu files
  mvn_kp_download_files, start_date=begin_date, end_date=end_date, /insitu, status=status, /new_files
  
  ;; Check for IUVS files
  if not keyword_set(insitu_only) then begin
    mvn_kp_download_files, start_date=begin_date, end_date=end_date, /iuvs, status=status, /new_files
  endif
  
endif



;; Get list of files now (some may have been downloaded)
;; And trim list to only have highest versions/revisions of each file
insitu_filenames = MVN_KP_LOCAL_INSITU_FILES(begin_jul, end_jul, insitu_dir, binary=binary)
insitu_filenames = MVN_KP_LATEST_VERSIONS(insitu_filenames, 5, 6, 21)

if not keyword_set(insitu_only) then begin
  iuvs_filenames = MVN_KP_LOCAL_IUVS_FILES(begin_jul, end_jul, iuvs_dir, binary=binary)
  iuvs_filenames = MVN_KP_LATEST_VERSIONS(iuvs_filenames, 4, 5, 27)
endif


end