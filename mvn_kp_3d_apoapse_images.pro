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
pro MVN_KP_3D_APOAPSE_IMAGES,input, image_out, blend, time, start

  if blend eq 1 then begin              ;RETURN AVERAGE IMAGE OVER ALL INPUT DATA
        sizes = size(input)
        counts = intarr(sizes(1),sizes(2))
        temp_image = fltarr(sizes(1),sizes(2))
        
       
        for i=0,sizes(3)-1 do begin
          for j=0,sizes(1)-1 do begin
           for k=0,sizes(2)-1 do begin
            temp_image[j,k] = temp_image[j,k]+input[j,k,i]
            if input[j,k,i] ne 0.0 then counts[j,k] = counts[j,k]+1
           endfor
          endfor
        endfor
        for i=0,sizes(1)-1 do begin
          for j=0,sizes(2)-1 do begin
            if counts[i,j] ne 0 then temp_image[i,j] = temp_image[i,j]/counts[i,j]
          endfor
        endfor
        for i=0,2 do begin
          image_out[i,*,*] = bytscl(temp_image)
        endfor
  endif                                   ;END AVERAGING LOO
  
  
  if blend eq 0 then begin
    
    new_start = time_double(start)
    new_time = time_double(time)
    
    start_min = new_start - new_time
    index = min(abs(start_min), new_min)

        for i=0,2 do begin
          image_out[i,*,*] = bytscl(input[*,*,new_min])
        endfor

  endif 





END