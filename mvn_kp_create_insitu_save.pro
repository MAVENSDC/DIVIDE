;; Infiles : Input array of files with paths of insitu ascii files to convert to save files
;; 
;; Outdir : Output path where created save files should go. 



pro mvn_kp_create_insitu_save, infiles, outdir              


for file=0, n_elements(infiles)-1 do begin

  base = file_basename(infiles[file])
  base = (strsplit(base, '.', /extract))[0]

  ;UPDATE THE READ STATUS BAR
  MVN_LOOP_PROGRESS,file,0,n_elements(infiles)-1,message='In-Situ Save file creation progress'
  
  ;OPEN THE KP DATA FILE
  openr,lun,infiles[file,0],/get_lun
  
  ;; Determine # of data points:
  data_count = 0
  while not eof(lun) do begin
    temp = ''
    readf,lun,temp
    data = strsplit(temp,' ',/extract)
    if data[0] ne '#' then begin
      data_count++
    endif
  endwhile
  free_lun, lun
  
  
  ;; Create Orbit array for structures to be put into
  orbit_temp = {time_string:'', time: 0.0, orbit:0L, IO_bound:'', data:fltarr(212)}
  orbit = replicate(orbit_temp, data_count)
  

  ;OPEN THE KP DATA FILE
  openr,lun,infiles[file,0],/get_lun
  
  ;READ IN A LINE, EXTRACTING THE TIME
  i=0
  while not eof(lun) do begin
    temp = ''
    readf,lun,temp
    data = strsplit(temp,' ',/extract)
    if data[0] ne '#' then begin
   

      
      ;READ IN AND INIT TEMP STRUCTURE OF DATA
      orbit[i].time_string = data[0]
      orbit[i].time = time_double(data[0])
      orbit[i].orbit = data[198]
      orbit[i].IO_bound = data[199]
      orbit[i].data[0:196] = data[1:197]
      orbit[i].data[197:211] = data[200:214]

      i++
    endif
  endwhile

  save,orbit,filename=outdir+'/'+base+'.sav'
  orbit=0
  free_lun,lun
endfor    


end

