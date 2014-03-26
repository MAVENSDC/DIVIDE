

function mvn_kp_relative_comp, local, server  
  server_out = server
  for i=0, n_elements(local)-1 do begin
    ind = where(server_out NE local[i], count)

    ;; If no items are found, this means there are no new files on the server
    ;; to download, so return with an empty string.
    if(count eq 0) then return, ''
    server_out = server_out(ind)
  endfor
  return, server_out
end




; Download the files of the given type using the given query parameters.
; If 'local_dir' is defined, save the files there, otherwise use the current directory.
;
; The 'query' is directly passed to the web service.
; See the web service documentation for valid query options.


pro mvn_kp_download_files, filenames=filenames, local_dir=local_dir, start_date=start_date, end_date=end_date, $
                           insitu=insitu, iuvs=iuvs, textfiles=textfiles,$
                           descriptor=descriptor, latest=latest, status=status, new_files=new_files, $
                           update_prefs=update_prefs, list_files=list_files, data_level=data_level
  
  
 
 
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ------------------ Check input options & set global variables----------------------- ;;
 
  ;; Get SDC server specs
  sdc_server_spec = mvn_kp_config(/data_retrieval)
  
  url_path = sdc_server_spec.url_path_download       ; Define the URL path for the download web service.
  check_max_files = sdc_server_spec.check_max_files  ; Define if we want to check the number of files before dl
  max_files = sdc_server_spec.max_files              ; Define the maximum number of files to allow.
  
  ;; Default behavior is to download KP data
  if keyword_set(iuvs) then begin
    if not keyword_set(data_level) then data_level='kp'        ;;; FIXME - Commented out for INsitu
  endif
  
  ; Web API defined with lower case.
  ;if n_elements(data_rate_mode) gt 0 then data_rate_mode = strlowcase(data_rate_mode)
  ;if n_elements(level)     gt 0 then data_level     = strlowcase(level)
  
  ; User must specify INSITU or IUVS, but not both
  if keyword_set(insitu) and keyword_set(iuvs) then begin
    printf, -2, "Error: Can't request both INSITU & IUVS data in one query. 
    return
  endif
  if not (keyword_set(insitu) or keyword_set(iuvs)) then begin
    printf, -2, "Error: Must specify either INSITU keyword or IUVS keyword."
    return
  endif

  
  
  ; Build query.
  ; Start by building an array of arguments based on inputs.
  ; Many values may be arrays so join with ",".
  ; Note that a single value will be treated as an array of one by IDL.
  query_args = ["hack"] ;IDL doesn't allow empty arrays before version 8.
  
  if keyword_set(insitu)             then query_args = [query_args, "instrument=pfp"]
  if keyword_set(iuvs)               then query_args = [query_args, "instrument=rs"]
  ;;if keyword_set(iuvs)               then query_args = [query_args, "instrument=iuv"]                                 ;; FIXME TESTING
  if n_elements(filename)       gt 0 then query_args = [query_args, "file=" + strjoin(filename, ",")]
  if n_elements(data_level)     gt 0 then query_args = [query_args, "level=" + strjoin(data_level, ",")]
  if n_elements(descriptor)     gt 0 then query_args = [query_args, "descriptor=" + strjoin(descriptor, ",")]
  if n_elements(start_date)     gt 0 then query_args = [query_args, "start_date=" + start_date]
  if n_elements(end_date)       gt 0 then query_args = [query_args, "end_date=" + end_date]
  
  
  
  ; Join query args with "&", drop the "hack"
  if n_elements(query_args) lt 2 then query = '' $
  else query = strjoin(query_args[1:*], "&")
 
  ; Set local_dir to current working dir if not specified.
  if n_elements(local_dir) eq 0 then cd, current=local_dir



  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ------------------------------ Main logic ------------------------------------------ ;;



  ; Get the IDLnetURL singleton. May prompt for password.
  connection = mvn_kp_get_connection(authentication=authentication)
  
  ; If no input filename(s), then query the server to find available files for download
  if not keyword_set (filenames) then begin
   
    ; Get the list of files. Names will be full path starting at "mms"? #FIXME - Not MMS
    filenames = mvn_kp_get_filenames(query=query)
    ; Warn if no files. Error code or empty.
    if (size(filenames, /type) eq 3 || n_elements(filenames) eq 0) then begin
      printf, -2, "WARN: No files found for the query: " + query
      status = -1 
      return
    endif
  endif
  
  
  stop
  ; If user supplied NEW_FILES option, determine which files they have downloaded
  if keyword_set (new_files) then begin
    
    ; Check config file for directories to data
    mvn_kp_config_file, insitu_data_dir=insitu_data_dir, iuvs_data_dir=iuvs_data_dir, update_prefs=update_prefs
    
    ;; Get filename convetion information from config
    insitu_file_spec = mvn_kp_config(/insitu_file_spec)
    iuvs_file_spec   = mvn_kp_config(/iuvs_file_spec)
    insitu_pattern = insitu_file_spec.pattern
    iuvs_pattern   = iuvs_file_spec.pattern
    
    ;; Append appropriate extension
    if keyword_set(textfiles) then insitu_pattern += '.txt' else insitu_pattern += '.cdf'
    if keyword_set(textfiles) then iuvs_pattern   += '.txt' else iuvs_pattern   += '.cdf' 
    
    ; Get list of all files currently downloaded
    if keyword_set(insitu) then begin 
      local_dir = insitu_data_dir
      local_files = file_basename(file_search(insitu_data_dir, insitu_pattern))
    endif
    if keyword_set(iuvs) then begin
      local_dir = iuvs_data_dir 
      local_files = file_basename(file_search(iuvs_data_dir  , iuvs_pattern))
    endif
        
    ; Get list of files on server (within a time span if entereted), that are not on local machine
    filenames = mvn_kp_relative_comp(local_files, filenames)
    
  endif
  
  
  ;; If LIST_FILES option, then just print out the file list (and save to list_files) 
  ; Don't actually download
  if keyword_set(list_files) then begin
    list_files=filenames
    print, "LIST_FILES option given, printing files instead of downloading"
    print, "Files that would be downloaded: "
    print, filenames
    status = 0
    return 

  endif
  
  
  
  ; Get the number of files that would be downloaded.
  ; If the 'latest' keyword is set, only return the latest,
  ;   which will be the first, so setting length to 1 will work. FIXME = I don't think we need/ using this "latest" flag
  nfiles = n_elements(filenames)
  
  ;; Hanlde the stupid case where IDL has an emptry string and n_elements will return 1.
  ;; Return from here if no files to download
  if (nfiles eq 1) and (strlen(filenames[0]) eq 0) then begin
    print, "No new files on server to download."
    status=0
    return
  endif
  
  if KEYWORD_SET(latest) then nfiles = 1
  
  ; Error if too many files. (TODO: - Do we want this?)
  if (check_max_files) and (nfiles gt max_files) then begin
    printf, -2, "ERROR: The resulting set of files (" + strtrim(nfiles,2) + ") is too large for the query: " + query
    status = -1 ;TODO: better error codes? http://www.exelisvis.com/docs/IDLnetURL.html#objects_network_1009015_1417867
    return
  endif

  ; Prompt user to ensure they want to download nfiles amount of files
  while(1) do begin 
    response = ''
    print, "Your request will download a total of: " +string(nfiles) +" files."
    print, "Would you like to proceed with this download:"
    read, response, PROMPT='(y/n) >'
    if (strlowcase(strmid(response,0,1)) eq 'y') then break
    if (strlowcase(strmid(response,0,1)) eq 'n') then begin
      print, "Canceled download. Returning..."
      status=0
      return
    endif else print, "Invalid input. Please answer with yes or no."
  endwhile
  
  
  stop                                                                       ;; FIXME - here to stop beforedownloading for testing
  ; Download files one at a time. 
  nerrs = 0 ;count number of errors
  for i = 0, nfiles-1 do begin
    ;TODO: flat or hierarchy? assume flat for now
    file = file_basename(filenames[i]) ;just the file name, no path
    local_file = local_dir + path_sep() + file ;all in one directory (i.e. flat)
    file_query = "file=" + file
    result = mvn_kp_execute_neturl_query(connection, url_path, file_query, filename=local_file)
    ;count failures so we can report a 'partial' status
    ;Presumably, mvn_kp_execute_neturl_query will print specific error messages.
    if size(result, /type) eq 3 then nerrs = nerrs + 1
  endfor

  ; Print error message if any of the downloads failed.
  if nerrs gt 0 then begin
    msg = "WARN: " + strtrim(nerrs,2) + " out of " + strtrim(nfiles,2) + " file downloads failed." 
    printf, -2, msg
    status = -1
    return
  endif else begin
  status = 0 
  return
  endelse
end
