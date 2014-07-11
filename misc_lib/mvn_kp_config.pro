

function mvn_kp_config, insitu_file_spec=insitu_file_spec, iuvs_file_spec=iuvs_file_spec, data_retrieval=data_retrieval, $
  orbit_number=orbit_number, iuvs_data=iuvs_data
  
  
  ;; Information describing the in situ filenames and where dates & versions are located
  if keyword_set(insitu_file_spec) then begin

    insitu_filename_spec = create_struct('pattern', 'mvn_pfp_l2_keyparam_*', $
      'year_index', 20, $
      'month_index', 24, $
      'day_index', 26, $
      'basetrim', 28, $
      'vpos', 5, $
      'rpos', 6)
      
    return, insitu_filename_spec
  endif
  
  
  ;; Information describing the iuvs filenames and where dates & versions are located
  if keyword_set(iuvs_file_spec) then begin

    iuvs_filename_spec   = create_struct('pattern', 'mvn_rs_kp_*T*', $
      'year_index', 10, $
      'month_index', 14, $
      'day_index', 16, $
      'hour_index', 19, $
      'min_index', 21, $
      'sec_index', 23, $
      'basetrim', 27, $
      'vpos', 4, $
      'rpos', 5)
      
    return, iuvs_filename_spec
  endif
  
  
  ;; Infomration describing the web services for downloading data files
  if keyword_set(data_retrieval) then begin
  
    ;; Rstricted live
;        sdc_server_spec = create_struct($
;          'url_path_file_names', '/maven/sdc/service/files/api/v1/file_names/science', $
;          'url_path_download', '/maven/sdc/service/files/api/v1/download/science', $
;          'host', 'lasp.colorado.edu', $
;          'port', 80, $,
;          'url_scheme', 'https', $
;          'authentication', 1, $
;          'check_max_files', 0, $
;          'max_files', 200, $
;          'expire_duration', 86400)
    
    
    ;; Unrestricted dev
    sdc_server_spec = create_struct($
      'url_path_file_names', 'maven/sdc/service/files/api/v1/search/science/fn_metadata/file_names', $
      'url_path_download', '/maven/sdc/service/files/api/v1/search/science/fn_metadata/download', $
      'host', 'sdc-webdev1', $
      'port', 80, $
      'url_scheme', 'http', $
      'authentication', 0, $
      'check_max_files', 1, $
      'max_files', 200, $
      'expire_duration', 86400)
      
      
    return, sdc_server_spec
  endif
  
  
  ;; Information regarding the orbit number file & orbit template filename
  if keyword_set(orbit_number) then begin
    orbit_number_spec = create_struct($
      'orbit_file', 'MVN_Orbit_Sequence.txt', $
      'orbit_template', 'orbit_template.sav')
      
    return, orbit_number_spec
  endif
  
  
  ;; Infomration regarding the IUVS kp data format
  if keyword_set(iuvs_data) then begin
    
    iuvs_data_spec = create_struct($
      'num_common', 23 )
      
    return, iuvs_data_spec
  endif
  
  
  
  return, 0
  
end