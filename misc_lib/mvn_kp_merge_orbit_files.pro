;+
; :Name: mvn_kp_merge_orbit_files
;
; :Author: Bryan Harter
;
;
; :Description:
;     A helper routine that merges orbit files into one master file.  
;
; :Params:
;    filenames : in, required, type=string array
;       Variable holding the file names to be merged into one file.
;       Must be given in chronological order
;-

pro MVN_KP_MERGE_ORBIT_FILES, filenames

;Initialize variables as strings
orbit_array = ''
line = ''
header0=''
header1=''

;Read all the filenames, and write each row to an element
;in orbit_array 
for i = 0, n_elements(filenames)-1 do begin
  openr, lun, filenames[i], /get_lun
  readf, lun, header0
  readf, lun, header1
  while not eof(lun) do begin
    readf, lun, line
    orbit_array = [orbit_array, line]
  endwhile
  free_lun, lun
endfor

;Open the master file, clear it, and write all of the
;elements of orbit_array to it
openw, lun, 'C:\DIVIDE Repo\maven_orb_rec.orb'
printf, lun, header0
printf, lun, header1
for i=0,n_elements(orbit_array)-1 do begin
  printf, lun, orbit_array[i] 
endfor
free_lun, lun


end