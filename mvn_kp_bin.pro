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
pro mvn_kp_bin, kp_data, fields, output, output_bins, binsize=binsize, list=list, average=average, $
                avg_out = avg_out, std = std

  ;CHECK THAT ALL INPUT FIELDS MATCH IN SIZE (fields ,BINS,)
  
  if keyword_set(binsize) then begin
    if n_elements(fields) ne n_elements(binsize) then begin
      print,'The number of fields fields and BINNING fields do not match.'
      return
    endif
  endif

  if n_elements(fields) gt 8 then begin
    print,'This routine is restricted to no more than 8 fields fields due to IDL routines used.'
    return
  endif

  ;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags

  ;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET
  if keyword_set(list) then begin
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    return
  endif

;DEFINE THE SIZES

  total_fields = n_elements(fields)
  
  input = dblarr(total_fields, n_elements(kp_data))
  output = dblarr(total_fields, n_elements(kp_data))
  output_bins = dblarr(total_fields,1000)
  nbins1 = lonarr(total_fields)
  range = dblarr(total_fields)
  if keyword_set(binsize) eq 0 then begin
    binsize=dblarr(total_fields)
  endif
  
  
  
  level0_index = fltarr(total_fields)
  level1_index = fltarr(total_fields)
  
;COLLECT THE INDICES OF THE DATA TO BE BINNED
  for i=0,total_fields -1 do begin
    MVN_KP_TAG_VERIFY, kp_data, fields[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, l0, l1, tag_array
    level0_index[i] = l0
    level1_index[i]= l1
    if check eq -1 then begin
      print,'Requested data parameters is not included in the data structure. Try /list to confirm selections.'
      return
    endif              
  endfor

  total_bins = 1.0d
  max_bins = 0

    for i=0,total_fields-1 do begin    

        nb=!null
        if keyword_set(binsize) then begin
          bs = binsize[i]
        endif else begin
          bs = !null
        endelse
        
        input[i,*] = histbins(kp_data.(level0_index[i]).(level1_index[i]),bin_out,nbins=nb,/retbins,binsize=bs)
        nbins1[i] = nb
        output_bins[i,0:n_elements(bin_out)-1] = bin_out
        total_bins = total_bins*nbins1[i]
        if n_elements(bin_out) gt max_bins then max_bins=n_elements(bin_out)
    endfor
  
    xyz_bins = input[0,*]
    for i=1,total_fields-1 do begin
      bin_multiplier = 1.0d
      for j=0,i-1 do begin
        bin_multiplier = bin_multiplier*nbins1[j]
      endfor
      xyz_bins = xyz_bins + input[i,*]*bin_multiplier
    endfor
    
    output = histogram(xyz_bins, min=0,max=total_bins-1, reverse=ri)

    if n_elements(nbins1) eq 1 then output=reform(output,nbins1[0],/over)
    if n_elements(nbins1) eq 2 then output=reform(output,nbins1[0],nbins1[1],/over)
    if n_elements(nbins1) eq 3 then output=reform(output,nbins1[0],nbins1[1],nbins1[2],/over)
    if n_elements(nbins1) eq 4 then output=reform(output,nbins1[0],nbins1[1],nbins1[2],nbins1[3],/over)
    if n_elements(nbins1) eq 5 then output=reform(output,nbins1[0],nbins1[1],nbins1[2],nbins1[3],nbins1[4],/over)
    if n_elements(nbins1) eq 6 then output=reform(output,nbins1[0],nbins1[1],nbins1[2],nbins1[3],nbins1[4],nbins1[5],/over)
    if n_elements(nbins1) eq 7 then output=reform(output,nbins1[0],nbins1[1],nbins1[2],nbins1[3],nbins1[4],nbins1[5],nbins1[6],/over)
    if n_elements(nbins1) eq 8 then output=reform(output,nbins1[0],nbins1[1],nbins1[2],nbins1[3],nbins1[4],nbins1[5],nbins1[6],nbins1[7],/over)

    output_bins = reform(output_bins[*,0:max_bins-1])
    
    if keyword_set(average) then begin
      avg_out = output
      std = output
      avg_count = output

      avg_out[*] = 0.0
      std[*] = 0.0
      avg_count[*] = 0
      
      for i=0, total_fields-1 do begin
        
        
      endfor
      
    endif
    

end