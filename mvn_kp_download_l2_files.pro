;+
; :Name: mvn_kp_download_l2_files
;
; :Author: John Martin
;
;
; :Description:
;     Download level 2 data files from the Maven SDC web service for any instrument. 
;
;
; :Keywords:
;    instruments: in, required, type=string or strarr
;       Scalar or array of instruments (three letter representations) of l2 data to download/list
;       
;    filenames: in, optional, type=string or strarr
;       Scalar or array of filename strings to download. If used, /new_files keyword is ignored.
;
;    list_files: in, optional, type=boolean
;       Print to standard output a list of files instead of actually downloading
;
;    new_files: in, optional, type=boolean
;       Only download files you don't already have saved locally. This option is ignored if specific
;       filenames are input via the filenames keyword.
;       
;    start_date: in, optional, type=string
;       Beginning of time range to search/download files. Format='YYYY-MM-DD'
;
;    end_date: in, optional, type=string
;       End of time range to search/download files. Format='YYYY-MM-DD'
;       
;    update_prefs: in, optional, type=boolean
;       Before searching or downloading data, allow user to update mvn_toolkit_prefs.txt - which 
;       contains location of ROOT_DATA_DIR. After selecting new path to data folders, 
;       search or download of data files will continue.
;
;    only_update_prefs: in, optional, type=boolean
;       Allow user to update mvn_toolkit_prefs.txt - which contains location of ROOT_DATA_DIR.
;       After selecting new paths to data folders, procedure will return - not
;       downloading any data.
;
;    exclude_orbit_file: in, optional, type=boolean
;       Don't download an updated version of the orbit # file from naif.jpl.nasa.gov
;
;    debug: in, optional, type=boolean
;       On error, - "Stop immediately at the statement that caused the error and print
;       the current program stack." If not specified, error message will be printed and
;       IDL with return to main program level and stop.
;
;
;  Note- One can override the preferences file by setting the environment variable ROOT_DATA_DIR
; 
; 
;   Directory structure that will be created under <root_data_dir>/ (user chooses top root_data_dir):
;   
;   <root_data_dir>/maven/data/sci/
;   |
;   --sta/
;      |
;      --l2/
;   --sep/
;      |
;      --l2/
;   --swi/
;      |
;      --l2/
;   --swe/
;      |
;      --l2/
;   --lpw/
;      |
;      --l2/
;   --mag/
;      |
;      --l2/
;   --iuv/
;      |
;      --l2/
;   --ngi/
;      |
;      --l2/
;   --euv/
;      |
;      --l2/
;   --acc/
;      |
;      --l2/
;   --kp/
;      |
;      --insitu/
;      --iuvs/
;
;
;   Credit to Doug Lindholm for initial version of this procedure.
;-



