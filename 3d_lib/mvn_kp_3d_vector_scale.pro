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
pro MVN_KP_3D_VECTOR_SCALE, old_data, old_scale, new_scale


    true_scale = old_scale/new_scale

    for i=0,(n_elements(old_data[0,*])/2)-1 do begin
      old_data[0,(i*2)+1] = old_data[0,(i*2)+1]/true_scale
      old_data[1,(i*2)+1] = old_data[1,(i*2)+1]/true_scale
      old_data[2,(i*2)+1] = old_data[2,(i*2)+1]/true_scale
    endfor


END