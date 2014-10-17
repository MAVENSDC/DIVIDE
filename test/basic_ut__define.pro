;+
; Basic test to check that testing is working.
; 
; :Author:  Ed Hartnett
;-

function basic_ut::test_simple
  compile_opt strictarr
  
  assert, 1 eq 1, 'Test failed'
  
  return, 1
end


pro basic_ut__define
  compile_opt strictarr
  
  define = { basic_ut, inherits MGutTestCase }
end
