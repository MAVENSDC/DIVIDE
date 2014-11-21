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
  mvn_kp_read, ['2015-04-05/01:00:00', '2015-04-05/02:00:00'] , insitu, /insitu_only
  
  ;; Test listing insitu parameters that can be searched on
  ;; Compare output line by line against known good output
  test_journal = getenv('MVN_TEST_JOURNAL')
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
    line2 = ''
    readf,lun2,line1
    readf,lun1,line2
    if line1 eq ';Fields available for searching are as follows' then break
  endwhile
  
  ;; Make sure we found the end of the header
  assert, line1 eq ';Fields available for searching are as follows', "Problem parsing header of list output"
  
  ;; Compare line by line
  while not eof(lun2) do begin
    readf, lun1, line1
    readf, lun2, line2
    assert, line1 eq line2, "Output of /list incorrect"
  endwhile
  
  return, 1
end

function mvn_kp_insitu_search_ut::test_insitu_search_param_num
  compile_opt strictarr
  
  ;; Read in data to search against
  mvn_kp_read, ['2015-04-05/01:00:00', '2015-04-06/02:00:00'] , insitu, /insitu_only

  ;; Test searching based on one param number with min, max, min&max
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=181,min=1000
  assert, size(insitu_out, /N_ELEMENTS) eq 9535, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=18,max=5
  assert, size(insitu_out, /N_ELEMENTS) eq 2042, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=5,min=1,max=10
  assert, size(insitu_out, /N_ELEMENTS) eq 127, "Wrong number of records returned from search"
    
  return, 1
end

function mvn_kp_insitu_search_ut::test_insitu_search_param_string
  compile_opt strictarr
  
  ;; Read in data to search against
  mvn_kp_read, ['2015-04-07/01:00:00', '2015-04-09/18:02:00'] , insitu, /insitu_only
  
  ;; Test searching based on one param string with min, max, min&max
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='SPACECRAFT.ALTITUDE', max=200
  assert, size(insitu_out, /N_ELEMENTS) eq 1676, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='STATIC.CO2PLUS_DENSITY', max=.000001
  assert, size(insitu_out, /N_ELEMENTS) eq 7213, "Wrong number of records returned from search"

  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='spacecraft.sub_sc_latitude', min=70
  assert, size(insitu_out, /N_ELEMENTS) eq 1536, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter='spacecraft.sub_sc_latitude', min=50, max=65
  assert, size(insitu_out, /N_ELEMENTS) eq 2292, "Wrong number of records returned from search"
   
  return, 1
end

function mvn_kp_insitu_search_ut::test_insitu_search_multiple_param
  compile_opt strictarr
  
  ;; Read in data to search against
  mvn_kp_read, ['2015-04-05/01:00:00', '2015-04-09/01:00:00'] , insitu, iuvs
  
  ;; Test searching multiple paramaters at once
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=[1, 73], max=[4000,6000]
  assert, size(insitu_out, /N_ELEMENTS) eq 7496, "Wrong number of records returned from search"

  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=['NGIMS.NPLUS_DENSITY', 'SPACECRAFT.SZA', 'SEP.ION_ENERGY_FLUX_2_FRONT'] ,min=[-1,5,-1], max=[4000,5000, 1000]
  assert, insitu_out eq 0, "Wrong number of records returned from search"
  
  insitu_out=0
  mvn_kp_insitu_search,insitu,insitu_out,parameter=[185, 186,190], min=[-1,-1,-4], max=10
  assert, size(insitu_out, /N_ELEMENTS) eq 1380, "Wrong number of records returned from search"
  
  return, 1
end


pro mvn_kp_insitu_search_ut::teardown
  compile_opt strictarr
  
end


pro mvn_kp_insitu_search_ut__define
  compile_opt strictarr
  
  define = { mvn_kp_insitu_search_ut, inherits MGutTestCase }
end
