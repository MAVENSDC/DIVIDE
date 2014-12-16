

function mvn_kp_config, insitu_file_spec=insitu_file_spec, iuvs_file_spec=iuvs_file_spec, data_retrieval=data_retrieval, $
  orbit_number=orbit_number, iuvs_data=iuvs_data, orbit_file_location=orbit_file_location
  
  
  ;; Information describing the in situ filenames and where dates & versions are located
  if keyword_set(insitu_file_spec) then begin
      
      ;; Production filename spec
      insitu_filename_spec = create_struct('pattern', 'mvn_kp_insitu_*', $
      'year_index', 14, $
      'month_index', 18, $
      'day_index', 20, $
      'basetrim', 23, $
      'vpos', 4, $
      'rpos', 5)
        
    return, insitu_filename_spec
    
  endif
  
  
  ;; Information describing the iuvs filenames and where dates & versions are located
  if keyword_set(iuvs_file_spec) then begin
      
      ;; Production filename spec
      iuvs_filename_spec   = create_struct('pattern', 'mvn_kp_iuvs_*T*', $
      'year_index', 12, $
      'month_index', 16, $
      'day_index', 18, $
      'hour_index', 21, $
      'min_index', 23, $
      'sec_index', 25, $
      'basetrim', 27, $
      'vpos', 4, $
      'rpos', 5)
      
    return, iuvs_filename_spec
  endif
  
  
  ;; Infomration describing the web services for downloading data files
  if keyword_set(data_retrieval) then begin
  
  ; Restricted production SDC server
  sdc_server_spec = create_struct($
    'url_path_file_names', '/maven/sdc/service/files/api/v1/search/science/fn_metadata/file_names', $
    'url_path_download', '/maven/sdc/service/files/api/v1/search/science/fn_metadata/download', $
    'host', 'lasp.colorado.edu', $
    'port', 80, $,
    'url_scheme', 'https', $
    'authentication', 1, $
    'check_max_files', 0, $
    'max_files', 200, $
    'expire_duration', 86400)
      
    return, sdc_server_spec
  endif
  
  
  ;; Information regarding the orbit number file & orbit template filename
  if keyword_set(orbit_number) then begin
    orbit_number_spec = create_struct($
      'orbit_file', 'maven_orb_rec.orb', $
      'orbit_template', 'orbit_template.sav')
      
    return, orbit_number_spec
  endif
  
    
  ;; Information for where to download orbit file from
  if keyword_set(orbit_file_location) then begin
    orbit_file_server_spec = create_struct($
      'host', 'naif.jpl.nasa.gov/', $
      'port', 80, $
      'username', '', $
      'password', '', $
      'url_scheme', 'http', $
      'authentication', 0, $
      'url_path', '/pub/naif/MAVEN/kernels/spk/maven_orb_rec.orb', $
      'orbit_filename', 'maven_orb_rec.orb')
    
    return, orbit_file_server_spec
  endif
  
  ;; Infomration regarding the IUVS kp data format
  if keyword_set(iuvs_data) then begin
    
    iuvs_data_spec = create_struct($
      'num_common', 23 )
      
    return, iuvs_data_spec
  endif
  
  
  
  return, 0
  
end