pro mvn_kp_download_l2_files, instruments=instruments, filenames=filenames, list_files=list_files, $
                              start_date=start_date, end_date=end_date, new_files=new_files, $
                              update_prefs=update_prefs, only_update_prefs=only_update_prefs, $
                              exclude_orbit_file=exclude_orbit_file, debug=debug, help=help
                              

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    print,'MVN_KP_DOWNLOAD_L2_FILES'
    print,'  Download level 2 data files from the Maven SDC web service for any instrument.'
    print,''
    print,'mvn_kp_download_l2_files, instruments=instruments, filenames=filenames, list_files=list_files, $'
    print,'                          start_date=start_date, end_date=end_date, new_files=new_files, $'
    print,'                          update_prefs=update_prefs, only_update_prefs=only_update_prefs, $'
    print,'                          debug=debug, help=help'
    print,''
    print,'OPTIONAL FIELDS'
    print,'***************'
    print,'  instruments: Scalar or array of instruments (three letter representations) of l2 data to download/list'
    print,'  filenames: Scalar or array of filename strings to download. If used, /new_files keyword is ignored.'
    print,'  list_files: Print to standard output a list of files instead of actually downloading'
    print,'  new_files: Only download files you do not already have saved locally'
    print,'  start_date: Beginning of time range to search/download files. Format="YYYY-MM-DD"'   
    print,'  end_date: End of time range to search/download files. Format="YYYY-MM-DD"'
    print,'  update_prefs: Before searching or downloading data, allow user to update mvn_toolkit_prefs.txt - which '
    print,'                contains paths to the root data directory. After selecting new path to data folders, '
    print,'                search or download of data files will continue.'
    print,'  only_update_prefs: Allow user to update mvn_toolkit_prefs.txt - which contains paths to the root data directory.'
    print,'                     After selecting new path to data folders, procedure will return - not downloading any data.'
    print,'  exclude_orbit_file: Do not download updated orbit # file from naif.jpl.nasa.gov'
    print,'  debug: On error, - "Stop immediately at the statement that caused the error and print '
    print,'         the current program stack." If not specified, error message will be printed and '
    print,'         IDL with return to main program level and stop.'

    print,'  help: Invoke this list.'
    print, ''
    print, ''
    print, 'Note- One can override the preferences file by setting the environment variable ROOT_DATA_DIR'
    print, ''
    return
  endif
  
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
  
  
  ;;
  ;; Directory Structure
  ;;
  if keyword_set(only_update_prefs) then update_prefs=1
  
  ;; Read or create preferences file
  mvn_root_data_dir = mvn_kp_config_file(update_prefs=update_prefs, /l2)
  base_l2_dir = mvn_root_data_dir+'maven'+path_sep()+'data'+path_sep()+'sci'  
  
  if keyword_set(only_update_prefs) then begin
    print, "/only_update_prefs keyword given. Not doing any download. Returning.."
    return
  endif
  
  l2_dirs = create_struct( $
    'sta', base_l2_dir+path_sep()+'sta'+path_sep()+'l2'+path_sep(), $
    'sep', base_l2_dir+path_sep()+'sep'+path_sep()+'l2'+path_sep(), $
    'swi', base_l2_dir+path_sep()+'swi'+path_sep()+'l2'+path_sep(), $
    'swe', base_l2_dir+path_sep()+'swe'+path_sep()+'l2'+path_sep(), $
    'lpw', base_l2_dir+path_sep()+'lpw'+path_sep()+'l2'+path_sep(), $
    'euv', base_l2_dir+path_sep()+'euv'+path_sep()+'l2'+path_sep(), $
    'mag', base_l2_dir+path_sep()+'mag'+path_sep()+'l2'+path_sep(), $
    'iuv', base_l2_dir+path_sep()+'iuv'+path_sep()+'l2'+path_sep(), $
    'acc', base_l2_dir+path_sep()+'acc'+path_sep()+'l2'+path_sep(), $
    'ngi', base_l2_dir+path_sep()+'ngi'+path_sep()+'l2'+path_sep())

  
  if n_elements(instruments) le 0 then begin
    print, 'Must supply instruments keyword with one or more instrument.'
    print, "Example: ... instruments=['sta', 'ngi']"
    return
  endif
  
  if keyword_set(list_files) then begin
    print, "LIST_FILES option given, printing files instead of downloading"
    print, ""
  endif


  if n_elements(filenames) gt 0 then begin
    
    ;; Ensure only one instrument supplied
    if n_elements(instruments) ne 1 then begin
      message, "If specifying filename(s), must specify one and only one instrument"
    endif
    
  endif


  ;; Get SDC server specs
  sdc_server_spec = mvn_kp_config(/data_retrieval)
  
  url_path  = sdc_server_spec.url_path_download      ; Define the URL path for the download web service.
  max_files = sdc_server_spec.max_files              ; Define the maximum number of files to allow w/o an extra warning.


  ;; Unless specified not to, check for & download updated orbit # file
  if (not keyword_set(exclude_orbit_file)) and (not keyword_set(list_files)) then begin
    print, "Before downloading data files, checking for updated orbit # file from naif.jpl.nasa.gov"
    print, ""
    mvn_kp_download_orbit_file
  endif

  ;; ------------------------------------------------------------------------------------ ;;
  ;; ------------------------------ Main logic ------------------------------------------ ;;
  
  ;; Loop over each instruments - Handle seperately to ease logic for new files
  for inst_i=0, n_elements(instruments)-1 do begin

    ;; Get directory of where l2 files are stored on machine
    inst_tag_i = where(tag_names(l2_dirs) eq strupcase(instruments[inst_i]), counter)
    if counter le 0 then begin
      print, "Unknown instrument: "+string(instruments[inst_i])
      if n_elements(instruments[inst_i]) ne 3 then begin
        print, "Recall: Instrument must be provided with 3 letter representation"
      endif
      print, ""
      continue
    endif
    current_l2_dir = l2_dirs.(inst_tag_i)

    ;; Unless filenames specified, preform query to SDC server to get list of filenames to download/list
    if not keyword_set(filenames) then begin
      

      ; Build query.
      ; Start by building an array of arguments based on inputs.
      ; Many values may be arrays so join with ",".
      ; Note that a single value will be treated as an array of one by IDL.
      query_args = ["hack"] ;IDL doesn't allow empty arrays before version 8.
      
      query_args = [query_args, "instrument="+instruments[inst_i]]
      if n_elements(filename)       gt 0 then query_args = [query_args, "file=" + strjoin(filename, ",")]
      
      if n_elements(start_date)     gt 0 then query_args = [query_args, "start_date=" + start_date]
      if n_elements(end_date)       gt 0 then query_args = [query_args, "end_date=" + end_date]
      if n_elements(extension)      gt 0 then query_args = [query_args, "file_extension=" + extension]
      ;  if n_elements(groupings)  - l0 data
      ;  if n_elements(descriptor)
      ;  if n_elements(plan)
      ;  if n_elements(orbit)
      ;   if n_elements(mode)           gt 0 then query_args = [query_args, "mode=" +strjoin(mode, ",")]
      ;  if n_elements(data_type)
      
      
      ;; Always l2 for this procedure
      query_args = [query_args, "level=l2"]
      
      ; Join query args with "&", drop the "hack"
      if n_elements(query_args) lt 2 then query = '' $
      else query = strjoin(query_args[1:*], "&")
            
      
      ; Get the IDLnetURL singleton. May prompt for password.
      connection = mvn_kp_get_connection()
      
      ;query the server to find available files for download

      filenames = mvn_kp_get_filenames(query=query)
      ; Warn if no files. Error code or empty.
      if (size(filenames, /type) eq 3 || n_elements(filenames) eq 0) then begin
        print, "For instrument: "+instruments[inst_i]+" - No l2 files found on server for input query"
        print, ""
        ;; Clear out filenames for next pass through loop
        filenames = ''
        continue
      endif
  
      
      ; If user supplied NEW_FILES option, determine which files they have locally
      if keyword_set (new_files) then begin
    
        ;; Get filename convetion information from config
        pattern = 'mvn_'+instruments[inst_i]+'*'
    
        ; Get list of all files currently downloaded - recursive search to look through year/month subdirs
        local_files = file_basename(file_search(current_l2_dir+path_sep(), pattern))

        ; Get list of files on server (within a time span if entereted), that are not on local machine
        filenames = mvn_kp_relative_complement(local_files, filenames)
    
      endif
      
      ;; Sort the filenames
      filenames = filenames[sort(filenames)]
      
      ;; If LIST_FILES option, then just print out the file list (and save to list_files)
      ; Don't actually download
      if keyword_set(list_files) then begin
        print, 'For instrument: '+instruments[inst_i]+" - l2 files that would be downloaded: "
        print, "-------------------------------------------------------"
        for file_i=0l, n_elements(filenames)-1 do begin
          print, filenames[file_i]
        endfor
        print, ""
        ;; Clear out filenames for next pass through loop
        filenames=''
        continue
        
      endif
      
    endif
    
      
    ; Get the number of files that would be downloaded.
    nfiles = n_elements(filenames)
    
    ;; Hanlde the stupid case where IDL has an emptry string and n_elements will return 1.
    ;; Continue to next inst from here if no files to download
    if (nfiles eq 1) and (strlen(filenames[0]) eq 0) then begin
      print, "For instrument: "+instruments[inst_i]+" - No new files to download"
      print, ""
      ;; Clear out filenames for next pass through loop
      filenames = ''
      continue
    endif
    
    ; Prompt user to ensure they want to download nfiles amount of files
    download_bool = 'yes'
    while(1) do begin
      response = ''
      print, "For instrument: "+instruments[inst_i]+" - Your request will download a total of: " +strtrim(string(nfiles),2) +" files."
      if (nfiles gt max_files) then print, "NOTE - This is a large number of files and may take a long time to download"
      print, "Would you like to proceed with this download:"
      read, response, PROMPT='(y/n) >'
      if (strlowcase(strmid(response,0,1)) eq 'y') then break
      if (strlowcase(strmid(response,0,1)) eq 'n') then begin
        print, "Canceled download for: "+string(instruments[inst_i])+"."
        download_bool = 'no'
        break
      endif else print, "Invalid input. Please answer with yes or no."
    endwhile
    
    if download_bool eq 'yes' then begin
      
      ;; If connection not set, filenames was specified - need to get connection
      if not keyword_set(connection) then begin
        ; Get the IDLnetURL singleton. May prompt for password.
        connection = mvn_kp_get_connection()
      endif
      
      print, "Starting download of l2 file(s)..."
      ; Download files one at a time.
      nerrs = 0 ;count number of errors
      for i = 0, nfiles-1 do begin
        
        file = file_basename(filenames[i]) ;just the file name, no path
  
        ;; Check for correct YYYY/MM directory to place into & create if necessary
        date_path = mvn_kp_date_subdir(file)
        full_path = current_l2_dir + path_sep() + date_path
        mvn_kp_create_dir_if_needed, full_path, /verbose, /open_permissions
        
        ;; directory to download to
        local_file = full_path + file
        file_query = "file=" + file
        
        result = mvn_kp_execute_neturl_query(connection, url_path, file_query, filename=local_file)
        
        ; Updated the download progress bar
        MVN_KP_LOOP_PROGRESS,i,0,nfiles-1,message=instruments[inst_i]+' Download Progress'

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
      
   
      ; Print amount of successful downloads and where they went
      print, strtrim(string(nfiles-nerrs),2)+" total files successfully downloaded to: "+current_l2_dir
      print, ""
      
      ; Print error message if any of the downloads failed.
      if nerrs gt 0 then begin
        msg = "WARN: " + strtrim(nerrs,2) + " out of " + strtrim(nfiles,2) + " file downloads failed."
        printf, -2, msg
        
        ;; Clear out filenames for next pass through loop
        filenames = ''
        continue
      endif
    
    endif

    ;; Clear out filenames for next pass through loop
    filenames = ''

  endfor

  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
end
