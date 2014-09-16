

function mvn_kp_config_file, update_prefs=update_prefs, kp=kp, l2=l2

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Read or create preferences file ---------------------------- ;;

  ;; FIRST  -Check for ROOT_DATA_DIR environment varaible
  ;; If present, parse to find first existing directory and return. Otherwise continue on to
  ;; look for and/or create a mvn_toolkit_prefs.txt file.
  ;; This env variable is what the SSL uses for their software.
  root_data_dir_env = getenv('ROOT_DATA_DIR')
  if keyword_set(root_data_dir_env) then begin
  
    ;; Below code snippet taking from SSL's root_data_dir.pro
    rootdirs = strsplit(root_data_dir_env,path_sep(/search_path),/extract ,count=n )
    for i=0,n-1 do begin
      rootdir = rootdirs[i]
      if file_test(/direc,rootdir) then break
    endfor
    
    if not file_test(/direc,rootdir) then message, 'ROOT_DATA_DIR env varaible contained no usable paths'
    
    rootdir = rootdir + path_sep()
    print, 'ROOT_DATA_DIR enviroment variable set. Using: '+string(rootdir)+' as maven root data directory'
    mvn_root_data_dir=rootdir

  endif else begin
    
    ;; Find where preferences file should be
    install_result = routine_info('mvn_kp_config_file',/source, /function)
    install_directory = strsplit(install_result.path,'mvn_kp_config_file.pro',/extract,/regex)
    install_directory = install_directory+path_sep()+'..'+path_sep()
    mvn_root_data_dir = ''
    
    
    
    ;; If not specified to update preferences file, then check for and read mvn_toolkit_prefs.txt
    if not keyword_set(update_prefs) then begin
    
      ;CHECK IF THE PREFERENCES FILE EXISTS & READ IF IT DOES
      preference_exists = file_search(install_directory+path_sep()+'mvn_toolkit_prefs.txt',count=pref_exists)
      if pref_exists ne 0 then begin
      
        ;LOOP THROUGH L2 PREFS FILE LOOKING FOR PARTICULAR PREFERENCES
        openr,lun,install_directory+'mvn_toolkit_prefs.txt',/get_lun
        while not eof(lun) do begin
          line=''
          readf,lun,line
          tokens = strsplit(line,' ',/extract)
          if tokens[0] ne ';' then begin
          case tokens[0] of
            'mvn_root_data_dir:':  mvn_root_data_dir = tokens[1:(n_elements(tokens)-1)]
            else                        :  print, 'Unknown preference: ', tokens[0], ' ', tokens[1]
          endcase
          
          endif
        endwhile
      
        mvn_root_data_dir = strjoin(mvn_root_data_dir, ' ', /SINGLE)
      
        free_lun,lun
      
        ;IF NO TOP LEVEL DIRECOTRY FOUND IN PREFS FILE, PROMPT USER TO RE-RUN WITH UPDATE-PREFS OPTION (FIXME)
        if mvn_root_data_dir eq '' then begin
          print,      'Error: mvn_root_data_dir:/path/to/data/ not found in mvn_toolkit_prefs.txt file.'
          error_msg = 'Re run with /UPDATE_PREFS or manually fix mvn_toolkit_prefs.txt file.'
          message, error_msg
        endif
        
        ;; no  preferences file found
      endif else begin
        ;PROMPT USER FOR PATH
        print, ""
        print, "No mvn_toolkit_prefs.txt file found. Now prompting for path to maven root data directory"
        print, "This root data directory will be populated with subdirectories to match the SDC directory structure:"
        print, "<maven_root_data_dir>/maven/data/sci/<inst>/<level>/<YYYY>/<MM>/"
        
        mvn_root_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the maven root data directory')
        if mvn_root_data_dir eq '' then message, "Canceled directory choice. Must choose path to maven root data directory. Exiting..."
        
        update_prefs=1
        
      endelse
        
    endif else begin
    
      ;PROMPT USER FOR PATH
      print, ""
      print, "/update_prefs keyword given. Now prompting for directory to maven root data directory"
        print, "This root data directory will be populated with subdirectories to match the SDC directory structure:"
      print, "<maven_root_data_dir>/maven/data/sci/<inst>/<level>/<YYYY>/<MM>/"
      
      mvn_root_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the maven root data directory')
      if mvn_root_data_dir eq '' then message, "Canceled directory choice. Must choose path to maven root data directory. Exiting..."
      
    endelse
    
    
    
    ;WRITE/UPDATE PREFERENCES FILE IF NECESSARY
    if keyword_set(update_prefs) then begin
      ;CREATE mvn_toolkit_prefs.txt FOR FUTURE USE
      openw,lun,install_directory+'mvn_toolkit_prefs.txt',/get_lun
      printf,lun,'; IDL Toolkit Data Preferences File'
      printf,lun,'mvn_root_data_dir: '+mvn_root_data_dir
      free_lun,lun
      print, "Updated/created mvn_toolkit_prefs.txt file."
    endif
  endelse
  

  
  ;; Create kp directory structure under top level data directory
  if keyword_set(kp) then begin
    pre='maven'+path_sep()+'data'+path_sep()+'sci'+path_sep()
    
    dirs_to_create = [$
      pre+'insitu'+path_sep()+'kp', $
      pre+'iuvs'+path_sep()+'kp']
      
      
    for dir_i=0, n_elements(dirs_to_create)-1 do begin
      mvn_kp_create_dir_if_needed, mvn_root_data_dir+path_sep()+dirs_to_create[dir_i], /verbose, /open_permissions
    endfor
    
  endif 
  
  ;; Create l2 directory structure under top level data directory
  if keyword_set(l2) then begin
    pre='maven'+path_sep()+'data'+path_sep()+'sci'+path_sep()
    
    dirs_to_create = [pre+'sta'+path_sep()+'l2', $
      pre+'sep'+path_sep()+'l2', $
      pre+'swi'+path_sep()+'l2', $
      pre+'swe'+path_sep()+'l2', $
      pre+'lpw'+path_sep()+'l2', $
      pre+'euv'+path_sep()+'l2', $
      pre+'mag'+path_sep()+'l2', $
      pre+'iuv'+path_sep()+'l2', $
      pre+'acc'+path_sep()+'l2', $
      pre+'ngi'+path_sep()+'l2', $
      pre+'insitu'+path_sep()+'kp', $
      pre+'iuvs'+path_sep()+'kp']
      
     
    for dir_i=0, n_elements(dirs_to_create)-1 do begin
      mvn_kp_create_dir_if_needed, mvn_root_data_dir+path_sep()+dirs_to_create[dir_i], /verbose, /open_permissions
    endfor
    
  endif
  
  return, mvn_root_data_dir
end