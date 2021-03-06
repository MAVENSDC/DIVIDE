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
;       
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
pro MVN_KP_3D_MAVEN_MODEL, x,y,z,polylist, scale,cow=cow,install_directory


  if keyword_set(cow) then begin
    filename = filepath('cow10.sav', subdir=['examples','data'])
  endif else begin
    if !version.os_family eq 'unix' then begin
      filename = install_directory+'/3d_lib/maven_model.sav'  
    endif else begin
      filename = install_directory+'\3d_lib\maven_model.sav'
    endelse
  endelse
  restore,filename=filename

  x = x * scale
  y = y * scale
  z = z * scale




END