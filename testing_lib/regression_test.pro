;+
; A routine to run a series of tests on procedures and functions in the toolkit. 
;
; :Params:
;     READ : in, optional, type=boolean
;       Run tests on MVN_KP_READ
;     INSITU_SEARCH : in, optional, type=boolean
;       Run tests on MVN_KP_INSITU_SEARCH
;-

 @mvn_kp_read
 @mvn_kp_insitu_search
 

PRO REGRESSION_TEST, CDF=CDF, save_files=save_files, INSITU_SEARCH=INSITU_SEARCH, ASCII=ASCII, $
                     COMPAREINSITU=COMPAREINSITU, COMPAREIUVS=COMPAREIUVS, CREATE_TEST_SAVE=CREATE_TEST_SAVE, $
                     COMPARE_TEST_SAVE=COMPARE_TEST_SAVE

ON_ERROR, 1   ; PRINT STACK AND RETURN TO MAIN
 
 
; Default if no arguments passed
if n_params() eq 0 then begin
 ; save_files="TRUE"
  CDF="TRUE"
 ; INSITU_SEARCH="TRUE"
 ; ASCII="TRUE"
 ; COMPAREINSITU="TRUE"
 ; COMPAREIUVS="TRUE"
 
  ;; Only makes sense to run one of the below two
 ; CREATE_TEST_SAVE="TRUE"
 ; COMPARE_TEST_SAVE='TRUE'
endif

;; Make sure not both of these set:
if keyword_set(CREATE_TEST_SAVE) and keyword_set(COMPARE_TEST_SAVE) then begin
  print, "Can only specify one of the two options: CREATE_TEST_SAVE, COMPARE_TEST_SAVE"
  return
endif


;;
;; The following four arrays cannot be init empty for pre idl 8 compatability

;; Init array to hold results of the tests
test_results = ["hack"]

;; Init array to hold results of tests that SHOULD fail
test_results_prob = ["hack"]

;; Init array to hold commands to execute
cmd_list = ["hack"]

;; Init array to hold commands that should fail, and we want to see how error handling deals with them
cmd_list_prob = ["hack"]




;; ------------------------------------------------------------------------------------ ;;
;; ----------------------------- Test MVN_KP_READ ------------------------------------- ;;


if keyword_set(CDF) then begin
  ;; *** Test reading in only INSITU data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-08/01:00:00' , insitu, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu,  /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /ngims, /static, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/01:00:00', '2015-04-15/17:01:05'] , insitu, /insitu_all, /insitu_only"]
  
  
  ;; *** Test string time input ***
  
  ;; Test single time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs"]
  
  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs"]
  
  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs"]
  
  
  ;; Test specifying certain instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/ngims,/sep,/iuvs_periapse"]
  
  ;; Test inbound flag & instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound"]
  
  ;; FIXME - This is failing and shouldn't - Bigger question, how to handle time range inputs that are less than 1 day.
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs"]
  
  ;; Test single time input for files that we don't have data for - binary
  ;; This used to Error out, now it handles it and warns user.
  cmd_list = [cmd_list, "mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs"]
  
  ;; *** Test orbit time range input ***
  cmd_list = [cmd_list, "mvn_kp_read, 1021 , insitu, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, [1021,1030] , insitu, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, 1035 , insitu, iuvs"]
  cmd_list = [cmd_list, "mvn_kp_read, [1035,1040] , insitu, iuvs"]
  cmd_list = [cmd_list, "mvn_kp_read, [1024],insitu,iuvs,/ngims,/sep,/iuvs_periapse"]
  cmd_list = [cmd_list, "mvn_kp_read, [1024,1025],insitu,iuvs,/ngims,/sep,/iuvs_periapse"]
  cmd_list = [cmd_list, "mvn_kp_read, [1022,1060],insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound"]
  
  ;; ---- Tests that shoudl fail ----
  
endif

