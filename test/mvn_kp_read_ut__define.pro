;+
; Test of mvn_kp_read procedure
;
; :Author:  John Martin
;-

pro mvn_kp_read_ut::setup
  compile_opt strictarr
  
end


function mvn_kp_read_ut::test_read_insitu_only
  compile_opt strictarr
  ;; Test reading in only INSITU data
  mvn_kp_read, '2015-04-08/01:00:00' , insitu, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 11825, "Wrong number of data points read in"
   
  mvn_kp_read, ['2015-04-08/23:58:00', '2015-04-09/00:01:05'] , insitu,  /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 47, "Wrong number of data points read in"
  insitu=0
  
  mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /ngims, /static, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 89993, "Wrong number of data points read in"
  insitu=0
  
  mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /insitu_all, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 89993, "Wrong number of data points read in"
  insitu=0
  
  mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /ngims, /static, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 89993, "Wrong number of data points read in"

return, 1
end

function mvn_kp_read_ut::test_read_single_string_time
  compile_opt strictarr
  ;; Test single time input - binary
  mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 11864, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 6, "Wrong number of iuvs data points read in"

  return, 1
end

function mvn_kp_read_ut::test_read_array_string_time
  compile_opt strictarr 
  ;; Test range time input - binary
  mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 20446, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 9, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  ;; Test range time input longer time input
  mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 68303, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 31, "Wrong number of iuvs data points read in"
  
  return, 1
end


function mvn_kp_read_ut::test_read_subset_inst
  compile_opt strictarr  
  ;; Test specifying certain instruments
  mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/ngims,/sep,/iuvs_periapse
  assert, size(insitu, /N_ELEMENTS) eq 11655, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/lpw,/euv,/iuvs_apoapse
  assert, size(insitu, /N_ELEMENTS) eq 11655, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  
  return, 1
end

function mvn_kp_read_ut::test_read_inbound_flag
  compile_opt strictarr
  ;; Test inbound flag & instruments
  mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound
  assert, size(insitu, /N_ELEMENTS) eq 5960, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_read_small_time_span
  compile_opt strictarr
  ;; FIXME - TTHe iuvs output here is broken THere should be no iuvs returned
  mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 454, "Wrong number of insitu data points read in"
  assert, iuvs eq 0, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_try_read_data_dont_have
  compile_opt strictarr

  insitu = 0
  iuvs = 0
  mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs
  assert, insitu eq 0, "Wrong number of insitu data points read in"
  assert, iuvs eq 0, "Wrong number of iuvs data points read in"

  return, 1
end

;  ;; FIXME - Update when we have CDF versions of data files in orbit # range
;function mvn_kp_read_ut::test_read_orbit_number_input
;  compile_opt strictarr
;  ;; Test orbit time range input
;  mvn_kp_read, 1021 , insitu, /insitu_only
;  assert, size(insitu, /N_ELEMENTS) ne 0, "Data not read in when orbit number specified"
;  mvn_kp_read, [1021,1030] , insitu, /insitu_only 
;  mvn_kp_read, 1035 , insitu, iuvs
;  mvn_kp_read, [1035,1040] , insitu, iuvs
;  
;  return, 1
;end

function mvn_kp_read_ut::test_read_ascii_insitu_only
  compile_opt strictarr
  ;; Test reading in only INSITU data
  mvn_kp_read, '2015-04-03/01:00:00' , insitu, /text_files, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 11843, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-10/17:01:05'] , insitu, /text_files, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 78150, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  mvn_kp_read, ['2015-04-08/00:00:00', '2015-04-11/00:00:01'] , insitu, /text_files, /swia, /mag, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 35134, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0  
  
  mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-24/17:01:05'] , insitu, /text_files, /insitu_all, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 31363, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_read_ascii
  compile_opt strictarr
  ;; Test reading in ascii data with single time input & array time input
  mvn_kp_read, '2015-04-02/03:04:00' , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 11865, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 6, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  mvn_kp_read, ['2015-04-05/00:00:00', '2015-04-08/17:01:05'] , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 43468, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 20, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
    
  return, 1
end

function mvn_kp_read_ut::test_read_ascii_subset
  compile_opt strictarr
  ;; Test reading in a subset of ascii data
  mvn_kp_read, ['2015-04-08/00:00:15', '2015-04-11/00:00:01'] , insitu, iuvs, /text_files, /swia, /mag, /iuvs_periapse, /iuvs_apoapse
  assert, size(insitu, /N_ELEMENTS) eq 35132, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 16, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 23103, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 11, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-27/17:01:05'] , insitu, iuvs, /text_files, /insitu_all, /iuvs_all
  assert, size(insitu, /N_ELEMENTS) eq 66489, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 31, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_read_ascii_orbit_number_input
  compile_opt strictarr  
  
  ;; First download latest maven orbit # file
  mvn_kp_download_orbit_file
  
  ;; Test reading in ascii files when giving orbit number for time
  insitu=0
  iuvs=0
  mvn_kp_read, [3,150] , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 11637, "Wrong number of insitu data points read in" 
  assert, iuvs eq 0, "Wrong number of IUVS data points read in"
  
  return, 1
end

function mvn_kp_read_ut::test_read_ascii_data_dont_have
  compile_opt strictarr
  ;; Test reading in ascii data we don't have
  insitu=0
  iuvs=0
  mvn_kp_read, '2015-01-03/10:00:00' , insitu, iuvs, /text_files
  assert, insitu eq 0 AND iuvs eq 0, "Output variables filled when no data files present for input time."
  return, 1
end


pro mvn_kp_read_ut::teardown
  compile_opt strictarr
  
end


pro mvn_kp_read_ut__define
  compile_opt strictarr

  define = { mvn_kp_read_ut, inherits MGutTestCase }
end
