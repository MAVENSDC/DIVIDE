;+
; :Name: mvn_kp_download_files
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: John Martin
;
;
; :Description:
;     Download in situ or IUVS kp data files from the Maven SDC web service. 
;     Download either CDF or ASCII versions of the data files. 
;
;
;
; :Keywords:
;    filenames: in, optional, type=string or strarr
;       Scalar or array of filename strings to download
;       
;    list_files: in, optional, type=boolean
;       Print to standard output a list of files instead of actually downloading
;    
;    insitu: in, optional, type=boolean
;       Search/download in situ KP data files
;
;    iuvs: in, optional, type=boolean
;       Search/download IUVS KP data files
;    
;    text_files: in, optional, type=boolean
;       Search/download ASCII (.tab) versions of the KP data files
;
;    cdf_files: in, optional, type=boolean
;       Search/download CDF (.cdf) versions of the KP data files
;    
;    new_files: in, optional, type=boolean
;       Only download files you don't already have saved locally
;    
;    start_date: in, optional, type=string
;       Beginning of time range to search/download files. Format='YYYY-MM-DD'   
;
;    end_date: in, optional, type=string
;       End of time range to search/download files. Format='YYYY-MM-DD'
;    
;    update_prefs: in, optional, type=boolean
;       Before searching or downloading data, allow user to update 
;       mvn_toolkit_prefs.txt - which contains location of ROOT_DATA_DIR. 
;       After selecting new path to data folders, search or download of 
;       data files will continue.
;
;    only_update_prefs: in, optional, type=boolean
;       Allow user to update mvn_toolkit_prefs.txt - which contains location 
;       of ROOT_DATA_DIR.
;       After selecting new paths to data folders, procedure will return - not
;       downloading any data.
;       
;    exclude_orbit_file: in, optional, type=boolean
;       Don't download an updated version of the orbit # file 
;       from naif.jpl.nasa.gov
;    
;    local_dir: in, optional, type=string
;       Specify a directory to download files to - this overrides what's 
;       stored in mvn_toolkit_prefs.txt
;        
;    debug: in, optional, type=boolean
;       On error, - "Stop immediately at the statement that caused the error 
;       and print the current program stack." If not specified, error message 
;       will be printed and IDL with return to main program level and stop.
;
;    help: in, optional, type=boolean
;       Prints keyword descriptions to screen.
;
;
;   Note- One can override the preferences file by setting the environment 
;   variable ROOT_DATA_DIR
;
;   Credit to Doug Lindholm for initial version of this procedure. 
;-



