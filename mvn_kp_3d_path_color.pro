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
pro MVN_KP_3D_PATH_COLOR, insitu, level0_index, level1_index, path_color_table, vert_color, colorbar_ticks

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  if level0_index eq -9 then begin        ;NO DATA PARAMETER FOR PLOTTING REQUESTED, DEFAULT TO SOLID RED ORBIT PATH
     vert_color[0,*] = 255 
     colorbar_ticks = [0.0,0.25,0.50,0.75,1.0]
  endif else begin                        ;COLOR THE ORBITAL PATH ACCORDING TO REQUESTED PARAMETER
    minimum_value = min(insitu.(level0_index).(level1_index))
    maximum_value = max(insitu.(level0_index).(level1_index))
    
    delta = (maximum_value-minimum_value)/255.
    for i=0,n_elements(vert_color[0,*])-1 do begin
      t = floor((insitu[i].(level0_index).(level1_index)-minimum_value)/delta)
      vert_color[0,i] = r_orig[t]
      vert_color[1,i] = g_orig[t]
      vert_color[2,i] = b_orig[t]
    endfor
    
    colorbar_ticks = fltarr(5)
    for i=0,4 do begin
      colorbar_ticks[i] = minimum_value + i*((maximum_value-minimum_value)/4.)
    endfor
    
  endelse




END