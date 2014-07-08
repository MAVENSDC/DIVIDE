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
pro MVN_KP_3D_CORONA_COLORS, stage, param, index, vert_color, data1

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

    target_tag = strjoin(strsplit(strupcase(strmid(param[index],0,strpos(param[index],':'))),/extract),'_')
    target_name = strmid(param[index],strpos(param[index],':')+1,strlen(param[index]))


    tags = tag_names(data1)
    level0_index = where(tags eq target_tag)
 
 
    corona_index = 0
    for i=0, n_elements(data1)-1 do begin
      if finite(data1[i].alt[0]) then begin
        level1_index = where(target_name eq data1[i].(level0_index-1))
      
        data_hold = alog10(data1[i].(level0_index))
        data_min = min(data_hold[level1_index,*])
        data_max = max(data_hold[level1_index,*])
        range = data_max - data_min
     
        if finite(range) then begin
      
          log_data = 254*(data_hold[level1_index,*]-data_min)/range
        
          for j=0, n_elements(data_hold[level1_index,*])-1 do begin
            if finite(log_data[j]) then begin
              t = log_data[j]
              vert_color[0,corona_index:corona_index+3 ] = r_orig[t]
              vert_color[1, corona_index:corona_index+3] = g_orig[t]
              vert_color[2, corona_index:corona_index+3] = b_orig[t]
            endif
              corona_index = corona_index + 4
          endfor
         endif else begin
          for j=0, n_elements(data_hold[level1_index,*])-1 do begin
           
             
              vert_color[0,corona_index:corona_index+3 ] = 0
              vert_color[1, corona_index:corona_index+3] = 0
              vert_color[2, corona_index:corona_index+3] = 0
         
              corona_index = corona_index + 4
          endfor
            
         endelse
         
        
        
        
      endif
    endfor
 
 
 
 

END