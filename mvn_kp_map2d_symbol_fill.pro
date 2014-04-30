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
pro MVN_KP_MAP2D_SYMBOL_FILL, input, fill_color, color_default, colorbars

  common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  loadct,color_default,/silent

  
  parameter_minimum = min(input)
  parameter_maximum = max(input)
  
  fill_color[0,*] = r_curr[fix(((input-parameter_minimum)/(parameter_maximum-parameter_minimum))*255)] 
  fill_color[1,*] = g_curr[fix(((input-parameter_minimum)/(parameter_maximum-parameter_minimum))*255)] 
  fill_color[2,*] = b_curr[fix(((input-parameter_minimum)/(parameter_maximum-parameter_minimum))*255)] 

  colorbars = intarr(3,256)
  colorbars[0,*] = r_curr
  colorbars[1,*] = g_curr
  colorbars[2,*] = b_curr


END