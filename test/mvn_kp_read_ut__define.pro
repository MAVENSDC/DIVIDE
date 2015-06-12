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
  print,"mvn_kp_read, '2015-04-08/01:00:00' , insitu, /insitu_only"
  mvn_kp_read, '2015-04-08/01:00:00' , insitu, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 11825, "Wrong number of data points read in"
   
  print,"mvn_kp_read, ['2015-04-08/23:58:00', '2015-04-09/00:01:05'] , insitu,  /insitu_only"
  mvn_kp_read, ['2015-04-08/23:58:00', '2015-04-09/00:01:05'] , insitu,  /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 47, "Wrong number of data points read in"
  insitu=0
  
  print,"mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /ngims, /static, /insitu_only"
  mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /ngims, /static, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 89993, "Wrong number of data points read in"
  insitu=0
  
  print,"mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /insitu_all, /insitu_only"
  mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /insitu_all, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 89993, "Wrong number of data points read in"
  insitu=0
  
  print,"mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /ngims, /static, /insitu_only"
  mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /ngims, /static, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 89993, "Wrong number of data points read in"

return, 1
end

function mvn_kp_read_ut::test_read_single_string_time
  compile_opt strictarr
  ;; Test single time input - binary
  print,"mvn_kp_read, '2014-10-18/16:05:58' , insitu, iuvs"
  mvn_kp_read, '2014-10-18/16:05:58' , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 11758, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"

  return, 1
end

function mvn_kp_read_ut::test_read_array_string_time
  compile_opt strictarr 
  ;; Test range time input - binary
  print,"mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs"
  mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 20350, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 7, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
    
  ;; Test range time input longer time input
  ;; km; Only slightly longer until IUVS supplies more data
  print,"time = '2014-10-'+['05','23']+'T00:00:00'"
  print,"mvn_kp_read, time , insitu, iuvs"
  time = '2014-10-'+['05','23']+'T00:00:00'
  mvn_kp_read, time , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 209490, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 18, "Wrong number of iuvs data points read in"
  
  return, 1
end


function mvn_kp_read_ut::test_read_subset_inst
  compile_opt strictarr  
  ;; Test specifying certain instruments
  print,"mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse"
  mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse
  assert, size(insitu, /N_ELEMENTS) eq 11758, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/lpw,/euv,/iuvs_apoapse"
  mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/lpw,/euv,/iuvs_apoapse
  assert, size(insitu, /N_ELEMENTS) eq 11758, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  
  return, 1
end

function mvn_kp_read_ut::test_read_inbound_flag
  compile_opt strictarr
  ;; Test inbound flag & instruments
  print,"mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound"
  mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound
  assert, size(insitu, /N_ELEMENTS) eq 5766, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_read_small_time_span
  compile_opt strictarr
  ;; FIXME - THe iuvs output here is broken for CDF.  
  ;          THere should be no iuvs returned; but 2 are
  ;          The 1 returned if ASCII is the preset NaN-full structure
  ;          This may indicate an error in definition of jul time in 
  ;               the begin_time and end_time structures (+12hr?)
  print,"time = '2014-10-19T'+['07','08']+':00:00'"
  print,"mvn_kp_read, time , insitu, iuvs"
  time = '2014-10-19T'+['07','08']+':00:00'
  mvn_kp_read, time , insitu, iuvs
  assert, size(insitu, /N_ELEMENTS) eq 451, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 1 , "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_try_read_data_dont_have
  compile_opt strictarr

  insitu = 0
  iuvs = 0
  print,"mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs"
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
  print,"mvn_kp_read, '2015-04-03/01:00:00' , insitu, /text_files, /insitu_only"
  mvn_kp_read, '2015-04-03/01:00:00' , insitu, /text_files, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 11843, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-10/17:01:05'] , insitu, /text_files, /insitu_only"
  mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-10/17:01:05'] , insitu, /text_files, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 78150, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, ['2015-04-08/00:00:00', '2015-04-11/00:00:01'] , insitu, /text_files, /swia, /mag, /insitu_only"
  mvn_kp_read, ['2015-04-08/00:00:00', '2015-04-11/00:00:01'] , insitu, /text_files, /swia, /mag, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 35134, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0  
  
  print,"mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-24/17:01:05'] , insitu, /text_files, /insitu_all, /insitu_only"
  mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-24/17:01:05'] , insitu, /text_files, /insitu_all, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 31363, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_read_ascii
  compile_opt strictarr
  ;; Test reading in ascii data with single time input & array time input
  print,"mvn_kp_read, '2015-10-18/16:05:58' , insitu, iuvs, /text_files"
  mvn_kp_read, '2015-10-18/16:05:58' , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 11758, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs, /text_files"
  mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 20350, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 7, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
    
  return, 1
end

function mvn_kp_read_ut::test_read_ascii_subset
  compile_opt strictarr
  ;; Test reading in a subset of ascii data
  print,"time = '2014-10-'+['18','21']+'T00:00:00'"
  print,"mvn_kp_read, time , insitu, iuvs, /text_files, /swia, /mag, /iuvs_periapse, /iuvs_apoapse"
  time = '2014-10-'+['18','21']+'T00:00:00'
  mvn_kp_read, time , insitu, iuvs, /text_files, /swia, /mag, /iuvs_periapse, /iuvs_apoapse, /download_new
  assert, size(insitu, /N_ELEMENTS) eq 34968, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 11, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, time , insitu, iuvs, /text_files"
  mvn_kp_read, time , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 34968, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 11, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, time , insitu, iuvs, /text_files, /insitu_all, /iuvs_all"
  mvn_kp_read, time , insitu, iuvs, /text_files, /insitu_all, /iuvs_all
  assert, size(insitu, /N_ELEMENTS) eq 34968, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 11, "Wrong number of iuvs data points read in"
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
  print,"mvn_kp_read, [3,150] , insitu, iuvs, /text_files"
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
  print,"mvn_kp_read, '2015-01-03/10:00:00' , insitu, iuvs, /text_files"
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
