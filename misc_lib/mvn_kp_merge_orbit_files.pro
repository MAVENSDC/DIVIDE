pro MVN_KP_MERGE_ORBIT_FILES, filenames

array = ''
line = ''
header0=''
header1=''

for i = 0, n_elements(filenames)-1 do begin
  openr, lun, filenames[i], /get_lun
  readf, lun, header0
  readf, lun, header1
  while not eof(lun) do begin
    readf, lun, line
    array = [array, line]
  endwhile
  free_lun, lun
endfor

openw, lun, 'C:\DIVIDE Repo\maven_orb_rec.orb'
printf, lun, header0
printf, lun, header1
for i=0,n_elements(array)-1 do begin
  printf, lun, array[i] 
endfor
free_lun, lun



end