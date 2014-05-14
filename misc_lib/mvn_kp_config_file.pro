

pro mvn_kp_config_file, insitu_data_dir=insitu_data_dir, iuvs_data_dir=iuvs_data_dir, $
                        update_prefs=update_prefs

;; ------------------------------------------------------------------------------------ ;;
;; ----------------------- Read or create preferences file ---------------------------- ;;


;FIXME TAKE ANOTHER LOOK OVER LOGIC HERE, MAKE SURE SOLID ENOUGH
install_result = routine_info('mvn_kp_config_file',/source)
install_directory = strsplit(install_result.path,'mvn_kp_config_file.pro',/extract,/regex)
install_directory = install_directory+path_sep()+'..'+path_sep()
insitu_data_dir = ''
iuvs_data_dir = ''
if not keyword_set(update_prefs) then begin

  ;CHECK IF THE PREFERENCES FILE EXISTS & READ IF IT DOES
  preference_exists = file_search(install_directory,'kp_preferences.txt',count=kp_pref_exists)
  if kp_pref_exists ne 0 then begin
  
    ;LOOP THROUGH KP PREFS FILE LOOKING FOR PARTICULAR PREFERENCES
    openr,lun,install_directory+'kp_preferences.txt',/get_lun
    while not eof(lun) do begin
      line=''
      readf,lun,line
      tokens = strsplit(line,' ',/extract)
      if tokens[0] ne ';' then begin
      case tokens[0] of
        'insitu_data_dir:':  insitu_data_dir = tokens[1]
        'iuvs_data_dir:'  :  iuvs_data_dir   = tokens[1]
        else                        :  print, 'Unknown preference: ', tokens[0], ' ', tokens[1]
      endcase
      
    endif
  endwhile
  free_lun,lun
  
  ;IF NO INSITU DIRECOTRY FOUND IN PREFS FILE, PROMPT USER TO RE-RUN WITH UPDATE-PREFS OPTION (FIXME)
  if insitu_data_dir eq '' then begin
    print,      'Error: No insitu_data_dir: /path/ found in kp_preferences.txt file.'
    error_msg = 'Re run mvn_kp_read with /UPDATE_PREFS or manually fix kp_preferences.txt file.'
    message, error_msg
  endif
  
  ;IF NO IUVS DIRECTORY AND NOT IN INSITU ONLY MODE, PROMPT USER FOR IUVS DIRECTORY
  if iuvs_data_dir eq '' and not keyword_set(insitu_only) then begin
    print, "kp_preferences.txt file only contains insitu path. Requesting path to IUVS data..."
    iuvs_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing IUVS KP data files')
    update_prefs=1
  endif
  
endif else begin
  ;NO PREFS FILE EXISTS, PROMPT USER FOR PATHS
  insitu_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing insitu KP data files')
  
  if not keyword_set(insitu_only) then begin
    iuvs_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing IUVS KP data files')
  endif
  update_prefs=1
endelse

endif else begin
  ;WETHER OR NOT kp_preferences.txt FILE EXISTS, USE DIALOG BOXES TO REQUEST NEW LOCATIONS AND THEN WRITE (OR OVERWRITE) kp_preferences.txt
  ;FIXME - THIS LOGIC CAN BE CLEANED UP
  
  insitu_data_dir = dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing insitu KP data files')
  iuvs_data_dir =   dialog_pickfile(path=install_directory,/directory,title='Choose the directory containing IUVS KP data files')
  update_prefs=1
  
endelse


;WRITE/UPDATE PREFERENCES FILE IF NECESSARY
if keyword_set(update_prefs) then begin
  ;CREATE KP_PREFERENCES.TXT FOR FUTURE USE
  openw,lun,install_directory+'kp_preferences.txt',/get_lun
  printf,lun,'; IDL Toolkit KP Reader Preferences File'
  printf,lun,'insitu_data_dir: '+insitu_data_dir
  if iuvs_data_dir ne '' then printf,lun,'iuvs_data_dir: '+iuvs_data_dir
  free_lun,lun
endif

end