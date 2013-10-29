 @mvn_kp_read
 

PRO REGRESSION_TEST, READ=READ, INSITU_SEARCH=INSITU_SEARCH

ON_ERROR, 1   ; PRINT STACK AND RETURN TO MAIN
 
 
; Default if no arguments passed
if n_params() eq 0 then begin
  READ="TRUE"
  INSITU_SEARCH="TRUE"
endif


;; Init array to hold results of the tests
test_results = []

;; Init array to hold commands to execute
cmd_list = []


;; ------------------------------------------------------------------------------------ ;;
;; ----------------------------- Test MVN_KP_READ ------------------------------------- ;;

if keyword_set(READ) then begin

  ;; Test string time input

  ;; Test single time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, '2014-04-01/01:00:00' , insitu, iuvs, /binary"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-05/06:00:30'] , insitu, iuvs, /binary"]

  ;; Test range time input - binary
  cmd_list = [cmd_list, "mvn_kp_read, ['2015-04-09/01:00:00', '2015-04-14/21:00:00'] , insitu, iuvs, /binary"]

  ;; Test single time input - ascii

  ;; Test range time input - ascii


  ;; Test orbit time range input  FIXME not working
  ;mvn_kp_read, 10, insitu, iuvs, /binary
  
endif


;; ------------------------------------------------------------------------------------ ;;
;; ----------------------------- Test MVN_KP_INSITU_SEARCH ---------------------------- ;;

if keyword_set(INSITU_SEARCH) then begin
  print, "Here would be test on the mvn_kp_insitu_search procedure.
  
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


;; ------------------------------------------------------------------------------------ ;;
;; ---------------------------------- Print Results ----------------------------------- ;;


print, ""
print, ""
print, " ---- Test Results ----"
print, ""
for i=0, n_elements(test_results)-1 do begin
  print, test_results[i]
endfor

end