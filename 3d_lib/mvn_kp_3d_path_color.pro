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
pro MVN_KP_3D_PATH_COLOR, insitu, level0_index, level1_index, $
                          path_color_table, vert_color, colorbar_ticks, $
                          colorbar_min, colorbar_max, colorbar_stretch, $
                          reset=reset

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  if level0_index eq -9 then begin        
    ;NO DATA PARAMETER FOR PLOTTING REQUESTED, DEFAULT TO SOLID RED ORBIT PATH
    vert_color[0,*] = 255
    ; The plotted parameter in this case is altitude, so use those to
    ;  define the color bar ticks
    minimum_value = min( insitu.spacecraft.altitude, /NaN )
    maximum_value = max( insitu.spacecraft.altitude, /NaN )
    colorbar_min = minimum_value
    colorbar_max = maximum_value
  endif else begin
    ; ToDo: May need to allow for log scaling.
    ; Not sure when reset is ever sent to this procedure.
    minimum_value = colorbar_min
    maximum_value = colorbar_max
    ;COLOR THE ORBITAL PATH ACCORDING TO REQUESTED PARAMETER
    if keyword_set(reset) then begin
      minimum_value = min(insitu.(level0_index).(level1_index),/NaN)
      maximum_value = max(insitu.(level0_index).(level1_index),/NaN)
      colorbar_min = minimum_value
      colorbar_max = maximum_value
    endif
    
    if colorbar_stretch eq 0 then begin                         
      ;STRAIGHT LINEAR DATA STRETCH
      delta = (maximum_value-minimum_value)/255.
      for i=0,n_elements(insitu.(level0_index).(level1_index))-1 do begin
;        if insitu[i].(level0_index).(level1_index) ne 0.0 then begin
          t = floor( ( insitu[i].(level0_index).(level1_index) $
                     - minimum_value ) $
                   / delta )
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
;        endif ; check on value ne 0
      endfor  ; loop over elements in insitu1
    endif     ; if linear stretch
    
    if colorbar_stretch eq 1 then begin                         
      ;Log stretch
;-km- may need to multiply this by signum(arg) to preserve negative vals
      delta = alog10( maximum_value / minimum_value ) / 255.
      for i=0,n_elements(insitu.(level0_index).(level1_index))-1 do  begin
        t = floor( alog10( insitu[i].(level0_index).(level1_index) $
                         / minimum_value ) $
                 / delta )
        if insitu[i].(level0_index).(level1_index) ne 0.0 then begin
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
        endif
      endfor      
    endif
  endelse

  colorbar_ticks = fltarr(5)
  for i=0,4 do begin
    colorbar_ticks[i] = keyword_set( colorbar_stretch ) $
      ? minimum_value * 10.^(i*alog10(maximum_value/minimum_value)/4.)$
      : minimum_value + i*((maximum_value-minimum_value)/4.)
  endfor
END