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
pro MVN_KP_3D_PATH_COLOR, insitu, level0_index, level1_index, path_color_table, vert_color, colorbar_ticks, $
                          colorbar_min, colorbar_max, colorbar_stretch, reset=reset

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  if level0_index eq -9 then begin        ;NO DATA PARAMETER FOR PLOTTING REQUESTED, DEFAULT TO SOLID RED ORBIT PATH
     vert_color[0,*] = 255 
     colorbar_ticks = [0.0,0.25,0.50,0.75,1.0]
  endif else begin                        ;COLOR THE ORBITAL PATH ACCORDING TO REQUESTED PARAMETER
    if colorbar_min eq 0. then begin
      minimum_value = min(insitu.(level0_index).(level1_index))
    endif else begin
      minimum_value = colorbar_min
    endelse
    if colorbar_max eq 100. then begin
      maximum_value = max(insitu.(level0_index).(level1_index))
    endif else begin
      maximum_value = colorbar_max
    endelse 
    if keyword_set(reset) then begin
      minimum_value = min(insitu.(level0_index).(level1_index))
      maximum_value = max(insitu.(level0_index).(level1_index))
      colorbar_min = minimum_value
      colorbar_max = maximum_value
    endif
    
    if colorbar_stretch eq 0 then begin                         ;STRAIGHT LINEAR DATA STRETCH
      delta = (maximum_value-minimum_value)/255.
      for i=0,n_elements(vert_color[0,*])-1 do begin
        t = floor((insitu[i].(level0_index).(level1_index)-minimum_value)/delta)
        if t gt 255 then begin
          vert_color[0,i] = r_orig[255]
          vert_color[1,i] = g_orig[255]
          vert_color[2,i] = b_orig[255]
        endif
        if t lt 0 then begin
          vert_color[0,i] = r_orig[0]
          vert_color[1,i] = g_orig[0]
          vert_color[2,i] = b_orig[0]
        endif
        if t ge 0 and t le 255 then begin
          vert_color[0,i] = r_orig[t]
          vert_color[1,i] = g_orig[t]
          vert_color[2,i] = b_orig[t]
        endif
      endfor
    endif 
    
    if colorbar_stretch eq 1 then begin                         ;Log stretch
      exponent = 2
      data_mean = 0.5
      for i=0,n_elements(insitu.(level0_index).(level1_index))-1 do  begin
        if insitu[i].(level0_index).(level1_index) lt minimum_value then begin
          vert_color[0,i] = r_orig[0]
          vert_color[1,i] = g_orig[0]
          vert_color[2,i] = b_orig[0]
        endif
        if insitu[i].(level0_index).(level1_index) gt maximum_value then begin
          vert_color[0,i] = r_orig[255]
          vert_color[1,i] = g_orig[255]
          vert_color[2,i] = b_orig[255]
        endif
        if (insitu[i].(level0_index).(level1_index) gt minimum_value) and (insitu[i].(level0_index).(level1_index) lt maximum_value) then begin
          t = 255./(1.+(data_mean/insitu[i].(level0_index).(level1_index))^exponent)
          vert_color[0,i] = r_orig[t]
          vert_color[1,i] = g_orig[t]
          vert_color[2,i] = b_orig[t]
        endif
      endfor      
    endif
    
    colorbar_ticks = fltarr(5)
    for i=0,4 do begin
      colorbar_ticks[i] = minimum_value + i*((maximum_value-minimum_value)/4.)
    endfor

    
  endelse




END