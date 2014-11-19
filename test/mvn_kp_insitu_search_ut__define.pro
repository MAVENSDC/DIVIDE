;+
; Test of mvn_kp_insitu_search
;
; :Author:  John Martin
;-

pro mvn_kp_insitu_search_ut::setup
  compile_opt strictarr
  
  ;; Modify this if running locally (set up for Jenkins build server)
  mvn_root_data_dir = '/maven/DIViDE_Toolkit/Sample_Data/'
  
  ;; Temp copy preference file is one exists so don't overwrite it
  install_result = routine_info('mvn_kp_insitu_search_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_insitu_search_ut__define.pro',/extract,/regex)
  install_directory = install_directory+path_sep()+'..'+path_sep()
  if file_test(install_directory+'mvn_toolkit_prefs.txt') then begin
    file_move, install_directory+'mvn_toolkit_prefs.txt', install_directory+'mvn_toolkit_prefs.txt.bak'
  endif
  
  ;; Create a config file pointing to the root data dir
  ;; on dsinteg1
  openw,lun,install_directory+'mvn_toolkit_prefs.txt',/get_lun
  printf,lun,'; IDL Toolkit Data Preferences File'
  printf,lun,'mvn_root_data_dir: '+mvn_root_data_dir
  free_lun,lun
  print, "Updated/created mvn_toolkit_prefs.txt file."
  
end


function mvn_kp_insitu_search_ut::test_insitu_search_list
  compile_opt strictarr

  ;; Read in data to search against  
  mvn_kp_read, ['2015-04-05/01:00:00', '2015-04-05/02:00:00'] , insitu, /insitu_only

  ;; Test listing insitu parameters that can be searched on
  mvn_kp_insitu_search,insitu,insitu_out,/list
  
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
  
  install_result = routine_info('mvn_kp_insitu_search_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_insitu_search_ut__define.pro',/extract,/regex)
  install_directory = install_directory+path_sep()+'..'+path_sep()
  
  ;; Remove temp config file
  file_delete,install_directory+'mvn_toolkit_prefs.txt'
  
  ;; If we backed up an exisiting pref file, move it back.
  if file_test(install_directory+'mvn_toolkit_prefs.txt.bak') then begin
    file_move, install_directory+'mvn_toolkit_prefs.txt.bak', install_directory+'mvn_toolkit_prefs.txt'
  endif
  
end


pro mvn_kp_insitu_search_ut__define
  compile_opt strictarr
  
  define = { mvn_kp_insitu_search_ut, inherits MGutTestCase }
end
