;+
; Takes input array of insitu data and assigns the values to input structure
;
; :Params:
;    record : in, required, type=structure
;       the named structure for the sorted and output INSITU KP data
;    data_array: in, required, type=fltarr(ndims)
;       the KP data read from the ascii or binary files, includes all instrument data
;    instruments: in, required, type=struct
;       the instrument choice flags that determine which data will be returned from struct
;

;-
pro MVN_KP_INSITU_ASSIGN, record, data_array, instruments, colmap

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  debug=keyword_set(1B)
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  nrec = n_elements(data_array.(0))
;stop
  record[0:nrec-1].time_string = data_array.(colmap.time_string-1)
  record[0:nrec-1].time        = time_double(record.time_string, $
                                             tformat='YYYY-MM-DDThh:mm:ss')
  record[0:nrec-1].orbit       = data_array.(colmap.orbit-1)
  record[0:nrec-1].io_bound    = data_array.(colmap.io_bound-1)
  
  if instruments.lpw then begin            ;return all the LPW data   
    for i = 0,n_tags(record.lpw)-1 do begin
      record.lpw.(i) = data_array.(colmap.lpw.(i)-1)
    endfor
  endif

  if instruments.euv then begin             ;return all EUV data
    for i = 0,n_tags(record.euv)-1 do begin
      record.euv.(i) = data_array.(colmap.lpw.(i)-1)
    endfor
  endif

  if instruments.static then begin          ;return all teh Static data    
    for i = 0,n_tags(record.static)-1 do begin
      record.static.(i) = data_array.(colmap.static.(i)-1)
    endfor
  endif

  if instruments.swia then begin      ;return all the swia data
    for i = 0,n_tags(record.swia)-1 do begin
      record.swia.(i) = data_array.(colmap.swia.(i)-1)
    endfor
  endif

  if instruments.swea then begin      ;return all the swea data
    for i = 0,n_tags(record.swea)-1 do begin
      record.swea.(i) = data_array.(colmap.swea.(i)-1)
    endfor
  endif

  if instruments.mag then begin      ;retunr all the mag data
    for i = 0,n_tags(record.mag)-1 do begin
      record.mag.(i) = data_array.(colmap.mag.(i)-1)
    endfor
  endif

  if instruments.sep then begin    ;return atll the SEP data
    for i = 0,n_tags(record.sep)-1 do begin
      record.sep.(i) = data_array.(colmap.sep.(i)-1)
    endfor
  endif

  if instruments.ngims then begin        ;return all the NGIMS data
    for i = 0,n_tags(record.ngims)-1 do begin
      record.ngims.(i) = data_array.(colmap.ngims.(i)-1)
    endfor
  endif
  
  for i = 0,n_tags(record.spacecraft)-1 do begin
    record.spacecraft.(i) = data_array.(colmap.spacecraft.(i)-1)
  endfor

  for i = 0,n_tags(record.app)-1 do begin
    record.app.(i) = data_array.(colmap.app.(i)-1)
  endfor
  
end
