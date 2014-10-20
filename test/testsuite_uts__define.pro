; docformat = 'rst'

;+
; Initialize object, adding all test cases. This automatically finds
; all tests will name <SOMETHING>_ut__define.pro.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `MGutTestSuite::init`
;-
function testsuite_uts::init, _extra=e
  compile_opt strictarr
  
  if (~self->mguttestsuite::init(_strict_extra=e)) then return, 0
  
  self->add, /all
  
  return, 1
end


;+
; Define the testsuite. This does not need to be changed as tests are added.
;-
pro testsuite_uts__define
  compile_opt strictarr
  
  define = { testsuite_uts, inherits MGutTestSuite }
end
