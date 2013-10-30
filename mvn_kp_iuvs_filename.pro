;+
; A ROUTINE TO CREATE THE IUVS KP FILENAMES FOR THE PURPOSE OF OPENING AND READING.
;
; :Params:
;    year: in, required, type=integer
;       input year of the data files
;    month: in, required, type=integer
;       input month of the data files
;    day: in, required, type=integer
;       input day of the data files   
;    hour: in, required, type=integer
;       input hour of the data files
;    begin_jul: in, required, type=integer
;       julian date of the beginning of the search period
;    end_jul: in, required, type=integer
;       julian date of the end of the search period
;    data_dir: in, required, type=string
;       the directory in which IUVS KP files are stored locally
;    file_count: out, required, type=integer
;       a count of how many files are present on that given day
;    filename: out, required, type=strarr(file_count)
;       the array of IUVS KP filenames to be read 
;       
; :Keywords:
;    binary: in, optional, type=boolean
;       the binary flag to determine whether binary or ascii filenames are to be generated
;-
pro MVN_KP_IUVS_FILENAME, year, month, day, hour, begin_jul, end_jul, data_dir, file_count, filename, binary=binary, debug=debug

  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif

  time_jul = julday(month,day,year,hour)

  filename_temp = strarr(10)           ;FAR TOO LARGE, BUT TEMPORARY 

  ;SET THE PATTERN FOR THE IUVS KP FILENAME BASED ON THE BEGINNING DATE
  if keyword_set(binary) then begin
    file_pattern = 'MVN_IUV_KP_'+strtrim(string(year),2)+strtrim(string(month),2)+strtrim(string(day),2)+'T*.sav'
  endif else begin
    file_pattern = 'MVN_IUV_KP_'+strtrim(string(year),2)+strtrim(string(month),2)+strtrim(string(day),2)+'T*.txt'
  endelse
  
  ;SEARCH THE IUVS DIRECTORY FOR ALL FILES THAT OCCUR ON THE START DATE
  file_list = file_search(data_dir,file_pattern)


  ;LOOP THROUGH THE FILE LISTING AND ELIMINATE ALL BUT THE HIGHEST VERSION NUMBER KP FILE
    keeper_list = strarr(n_elements(file_list))
    check = 0
    for i=0,n_elements(file_list) - 1 do begin
     version = fix(strmid(file_list[i],11,3,/reverse_offset))                ;CHANGE THIS WHEN 3 DIGIT VERSION NUMBERS ARE IMPLEMENTED
      if version gt 0 then begin
        time1 =  strmid(file_list[i],17,6,/reverse_offset)
        for j=version,1, -1 do begin
          time2 = strmid(file_list[i-j],17,6,/reverse_offset)
          if time2 eq time1 then begin
            file_list[i-j] = ''
          endif
        endfor
      endif
    endfor
    deleter = where(file_list ne '')
    file_list = file_list[deleter]

  ;ERROR HANDLING: CHECK TO MAKE SURE WE FOUND A FILE
  if file_list[0] eq '' then begin
    if not keyword_set(debug) then begin
      message, "No Files found in"+data_dir+"for the input time/timerange" + $
        "Note: IUVS filenames must be of the form: MVN_IUV_KP_YYYYMMDDTHHMMSS_V###_R###.[sav,txt]"
    endif else begin
      print, "**ERROR HANDLING - No Files found in"+data_dir+"for the input time/timerange"
      print, "**ERROR HANDLING - Note: IUVS filenames must be of the form: MVN_IUV_KP_YYYYMMDDTHHMMSS_V###_R###.[sav,txt]"
      print, "**ERROR HANDLING - Debug mode set: Stoping."
      stop
    endelse
    
  endif

  ;EXTRACT THE HOUR-STAMP OF EACH FILE FROM THE LIST
  sec_list = fix(strmid(file_list,15,2,/reverse_offset))
  min_list = fix(strmid(file_list,17,2,/reverse_offset))
  hour_list = fix(strmid(file_list, 19,2,/reverse_offset))
  day_list = fix(strmid(file_list, 22,2,/reverse_offset))
  month_list = fix(strmid(file_list,24,2,/reverse_offset))
  year_list = fix(strmid(file_list,28,4,/reverse_offset))
 
  jul_list = julday(month_list, day_list, year_list, hour_list, min_list, sec_list)
  
  temp_file_count = 0
  for i=0,n_elements(jul_list)-1 do begin
    if jul_list[i]-begin_jul ge 0.0 then begin
     if jul_list[i]-end_jul le 0.0 then begin
      filename_temp[temp_file_count] = file_list[i]
      temp_file_count = temp_file_count+1
     endif
    endif
  endfor
  
  
  ;PASS BACK THE LIST OF IUVS FILENAMES WITH THE 
  filename = filename_temp[0:temp_file_count-1]
  file_count = file_count + temp_file_count
  
  
 
end