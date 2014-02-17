

function mvn_kp_config, insitu_file_spec=insitu_file_spec, iuvs_file_spec=iuvs_file_spec
 
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

  return, 0

end