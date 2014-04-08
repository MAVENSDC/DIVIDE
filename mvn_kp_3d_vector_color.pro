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
;-
pro MVN_KP_3D_VECTOR_COLOR, data, vert_color, colorbar_stretch


common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr



    maximum_value = max(data)
    minimum_value = min(data)
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