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
 

PRO REGRESSION_TEST, CDF=CDF, SAVEFILES=SAVEFILES, INSITU_SEARCH=INSITU_SEARCH, ASCII=ASCII, $
                     COMPAREINSITU=COMPAREINSITU, COMPAREIUVS=COMPAREIUVS

ON_ERROR, 1   ; PRINT STACK AND RETURN TO MAIN
 
 
; Default if no arguments passed
if n_params() eq 0 then begin
 ; SAVEFILES="TRUE"
 ; CDF="TRUE"
 ; INSITU_SEARCH="TRUE"
 ; ASCII="TRUE"
 ; COMPAREINSITU="TRUE"
 ; COMPAREIUVS="TRUE"
endif


;; Init array to hold results of the tests
test_results = []

;; Init array to hold results of tests that SHOULD fail
test_results_prob = []

;; Init array to hold commands to execute
cmd_list = []

;; Init array to hold commands that should fail, and we want to see how error handling deals with them
cmd_list_prob = []




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


if keyword_set(SAVEFILES) then begin

  ;; *** Test reading in only INSITU data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /savefiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-10/17:01:05'] , insitu, /savefiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/00:00:00', '2015-04-11/00:00:01'] , insitu, /savefiles, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu, /savefiles, /ngims, /static, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-29/17:01:05'] , insitu, /savefiles, /insitu_all, /insitu_only"]


  ;; *** Test string time input ***

  ;; Test single time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs, /savefiles"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs, /savefiles"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs, /savefiles"]



  ;; Test specifying certain instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/savefiles,/ngims,/sep,/iuvs_periapse"]
  
  ;; Test inbound flag & instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/savefiles,/ngims,/sep,/iuvs_periapse, /inbound"]
  
  ;; FIXME - This is failing and shouldn't - Bigger question, how to handle time range inputs that are less than 1 day.
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs, /savefiles"]
  
   ;; Test single time input for files that we don't have data for - binary
   ;; This used to Error out, now it handles it and warns user.
  cmd_list = [cmd_list, "mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs, /savefiles"]

  ;; *** Test orbit time range input  FIXME not working ***
  cmd_list = [cmd_list, "mvn_kp_read, 1022 , insitu, /insitu_only, /SAVEFILES"]
  cmd_list = [cmd_list, "mvn_kp_read, [1021,1032] , insitu, /insitu_only, /SAVEFILES"]
  cmd_list = [cmd_list, "mvn_kp_read, 1034 , insitu, iuvs, /SAVEFILES"]
  cmd_list = [cmd_list, "mvn_kp_read, [1030,1070] , insitu, iuvs, /SAVEFILES"]
  cmd_list = [cmd_list, "mvn_kp_read, [1026],insitu,iuvs,/ngims,/sep,/iuvs_periapse, /SAVEFILES"]
  cmd_list = [cmd_list, "mvn_kp_read, [1024,1025],insitu,iuvs,/ngims,/sep,/iuvs_periapse, /SAVEFILES"]
  cmd_list = [cmd_list, "mvn_kp_read, [1022,1040],insitu,iuvs,/ngims,/sep,/iuvs_periapse, /inbound, /SAVEFILES"]
  
  
  
  ;; ---- Tests that shoudl fail ----
  
  
endif


if keyword_set(ASCII) then begin
  ;; *** Test reading in only INSITU data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /textfiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-10/17:01:05'] , insitu, /textfiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/00:00:00', '2015-04-11/00:00:01'] , insitu, /textfiles, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-24/17:01:05'] , insitu, /textfiles, /insitu_all, /insitu_only"]
  
  
  ;; Orbit Numer ascii & insitu
  cmd_list = [cmd_list, "mvn_kp_read, 1024 , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, [1021,1032] , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, [1030,1045] , insitu, iuvs, /textfiles, /swia, /mag, /iuvs_all"]
  cmd_list = [cmd_list, "mvn_kp_read, [1060] , insitu, iuvs, /textfiles, /ngims, /static, /iuvs_periapse, /iuvs_coronaEchelleDisk"]
  cmd_list = [cmd_list, "mvn_kp_read, [1021, 2022] , insitu, iuvs, /textfiles"]
  
  
  ;; *** Test reading in INSITU & IUVS ascii data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-02/03:04:00' , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-05/00:00:00', '2015-04-19/17:01:05'] , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-08/00:00:15', '2015-04-11/00:00:01'] , insitu, iuvs, /textfiles, /swia, /mag, /iuvs_periapse, /iuvs_apoapse"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-22/01:00:00', '2015-04-27/17:01:05'] , insitu, iuvs, /textfiles, /insitu_all, /iuvs_all"]
  

  
  
