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
pro MVN_KP_3D_APOAPSE_IMAGES,input, image_out, blend, time, start, stop, apo_time_blend

  if blend eq 0 then begin
    a = where(start eq '',count)
    if count gt 0 then begin
      temp_start = strarr(n_elements(start))
      temp_stop = strarr(n_elements(stop))
      temp_input = input
      temp_input[*] = 0.0d
      temp_index = 0
      for i=0,n_elements(start)-1 do begin
        if start[i] ne '' then begin
          temp_start[temp_index] = start[i]
          temp_stop[temp_index] = stop[i]
          temp_input[*,*,temp_index] = input[*,*,i]
          temp_index=temp_index+1
        endif
      endfor
      start = temp_start[0:temp_index-1]
      stop = temp_stop[0:temp_index-1]
      input = temp_input[*,*,0:temp_index-1]
    endif
  endif else begin
    a = where(start eq '')
    if a ne -1 then begin
      temp_start = strarr(n_elements(start))
      temp_input = input
      temp_input[*] = 0.0d
      temp_index = 0
      for i=0,n_elements(start)-1 do begin
        if start[i] ne '' then begin
          temp_start[temp_index] = start[i]
          temp_input[*,*,temp_index] = input[*,*,i]
          temp_index=temp_index+1
        endif
      endfor
      start = temp_start[0:temp_index-1]
      input = temp_input[*,*,0:temp_index-1]
    endif    
  endelse  

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
    
  
    if apo_time_blend eq 0 then begin
      new_start = time_double(start, tformat="YYYY-MM-DDThh:mm:ss")
      new_end = time_double(stop, tformat="YYYY-MM-DDThh:mm:ss")
      new_time = time_double(time, tformat="YYYY-MM-DDThh:mm:ss")
    endif else begin
      new_start = time_double(start, tformat="YYYY-MM-DDThh:mm:ss")
      new_end = time_double(stop, tformat="YYYY-MM-DDThh:mm:ss")
      new_time = time_double(time, tformat="YYYY-MM-DDThh:mm:ss")
      
      temp_start = dblarr(n_elements(new_start))
      temp_end = dblarr(n_elements(new_end))
      
      temp_start[0] = 0d
      for i=1,n_elements(new_start)-1 do begin
        temp_start[i] = new_start[i] - ((new_start[i] - new_end[i-1])/2)
        temp_end[i-1] = new_end[i-1] + ((new_start[i]-new_end[i-1])/2)
      endfor
      temp_end[n_elements(new_end)-1] = 1e10
      
      new_start = temp_start
      new_end = temp_end
    endelse 
 
 
    if new_time ge new_start[0] then begin    ;selected time falls after first iuvs image
      if new_time le new_end[n_elements(new_end)-1] then begin        ;selected time falls before final iuvs image
        image_index = -1
        
        start_gap = new_time - new_start
        end_gap = new_time - new_end
        
        for i=0,n_elements(new_start)-1 do begin
          if start_gap[i] ge 0.0 then begin
            if end_gap[i] le 0.0 then begin
              image_index = i 
            endif
          endif
        endfor
      
        if image_index ge 0 then begin
         for i=0,2 do begin
            image_out[i,*,*] = bytscl(input[*,*,image_index])
          endfor
        endif
        

        image_size=size(image_out,/dimensions)
        image_out = shift(image_out, 0,image_size[1]/2,0)
      
      endif else begin                              ;selected time falls before last iuvs image
        image_out[*,*,*] = 0
      endelse 
    endif else begin                          ;selected time falls before first iuvs image
      image_out[*,*,*] = 0
    endelse
 



       
  endif 





END