;+
; :Name: mvn_kp_create_dir_if_needed
;
; :Author: John Martin
;
; :Description:
;     Create a directory (and its parent dirs) if it doens't exist
;
;
;-

;; Create a directory (and parent directories) if they don't exist
pro mvn_kp_create_dir_if_needed, full_path, open_permissions=open_permissions, verbose=verbose

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
  ;; Check if directory exists, create if not. Check permissions
  result = ''
  result = file_search(full_path, /TEST_DIRECTORY)
  
  ;; If direcotory(s) dooesn't exist, try to create and set permissions
  if result eq '' then begin
  
    if not keyword_set(open_permissions) then begin
      file_mkdir, full_path
      
    endif else begin
      ;; If /open_permissions, then loop through and create each directory needed
      ;; and set the permissions to 777
      subdirs = strsplit(full_path,path_sep(),/extract,count=n)
      partial_path = ''
      for i=0,n-1 do begin
        ;; Build up path as we go
        partial_path = partial_path+subdirs[i]+path_sep()
        
        if not file_test(/direc, partial_path) then begin
          file_mkdir, partial_path
          file_chmod, partial_path, /A_EXECUTE, /A_READ, /A_WRITE
        endif
      endfor
    endelse
    
    if keyword_set(verbose) then print, "Creating directory: "+string(full_path)
  endif
  
end

