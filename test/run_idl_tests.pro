;+
; Driver to test MAVEN Visualization Toolkit.
; May be used for nightly CI testing or on personal workstation if the
; IDL_PATH is configured to include all dependent files.
; 
; To execute from shell, use testing_script.pro.
; 
; :Examples:
;    run_idl_tests
; 
; :Author:
;    Alexia Newgord, Nicholas Lindholm, Ed Hartnett
;-

;+
; :Keywords:
;    VERBOSE : in, optional, type=boolean
;        If set, tests will generate more output.  Defaults to FALSE.
;    IDLDE : in, optional, type=boolean
;        If set, config_test.pro will recognize that the tests are
;        being run in the
;        IDLDE and will not check the .idljavabrc configurations.
;-
pro run_idl_tests, VERBOSE=VERBOSE, IDLDE=IDLDE

                                ;For command line, use the .idljavabrc
                                ;that has the property,
                                ;-Djava.security.egd=file:///dev/urandom
  if NOT KEYWORD_SET(IDLDE) then setenv, 'IDLJAVAB_CONFIG=/tsis/tools/tests/testing_tools/.idljavabrc'
  
  if KEYWORD_SET(verbose) eq 0 then defsysv, '!VERBOSE', 0 else defsysv, '!VERBOSE', 1
  if KEYWORD_SET(idlde) eq 0 then defsysv, '!IDLDE', 0 else defsysv, '!IDLDE', 1
  start=systime(1)
  
  if keyword_set(verbose) then print, "ROUTINE INFO - ", ROUTINE_INFO(/SOURCE)
  
  print, 'Build ID = ' + GETENV('BUILD_ID')
  
  mgunit, 'testsuite_uts', nfail=nfail
 
  elapsed=systime(1)-start
  print, "TIME ELAPSED - " + strcompress(elapsed/60) + " minutes"

  ; fail the build
  if nfail gt 0 then exit, status=999

end
