;; Testing CDF Generation of insitu

pro insitu_cdf_write

mvn_kp_read, ['2015-04-03/12:00:00', '2015-04-03/16:00:30'] , insitu, iuvs, /binary

;masterCDF = 'cdf_work/maven_swia_master.cdf'
masterCDF = 'cdf_work/full_maven_insitu_master.cdf'
outputCDF = 'cdf_work/insitu_out.cdf'

insitu_cut = insitu[0:4]

;; Release insitu and iuvs
insitu=0
iuvs=0

insitu=insitu_cut

;; Top level data
time     = insitu.time
orbit    = insitu.orbit
io_bound = insitu.io_bound

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
cdfi_insitu = cdf_load_vars(masterCDF, /ALL)


;; Set top level variables
ptr = PTR_NEW(time)
cdfi_insitu.vars[1].dataptr = ptr
ptr = PTR_NEW(orbit)
cdfi_insitu.vars[2].dataptr = ptr
ptr = PTR_NEW(io_bound)
cdfi_insitu.vars[3].dataptr = ptr



;; Loop through varialbes, create a pointer to a (copy) of a paramter
;; Number of variables
j=4
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


dummy = cdf_save_vars(cdfi_insitu, outputCDF)


end
