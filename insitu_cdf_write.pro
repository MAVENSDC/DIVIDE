;; Testing CDF Generation of insitu

pro insitu_cdf_write

all_files = file_search('/Users/martin/repos/data_maven/kp_data/mvn*sav')
masterCDF = '/Users/martin/repos/maventoolkit/cdf_work/full_maven_insitu_master.cdf'

foreach file , all_files do begin

  
;; Release insitu and iuvs
insitu=0


base = file_basename(file, '.sav')
outpath='/Users/martin/repos/data_maven/insitu_cdf/'
year=strmid(base, 13, 4)
month=strmid(base, 17, 2)
day=strmid(base, 19, 2)

startdate = year+'-'+month+'-'+day+'/00:00:00'
enddate = year+'-'+month+'-'+day+'/23:59:59'

mvn_kp_read, [startdate, enddate] , insitu, /binary, /insitu_only


;; Top level data
time        = insitu.time
time_string = insitu.time_string
orbit       = insitu.orbit
io_bound    = insitu.io_bound

;; Instruments
ngims      = insitu.ngims
sep        = insitu.sep
mag        = insitu.mag
swea       = insitu.swea
swia       = insitu.swia
static     = insitu.static
lpw        = insitu.lpw
spacecraft = insitu.spacecraft
app        = insitu.app


;; Load CDF Master file (empty) that we will fill in
cdfi_insitu=0
cdfi_insitu = cdf_load_vars(masterCDF, /ALL)


;; Set top level variables
ptr = PTR_NEW(time_string)
cdfi_insitu.vars[1].dataptr = ptr
ptr = PTR_NEW(time)
cdfi_insitu.vars[2].dataptr = ptr
ptr = PTR_NEW(orbit)
cdfi_insitu.vars[3].dataptr = ptr
ptr = PTR_NEW(io_bound)
cdfi_insitu.vars[4].dataptr = ptr



;; Loop through varialbes, create a pointer to a (copy) of a paramter
;; Number of variables
j=5
NV=n_tags(lpw)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(lpw.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr

  ;; Debuging
  ;print, cdfi_insitu.vars[j].name, "  ", (tag_names(lpw))[i]
  
  j++
endfor

NV=n_tags(static)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(static.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor

NV=n_tags(swia)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(swia.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor

NV=n_tags(swea)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(swea.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor

NV=n_tags(mag)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(mag.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor

NV=n_tags(sep)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(sep.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor

NV=n_tags(ngims)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(ngims.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor

NV=n_tags(spacecraft)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(spacecraft.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor

NV=n_tags(app)
for i=0, NV-1 Do begin
  ptr = PTR_NEW(app.(i))
  
  ;; Point Cdfi.swia pointer to new copied memory of variable
  cdfi_insitu.vars[j].dataptr = ptr
  j++
endfor


dummy = cdf_save_vars(cdfi_insitu,outpath+base+'.cdf')


endforeach

end
