;+
; Test of mvn_kp_insitu_search
;
; :Author:  John Martin
;-

pro mvn_kp_insitu_search_ut::setup
  compile_opt strictarr
  
end

function mvn_kp_insitu_search_ut::test_insitu_search_list
  compile_opt strictarr
  
  ;; Read in data to search against
  mvn_kp_read, ['2014-10-05/01:00:00', '2014-10-05/02:00:00'] , insitu, /insitu_only, /text_files
  
  ;; Test listing insitu parameters that can be searched on
  ;; Compare output line by line against known good output
  install_result = routine_info('mvn_kp_insitu_search_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_insitu_search_ut__define.pro',/extract,/regex)
  test_journal = install_directory+path_sep()+'known_files'+path_sep()+'actual_list.txt'
  journal, test_journal
  mvn_kp_insitu_search,insitu,insitu_out,/list
  journal

  ;; Open known good output
  install_result = routine_info('mvn_kp_insitu_search_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_insitu_search_ut__define.pro',/extract,/regex)
  correct_list = install_directory+path_sep()+'known_files'+path_sep()+'test_insitu_search_list.txt'
  
  openr,lun1,test_journal,/get_lun
  openr,lun2,correct_list, /get_lun
  
  ;; Ignore header
  while not eof(lun2) do begin
    line1 = ''
    readf,lun2,line1
    if line1 eq ';Fields available for searching are as follows' then break
  endwhile
  
  while not eof(lun1) do begin
    line2 = ''
    readf,lun1,line2
    if line2 eq ';Fields available for searching are as follows' then break
  endwhile
  
  ;; Make sure we found the end of the header
  assert, line1 eq ';Fields available for searching are as follows', "Problem parsing header of list output"
  assert, line2 eq ';Fields available for searching are as follows', "Problem parsing header of list output"
  
  ;; Compare line by line
  while not eof(lun2) do begin
    readf, lun1, line1
    readf, lun2, line2
    assert, line1 eq line2, "Output of /list incorrect:   LINE 1: " + line1 + "   LINE 2:  " + line2
  endwhile
  
  return, 1
end

function mvn_kp_insitu_search_ut::test_insitu_search_param_num
  compile_opt strictarr
  
  ;; Read in data to search against
  mvn_kp_read, ['2014-10-05/01:00:00', '2014-10-06/02:00:00'] , insitu, /insitu_only, /text_files

  ;; Test searching based on one param number with min, max, min&max
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=202,min=1000
  assert, size(insitu_out, /N_ELEMENTS) eq 9853, "Wrong number of records returned from search"
    
  return, 1
end

function mvn_kp_insitu_search_ut::test_insitu_search_param_string
  compile_opt strictarr
  
  ;; Read in data to search against
  mvn_kp_read, ['2014-10-07/01:00:00', '2014-10-09/18:02:00'] , insitu, /insitu_only, /text_files
  
  ;; Test searching based on one param string with min, max, min&max
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='SPACECRAFT.ALTITUDE', max=200
  assert, size(insitu_out, /N_ELEMENTS) eq 1094, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='STATIC.HPLUS_CHARACTERISTIC_ENERGY', max=800
  assert, size(insitu_out, /N_ELEMENTS) eq 11679, "Wrong number of records returned from search"

  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='spacecraft.sub_sc_latitude', min=70
  assert, size(insitu_out, /N_ELEMENTS) eq 884, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='spacecraft.sub_sc_latitude', min=50, max=65
  assert, size(insitu_out, /N_ELEMENTS) eq 1833, "Wrong number of records returned from search"
   
  return, 1
end

function mvn_kp_insitu_search_ut::test_insitu_search_multiple_param
  compile_opt strictarr
  
  ;; Read in data to search against
  mvn_kp_read, ['2014-10-05/01:00:00', '2014-10-09/01:00:00'] , insitu, iuvs, /text_files
  
  ;; Test searching multiple paramaters at once
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=[202, 78], max=[4000,6000]
  assert, size(insitu_out, /N_ELEMENTS) eq 6021, "Wrong number of records returned from search"

  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=['NGIMS.NPLUS_DENSITY', 'SPACECRAFT.SZA', 'SEP.ION_ENERGY_FLUX_2_FRONT'] ,min=[-1,5,-1], max=[4000,5000, 1000]
  assert, insitu_out eq 0, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=[186,190], min=[-1,-4], max=10
  assert, size(insitu_out, /N_ELEMENTS) eq 46491, "Wrong number of records returned from search"
  
  return, 1
end


pro mvn_kp_insitu_search_ut::teardown
  compile_opt strictarr
  
end


pro mvn_kp_insitu_search_ut__define
  compile_opt strictarr
  
  define = { mvn_kp_insitu_search_ut, inherits MGutTestCase }
end
