

pro mvn_kp_config_l2, l2_data_dir=l2_data_dir, update_prefs=update_prefs, create_dirs=create_dirs


  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif


  ;; ------------------------------------------------------------------------------------ ;;
  ;; ----------------------- Read or create preferences file ---------------------------- ;;
  
  
  ;FIXME TAKE ANOTHER LOOK OVER LOGIC HERE, MAKE SURE SOLID ENOUGH
  install_result = routine_info('mvn_kp_config_l2',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_config_l2.pro',/extract,/regex)
  install_directory = install_directory+path_sep()+'..'+path_sep()
  
  l2_data_dir = ''
  
  
  ;; If not specified to update preferences file, then check for and read l2_preferences.txt
  if not keyword_set(update_prefs) then begin
  
    ;CHECK IF THE l2 PREFERENCES FILE EXISTS & READ IF IT DOES
    preference_exists = file_search(install_directory+path_sep()+'l2_preferences.txt',count=l2_pref_exists)
    if l2_pref_exists ne 0 then begin
    
      ;LOOP THROUGH L2 PREFS FILE LOOKING FOR PARTICULAR PREFERENCES
      openr,lun,install_directory+'l2_preferences.txt',/get_lun
      while not eof(lun) do begin
        line=''
        readf,lun,line
        tokens = strsplit(line,' ',/extract)
        if tokens[0] ne ';' then begin
        case tokens[0] of
          'l2_top_data_dir:':  l2_data_dir = tokens[1]
          else                        :  print, 'Unknown preference: ', tokens[0], ' ', tokens[1]
        endcase
        
      endif
    endwhile
    free_lun,lun
    
    
    ;IF NO TOP LEVEL l2 DIRECOTRY FOUND IN PREFS FILE, PROMPT USER TO RE-RUN WITH UPDATE-PREFS OPTION (FIXME)
    if l2_data_dir eq '' then begin
      print,      'Error: l2_top_data_dir: /path/ found in l2_preferences.txt file.'
      error_msg = 'Re run with /UPDATE_PREFS or manually fix l2_preferences.txt file.'
      message, error_msg
    endif
    
    ;; no l2 preferences file found
    endif else begin
      ;PROMPT USER FOR PATH
      print, ""
      print, "No l2_preferences.txt file found. Now prompting for directory to top level l2 data directory"
      print, "This top level data directory must contain sub directories for each instrument that match the SDC structure:"
      print, "<top_level>/sta/l2/"
      print, "<top_level>/sep/l2/"
      print, "... continue for all 8 instruments ..."
      print, ""
      print, "If you want these directories created for you, re-run with the /create_dirs keyword. "
      
      l2_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the top level l2 data directory')
      if l2_data_dir eq '' then message, "Canceled directory choice. Must choose path to top level l2 data directory. Exiting..."
      
    endelse
  
  endif else begin

  ;PROMPT USER FOR PATH
  print, ""
  print, "/update_prefs keyword given. Now prompting for directory to top level l2 data directory"
  print, "This top level data directory must contain sub directories for each instrument that match the SDC structure:"
  print, "<top_level>/sta/l2/"
  print, "<top_level>/sep/l2/"
  print, "... continue for all 8 instruments ..."
  print, ""
  print, "If you want these directories created for you, re-run with the /create_dirs keyword. "
  
  l2_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the top level l2 data directory')
  if l2_data_dir eq '' then message, "Canceled directory choice. Must choose path to top level l2 data directory. Exiting..."
  
  endelse



  ;WRITE/UPDATE l2 PREFERENCES FILE IF NECESSARY
  if keyword_set(update_prefs) then begin
    ;CREATE l2_preferences.txt FOR FUTURE USE
    openw,lun,install_directory+'l2_preferences.txt',/get_lun
    printf,lun,'; IDL Toolkit l2 data Preferences File'
    printf,lun,'l2_top_data_dir: '+l2_data_dir
    free_lun,lun
    print, "Updated/created l2_preferences.txt file."
  endif

  
  ;; Create l2 directory structure under top level data directory
  if keyword_set(create_dirs) then begin
    l2_dirs_to_create = ['sta'+path_sep()+'l2', $
      'sep'+path_sep()+'l2', $
      'swi'+path_sep()+'l2', $
      'swe'+path_sep()+'l2', $
      'lpw'+path_sep()+'l2', $
      'mag'+path_sep()+'l2', $
      'iuv'+path_sep()+'l2', $
      'ngi'+path_sep()+'l2']
      
      
    print, "Creating (if not already present) directories:
    for dir_i=0, n_elements(l2_dirs_to_create)-1 do begin
      file_mkdir, l2_data_dir+path_sep()+l2_dirs_to_create[dir_i]
      print, "  "+string(l2_data_dir+path_sep()+l2_dirs_to_create[dir_i])
    endfor
    
  endif

end