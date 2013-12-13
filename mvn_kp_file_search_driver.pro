;+
; A routine to produce the total number and names of the KP files that will be read/searched 
;
; :Params:
;    begin_time : in, required, type="string"
;       The time to begin the read/search procedure
;    end_time : in, required, type="string"
;       The time to end the read/search procedure
;    file_count : out, required, type="integer"
;       A returned variable holding the total number of KP files to read
;    insitu_filenames : out, required, type="strarr(file_count)"
;       A returned array the holds the names of the relevant INSITU KP files
;    iuvs_filenames: out, required, type="strarr(file_count)"
;       A returned array holding the names of the relevant IUVS KP data files
;    data_dir: in, required, type="string"
;       The directory in which KP data files are held.
;    binary: in, required, type=boolean
;       A flag that creates filesnames with the binary extension instead of ascii default.
;-
pro MVN_KP_FILE_SEARCH_DRIVER, begin_time, end_time, file_count, insitu_filenames, iuvs_filenames, data_dir, iuvs_dir, $
                               binary, insitu_only=insitu_only

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
  ;EXTRACT THE VARIOUS TIME/DATE COMPONENTS
  begin_year   = fix(strmid(begin_time,0,4))
  begin_month  = fix(strmid(begin_time,5,2))
  begin_day    = fix(strmid(begin_time,8,2))
  begin_hour   = fix(strmid(begin_time,11,2))
  begin_minute = fix(strmid(begin_time,14,2))
  begin_second = fix(strmid(begin_time,17,2))
  end_year     = fix(strmid(end_time,0,4))
  end_month    = fix(strmid(end_time,5,2))
  end_day      = fix(strmid(end_time,8,2))
  end_hour     = fix(strmid(end_time,11,2))
  end_minute   = fix(strmid(end_time,14,2))
  end_second   = fix(strmid(end_time,17,2))


  ;CALCULATE THE JULIAN DATES FOR BEGIN AND END
  
  begin_jul = julday(begin_month,begin_day,begin_year, begin_hour)
  end_jul = julday(end_month, end_day, end_year, end_hour)


  ;CHECK FIRST THAT THE ENTERED TIMES FALL WITHIN THE RANGE OF THE KP DATA FILES
  ;SPIT OUT ERROR IF THEY DO NOT
  
  ;COUNT THE NUMBER OF DAYS THE SEARCH PERIOD ENCOMPASSES
  ;FOR SIMPLICITIES SAKE, DAY 1 IS DEFINED AS JANUARY 1, 2013 WITH THE TOTAL DAYS SINCE THEN A SIMPLE INTEGER
   case begin_month of
    1: begin_day1 = ((begin_year-2013)*365)+begin_day
    2: begin_day1 = ((begin_year-2013)*365)+(31 + begin_day)
    3: begin_day1 = ((begin_year-2013)*365)+(59 +begin_day)
    4: begin_day1 = ((begin_year-2013)*365)+(90 + begin_day)
    5: begin_day1 = ((begin_year-2013)*365)+(120 + begin_day)
    6: begin_day1 = ((begin_year-2013)*365)+(151 + begin_day)
    7: begin_day1 = ((begin_year-2013)*365)+(181 + begin_day)
    8: begin_day1 = ((begin_year-2013)*365)+(212 + begin_day)
    9: begin_day1 = ((begin_year-2013)*365)+(243 + begin_day)
    10: begin_day1 = ((begin_year-2013)*365)+(273 + begin_day)
    11: begin_day1 = ((begin_year-2013)*365)+(304 + begin_day)
    12: begin_day1 = ((begin_year-2013)*365)+(334 + begin_day)
  endcase
  case end_month of
    1: end_day1 = ((end_year-2013)*365)+end_day
    2: end_day1 = ((end_year-2013)*365)+(31 + end_day)
    3: end_day1 = ((end_year-2013)*365)+(59 + end_day)
    4: end_day1 = ((end_year-2013)*365)+(90 + end_day)
    5: end_day1 = ((end_year-2013)*365)+(120 + end_day)
    6: end_day1 = ((end_year-2013)*365)+(151 + end_day)
    7: end_day1 = ((end_year-2013)*365)+(181 + end_day)
    8: end_day1 = ((end_year-2013)*365)+(212 + end_day)
    9: end_day1 = ((end_year-2013)*365)+(243 + end_day)
    10: end_day1 = ((end_year-2013)*365)+(273 + end_day)
    11: end_day1 = ((end_year-2013)*365)+(304 + end_day)
    12: end_day1 = ((end_year-2013)*365)+(334 + end_day)
  endcase
  
  file_count = end_day1 - begin_day1 + 1   ;AS IN-SITU KP FILES ARE 1/DAY THIS IS EQUIVALENT
  
  insitu_filenames = strarr(file_count)      ;DEFINE ONE FILE NAME/DAY WITHIN RANGE for insitu
  iuvs_filenames_temp = strarr(file_count*6+1)
  
  year_array = strarr(file_count)
  month_array = strarr(file_count)
  day_array = strarr(file_count)
  
  date_array = TIMEGEN(file_count, START=JULDAY(begin_month,begin_day,begin_year))
  
  iuvs_file_count = 0
  iuvs_file_index_low = 0
  iuvs_file_index_hight = 0
  new_filename = ''

  for i=0,file_count[0]-1 do begin
    caldat, date_array[i], m1, d1, y1
    year_array[i] = strtrim(string(y1),2)
    if m1 lt 10 then begin
      month_array[i] = '0'+strtrim(string(m1),2)
    endif else begin
      month_array[i] = strtrim(string(m1),2)
    endelse
    if d1 lt 10 then begin
      day_array[i] = '0' + strtrim(string(d1),2)
    endif else begin
      day_array[i] = strtrim(string(d1),2)
    endelse

    ; SETUP SUFFIX FOR INSITU FILES DEPENDING ON IF LOOKING FOR BINARY FILES OR NOT
    if binary eq 0 then begin
      insitu_suffix='_v001_r01.txt'
    endif else begin
      insitu_suffix='_v001_r04.sav'
    endelse
    
    ;LOOK FOR PARTICULAR FILES BASED ON TIMESTAMP AND PICK THE HIGHEST VERSION FILE
    insitu_filenames[i] = 'mvn_KP_l2_pf_'+strtrim(string(year_array[i]),2)+strtrim(month_array[i],2)+strtrim(day_array[i],2)+insitu_suffix
    MVN_KP_INSITU_FILE_VERSIONS, insitu_filenames[i], data_dir, new_filename, binary=binary
    insitu_filenames[i] = new_filename
    
    if not keyword_set(insitu_only) then begin
      MVN_KP_IUVS_FILE_VERSIONS, year_array[i], month_array[i], day_array[i], begin_hour, begin_jul, end_jul, iuvs_dir, iuvs_file_count, iuvs, binary=binary
      ; MAKE SURE IUVS FILES WERE FOUND BEFORE TRYING TO ADD THEM
      if iuvs_file_count gt iuvs_file_index_low then begin
        iuvs_filenames_temp[iuvs_file_index_low:(iuvs_file_count-1)] = iuvs
        iuvs_file_index_low = iuvs_file_count
      endif
    endif

  endfor
  
  ;OUTPUT IUVS STRUCTURE IF NOT INSITU ONLY MODE
  if not keyword_set(insitu_only) then iuvs_filenames = iuvs_filenames_temp[0:iuvs_file_count-1]
  
end