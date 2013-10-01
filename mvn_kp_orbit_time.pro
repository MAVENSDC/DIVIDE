;+
; A helper routine that converts from orbit number to date and time for the purpose of reading KP data.
;
; :Params:
;    begin_orbit : in, required, type=integer
;       variable holding the beginning orbit number to convert
;    end_orbit : in, required, type=integer
;       variable holding the ending orbit number to convert
;    begin_time : out, required, type=integer
;       variable returned holding the beginning time equivalent to the start orbit
;    end_time : out, required, type=integer
;       variable returned holding the end time equivalent to the end orbit
;
; :Keywords:
;-
pro MVN_KP_ORBIT_TIME, begin_orbit, end_orbit, begin_time, end_time, begin_index, end_index


;FIND THE ORBIT/TIME TEXT FILE, OR PROMPT IF IT CAN'T BE FOUND.
   orbit_directory = strsplit(file_search('$HOME', 'MVN_Orbit_Sequence.txt'),'MVN_Orbit_Sequence.txt',/extract,/regex)     ;Determine the toolkit installation directory

   if orbit_directory eq '' then begin        ;PROMPT THE USER BECAUSE THE ORBIT FILE COULDN'T BE FOUND
     orbit_directory = dialog_pickfile(path=orbit_directory,/directory,title='Choose the directory containing time ordered orbit list')
   endif 


;READ IN THE ORBIT TEXT FILE FOR COMPARISON PURPOSES

  restore,orbit_directory+'orbit_template.sav'
  orbits = read_ascii(orbit_directory+'MVN_Orbit_Sequence.txt',template=orbit_template)

;FIND THE TIME FOR THE BEGINNING ORBIT

  begin_index = where(orbits.orbit eq begin_orbit)
  
  case orbits.month(begin_index) of
    'JAN': month_tag = '01'
    'FEB': month_tag = '02'
    'MAR': month_tag = '03'
    'APR': month_tag = '04'
    'MAY': month_tag = '05'
    'JUN': month_tag = '06'
    'JUL': month_tag = '07'
    'AUG': month_tag = '08'
    'SEP': month_tag = '09'
    'OCT': month_tag = '10'
    'NOV': month_tag = '11'
    'DEC': month_tag = '12'
  endcase
  
  ;ADD THE LEADING ZERO TO THE DAY, IF NEEDED
  if orbits.day(begin_index) lt 10 then begin
   day_tag = '0'+ strtrim(string(orbits.day(begin_index)),2)
  endif else begin
   day_tag = strtrim(string(orbits.day(begin_index)),2)
  endelse
  
  begin_time = strtrim(string(orbits.year(begin_index)),2)+'-'+strtrim(string(month_tag),2)+'-'+day_tag+$
               '/'+strtrim(string(orbits.time(begin_index)),2)
               
               
               
;FIND THE TIME FOR THE ENDING ORBIT

  end_index = where(orbits.orbit eq end_orbit) + 1        ;ADD ONE TO MAKE SURE WE GET THE FULL EXTENT OF THE FINAL ORBIT

  case orbits.month(end_index) of
    'JAN': month_tag = '01'
    'FEB': month_tag = '02'
    'MAR': month_tag = '03'
    'APR': month_tag = '04'
    'MAY': month_tag = '05'
    'JUN': month_tag = '06'
    'JUL': month_tag = '07'
    'AUG': month_tag = '08'
    'SEP': month_tag = '09'
    'OCT': month_tag = '10'
    'NOV': month_tag = '11'
    'DEC': month_tag = '12'
  endcase
  
  if orbits.day(end_index) lt 10 then begin
   day_tag = '0'+ strtrim(string(orbits.day(end_index)),2)
  endif else begin
   day_tag = strtrim(string(orbits.day(end_index)),2)
  endelse
  
  end_time = strtrim(string(orbits.year(end_index)),2)+'-'+strtrim(string(month_tag),2)+'-'+day_tag+$
               '/'+strtrim(string(orbits.time(end_index)),2)



end 