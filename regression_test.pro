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
 

PRO REGRESSION_TEST, READ=READ, INSITU_SEARCH=INSITU_SEARCH

ON_ERROR, 1   ; PRINT STACK AND RETURN TO MAIN
 
 
; Default if no arguments passed
if n_params() eq 0 then begin
  READ="TRUE"
  INSITU_SEARCH="TRUE"
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

if keyword_set(READ) then begin

  ;; Test string time input

  ;; Test single time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, '2015-04-01/01:00:00' , insitu, iuvs, /binary"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs, /binary"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs, /binary"]

  ;; Test single time input - ascii  FIXME not working
  ;; Test range time input - ascii   FIXME not working

  ;; Test specifying just insitu or just iuvs FIXME not working
  ;;cmd_list = [cmd_list, "mvn_kp_read, '2015-04-02/14:00:00', insitu, iuvs, /binary, /insitu"]
  ;;cmd_list = [cmd_list, "mvn_kp_read, '2015-04-03/14:00:00', insitu, iuvs, /binary, /iuvs"]

  ;; Test specifying certain instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/binary,/ngims,/sep,/iuvs_periapse"]
  
  ;; Test inbound flag & instruments
  cmd_list = [cmd_list, "mvn_kp_read,'2015-04-12/09:30:00',insitu,iuvs,/binary,/ngims,/sep,/iuvs_periapse, /inbound"]
  
  ;; FIXME - This is failing and shouldn't
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/13:00:30'] , insitu, iuvs, /binary"]

  ;; Test orbit time range input  FIXME not working
  ;mvn_kp_read, 10, insitu, iuvs, /binary
  
  
  ;; ---- Tests that shoudl fail ----
  
  
  ;; Test single time input for files that we don't have data for - binary
  cmd_list_prob = [cmd_list_prob, "mvn_kp_read, '2014-04-01/06:00:00' , insitu, iuvs, /binary"]
  
  
endif


;; ------------------------------------------------------------------------------------ ;;
;; ----------------------------- Test MVN_KP_INSITU_SEARCH ---------------------------- ;;

if keyword_set(INSITU_SEARCH) then begin
  
  ;; read in two days worth of data and all instruments to do below testing
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-05/01:00:00', '2015-04-07/01:00:00'] , insitu, iuvs, /binary"]

  
  ;; Test search of insitu with /list option
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,/list"]
  
  ;; Test searching based on tag number with min
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=185,min=1000"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=18,max=5"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=140,min=2, max=10"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=50,max=3"]


  ;; Test searching based on a tage number with with min & max 
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag=185,min=1000, max=5000"]
  
  ;; Test searching with tag string and max
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='SPACECRAFT.ALTITUDE', max=5000"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='STATIC.HPLUS_DENSITY', max=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='LPW.ELECTRON_DENSITY', max=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='LPW.ELECTRON_DENSITY', max=2"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='NGIMS.HE_DENSITY', min=1"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='STATIC.HPLUS_DENSITY', min=1, max=5"]
  cmd_list = [cmd_list, "mvn_kp_insitu_search,insitu,insitu1,tag='APP.ATTITUDE_GEO_X', max=1000"]
  
  
  ;; Commands that should fail
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag='SPACECRAFT.MADEUP', max=1"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=400, max=1"]
  cmd_list_prob = [cmd_list_prob, "mvn_kp_insitu_search,insitu,insitu1,tag=-1, max=1"]


  
endif


;; ------------------------------------------------------------------------------------ ;;
;; ------------------------------ Excute all commands --------------------------------- ;;

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