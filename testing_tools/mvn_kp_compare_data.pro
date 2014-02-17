;;
;;
;;
;; Procedure to aid in regression testing
;;
;; This procedure takes in two arbitrary arrays of structures and compares them element by element
;;
;; The input structure can look like:
;; Any length array (including zero) of structures
;; Each structure tag can point to a Scalar, an multidemensional array, or arrays of sub structures
;; The substructures tags can point to scalars or multidemensional arrays. 
;;


pro mvn_kp_compare_nonfinite, val1, val2

    ;; If Numbers are NaNs
    if finite(val1, /NAN) then begin
      if finite(val1, /NAN) ne finite(val2, /NAN) then message,  "values not equal: " +val1 + " and "+val2
    endif
    
    ;; If Numbers are Infinity
    if finite(val1, /INFINITY) then begin
      if finite(val1, /INFINITY) ne finite(val2, /INFINITY) then message,  "values not equal: " +val1 + " and "+val2      
    endif
    
end


pro mvn_kp_compare_scalars, input1, input2, i=i, j=j, k=k, l=l, x=x, y=y, z=z, si=si
  ;; Check first if NAN or Infinity
  if size(input1, /TYPE) eq 4 or size(input1, /TYPE) eq 5 then begin
    if not finite(input1) then begin
      mvn_kp_compare_nonfinite, input1, input2
    endif else begin
      if input1 ne input2 then message, "values not equal in array: " +string(input1) + " and "+string(input2)
    endelse
  endif else begin
    if input1 ne input2 then message, "values not equal in array: " +string(input1) + " and "+string(input2)
  endelse

end

pro mvn_kp_compare_arrays, input1, input2, dim, i=i, j=j, k=k, l=l, si=si
  
  ;; 0 dim array - Scalar
  if dim eq 0 then begin
    mvn_kp_compare_scalars, input1, input2, i=i, j=j, k=k, l=l, si=si
  endif
    
  ;; 1 dmin array
  if dim eq 1 then begin
    xdim1 = (size(input1, /dimensions))[0]
    xdim2 = (size(input2, /dimensions))[0]
    if xdim1 ne xdim2 then message, "Dimensions not equal xdim1: "+string(xdmin1)+ " xdim2: "+string(xdim2)
    
    for x=0, xdim1-1 do begin     
      mvn_kp_compare_scalars, input1[x], input2[x], i=i, j=j, k=k, si=si, l=l, x=x
    endfor
  
  endif

  ;; 2 Dmin array
  if dim eq 2 then begin
    xdim1 = (size(input1, /dimensions))[0]
    xdim2 = (size(input2, /dimensions))[0]
    ydim1 = (size(input1, /dimensions))[1] 
    ydim2 = (size(input2, /dimensions))[1]
    
    if xdim1 ne xdim2 then message, "Dimensions not equal xdim1: "+string(xdmin1)+ " xdim2: "+string(xdim2)
    if ydim1 ne ydim2 then message, "Dimensions not equal ydim1: "+string(ydmin1)+ " ydim2: "+string(ydim2)
    
    for x=0, xdim1-1 do begin
      for y=0, ydim1-1 do begin
        mvn_kp_compare_scalars, input1[x,y], input2[x,y], i=i, j=j, k=k, l=l, si=si, x=x, y=y
      endfor
    endfor

  endif


  ;; 3 Dimin array
  if dim eq 3 then begin
    xdim1 = (size(input1, /dimensions))[0]
    xdim2 = (size(input2, /dimensions))[0]
    ydim1 = (size(input1, /dimensions))[1]
    ydim2 = (size(input2, /dimensions))[1]
    zdim1 = (size(input1, /dimensions))[2]
    zdim2 = (size(input2, /dimensions))[2]
    
    if xdim1 ne xdim2 then message, "Dimensions not equal xdim1: "+string(xdmin1)+ " xdim2: "+string(xdim2)
    if ydim1 ne ydim2 then message, "Dimensions not equal ydim1: "+string(ydmin1)+ " ydim2: "+string(ydim2)
    if zdim1 ne zdim2 then message, "Dimensions not equal zdim1: "+string(zdmin1)+ " zdim2: "+string(zdim2)
    
    for x=0, xdim1-1 do begin
      for y=0, ydim1-1 do begin
        for z=0, zdim1-1 do begin
          mvn_kp_compare_scalars, input1[x,y,z], input2[x,y,z], i=i, j=j, k=k, l=l, si=si, x=x, y=y, z=z
        endfor
      endfor
    endfor
    
  endif

  if dim gt 3 then begin
    message, "Dimension greater than three found. Not expected and cannot handle"
  endif

end



;;
;; Main Procedure
;; Takes two structures or arrays of structures structured like Insitu Or IUVVS data
;; and compares them element by element. 
;;
;;
pro mvn_kp_compare_data, input1, input2


