;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds 
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;       input for start argument to H5S_SELECT_HYPERSLAB
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to H5S_SELECT_HYPERSLAB
;    block : out, optional, type=lonarr(ndims)
;       input for block keyword to H5S_SELECT_HYPERSLAB
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to H5S_SELECT_HYPERSLAB
;-
pro MVN_KP_INSITU_FILE_VERSIONS, filenames, data_dir, higher_version, binary=binary

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  ;SET THE FILENAME PATTERN TO SEARCH THE DIRECTORY FOR
  if keyword_set(binary) then begin
    file_pattern = 'mvn_KP_l2_pf*.sav'
  endif else begin
    file_pattern = 'mvn_KP_l2_pf*.txt'
  endelse
  
  data_dir1 = data_dir
  ;SEARCH THE INSITU DIRECTORY FOR ALL FILES THAT OCCUR ON THE START DATE
  file_list = file_search(data_dir1,file_pattern)
  
  file_time = strmid(file_list, 20, 8, /reverse_offset)
  
  ;EXTRACT THE TIME STAMPS TO MATCH
  time1 = strmid(filenames, 20, 8,/reverse_offset)
  
  matched = where(file_time eq time1)
  
  ;PULL OUT THE VERSION NUMBERS
  versions = fix(strmid(file_list(matched), 10, 3, /reverse_offset))
  
  ;FIND THE MAXIMUM VERSION COUNT
  maxed = max(versions, max_index)
  
  ;FIND THE MAXIMUM SOFTWARE REVISION CODE
  higher_version = file_list(matched(max_index))
  
  ;RESET THE FILENAME TO THE MAXIMUM FILE VERSION LABEL
  final_slash = strpos(higher_version, '/', /reverse_search)
  higher_version = strmid(higher_version, final_slash+1)

end