endif

if keyword_set(COMPAREINSITU) then begin
  ;; *** Test reading in only INSITU data ****
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /savefiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]


  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-08/17:01:05'] , insitu, /savefiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-04/01:00:00', '2015-04-08/17:01:05'] , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]

  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-12/00:00:01'] , insitu, /savefiles, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-12/00:00:01'] , insitu2,  /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
    
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu, /savefiles, /ngims, /static, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-01/01:00:59', '2015-04-03/00:01:05'] , insitu2,  /ngims, /static, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]

  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-23/01:00:00', '2015-04-29/17:01:05'] , insitu, /savefiles, /insitu_all, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-23/01:00:00', '2015-04-29/17:01:05'] , insitu2, /insitu_all, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  
;  ;; Compare Ascii to CDF
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, /textfiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu, /insitu_only, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu, /textfiles, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu2, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu, /swia, /mag, /insitu_only, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu2, /swia, /mag, /insitu_only"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, insitu, insitu2"]
  
endif

if keyword_set(COMPAREIUVS) then begin

  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs, /savefiles"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]
  

  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs, /savefiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]

  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs, /savefiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]



  
  ;; Test specifying certain instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/savefiles,/ngims,/sep,/iuvs_periapse"]
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs2,/ngims,/sep,/iuvs_periapse"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]
  
  ;; Test inbound flag & instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/savefiles,/ngims,/sep,/iuvs_periapse, /inbound"]
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs2,/ngims,/sep,/iuvs_periapse, /inbound"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]  
  
  ;; FIXME - This is failing and shouldn't - Bigger question, how to handle time range inputs that are less than 1 day.
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs, /savefiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2"]  


    ;; Compare Ascii to CDF
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/01:00:00' , insitu2, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-02/01:00:00', '2015-04-06/17:01:05'] , insitu2, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-11/13:01:59' , insitu2, iuvs2"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu, iuvs, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/00:00:00', '2015-04-15/00:00:01'] , insitu2, iuvs2, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]

  
  ;; Compare Ascii to Save
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-22/00:00:01' , insitu, iuvs, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-22/00:00:01' , insitu2, iuvs2, /savefiles"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/23:59:59', '2015-04-15/00:00:01'] , insitu, iuvs, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb, /textfiles"]
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-10/23:59:59', '2015-04-15/00:00:01'] , insitu2, iuvs2, /iuvs_periapse, /iuvs_coronaLoresDisk, /iuvs_coronaEchelleLimb, /savefiles"]
  cmd_list = [cmd_list, "mvn_kp_compare_data, iuvs, iuvs2, /approx"]
  
endif

;; ------------------------------------------------------------------------------------ ;;
;; ----------------------------- Test MVN_KP_INSITU_SEARCH ---------------------------- ;;

if keyword_set(INSITU_SEARCH) then begin
  
  ;; read in two days worth of data and all instruments to do below testing
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-05/01:00:00', '2015-04-09/01:00:00'] , insitu, iuvs"]

  
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
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='STATIC.HPLUS_DENSITY', max=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='LPW.ELECTRON_DENSITY', max=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='LPW.ELECTRON_DENSITY', max=2"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='NGIMS.HE_DENSITY', min=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='STATIC.HPLUS_DENSITY', min=1, max=5"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='APP.ATTITUDE_GEO_X', max=1000"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='spacecraft.t21', min=-1, max=1"]
  
  
  
  ;; Commands that should fail
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag='SPACECRAFT.MADEUP', max=1"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=400, max=1"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=-1, max=1"]


  
endif


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
;;cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/17:00:30'] , insitu, iuvs, /savefiles"]


;; ------------------------------------------------------------------------------------ ;;
;; ---------------------------------- Print Results ----------------------------------- ;;


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