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
pro MVN_KP_3D_PERI_COLOR, vert_color, data

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr



    maximum_value = max(data, /NAN)
    minimum_value = min(data, /NAN)
    delta = (maximum_value-minimum_value)/255.

    range = size(data)
    
    index=0
    for i=0,range[1]-1 do begin
      for j=0,range[2]-1 do begin
        t = floor((data[i,j]-minimum_value)/delta)
        if t gt 255 then begin
          vert_color[0,index] = r_orig[255]
          vert_color[1,index] = g_orig[255]
          vert_color[2,index] = b_orig[255]
        endif
        if t lt 0 then begin
          vert_color[0,index] = r_orig[0]
          vert_color[1,index] = g_orig[0]
          vert_color[2,index] = b_orig[0]
        endif
        if t ge 0 and t le 255 then begin
          vert_color[0,index] = r_orig[t]
          vert_color[1,index] = g_orig[t]
          vert_color[2,index] = b_orig[t]
        endif
        index++
      endfor
    endfor



END