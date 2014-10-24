;+
; Test of mvn_kp_create_dir_if_needed function
;
; :Author:  John Martin
;-

pro mvn_kp_create_dir_if_needed_ut::setup
  compile_opt strictarr

  self.sandbox_dir = '.' + path_sep() + 'mvn_kp_tmp_unit_tests_sandbox' + path_sep()
end


function mvn_kp_create_dir_if_needed_ut::test_basic
  compile_opt strictarr

  ;; Create sandbox directory 
  file_mkdir, self.sandbox_dir
 
  ;; Test path to be created  
  test_path = 'testdir1' +path_sep() + 'testdir2' + path_sep() + 'test dir3'  
  full_path = self.sandbox_dir + test_path
  mvn_kp_create_dir_if_needed, full_path, /OPEN_PERMISSIONS, /VERBOSE
  
  
  ;; Test created directories
  subdirs = strsplit(test_path,path_sep(),/extract,count=n)
  partial_path = self.sandbox_dir
  for i=0,n-1 do begin
    ;; Build up path as we go
    partial_path = partial_path+subdirs[i]+path_sep()
    
    assert, file_test(partial_path, /directory, get_mode=mode), 'Directory not created'
    assert, mode eq 511, 'Directory not created with correct permissions'
  endfor
 
  return, 1
end


pro mvn_kp_create_dir_if_needed_ut::teardown
  compile_opt strictarr

  ;; Clean up sandbox & created dirs
  file_delete, self.sandbox_dir, /recursive
end


pro mvn_kp_create_dir_if_needed_ut__define
  compile_opt strictarr
  
  define = { mvn_kp_create_dir_if_needed_ut, inherits MGutTestCase, sandbox_dir:'' }
end