if keyword_set(CREATE_TEST_SAVE) then begin

 
  ;; Get directory to store tes files in  
  test_loc = routine_info('regression_test',/source)
  test_loc_dir = strsplit(test_loc.path,'regression_test.pro',/extract,/regex)
  test_loc_dir = test_loc_dir + 'known_files/'


  mvn_kp_read, '2015-04-03/01:00:00' , insitu, iuvs
  save, insitu, filename=test_loc_dir+'insitu_old1.sav'
  save, iuvs,   filename=test_loc_dir+'iuvs_old1.sav'
  insitu=0 & iuvs = 0

  mvn_kp_read, ['2015-04-01/11:00:00','2015-04-03/01:00:00']  ,insitu, iuvs, /lpw, /static, /iuvs_periapse, /iuvs_coronaEchelleDisk, /save_files
  save, insitu, filename=test_loc_dir+'insitu_old2.sav'
  save, iuvs,   filename=test_loc_dir+'iuvs_old2.sav'
  insitu=0 & iuvs = 0
  
  mvn_kp_read, ['2015-04-06/02:00:08','2015-04-08/00:00:00']  ,insitu, iuvs, /swia, /swea, /iuvs_apoapse, /iuvs_coronaEchelleHigh, /save_files
  save, insitu, filename=test_loc_dir+'insitu_old3.sav'
  save, iuvs,   filename=test_loc_dir+'iuvs_old3.sav'
  insitu=0 & iuvs = 0
  
  mvn_kp_read, '2015-04-15/12:02:12'  ,insitu, iuvs, /mag, /sep, /iuvs_coronaLoresHigh, /iuvs_coronaEchelleLimb, duration=100000
  save, insitu, filename=test_loc_dir+'insitu_old4.sav'
  save, iuvs,   filename=test_loc_dir+'iuvs_old4.sav'
  insitu=0 & iuvs = 0
  
  mvn_kp_read, 1036  ,insitu, iuvs, /ngims, /iuvs_coronaLoresLimb, /iuvs_coronaLoresDisk , /text_files
  save, insitu, filename=test_loc_dir+'insitu_old5.sav'
  save, iuvs,   filename=test_loc_dir+'iuvs_old5.sav'
  insitu=0 & iuvs = 0

  mvn_kp_read, [1040, 1044]  ,insitu, iuvs, /insitu_all, /iuvs_all
  save, insitu, filename=test_loc_dir+'insitu_old6.sav'
  save, iuvs,   filename=test_loc_dir+'iuvs_old6.sav'
  insitu=0 & iuvs = 0
  
  mvn_kp_read, 1045  ,insitu,  /insitu_only, duration=2
  save, insitu, filename=test_loc_dir+'insitu_old7.sav'
  insitu=0 & iuvs = 0
  
  
endif

