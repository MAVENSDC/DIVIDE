

function mvn_kp_config, insitu_file_spec=insitu_file_spec, iuvs_file_spec=iuvs_file_spec, data_retrieval=data_retrieval, $
  orbit_number=orbit_number, iuvs_data=iuvs_data, orbit_file_location=orbit_file_location, private=private, $
  template_file_location=template_file_location, source_files_location=source_Files_location
  
  
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
      iuvs_filename_spec   = create_struct('pattern', 'mvn_kp_iuvs_*_*T*', $
      'orbit_index', 12, $
      'year_index', 18, $
      'month_index', 22, $
      'day_index', 24, $
      'hour_index', 27, $
      'min_index', 29, $
      'sec_index', 31, $
      'basetrim', 33, $
      'vpos', 4, $
      'rpos', 5)
      
    return, iuvs_filename_spec
  endif
  
  ;; Infomration describing the web services for downloading data files
  if keyword_set(data_retrieval) then begin
  
  if (keyword_set(private)) then begin

  ; Restricted production SDC server
  sdc_server_spec = create_struct($
    'url_path_file_names', '/maven/sdc/service/files/api/v1/search/science/fn_metadata/file_names', $
    'url_path_download', '/maven/sdc/service/files/api/v1/search/science/fn_metadata/download', $
    'host', 'lasp.colorado.edu', $
    'port', 443, $,
    'url_scheme', 'https', $
    'authentication', 1, $
    'check_max_files', 0, $
    'max_files', 200, $
    'expire_duration', 86400)
   endif else begin
   sdc_server_spec = create_struct($
    'url_path_file_names', '/maven/sdc/public/files/api/v1/search/science/fn_metadata/file_names', $
    'url_path_download', '/maven/sdc/public/files/api/v1/search/science/fn_metadata/download', $
    'host', 'lasp.colorado.edu', $
    'port', 443, $,
    'url_scheme', 'https', $
    'authentication', 0, $
    'check_max_files', 0, $
    'max_files', 200, $
    'expire_duration', 86400)
    endelse 
    
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
    
    ;UPDATE FILES IN TIME ORDER HERE AS NEEDED
    base_url_path = '/pub/naif/MAVEN/kernels/spk/'
    orbit_files_rec = ['maven_orb_rec_140922_150101_v1.orb',$
                      'maven_orb_rec_150101_150401_v1.orb',$
                      'maven_orb_rec_150401_150701_v1.orb',$
                      'maven_orb_rec_150701_151001_v1.orb',$
                      'maven_orb_rec.orb']
    
    
    orbit_file_server_spec = create_struct($
      'host', 'naif.jpl.nasa.gov/', $
      'port', 80, $
      'username', '', $
      'password', '', $
      'url_scheme', 'http', $
      'authentication', 0, $
      'url_path', base_url_path+orbit_files_rec,$
      'orbit_filename', orbit_files_rec)
    
    return, orbit_file_server_spec
  endif
  
  ;; Information for where to download template files from
  if keyword_set(template_file_location) then begin

    base_url_path = '/maven/sdc/public/data/sdc/software/idl_toolkit/Templates'

    template_file_server_spec = create_struct($
      'host', 'lasp.colorado.edu/', $
      'port', 80, $
      'username', '', $
      'password', '', $
      'url_scheme', 'https', $
      'authentication', 0, $
      'url_path', base_url_path)

    return, template_file_server_spec
  endif
  
  ;; Information for where to download source code from
  if keyword_set(source_files_location) then begin

    base_url_path = '/maven/sdc/public/data/sdc/software/idl_toolkit/Source'

    source_files_server_spec = create_struct($
      'host', 'lasp.colorado.edu/', $
      'port', 80, $
      'username', '', $
      'password', '', $
      'url_scheme', 'https', $
      'authentication', 0, $
      'url_path', base_url_path)

    return, source_files_server_spec
  endif
  
  ;; Information regarding the IUVS kp data format
  if keyword_set(iuvs_data) then begin
    
    iuvs_data_spec = create_struct($
      'num_common', 23 )
      
    return, iuvs_data_spec
  endif
  
  
  
  return, 0
  
end
