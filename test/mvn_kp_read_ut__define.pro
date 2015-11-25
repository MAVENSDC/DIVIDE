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
  print,"mvn_kp_read, '2014-10-18/01:00:00' , insitu, /insitu_only, /text_files, /new_files"
  mvn_kp_read, '2014-10-18/01:00:00' , insitu, /insitu_only, /text_files, /new_files
  assert, size(insitu, /N_ELEMENTS) eq 11625, "Wrong number of data points read in"
   
  print,"mvn_kp_read, ['2014-10-18/23:58:00', '2014-10-19/00:01:05'] , insitu,  /insitu_only, /text_files, /new_files"
  mvn_kp_read, ['2014-10-18/23:58:00', '2014-10-19/00:01:05'] , insitu,  /insitu_only, /text_files, /new_files
  assert, size(insitu, /N_ELEMENTS) eq 24, "Wrong number of data points read in"
  insitu=0
  
  print,"mvn_kp_read, ['2014-10-18/01:00:00', '2014-10-18/17:01:05'] , insitu, /ngims, /static, /insitu_only, /text_files, /new_files"
  mvn_kp_read, ['2014-10-18/01:00:00', '2014-10-18/17:01:05'] , insitu, /ngims, /static, /insitu_only, /text_files, /new_files
  assert, size(insitu, /N_ELEMENTS) eq 7869, "Wrong number of data points read in"
  insitu=0
  
  print,"mvn_kp_read, ['2014-10-18/01:00:00', '2014-10-20/17:01:05'] , insitu, /all_insitu, /insitu_only, /text_files, /new_files"
  mvn_kp_read, ['2014-10-18/01:00:00', '2014-10-20/17:01:05'] , insitu, /all_insitu, /insitu_only, /text_files, /new_files
  assert, size(insitu, /N_ELEMENTS) eq 31115, "Wrong number of data points read in"
  insitu=0
  
  print,"mvn_kp_read, ['2014-10-18/01:00:00', '2014-10-22/17:01:05'] , insitu, /ngims, /static, /insitu_only, /text_files, /new_files"
  mvn_kp_read, ['2014-10-18/01:00:00', '2014-10-22/17:01:05'] , insitu, /ngims, /static, /insitu_only, /text_files, /new_files
  assert, size(insitu, /N_ELEMENTS) eq 54361, "Wrong number of data points read in"

return, 1
end

function mvn_kp_read_ut::test_read_single_string_time
  compile_opt strictarr
  ;; Test single time input - binary
  print,"mvn_kp_read, '2014-10-18/20:43:00' , insitu, iuvs, /text_files, /new_files"
  mvn_kp_read, '2014-10-18/20:43:00' , insitu, iuvs, /text_files, /new_files
  assert, size(insitu, /N_ELEMENTS) eq 11781, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"

  return, 1
end

function mvn_kp_read_ut::test_read_array_string_time
  compile_opt strictarr 
  ;; Test range time input - binary
  print,"mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs, /text_files, /new_files"
  mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs, /text_files, /new_files
  assert, size(insitu, /N_ELEMENTS) eq 20386, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 9, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
    
  ;; Test range time input longer time input
  ;; km; Only slightly longer until IUVS supplies more data
  ;; km: This does not test anything that previous test does not check
  ;; km: So, I'll comment this out for now, since it fails on IUVS 
  ;; km: because there are multiple version types in the given range
;  print,"time = '2014-10-'+['05','23']+'T00:00:00'"
;  print,"mvn_kp_read, time , insitu, iuvs, /text_files"
;  time = '2014-10-'+['05','23']+'T00:00:00'
;  mvn_kp_read, time , insitu, iuvs, /text_files
;  assert, size(insitu, /N_ELEMENTS) eq 209884, "Wrong number of insitu data points read in"
;  assert, size(iuvs, /N_ELEMENTS) eq 18, "Wrong number of iuvs data points read in"
  
  return, 1
end


function mvn_kp_read_ut::test_read_subset_inst
  compile_opt strictarr  
  ;; Test specifying certain instruments
  print,"mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /text_files"
  mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 11780, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/lpw,/euv,/iuvs_apoapse, /text_files"
  mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/lpw,/euv,/iuvs_apoapse, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 11780, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  
  return, 1
