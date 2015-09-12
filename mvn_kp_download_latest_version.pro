;+
; :Name: mvn_kp_download_source_files
;
; :Author: Bryan Harter
;
;
; :Description:
;     Download Latest Files for the Toolkit
;

pro mvn_kp_download_latest_version

  ;; Get SDC source file location
  spec = mvn_kp_config(/source_files_location)

  ;; Get location to save the source code files
  install_result = routine_info('mvn_kp_download_latest_version',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_download_latest_version.pro',/extract,/regex)

  ;; Get connection & execute GET query for source code file list
  netURL = mvn_kp_get_temp_connection(spec.host, spec.port, spec.username, spec.password, spec.url_scheme, spec.authentication)
  new_file_checksums = mvn_kp_execute_neturl_query(netURL, spec.url_path+'/SourceList', '', /not_sdc_connection)
  if size(new_file_checksums, /TYPE) ne 7 then begin
    print, "Problem downloading template file."
    print, "If not connected to the internet, then this is to be expected"
    return
  endif
  
  ;; Break the checksum file into file names and checksums 
  new_file_names = strarr(n_elements(new_file_checksums))
  new_checksums = strarr(n_elements(new_file_checksums))
  temp = strsplit(new_file_checksums, /EXTRACT) 
  for i = 0,n_elements(new_file_checksums)-1 do begin
    if (size(temp[i], /n_dimensions) eq 0) then begin
      continue
    endif
    new_file_names[i] = (temp[i])[1]
    new_checksums[i] = (temp[i])[0]
  endfor
  

  ;; Read the checksum file on the user's computer into 'file_names' and 'checksums'
  file_names=''
  checksums=''
  
  openr,lun,install_directory+'SourceList',/get_lun
  while not eof(lun) do begin
    line=''
    readf,lun,line
    tokens = strsplit(line,' ',/extract)
    if tokens[0] ne '' then begin
      file_names = [file_names, tokens[1]]
      checksums = [checksums, tokens[0]]
    endif
  endwhile
  free_lun, lun
  
  ;; Compare the two files, download the new stuff
  return_value=''
  index_to_download = []
  for i = 0,n_elements(new_file_names)-1 do begin
    
    ;;Create a filename for windows or linux
    file = strjoin(strsplit(strmid(new_file_names[i], 2), '/', /extract), path_sep())
    
    ;; Find where file names match
    matching_index=where(strmatch(file_names, new_file_names[i], /fold_case) eq 1)
    
    if (file eq 'access.txt') then begin
      continue
    endif
    
    ;; If there is no match, we need to download that file
    if (matching_index eq -1) then begin
      file_and_path = install_directory[0] + file
      return_value = mvn_kp_execute_neturl_query(netURL, spec.url_path+'/'+strmid(new_file_names[i], 2), '', filename=file_and_path, /not_sdc_connection)
      print, "Downloading " + file 
    endif
    
    ;; If the checksums are different, the file is new and needs to be downloaded
    if (new_checksums[i] eq checksums[matching_index]) then begin
      ;; Don't do anything
    endif else begin
      file_and_path = install_directory[0] + file
      return_value = mvn_kp_execute_neturl_query(netURL, spec.url_path+'/'+strmid(new_file_names[i], 2), '', filename=file_and_path, /not_sdc_connection)
      print, "Downloading " + file 
    endelse
  endfor
  
  file ='SourceList'
  file_and_path = install_directory[0] + file
  return_value = mvn_kp_execute_neturl_query(netURL, spec.url_path+'/'+file, '', filename=file_and_path, /not_sdc_connection)
  print, "Downloading " + file

  ;; Catch error
  if size(return_value, /TYPE) ne 7 then begin
    print, "Problem downloading template file."
    print, "If not connected to the internet, then this is to be expected"
  endif 

end