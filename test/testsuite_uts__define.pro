; docformat = 'rst'

;+
; Initialize object, adding all test cases. This automatically finds
; all tests with a name like: <SOMETHING>_ut__define.pro. Additionally,
; create a preference file for testing.
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

  ;; Journal file that should be used by any test that needs to capture stdout
  setenv, 'MVN_TEST_JOURNAL=mvn_kp_journal_for_test.txt'

  ;;-------------------------------------------------------------------
  ;; Back up existing preference file, and create new one for testing
  
  mvn_root_data_dir = getenv('MVN_ROOT_DATA_DIR')
  if mvn_root_data_dir eq '' then message, 'MUST have MVN_ROOT_DATA_DIR set for unit tests'

  
  ;; Temp copy preference file if one exists so don't overwrite it
  install_result = routine_info('mvn_kp_read_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_read_ut__define.pro',/extract,/regex)
  install_directory = install_directory+path_sep()+'..'+path_sep()
  if file_test(install_directory+'mvn_toolkit_prefs.txt') then begin
    ;file_move, install_directory+'mvn_toolkit_prefs.txt', install_directory+'mvn_toolkit_prefs.txt.bak'
  endif

  ;; Create a config file pointing to the root data dir
  openw,lun,install_directory+'mvn_toolkit_prefs.txt',/get_lun
  printf,lun,'; IDL Toolkit Data Preferences File'
  printf,lun,'mvn_root_data_dir: '+mvn_root_data_dir+path_sep()
  free_lun,lun
  print, "Updated/created mvn_toolkit_prefs.txt file."
  
  return, 1
end

;+
; Clean up the preferences file that was created for testing. Also delete
; journal file if it was created/used at any point.
;-
pro testsuite_uts::cleanup
  compile_opt strictarr
  
  ;; Remove journal file if used/left around
  test_journal = getenv('MVN_TEST_JOURNAL')
  if (file_test(test_journal)) then begin
    file_delete, test_journal
  endif
  
  ;;-------------------------------------------------------------------
  ;; Remove testing preferences file & replace existing one if present
  
  install_result = routine_info('mvn_kp_read_ut__define',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_read_ut__define.pro',/extract,/regex)
  install_directory = install_directory+path_sep()+'..'+path_sep()
  
  ;; Remove temp config file
  file_delete,install_directory+'mvn_toolkit_prefs.txt'
  
  ;; If we backed up an existing pref file, move it back.
  if file_test(install_directory+'mvn_toolkit_prefs.txt.bak') then begin
    file_move, install_directory+'mvn_toolkit_prefs.txt.bak', install_directory+'mvn_toolkit_prefs.txt'
  endif
  
end

;+
; Define the testsuite. This does not need to be changed as tests are added.
;-
pro testsuite_uts__define
  compile_opt strictarr
  
  define = { testsuite_uts, inherits MGutTestSuite }
end