if keyword_set(COMPARE_TEST_SAVE) then begin
  
  ;; Get directory to store tes files in
  test_loc = routine_info('regression_test',/source)
  test_loc_dir = strsplit(test_loc.path,'regression_test.pro',/extract,/regex)
  test_loc_dir = test_loc_dir + 'known_files/'
  

  mvn_kp_read, '2015-04-03/01:00:00' , insitu_new, iuvs_new
  restore, filename=test_loc_dir+'insitu_old1.sav'
  restore, filename=test_loc_dir+'iuvs_old1.sav'
  mvn_kp_compare_data, insitu_new, insitu
  mvn_kp_compare_data, iuvs_new, iuvs
  insitu=0 & iuvs = 0 & insitu_new=0 & iuvs_new = 0
  
  
  mvn_kp_read, ['2015-04-01/11:00:00','2015-04-03/01:00:00']  ,insitu_new, iuvs_new, /lpw, /static, /iuvs_periapse, /iuvs_coronaEchelleDisk, /save_files
  restore, filename=test_loc_dir+'insitu_old2.sav'
  restore, filename=test_loc_dir+'iuvs_old2.sav'
  mvn_kp_compare_data, insitu_new, insitu
  mvn_kp_compare_data, iuvs_new, iuvs
  insitu=0 & iuvs = 0 & insitu_new=0 & iuvs_new = 0
  
  
  mvn_kp_read, ['2015-04-06/02:00:08','2015-04-08/00:00:00']  ,insitu_new, iuvs_new, /swia, /swea, /iuvs_apoapse, /iuvs_coronaEchelleHigh, /save_files
  restore, filename=test_loc_dir+'insitu_old3.sav'
  restore, filename=test_loc_dir+'iuvs_old3.sav'
  mvn_kp_compare_data, insitu_new, insitu
  mvn_kp_compare_data, iuvs_new, iuvs
  insitu=0 & iuvs = 0 & insitu_new=0 & iuvs_new = 0
  
  
  mvn_kp_read, '2015-04-15/12:02:12'  ,insitu_new, iuvs_new, /mag, /sep, /iuvs_coronaLoresHigh, /iuvs_coronaEchelleLimb, duration=100000
  restore, filename=test_loc_dir+'insitu_old4.sav'
  restore, filename=test_loc_dir+'iuvs_old4.sav'
  mvn_kp_compare_data, insitu_new, insitu
  mvn_kp_compare_data, iuvs_new, iuvs
  insitu=0 & iuvs = 0 & insitu_new=0 & iuvs_new = 0
  
  
  mvn_kp_read, 1036  ,insitu_new, iuvs_new, /ngims, /iuvs_coronaLoresLimb, /iuvs_coronaLoresDisk , /text_files
  restore, filename=test_loc_dir+'insitu_old5.sav'
  restore, filename=test_loc_dir+'iuvs_old5.sav'
  mvn_kp_compare_data, insitu_new, insitu
  mvn_kp_compare_data, iuvs_new, iuvs
  insitu=0 & iuvs = 0 & insitu_new=0 & iuvs_new = 0
  
  
  mvn_kp_read, [1040, 1044]  ,insitu_new, iuvs_new, /insitu_all, /iuvs_all
  restore, filename=test_loc_dir+'insitu_old6.sav'
  restore, filename=test_loc_dir+'iuvs_old6.sav'
  mvn_kp_compare_data, insitu_new, insitu
  mvn_kp_compare_data, iuvs_new, iuvs
  insitu=0 & iuvs = 0 & insitu_new=0 & iuvs_new = 0
  
  
  mvn_kp_read, 1045  ,insitu_new,  /insitu_only, duration=2
  restore, filename=test_loc_dir+'insitu_old7.sav'
  mvn_kp_compare_data, insitu_new, insitu
  insitu=0 & iuvs = 0 & insitu_new=0 & iuvs_new = 0
  
endif


if keyword_set(save_files) then begin

  ;; *** Test reading in only INSITU data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /save_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-10/17:01:05'] , insitu, /save_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/00:00:00', '2015-04-11/00:00:01'] , insitu, /save_files, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu, /save_files, /ngims, /static, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-29/17:01:05'] , insitu, /save_files, /insitu_all, /insitu_only"]


  ;; *** Test string time input ***

  ;; Test single time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs, /save_files"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs, /save_files"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs, /save_files"]



  ;; Test specifying certain instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/save_files,/ngims,/sep,/iuvs_periapse"]
  
  ;; Test inbound flag & instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/save_files,/ngims,/sep,/iuvs_periapse, /inbound"]
  
  ;; FIXME - This is failing and shouldn't - Bigger question, how to handle time range inputs that are less than 1 day.
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs, /save_files"]
  
   ;; Test single time input for files that we don't have data for - binary
   ;; This used to Error out, now it handles it and warns user.
  cmd_list = [cmd_list, "mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs, /save_files"]

  ;; *** Test orbit time range input  FIXME not working ***
  cmd_list = [cmd_list, "mvn_kp_read, 1022 , insitu, /insitu_only, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, [1021,1032] , insitu, /insitu_only, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, 1034 , insitu, iuvs, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, [1030,1070] , insitu, iuvs, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, [1026],insitu,iuvs,/ngims,/sep,/iuvs_periapse, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, [1024,1025],insitu,iuvs,/ngims,/sep,/iuvs_periapse, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, [1022,1040],insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound, /save_files"]
  
  
  
  ;; ---- Tests that shoudl fail ----
  
  
endif