pro mvn_kp_download_files, filenames=filenames, local_dir=local_dir, $
    insitu=insitu, iuvs=iuvs, new_files=new_files, text_files=text_files, $
    cdf_files=cdf_files, start_date=start_date, end_date=end_date, $
    update_prefs=update_prefs, list_files=list_files, debug=debug, $
    exclude_orbit_file=exclude_orbit_file, $
    exclude_template_files= exclude_template_files, $
    only_update_prefs=only_update_prefs, help=help

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_download_files'
    return
  endif

  MVN_KP_CHECK_VERSION
  
  ;Set to 0 for public release, 1 for team release
  private = mvn_kp_config_file(/check_access)

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
  
  
  if keyword_set(only_update_prefs) then begin
    out = mvn_kp_config_file(/update_prefs, /kp)
    
    ;; Warn user if other parameters supplied
    if keyword_set(filenames) or keyword_set(cdf_files) or keyword_set(text_files) then begin
      print, "Warning. /ONLY_UPDATE_PREFS option supplied, not querying server."
      print, "If you want to update the preferences file & download data, use /UPDATE_PREFS instead"
    endif
    
    ;; Only update prefs option, return now.
    return
  endif
 
  ;; Get SDC server specs
  

  sdc_server_spec = mvn_kp_config(/data_retrieval, private=private)
  
  url_path  = sdc_server_spec.url_path_download      ; Define the URL path for the download web service.
  max_files = sdc_server_spec.max_files              ; Define the maximum number of files to allow w/o an extra warning.
 
  
  ;; Set extension keyword based of text_file option or cdf_files
  if keyword_set(text_files) then begin
    extension = 'tab'
  endif else if keyword_set(cdf_files) then begin
    extension = 'cdf'
  endif else if n_elements(filenames) le 0 then begin
    text_files = 1
    extension = 'tab'
  endif
  
  ;; If specific filenames not specified, then user must specify insitu or iuvs
  if n_elements(filenames) le 0 then begin

    if keyword_set(insitu) and keyword_set(iuvs) then begin
      message, "Can't request both INSITU & IUVS data in one query." 
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

  query_args = [query_args, "instrument=kp"]         ;; Instrument is always 'kp' for insitu or iuvs
  if keyword_set(insitu)             then query_args = [query_args, "level=insitu"]
  if keyword_set(iuvs)               then query_args = [query_args, "level=iuvs"]
  if n_elements(filename)       gt 0 then query_args = [query_args, "file=" + strjoin(filename, ",")]
  if n_elements(start_date)     gt 0 then query_args = [query_args, "start_date=" + start_date]
  if n_elements(end_date)       gt 0 then query_args = [query_args, "end_date=" + end_date]
  if n_elements(extension)      gt 0 then query_args = [query_args, "file_extension=" + extension]
  
  
  
  ; Join query args with "&", drop the "hack"
  if n_elements(query_args) lt 2 then query = '' $
  else query = strjoin(query_args[1:*], "&")
 
  ; If local_dir not specified, check config file for insitu & iuvs dir.            
  if (n_elements(local_dir) eq 0) and ( (not keyword_set(list_files)) or keyword_set(new_files) or keyword_set(update_prefs)) then begin
    ; Check config file for directories to data
    mvn_root_data_dir = mvn_kp_config_file(update_prefs=update_prefs, /kp)
    
    insitu_data_dir = mvn_root_data_dir+'maven'+path_sep()+'data'+path_sep()+'sci'+path_sep()+'kp'+path_sep()+'insitu'+path_sep()
    iuvs_data_dir   = mvn_root_data_dir+'maven'+path_sep()+'data'+path_sep()+'sci'+path_sep()+'kp'+path_sep()+'iuvs'+path_sep()                    

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

    connection = mvn_kp_get_connection(private=private)


  ; If no input filename(s), then query the server to find available files for download
  if not keyword_set (filenames) then begin
   
    ; Get the list of files. Names will be full path starting at "mms"? #FIXME - Not MMS
      filenames = mvn_kp_get_filenames(query=query, private=private)

    ; Warn if no files. Error code or empty.
    if (size(filenames, /type) eq 3 || n_elements(filenames) eq 0) then begin
      print, "No files found for the query: " + query
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
    if keyword_set(text_files) then insitu_pattern += '.tab' else insitu_pattern += '.cdf'
    if keyword_set(text_files) then iuvs_pattern   += '.tab' else iuvs_pattern   += '.cdf' 
    
    ; Get list of all files currently downloaded - recursive search to look through year/month subdirs
    if keyword_set(insitu) then begin 
      local_files = file_basename(file_search(local_dir+path_sep(),insitu_pattern))
    endif
    if keyword_set(iuvs) then begin
      local_files = file_basename(file_search(local_dir+path_sep(),iuvs_pattern))
    endif

    ; Get list of files on server (within a time span if entereted), that are not on local machine
    filenames = mvn_kp_relative_complement(local_files, filenames)
  endif
  
  ;; Sort the filenames
  filenames = filenames[sort(filenames)]
  
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
  
  ;; Estimate total size of files to download
  if keyword_set(insitu) then begin
    if keyword_set(text_files) then begin
      estimate_size = nfiles * 38   ;; Roughly 38 MB per ASCII ile
    endif else begin
      estimate_size = nfiles * 19   ;; Roughing 19 MB per CDF File
    endelse
  endif else begin
    if keyword_set(text_files) then begin
      estimate_size = nfiles * 1.0  ;; Roughly 1 MB per ASCII file
    endif else begin
      estimate_size = nfiles * .684 ;; Roughly 684 kB per CDF File
    endelse
  endelse
    
    
  ; Prompt user to ensure they want to download nfiles amount of files
  while(1) do begin 
    response = ''
    print, "Your request will download a total of: " +strtrim(string(nfiles),2) +" files with an approx total size of: "+strtrim(string(estimate_size),2)+" MBs."
    if (nfiles gt max_files) then print, "NOTE - This is a large number of files and may take a long time to download"
    print, "Would you like to proceed with this download:"
    read, response, PROMPT='(y/n) >'
    if (strlowcase(strmid(response,0,1)) eq 'y') then break
    if (strlowcase(strmid(response,0,1)) eq 'n') then begin
      print, "Canceled download. Returning..."
      return
    endif else print, "Invalid input. Please answer with yes or no."
  endwhile
  
  ;; Unless specified not to, check for & download updated template files
  if not keyword_set(exclude_template_files) then begin
    print, "Before downloading data files, checking for updated KP templates from the SDC"
    print, ""
    mvn_kp_download_template_file
  endif
  
  ;; Unless specified not to, check for & download updated orbit # file
  if not keyword_set(exclude_orbit_file) then begin
    print, "Before downloading data files, checking for updated orbit # file from naif.jpl.nasa.gov"
    print, ""
    mvn_kp_download_orbit_file
  endif

  print, "Starting download of kp file(s)..."  
  ; Download files one at a time. 
  nerrs = 0 ;count number of errors
  for i = 0, nfiles-1 do begin

    file = file_basename(filenames[i]) ;just the file name, no path
    
    ;; Check for correct YYYY/MM directory to place into & create if necessary
    date_path = mvn_kp_date_subdir(file)
    full_path = local_dir + path_sep() + date_path
    mvn_kp_create_dir_if_needed, full_path, /verbose, /open_permissions
    
    local_file = full_path + path_sep() + file
    file_query = "file=" + file
    
    result = mvn_kp_execute_neturl_query(connection, url_path, file_query, filename=local_file)
    
    ; Updated the download progress bar
    MVN_KP_LOOP_PROGRESS,i,0,nfiles-1,message='KP Download Progress'

    ;count failures so we can report a 'partial' status
    ;Presumably, mvn_kp_execute_neturl_query will print specific error messages.
    if size(result, /type) eq 3 then begin
      nerrs = nerrs + 1
      ;; Check if file exists, and if so delete it - it is corrupt or doesn't contain
      ;; the correct data
      file_delete, local_file, /ALLOW_NONEXISTENT
    endif else begin
      ;; Change permisions of file to all open
      file_chmod, local_file, /A_EXECUTE, /A_READ, /A_WRITE
    endelse
    
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
