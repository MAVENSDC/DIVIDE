;+
; Test of mvn_kp_download_orbit_file
;
; :Author:  John Martin
;-

pro mvn_kp_download_orbit_file_ut::setup
  compile_opt strictarr

  ;; Copy local orbit file if it exists already
  install_result = routine_info('mvn_kp_download_orbit_file_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_download_orbit_file_ut__define.pro',/extract,/regex)
  install_directory = install_directory[0]+'..'+path_sep()
  
  if file_test(install_directory+'maven_orb_rec.orb') then begin
    file_move, install_directory+'maven_orb_rec.orb', install_directory+'maven_orb_rec.orb.bak'
  endif
  
end


function mvn_kp_download_orbit_file_ut::test_download_orbit_file
  compile_opt strictarr
  
  ;; Download orbit file, then convert two times
  mvn_kp_download_orbit_file
  
  mvn_kp_orbit_time, 3, 356, time1, time2
  assert, time1 eq '2014-09-24/23:59:56', "Either no orbit file, or wrong start time conversion"
  assert, time2 eq '2014-12-05/00:49:17', "Either no orbit file, or wrong end time conversion"

  return, 1
  
end


pro mvn_kp_download_orbit_file_ut::teardown
  compile_opt strictarr

  ;; Remove orbit # file
  install_result = routine_info('mvn_kp_download_orbit_file_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_download_orbit_file_ut__define.pro',/extract,/regex)
  install_directory = install_directory[0]+'..'+path_sep()

  file_delete,install_directory+'maven_orb_rec.orb'
  
  ;; Replace original, if it existed
  if file_test(install_directory+'maven_orb_rec.orb.bak') then begin
    file_move, install_directory+'maven_orb_rec.orb.bak', install_directory+'maven_orb_rec.orb'
  endif
  
end


pro mvn_kp_download_orbit_file_ut__define
  compile_opt strictarr
  
  define = { mvn_kp_download_orbit_file_ut, inherits MGutTestCase }
end
