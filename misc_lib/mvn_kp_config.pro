

function mvn_kp_config, insitu_file_spec=insitu_file_spec, iuvs_file_spec=iuvs_file_spec, data_retrieval=data_retrieval, $
                        orbit_number=orbit_number, iuvs_data=iuvs_data
 
  if keyword_set(insitu_file_spec) then begin
    ;  insitu_filename_spec = create_struct('pattern', 'mvn_KP_l2_pf*', $
    ;                                       'year_index', 13, $
    ;                                       'month_index', 17, $
    ;                                       'day_index', 19, $          ;; FIXME OLD FILE PATTERN HERE FOR CONVIENCE
    ;                                       'basetrim', 21, $
    ;                                       'vpos', 5, $
    ;                                       'rpos', 6)
    ;
    
    
    ;; Globals Describing the filenames and where dates & versions are located
    insitu_filename_spec = create_struct('pattern', 'mvn_pfp_l2_keyparam_*', $
      'year_index', 20, $
      'month_index', 25, $
      'day_index', 28, $
      'basetrim', 30, $
      'vpos', 7, $
      'rpos', 8)
    
    return, insitu_filename_spec
  endif
    
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


  if keyword_set(data_retrieval) then begin
    
    ;; Rstricted live
;    sdc_server_spec = create_struct($
;      'url_path_file_names', '/maven/sdc/service/files/api/v1/file_names/science', $
;      'url_path_download', '/maven/sdc/service/files/api/v1/download/science', $
;      'host', 'lasp.colorado.edu', $
;      'port', 80, $,
;      'url_scheme', 'https', $
;      'authentication', 1, $
;      'check_max_files', 0, $
;      'max_files', 500, $
;      'expire_duration', 86400)
    
    ;; Unrestricted dev
;    sdc_server_spec = create_struct($
;    'url_path_file_names', '/unrestricted/api/v1/file_names/science', $
;    'url_path_download', '/unrestricted/api/v1/download/science', $
;    'host', '10.247.10.27', $
;    'port', 40080, $
;    'url_scheme', 'https', $
;    'authentication', 0, $
;    'check_max_files', 1, $
;    'max_files', 500, $
;    'expire_duration', 86400)
    
    
    ;; Rstricted dev
;    sdc_server_spec = create_struct($
;    'url_path_file_names', '/api/v1/file_names/science', $
;    'url_path_download', '/api/v1/download/science', $
;    'host', '10.247.10.27', $
;    'port', 40080, $
;    'url_scheme', 'http', $
;    'authentication', 1, $
;    'check_max_files', 0, $
;    'max_files', 500, $
;    'expire_duration', 86400)

    ;; Unrestricted dev
    sdc_server_spec = create_struct($
      'url_path_file_names', '/maven/sdc/service/files/api/v1/file_names/science', $
      'url_path_download', '/maven/sdc/service/files/api/v1/download/science', $
      'host', 'sdc-webdev1', $
      'port', 80, $
      'url_scheme', 'http', $
      'authentication', 0, $
      'check_max_files', 1, $
      'max_files', 500, $
      'expire_duration', 86400)
  
    
    return, sdc_server_spec
    
  endif
  
  if keyword_set(orbit_number) then begin
    orbit_number_spec = create_struct($
      'orbit_file', 'MVN_Orbit_Sequence.txt', $
      'orbit_template', 'orbit_template.sav')
      
      return, orbit_number_spec
  endif
  
  
  if keyword_set(iuvs_data) then begin
    iuvs_data_spec = create_struct($
      'num_common', 23 )
      
    return, iuvs_data_spec
  endif
  
  

  return, 0

end