;mvn_kp_read, ['2015-04-01/13:06:51', '2015-04-04/14:59:00'] , insitu1, /insitu_only
;mvn_kp_read, ['2015-04-01/13:06:51', '2015-04-04/14:59:00'] , insitu2, /savefiles, /insitu_only
;input1 = insitu1
;input2 = insitu2


;mvn_kp_read, ['2015-04-01/13:00:02', '2015-04-06/11:00:59'] , insitu1, iuvs1
;mvn_kp_read, ['2015-04-01/13:00:02', '2015-04-06/11:00:59'] , insitu2, iuvs2, /savefiles
;input1 = iuvs1
;input2 = iuvs2
;; Testing compare function by altering single values at a time.
;;
;input1[2].periapse[1].density[2,1] = 4.99999
;input1[1].periapse[2].temperature_err = 4.9999
;input1[3].corona_e_disk.lat = 4.9999
;input1[2].corona_e_disk.radiance_err[2] = 4.9999
;input1[1].corona_e_limb.radiance[0,30] = 4.99999
;input1[4].apoapse.radiance[2,10,12] = 4.99999
;input1[0].orbit = 800




;; Top layer array
numElements1 = n_elements(input1)
numElements2 = n_elements(input2)

if numElements1 ne numElements2 then message, "Top level arrays have inequal number of elements"

for i=0, numElements1-1 do begin
  
  numTags1 = n_tags(input1[i])
  numTags2 = n_tags(input2[i])
  
  if numTags1 ne numTags2 then message, "Number of tags in index: "+string(i)+" are not equal."
  
  
  ;; For each tag
  for j=0, numTags1-1 do begin
    type1 = (size(input1[i].(j), /STRUCTURE)).type_name
    type2 = (size(input2[i].(j), /STRUCTURE)).type_name
    
    if type1 ne type2 then message, "Inconsitent types at array number: "+string(i)+" and tag position: "+string(j)
    
    
    ;; If type is not a struct, then we either have a scalar or an array (possibly multidimensional)
    if type1 ne 'STRUCT' then begin
      dim1 = size(input1[i].(j), /N_DIMENSIONS)
      dim2 = size(input2[i].(j), /N_DIMENSIONS)
      
      if dim1 ne dim2 then message, "Inconsistent array dimensions at top array #: "+string(i)+" and tag position: "+string(j)            
      mvn_kp_compare_arrays, input1[i].(j), input2[i].(j), dim1, i=i, j=j


    ;; If type IS a struct then handle it as such
    endif else begin
      numStructs1 = n_elements(input1[i].(j))
      numStructs2 = n_elements(input2[i].(j))
      if numStructs1 ne numStructs2 then message, "Number of substructs not equal: "+string(numStructs1)+" and "+string(numStructs2)
      
      ;; For each substruct
      for si=0, numStructs1-1 do begin
        
        innerNumElements1 = n_elements(input1[i].(j)[si])
        innerNumElements2 = n_elements(input2[i].(j)[si])
        
        if innerNumElements1 ne innerNumElements2 then message, "Inconsistent inner number of structure elements at top array#: "+string(i)+" and tag position: "+string(j)
        
        
        for k=0, innerNumElements1 - 1 do begin
          subStruct1 = (input1[i].(j)[si])[k]
          subStruct2 = (input2[i].(j)[si])[k]
          
          subStructNumTags1 = n_tags(subStruct1)
          subStructNumTags2 = n_tags(subStruct2)
          
          if subStructNumTags1 ne subStructNumTags2 then message, "Inconsistent number of tags in sub structurs at i:"+string(i)+" j:"+string(j)+" k:"+string(k)
          
          ;; For each tag in substructure
          for l=0, subStructNumTags1-1 do begin
            ;; At this point we assume we're dealing with only scalars and multidimensional arrays
            if (size(subStruct1.(l), /STRUCTURE)).type_name eq 'STRUCT' then message, "There shouldn't be structures at this point"         
            
            subDim1 = size(subStruct1.(l), /N_DIMENSIONS)
            subDim2 = size(subStruct2.(l), /N_DIMENSIONS)
            
            if subDim1 ne subDim2 then message, "Inconsistent dimensions on sub structure element at i:"+string(i)+" j:"+string(j)+" k:"+string(k)+" l:"+string(l)
            mvn_kp_compare_arrays, subStruct1.(l), subStruct2.(l), subDim1, i=i, j=j, si=si, k=k, l=l
  
          endfor
        endfor        
      
      endfor        
    endelse
  endfor


  if numElements1 gt 100 then begin
    if i MOD 1000  eq 0 then begin
      MVN_LOOP_PROGRESS,i,0,numElements1-1,message='Progress'  
    endif else if i eq numElements1-1 then begin
      MVN_LOOP_PROGRESS,i,0,numElements1-1,message='Progress'
    endif
  endif else begin
    MVN_LOOP_PROGRESS,i,0,numElements1-1,message='Progress'
  endelse

endfor



;; If made it here then both inputs are "equal"
print, "Both inputs match"

end