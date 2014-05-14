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
pro MVN_KP_3D_CURRENT_PERIAPSE, periapse, initial_time, current_periapse, plot_value,xlabel



    current_time = time_double(periapse.time_start)

    time_delta = min(abs(current_time-initial_time),min_index)
    
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