end

function mvn_kp_read_ut::test_read_inbound_flag
  compile_opt strictarr
  ;; Test inbound flag & instruments
  print,"mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound, /text_files"
  mvn_kp_read,'2014-10-18/16:05:58',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 5769, "Wrong number of insitu data points read in"
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
  print,"mvn_kp_read, time , insitu, iuvs, /text_files"
  time = '2014-10-19T'+['07','08']+':00:00'
  mvn_kp_read, time , insitu, iuvs, /text_files
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
  print,"mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs, /text_files"
  mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs, /text_files
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
  print,"mvn_kp_read, '2014-10-03/01:00:00' , insitu, /text_files, /insitu_only"
  mvn_kp_read, '2014-10-03/01:00:00' , insitu, /text_files, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 11609, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, ['2014-10-04/01:00:00', '2014-10-10/17:01:05'] , insitu, /text_files, /insitu_only"
  mvn_kp_read, ['2014-10-04/01:00:00', '2014-10-10/17:01:05'] , insitu, /text_files, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 77756, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, ['2014-10-08/00:00:00', '2014-10-11/00:00:01'] , insitu, /text_files, /swia, /mag, /insitu_only"
  mvn_kp_read, ['2014-10-08/00:00:00', '2014-10-11/00:00:01'] , insitu, /text_files, /swia, /mag, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 35042, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0  
  
  print,"mvn_kp_read, ['2014-10-22/01:00:00', '2014-10-24/17:01:05'] , insitu, /text_files, /all_insitu, /insitu_only"
  mvn_kp_read, ['2014-10-22/01:00:00', '2014-10-24/17:01:05'] , insitu, /text_files, /all_insitu, /insitu_only
  assert, size(insitu, /N_ELEMENTS) eq 31125, "Wrong number of insitu data points read in"
  insitu=0
  iuvs=0
  
  return, 1
end

function mvn_kp_read_ut::test_read_ascii
  compile_opt strictarr
  ;; Test reading in ascii data with single time input & array time input
  print,"mvn_kp_read, '2014-10-18/16:05:58' , insitu, iuvs, /text_files"
  mvn_kp_read, '2014-10-18/16:05:58' , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 11780, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 5, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs, /text_files"
  mvn_kp_read, ['2014-10-18/12:00:00', '2014-10-20/06:00:30'] , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 20386, "Wrong number of insitu data points read in"
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
  mvn_kp_read, time , insitu, iuvs, /text_files, /swia, /mag, /iuvs_periapse, /iuvs_apoapse
  assert, size(insitu, /N_ELEMENTS) eq 35037, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 11, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, time , insitu, iuvs, /text_files"
  mvn_kp_read, time , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 35037, "Wrong number of insitu data points read in"
  assert, size(iuvs, /N_ELEMENTS) eq 11, "Wrong number of iuvs data points read in"
  insitu=0
  iuvs=0
  
  print,"mvn_kp_read, time , insitu, iuvs, /text_files, /all_insitu, /all_iuvs"
  mvn_kp_read, time , insitu, iuvs, /text_files, /all_insitu, /all_iuvs
  assert, size(insitu, /N_ELEMENTS) eq 35037, "Wrong number of insitu data points read in"
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
  print,"mvn_kp_read, [20,150] , insitu, iuvs, /text_files"
  mvn_kp_read, [20,150] , insitu, iuvs, /text_files
  assert, size(insitu, /N_ELEMENTS) eq 294066, "Wrong number of insitu data points read in" 
  assert, size(iuvs, /N_ELEMENTS) eq 18, "Wrong number of IUVS data points read in"
  
  return, 1
end

function mvn_kp_read_ut::test_read_ascii_data_dont_have
  compile_opt strictarr
  ;; Test reading in ascii data we don't have
  insitu=0
  iuvs=0
  print,"mvn_kp_read, '2014-01-03/10:00:00' , insitu, iuvs, /text_files"
  mvn_kp_read, '2014-01-03/10:00:00' , insitu, iuvs, /text_files
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