if keyword_set(ASCII) then begin
  ;; *** Test reading in only INSITU data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /text_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-10/17:01:05'] , insitu, /text_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/00:00:00', '2015-04-11/00:00:01'] , insitu, /text_files, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-24/17:01:05'] , insitu, /text_files, /insitu_all, /insitu_only"]
  
  
  ;; Orbit Numer ascii & insitu
  cmd_list = [cmd_list, "mvn_kp_read, 1024 , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, [1021,1032] , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, [1030,1045] , insitu, iuvs, /text_files, /swia, /mag, /iuvs_all"]
  cmd_list = [cmd_list, "mvn_kp_read, [1060] , insitu, iuvs, /text_files, /ngims, /static, /iuvs_periapse, /iuvs_coronaEchelleDisk"]
  cmd_list = [cmd_list, "mvn_kp_read, [1021, 2022] , insitu, iuvs, /text_files"]
  
  
  ;; *** Test reading in INSITU & IUVS ascii data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-02/03:04:00' , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-05/00:00:00', '2015-04-19/17:01:05'] , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/00:00:15', '2015-04-11/00:00:01'] , insitu, iuvs, /text_files, /swia, /mag, /iuvs_periapse, /iuvs_apoapse"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-27/17:01:05'] , insitu, iuvs, /text_files, /insitu_all, /iuvs_all"]
  

  
  
endif

if keyword_set(COMPAREINSITU) then begin
  ;; *** Test reading in only INSITU data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /save_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]


  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-08/17:01:05'] , insitu, /save_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-08/17:01:05'] , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]

  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-12/00:00:01'] , insitu, /save_files, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-12/00:00:01'] , insitu2,  /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
    
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu, /save_files, /ngims, /static, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu2,  /ngims, /static, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]

  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-23/01:00:00', '2015-04-29/17:01:05'] , insitu, /save_files, /insitu_all, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-23/01:00:00', '2015-04-29/17:01:05'] , insitu2, /insitu_all, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  
;  ;; Compare Ascii to CDF
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /text_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu, /insitu_only, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu, /text_files, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu, /swia, /mag, /insitu_only, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu2, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
endif

if keyword_set(COMPAREIUVS) then begin

  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]
  

  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]

  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]



  
  ;; Test specifying certain instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/save_files,/ngims,/sep,/iuvs_periapse"]
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs2,/ngims,/sep,/iuvs_periapse"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]
  
  ;; Test inbound flag & instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/save_files,/ngims,/sep,/iuvs_periapse, /inbound"]
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs2,/ngims,/sep,/iuvs_periapse, /inbound"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]  
  
  ;; FIXME - This is failing and shouldn't - Bigger question, how to handle time range inputs that are less than 1 day.
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]  


    ;; Compare Ascii to CDF
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu2, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu2, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu2, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu, iuvs, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu2, iuvs2, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]

  
  ;; Compare Ascii to Save
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-22/00:00:01' , insitu, iuvs, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-22/00:00:01' , insitu2, iuvs2, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/23:59:59', '2015-04-15/00:00:01'] , insitu, iuvs, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb, /text_files"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/23:59:59', '2015-04-15/00:00:01'] , insitu2, iuvs2, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb, /save_files"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
endif

;; ------------------------------------------------------------------------------------ ;;
;; ----------------------------- Test MVN_KP_INSITU_SEARCH ---------------------------- ;;

if keyword_set(INSITU_SEARCH) then begin
  
  ;; read in two days worth of data and all instruments to do below testing
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-05/01:00:00', '2015-04-09/01:00:00'] , insitu, iuvs, /save_files"]  ;; FIXME - using save files for now

  
  ;; Test search of insitu with /list option
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,/list"]
  
  ;; Test searching based on tag number with min
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=185,min=1000"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=18,max=5"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=140,min=2, max=10"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=50,max=3"]


  ;; Test searching based on a tage number with with min & max 
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=185,min=1000, max=5000"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=205,min=-.1, max=.5"]
  
  ;; Test searching with tag string and max
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='SPACECRAFT.ALTITUDE', max=5000"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='STATIC.CO2PLUS_DENSITY', max=1"]      ;;;;
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='LPW.ELECTRON_DENSITY', max=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='LPW.ELECTRON_DENSITY', max=2"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='NGIMS.HE_DENSITY', min=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='STATIC.HPLUS_CHAR_DIR_MSOX', min=1, max=5"]      ;;;
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='APP.ATTITUDE_GEO_X', max=1000"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='spacecraft.t21', min=-1, max=1"]
  
  
  ;; Test searching for multiple tags
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=[1, 73] ,min=[-1,5], max=[4000,5000]"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=['NGIMS.NPLUS_DENSITY', 'SPACECRAFT.SZA', 'SEP.ION_ENERGY_FLUX_2_FRONT'] ,min=[-1,5,-1], max=[4000,5000, 1000]"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=[185, 186,190], min=[-1,-1,-4], max=10"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=[10, 12,40, 50], min=-1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=[9, 21,191], min=[-1,-1,-4], max=[10,20,30]"]
  
  ;; Commands that should fail
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=[185, 186,190], min=[-1,-1], max=10"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=[10, 12,40, 50], max=[5,6,7,8,9]"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=[9, 21,191], min=[-1,-1,-4], max=[10,20]"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag='SPACECRAFT.MADEUP', max=1"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=400, max=1"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=-1, max=1"]


  
endif

