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
pro MVN_KP_3D_CORONA_COLORS, stage, param, index, vert_color, data1, reset, time, alt

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  ;IF RESET IS SET, THEN APPLY COLORS TO THE ENTIRE ORBITAL PATH, SETING ZEROS TO GREY
  
  if reset eq 1 then vert_color[*,*] = 50
  
  ;IF RESET NOT SET, THEN APPLY COLORS ONLY TO THE APPLICABLE RANGE OF ORBIT PATH, LEAVING OTHERS ALONE

    target_tag = strjoin(strsplit(strupcase(strmid(param[index],0,strpos(param[index],':'))),/extract),'_')
    target_name = strmid(param[index],strpos(param[index],':')+1,strlen(param[index]))


    tags = tag_names(data1)
    found = where(tags eq target_tag)
  for i=0,n_elements(data1) - 1 do begin
    if data1[i].time_start ne '' then begin
      new_start = time_double(data1[i].time_start, tformat="YYYY-MM-DDThh:mm:ss")
      new_stop = time_double(data1[i].time_stop, tformat="YYYY-MM-DDThh:mm:ss")
      temp = min(abs(time - new_start),start_index)
      temp = min(abs(time - new_stop),end_index)
      
    endif
  endfor 

END