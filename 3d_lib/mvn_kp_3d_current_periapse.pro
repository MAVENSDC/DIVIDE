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
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
pro MVN_KP_3D_CURRENT_PERIAPSE, periapse, initial_time, current_periapse, plot_value,xlabel



    current_time = time_double(periapse.time_start, tformat="YYYY-MM-DDThh:mm:ss")

    time_delta = min(abs(current_time-initial_time),min_index, /NAN)
    
    current_periapse = fltarr(2,n_elements(periapse[min_index].alt))
    
    if strmid(plot_value,0,1) eq 'D' then begin
      xlabel = strtrim(strmid(plot_value, strpos(plot_value,':')+1,strlen(plot_value)-strpos(plot_value,':')),2)
      peri_index = where(periapse[min_index].density_id eq xlabel)
      current_periapse[0,*] = periapse[min_index].alt
      current_periapse[1,*] = periapse[min_index].density[peri_index,*]
    endif
    if strmid(plot_value,0,1) eq 'R' then begin
      xlabel = strtrim(strmid(plot_value, strpos(plot_value,':')+1,strlen(plot_value)-strpos(plot_value,':')),2)
      peri_index = where(periapse[min_index].radiance_id eq xlabel)
      current_periapse[0,*] = periapse[min_index].alt
      current_periapse[1,*] = periapse[min_index].radiance[peri_index,*]      
    endif

END