stop

;; Remove 'hack' first entry from all arrays - IDL 7 cannot
;; have empty arrays init.
if n_elements(cmd_list) gt 1 then cmd_list = cmd_list[1:-1] $
  else cmd_list= ''

 
if n_elements(cmd_list_prob) gt 1 then cmd_list_prob = cmd_list_prob[1:-1] $
  else cmd_list_prob = ''


;; ------------------------------------------------------------------------------------ ;;
;; ------------------------- Excute all normal commands ------------------------------- ;;

;;
;; Important Note:
;; It is necessary to call "message, /reset" before every call to a new procedure in order
;; to clear out the !ERROR_STATE structure that we use to check exit status.
;;

for J=0, n_elements(cmd_list)-1 do begin
  message, /reset
  return = EXECUTE(cmd_list[J])
  if !ERROR_STATE.CODE NE 0 then begin
    ;; Error occured
    test_results = [test_results, "[REGRESSION TEST] - ERROR with: "+cmd_list[J]]
    test_results = [test_results,  "                  ----- "+!ERROR_STATE.MSG]
  endif else begin
    ;; Success
    test_results = [test_results, "[REGRESSION TEST] - SUCCESS with: "+cmd_list[J]]
  endelse
endfor


;; The folowing tests should fail
for J=0, n_elements(cmd_list_prob)-1 do begin
  message, /reset
  return = EXECUTE(cmd_list_prob[J])
  if !ERROR_STATE.CODE NE 0 then begin
    ;; Error occured
    test_results_prob = [test_results_prob, "[REGRESSION TEST] - ERROR with: "+cmd_list_prob[J]]
    test_results_prob = [test_results_prob,  "                  ----- "+!ERROR_STATE.MSG]
  endif else begin
    ;; Success
    test_results_prob = [test_results_prob, "[REGRESSION TEST] - SUCCESS with: "+cmd_list_prob[J]]
  endelse
endfor



;; ------------------------------------------------------------------------------------ ;;
;; -------------- Special tests that require checking of output  ---------------------- ;;

;; FIXME implement these and more.

;; The insitu data structure has two data points at the end that were outside the time range due to single precision instead of double.
;; FIXME - Special, check first and last data points are within timerange. This was a bug recently fixed, need special check.
;;cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/17:00:30'] , insitu, iuvs, /save_files"]


;; ------------------------------------------------------------------------------------ ;;
;; ---------------------------------- Print Results ----------------------------------- ;;


;; Remove 'hack' first entry from all arrays - IDL 7 cannot
;; have empty arrays init.
if n_elements(test_results) gt 1 then test_results = test_results[1:-1] $
  else test_results = 0
  
if n_elements(test_results_prob) gt 1 then test_results_prob = test_results_prob[1:-1] $
  else test_results_prob = 0


print, ""
print, ""
print, " ---- Test Results  - Should Succeed----"
print, ""
for I=0, n_elements(test_results)-1 do begin
  print, test_results[I]
endfor


print, ""
print, "---- Test Results - Should Have Errors ----"
print, ""
for I=0, n_elements(test_results_prob)-1 do begin
  print, test_results_prob[I]
endfor


end