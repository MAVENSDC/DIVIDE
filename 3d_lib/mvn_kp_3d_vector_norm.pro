pro MVN_KP_3D_VECTOR_NORM, old_vec_data, old_data, scale


    length = fltarr(n_elements(old_vec_data[0,*]))
    for i=0,n_elements(old_vec_data[0,*]) - 1 do begin
      length[i] = sqrt(((old_vec_data[0, i]-old_data[0,i*2])^2)+((old_vec_data[1, i]-old_data[1,i*2])^2)+((old_vec_data[2, i]-old_data[2,i*2])^2))
    endfor
   
    max_length = max(length, /NaN)/scale
    
    for i=0,(n_elements(old_vec_data[0,*]))-1 do begin
      old_vec_data[0, i] = old_vec_data[0, i]/max_length
      old_vec_data[1, i] = old_vec_data[1, i]/max_length
      old_vec_data[2, i] = old_vec_data[2, i]/max_length
    endfor


END