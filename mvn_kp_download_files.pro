

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
; If 'local_dir' is defined, save the files there, otherwise use the preferences file.
;
; The 'query' is directly passed to the web service.
; See the web service documentation for valid query options.


pro mvn_kp_download_files, filenames=filenames, local_dir=local_dir, insitu=insitu, iuvs=iuvs, new_files=new_files, $
                           text_files=text_files, cdf_files=cdf_files, start_date=start_date, end_date=end_date, $
                           update_prefs=update_prefs, list_files=list_files, debug=debug
  

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
  

  ;; ------------------------------------------------------------------------------------ ;;
  ;; ------------------ Check input options & set global variables----------------------- ;;
 
  ; IF DEBUG SET, CREATE ENVIRONMENT VARIABLE SO ALL PROCEDURES/FUNCTIONS CALLED CAN CHECK FOR IT
  if keyword_set(debug) then begin
    setenv, 'MVNTOOLKIT_DEBUG=TRUE'
  endif
  
 
  ;; Get SDC server specs
  sdc_server_spec = mvn_kp_config(/data_retrieval)
  
  url_path  = sdc_server_spec.url_path_download      ; Define the URL path for the download web service.
  max_files = sdc_server_spec.max_files              ; Define the maximum number of files to allow w/o an extra warning.
  
  ;; Default behavior is to download KP data
  if keyword_set(insitu) then begin
    data_level='l2'                              ;; FIXME - Currently inconcsistency between insitu/iuvs levels. 
  endif else if keyword_set(iuvs) then begin
    data_level='kp'
  endif
  
  ;; Set extension keyword based of text_file option or cdf_files
  if keyword_set(text_files) then begin
    extension = 'txt'
  endif else if keyword_set(cdf_files) then begin
    extension = 'cdf'
  endif else if n_elements(filenames) le 0 then begin
    message, "If not specifying filename(s) to download, must specify either /TEXT_FILES or /CDF_FILES."
  endif
  
  ;; If specific filenames not specified, then user must specify insitu or iuvs
  if n_elements(filenames) le 0 then begin

    if keyword_set(insitu) and keyword_set(iuvs) then begin
      message, "Can't request both INSITU & IUVS data in one query. 
    endif
    if not (keyword_set(insitu) or keyword_set(iuvs)) then begin
      message, "If not specifying filename(s) to download, Must specify either /INSITU keyword or /IUVS."
    endif
  endif

  
  
  ; Build query.
  ; Start by building an array of arguments based on inputs.
  ; Many values may be arrays so join with ",".
  ; Note that a single value will be treated as an array of one by IDL.
  query_args = ["hack"] ;IDL doesn't allow empty arrays before version 8.
  
  if keyword_set(insitu)             then query_args = [query_args, "instrument=pfp"]
  if keyword_set(iuvs)               then query_args = [query_args, "instrument=rs"]
  if n_elements(filename)       gt 0 then query_args = [query_args, "file=" + strjoin(filename, ",")]
  if n_elements(data_level)     gt 0 then query_args = [query_args, "level=" + strjoin(data_level, ",")]
  if n_elements(start_date)     gt 0 then query_args = [query_args, "start_date=" + start_date]
  if n_elements(end_date)       gt 0 then query_args = [query_args, "end_date=" + end_date]
  if n_elements(extension)      gt 0 then query_args = [query_args, "file_extension=" + extension]
  
  
  
  ; Join query args with "&", drop the "hack"
  if n_elements(query_args) lt 2 then query = '' $
  else query = strjoin(query_args[1:*], "&")
 
  ; If local_dir not specified, check config file for insitu & iuvs dir.            
  if n_elements(local_dir) eq 0 then begin
    ; Check config file for directories to data
    mvn_kp_config_file, insitu_data_dir=insitu_data_dir, iuvs_data_dir=iuvs_data_dir, update_prefs=update_prefs

    if keyword_set(insitu) then begin 
      local_dir = insitu_data_dir
    endif else if keyword_set(iuvs)   then begin 
      local_dir = iuvs_data_dir
    endif else begin
      message, "If not specifying local_dir option, must specify /insitu or /iuvs"
    endelse
  endif


  ;; ------------------------------------------------------------------------------------ ;;
  ;; ------------------------------ Main logic ------------------------------------------ ;;

  ; Get the IDLnetURL singleton. May prompt for password.
  connection = mvn_kp_get_connection()
  
  ; If no input filename(s), then query the server to find available files for download
  if not keyword_set (filenames) then begin
   
    ; Get the list of files. Names will be full path starting at "mms"? #FIXME - Not MMS
    filenames = mvn_kp_get_filenames(query=query)
    ; Warn if no files. Error code or empty.
    if (size(filenames, /type) eq 3 || n_elements(filenames) eq 0) then begin
      printf, -2, "WARN: No files found for the query: " + query
      return
    endif
  endif
  
  
  
  ; If user supplied NEW_FILES option, determine which files they have locally
  if keyword_set (new_files) then begin
    
    ;; Get filename convetion information from config
    insitu_file_spec = mvn_kp_config(/insitu_file_spec)
    iuvs_file_spec   = mvn_kp_config(/iuvs_file_spec)
    insitu_pattern = insitu_file_spec.pattern
    iuvs_pattern   = iuvs_file_spec.pattern
    
    ;; Append appropriate extension
    if keyword_set(text_files) then insitu_pattern += '.txt' else insitu_pattern += '.cdf'
    if keyword_set(text_files) then iuvs_pattern   += '.txt' else iuvs_pattern   += '.cdf' 
    
    ; Get list of all files currently downloaded
    if keyword_set(insitu) then begin 
      local_files = file_basename(file_search(local_dir+path_sep()+insitu_pattern))
    endif
    if keyword_set(iuvs) then begin
      local_files = file_basename(file_search(local_dir+path_sep()+iuvs_pattern))
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
    return 

  endif
  

  ; Get the number of files that would be downloaded.
  nfiles = n_elements(filenames)
  
  ;; Hanlde the stupid case where IDL has an emptry string and n_elements will return 1.
  ;; Return from here if no files to download
  if (nfiles eq 1) and (strlen(filenames[0]) eq 0) then begin
    if keyword_set(insitu)    then filetype = 'in situ' else filetype = 'IUVS'
    if keyword_set(cdf_files) then extension = 'CDF' else extension = 'text'
    
    print, "No new "+filetype+" "+extension+" files on server to download."
    return
  endif
  
  ; Prompt user to ensure they want to download nfiles amount of files
  while(1) do begin 
    response = ''
    print, "Your request will download a total of: " +string(nfiles) +" files."
    if (nfiles gt max_files) then print, "NOTE - This is a large number of files and may take a long time to download"
    print, "Would you like to proceed with this download:"
    read, response, PROMPT='(y/n) >'
    if (strlowcase(strmid(response,0,1)) eq 'y') then break
    if (strlowcase(strmid(response,0,1)) eq 'n') then begin
      print, "Canceled download. Returning..."
      return
    endif else print, "Invalid input. Please answer with yes or no."
  endwhile
  
  
  ; Download files one at a time. 
  nerrs = 0 ;count number of errors
  for i = 0, nfiles-1 do begin

    ; Updated the download progress bar
    MVN_LOOP_PROGRESS,i,0,nfiles-1,message='KP Download Progress'
    
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
    return
  endif
  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
end
