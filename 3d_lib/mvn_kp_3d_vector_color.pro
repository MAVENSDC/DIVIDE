;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

pro MVN_KP_3D_VECTOR_COLOR, data, vert_color, colorbar_stretch


common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr



    maximum_value = max(data, /NAN)
    minimum_value = min(data, /NAN)
    delta = (maximum_value-minimum_value)/255.

    range = size(data)

  
    if colorbar_stretch eq 0 then begin
      for i=0,range[1]-1 do begin
          t = floor((data[i]-minimum_value)/delta)
          if t gt 255 then begin
            vert_color[0,(i*2)] = r_orig[255]
            vert_color[1,(i*2)] = g_orig[255]
            vert_color[2,(i*2)] = b_orig[255]
            vert_color[0,(i*2)+1] = r_orig[255]
            vert_color[1,(i*2)+1] = g_orig[255]
            vert_color[2,(i*2)+1] = b_orig[255]
          endif
          if t lt 0 then begin
            vert_color[0,(i*2)] = r_orig[0]
            vert_color[1,(i*2)] = g_orig[0]
            vert_color[2,(i*2)] = b_orig[0]
            vert_color[0,(i*2)+1] = r_orig[0]
            vert_color[1,(i*2)+1] = g_orig[0]
            vert_color[2,(i*2)+1] = b_orig[0]
          endif
          if t ge 0 and t le 255 then begin
            vert_color[0,(i*2)] = r_orig[t]
            vert_color[1,(i*2)] = g_orig[t]
            vert_color[2,(i*2)] = b_orig[t]
            vert_color[0,(i*2)+1] = r_orig[t]
            vert_color[1,(i*2)+1] = g_orig[t]
            vert_color[2,(i*2)+1] = b_orig[t]
          endif
          if finite(data[i]) eq 0 then begin
            vert_color[0,(i*2)] = 0
            vert_color[1,(i*2)] = 0
            vert_color[2,(i*2)] = 0
            vert_color[0,(i*2)+1] = 0
            vert_color[1,(i*2)+1] = 0
            vert_color[2,(i*2)+1] = 0
          endif
      endfor
    endif
    if colorbar_stretch eq 1 then begin
      exponent = 2
      data_mean = 0.5
        for i=0,range[1]-1 do begin
          t = floor((data[i]-minimum_value)/delta)
          if t gt 255 then begin
            vert_color[0,(i*2)] = r_orig[255]
            vert_color[1,(i*2)] = g_orig[255]
            vert_color[2,(i*2)] = b_orig[255]
            vert_color[0,(i*2)+1] = r_orig[255]
            vert_color[1,(i*2)+1] = g_orig[255]
            vert_color[2,(i*2)+1] = b_orig[255]
          endif
          if t lt 0 then begin
            vert_color[0,(i*2)] = r_orig[0]
            vert_color[1,(i*2)] = g_orig[0]
            vert_color[2,(i*2)] = b_orig[0]
            vert_color[0,(i*2)+1] = r_orig[0]
            vert_color[1,(i*2)+1] = g_orig[0]
            vert_color[2,(i*2)+1] = b_orig[0]
          endif
          if t ge 0 and t le 255 then begin
            t = 255./(1.+(data_mean/data[i])^exponent)
            vert_color[0,(i*2)] = r_orig[t]
            vert_color[1,(i*2)] = g_orig[t]
            vert_color[2,(i*2)] = b_orig[t]
            vert_color[0,(i*2)+1] = r_orig[t]
            vert_color[1,(i*2)+1] = g_orig[t]
            vert_color[2,(i*2)+1] = b_orig[t]
          endif
      endfor
    endif

END