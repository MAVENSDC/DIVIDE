;;
;; Routine to test install of Toolkit
;;
;; 


pro mvn_kp_test_install, test_number


  ;;
  
  test_result = routine_info('mvn_kp_test_install',/source)
  test_directory = strsplit(test_result.path,'mvn_kp_test_install.pro',$
                            /extract,/regex)
  test_file_directory = test_directory+path_sep()+'install_test'+path_sep()
  
  insitu_cdf = test_file_directory+'mvn_kp_insitu_20150403_v01_r01.cdf'
  insitu_txt = test_file_directory+'mvn_kp_insitu_20150406_v01_r01.tab'
  
;-orig
;  iuvs_cdf   = test_file_directory+'mvn_kp_iuvs_20141029T031433_v00_r00.cdf'
;  iuvs_txt   = test_file_directory+'mvn_kp_iuvs_20141030T021404_v00_r00.tab'
  iuvs_txt = test_file_directory+'mvn_kp_iuvs_20141022T031211_v02_r00.tab' 
  iuvs_cdf = test_file_directory+'mvn_kp_iuvs_20141022T031211_v02_r00.cdf'
  iuvs_txt = test_file_directory+'mvn_kp_iuvs_20141018T160558_v02_r00.tab'
  iuvs_cdf = test_file_directory+'mvn_kp_iuvs_20141018T160558_v02_r00.cdf'

  ;SET ALL INSTRUMENT FLAGS TO 1 TO CREATE
  ;FULL STRUCTURE FOR ALL INSTRUMENT DATA
  instruments = CREATE_STRUCT('lpw',      1, 'euv',      1, 'static',   1, $
    'swia',     1, $
    'swea',     1, 'mag',      1, 'sep',      1, $
    'ngims',    1, 'periapse', 1, 'c_e_disk', 1, $
    'c_e_limb', 1, 'c_e_high', 1, 'c_l_disk', 1, $
    'c_l_limb', 1, 'c_l_high', 1, 'apoapse' , 1, $
    'stellarocc', 1)

  results = []
  results_txt = []
  
  
  ;;
  ;; Test ASCII Read
  ;;
  print, "Starting tests..."
  
  message, /reset
  cmd = "mvn_kp_read_insitu_file, '"+insitu_txt+"', insitu, /text_files"
  
  return = EXECUTE(cmd[0])
  if !ERROR_STATE.CODE NE 0 then begin
    ;; Error occured
    results_txt = [results_txt, "[INSTALL TEST] - ERROR with: ASCII Test 1"]
    results_txt = [results_txt, "                  ----- "+!ERROR_STATE.MSG]
  endif else begin
    ;; Success
    results_txt = [results_txt, "[INSTALL TEST] - SUCCESS with: ASCII Test 1"]
  endelse
  
  message, /reset
  cmd = "mvn_kp_read_iuvs_file, '"+iuvs_txt+"', iuvs, /text_files"
  return = EXECUTE(cmd[0])
  if !ERROR_STATE.CODE NE 0 then begin
    ;; Error occured
    results_txt = [results_txt,"[INSTALL TEST] - ERROR with: ASCII Test 2"]
    results_txt = [results_txt,"                  ----- "+!ERROR_STATE.MSG]
  endif else begin
    ;; Success
    results_txt = [results_txt, "[INSTALL TEST] - SUCCESS with: ASCII Test 2"]
  endelse
  
  
  ;;
  ;; Test CDF Read
  ;;
  
  
  message, /reset
  cmd = "mvn_kp_read_insitu_file, '"+insitu_cdf+"', insitu"
  
  return = EXECUTE(cmd[0])
  if !ERROR_STATE.CODE NE 0 then begin
    ;; Error occured
    results = [results, "[INSTALL TEST] - ERROR with: CDF Test 1"]
    results = [results, "                  ----- "+!ERROR_STATE.MSG]
  endif else begin
    ;; Success
    results = [results, "[INSTALL TEST] - SUCCESS with: CDF Test 1"]
  endelse
  
  message, /reset
  cmd = "mvn_kp_read_iuvs_file, '"+iuvs_cdf+"', iuvs, instruments=instruments"
  return = EXECUTE(cmd[0])
  if !ERROR_STATE.CODE NE 0 then begin
    ;; Error occured
    results = [results,"[INSTALL TEST] - ERROR with: CDF Test 2"]
    results = [results,"                  ----- "+!ERROR_STATE.MSG]
  endif else begin
    ;; Success
    results = [results, "[INSTALL TEST] - SUCCESS with: CDF Test 2"]
  endelse
  
  print, "Completed tests."
  
  
  
  ;; Print Results
  
  print, ""
  print, ""
  print, "Install ASCII read test results"
  print, ""
  for I=0, n_elements(results_txt)-1 do begin
    print, results_txt[I]
  endfor
  
  print, ""
  print, "Install CDF read test results"
  print, ""
  for I=0, n_elements(results)-1 do begin
    print, results[I]
  endfor
  

  
  
  
end
