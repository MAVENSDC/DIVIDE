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
pro mvn_kp_bin, kp_data, data, output, binsize=binsize, res, list=list, average=average

  ;CHECK THAT ALL INPUT FIELDS MATCH IN SIZE (DATA ,BINS, MIN, MAX, RES)
  
  if keyword_set(binsize) then begin
    if n_elements(data) ne n_elements(binsize) then begin
      print,'The number of DATA fields and BINNING fields do not match.'
      return
    endif
  endif
;  if n_elements(data) ne n_elements(min) then begin
;    print,'The number of DATA fields and MINIMUM values do not match.'
;    return
;  endif
;  if n_elements(data) ne n_elements(max) then begin
;    print,'The number of DATA fields and MAXIMUM values do not match.'
;    return
;  endif  
;  if n_elements(data) ne n_elements(res) then begin
;    print,'The number of DATA fields and RESOLUTION values do not match.'
;    return
;  endif  
;  if n_elements(bin) ne n_elements(min) then begin
;    print,'The number of BINNING fields and MINIMUM values do not match.'
;    return
;  endif
;  if n_elements(bin) ne n_elements(max) then begin
;    print,'The number of BINNING fields and MAXIMUM values do not match.'
;    return
;  endif
;  if n_elements(bin) ne n_elements(res) then begin
;    print,'The number of BINNING fields and RESOLUTION values do not match.'
;    return
;  endif
;  if n_elements(min) ne n_elements(max) then begin
;    print,'The number of MINIMUM values and MAXIMUM values do not match.'
;    return
;  endif
;  if n_elements(min) ne n_elements(res) then begin
;    print,'The number of MINIMUM values and RESOLUTION values do not match.'
;    return
;  endif
;  if n_elements(max) ne n_elements(res) then begin
;    print,'The number of MAXIMUM values and RESOLUTION values do not match.'
;    return
;  endif

  if n_elements(data) gt 8 then begin
    print,'This routine is restricted to no more than 8 data fields due to IDL routines used.'
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

  total_fields = n_elements(data)
  
  input = dblarr(total_fields, n_elements(kp_data))
  output = dblarr(total_fields, n_elements(kp_data))
  new_vals = dblarr(total_fields, 50)
  nbins = lonarr(total_fields)
  range = dblarr(total_fields)
  if keyword_set(binsize) eq 0 then begin
    binsize=dblarr(total_fields)
  endif
  
  
  
  level0_index = fltarr(total_fields)
  level1_index = fltarr(total_fields)
  
;COLLECT THE INDICES OF THE DATA TO BE BINNED
  for i=0,total_fields -1 do begin
    MVN_KP_TAG_VERIFY, kp_data, data[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, l0, l1, tag_array
    level0_index[i] = l0
    level1_index[i]= l1
    if check eq -1 then begin
      print,'Requested data parameters is not included in the data structure. Try /list to confirm selections.'
      return
    endif              
  endfor

  total_bins = 1.0d
  if keyword_set(average) eq 0 then begin
    for i=0,total_fields-1 do begin    
      
        bs = binsize[i]
      
        input[i,*] = histbins(kp_data.(level0_index[i]).(level1_index[i]),new_vals[i,*],/retbins,range=ra,nbins=nb,binsize=bs,log=xlog,shift=shift)
      
        nbins[i] = nb
        total_bins = total_bins*nb
    endfor
  
    xyz_bins = input[0,*]
    for i=1,total_fields-1 do begin
      bin_multiplier = 1.0d
      for j=0,i-1 do begin
        bin_multiplier = bin_multiplier*nbins[j]
      endfor
      xyz_bins = xyz_bins + input[i,*]*bin_multiplier
    endfor
    
    output = histogram(xyz_bins, min=0,max=total_bins-1)
    
    if n_elements(nbins) eq 1 then output=reform(output,nbins[0],/over)
    if n_elements(nbins) eq 2 then output=reform(output,nbins[0],nbins[1],/over)
    if n_elements(nbins) eq 3 then output=reform(output,nbins[0],nbins[1],nbins[2],/over)
    if n_elements(nbins) eq 4 then output=reform(output,nbins[0],nbins[1],nbins[2],nbins[3],/over)
    if n_elements(nbins) eq 5 then output=reform(output,nbins[0],nbins[1],nbins[2],nbins[3],nbins[4],/over)
    if n_elements(nbins) eq 6 then output=reform(output,nbins[0],nbins[1],nbins[2],nbins[3],nbins[4],nbins[5],/over)
    if n_elements(nbins) eq 7 then output=reform(output,nbins[0],nbins[1],nbins[2],nbins[3],nbins[4],nbins[5],nbins[6],/over)
    if n_elements(nbins) eq 8 then output=reform(output,nbins[0],nbins[1],nbins[2],nbins[3],nbins[4],nbins[5],nbins[6],nbins[7],/over)
  endif
 
  
;  bins = histbins(kp_data.spacecraft.altitude, xval,range=[0d,3000d],nbins=25)
;  bins1 = histbins(kp_data.spacecraft.sza, yval,range=[-0d,50d], nbins=25)
;  
;  b1 = bins*25+bins1
;  nb1 = 25l*25l
;  h1 = histogram(b1,min=0,max=nb1-1,reverse=ri)
;  h1 = reform(h1,25,25,/over)
;  showh1 = congrid(h1,800,800,/interp)
;  
;  h = histbins2d(kp_data.spacecraft.altitude, kp_data.spacecraft.sza, xval, yval)
;  
;  showh = congrid(h,800,800)
;

 ; new_bin = dblarr(2,n_elements(kp_data.spacecraft.altitude))
 ; new_xval = dblarr(2,25)
 ; 
;;    new_bin[0,*] = histbins(kp_data.spacecraft.altitude, new_xval[0,*],nbins=25)
;;    new_bin[1,*] = histbins(kp_data.spacecraft.sza, new_xval[1,*],nbins=25)
 ;   
 ;   new_bin[0,*] = histbins(kp_data.spacecraft.altitude,new_xval[0,*],/retbins,range=xrange,nbins=xnbins,binsize=xbinsize,log=xlog,shift=shift)
 ;   new_bin[1,*] = histbins(kp_data.spacecraft.sza,new_xval[1,*],/retbins,range=yrange,nbins=ynbins,binsize=ybinsize,log=ylog,shift=shift)
 ;   
 ;   print,xnbins
 ;   print,ynbins
 ;   
 ;   new_nbins = long(xnbins)*ynbins
 ;   print,new_nbins
 ;   
 ;   new_bins = new_bin[1,*]*xnbins+new_bin[0,*]
 ;   
 ;   new_h = histogram(new_bins,min=0,max=new_nbins-1,reverse=ri)
 ;   new_h = reform(new_h,xnbins,ynbins,/over)
 ;   newh1 = congrid(new_h,800,800,/interp)
    
    
  ;new_bins = new_bin[1,*]*25 + new_bin[0,*]  
  ;new_bins = new_bin[1,*] + new_bin[0,*]  
  ;new_h = histogram(transpose(new_bins), min=0, max=(25*25)-1,reverse=ri)
  ;new_h = reform(new_h, 25, 25,/over)
  
 ;   shownewh = congrid(new_h, 800,800,/interp)
    
  ;3d
  ;print,'3d'
  ;print,''
 ; 
 ; x = kp_data.spacecraft.geo_x
 ; y = kp_data.spacecraft.geo_y
 ; z = kp_data.spacecraft.geo_z
 ; 
 ; p=plot3d(x,y,z,'b2d')
 ; 
 ; temp = bin3d(x,y,z)
 ; 
 ; x1 = reform(temp[0,*])
 ; y1 = reform(temp[1,*])
 ; z1 = reform(temp[2,*]);;;
;
;  
;  new3 = dblarr(3,n_elements(kp_data.spacecraft.geo_x))
;  newval = dblarr(3,25)
;  
;  new3[0,*] = histbins(x,newval[0,*],/retbins,range=xrange,nbins=xnbins,binsize=xbinsize,log=xlog,shift=shift)
;  new3[1,*] = histbins(y,newval[1,*],/retbins,range=yrange,nbins=ynbins,binsize=ybinsize,log=ylog,shift=shift)
;  new3[2,*] = histbins(z,newval[2,*],/retbins,range=zrange,nbins=znbins,binsize=zbinsize,log=zlog,shift=shift)
;  
;  print,xnbins,ynbins,znbins
;  xyz_nbins = long(xnbins)*ynbins*znbins
;  
;  xy_nbins = long(xnbins)*ynbins
;  xz_nbins = long(xnbins)*znbins
;  yz_nbins = long(ynbins)*znbins
;  
;  xy_bins = new3[1,*]*xnbins+new3[0,*]
;  xz_bins = new3[2,*]*xnbins+new3[0,*]
;  yz_bins = new3[2,*]*ynbins+new3[1,*]
;  
;  xyz_bins = new3[0,*]+new3[1,*]*xnbins+new3[2,*]*ynbins*znbins
;  
;  newxy = histogram(xy_bins, min=0,max=xy_nbins-1,reverse=ri)
;  newxz = histogram(xz_bins, min=0,max=xz_nbins-1,reverse=ri)
;  newyz = histogram(yz_bins, min=0,max=yz_nbins-1,reverse=ri)
 ; 
 ;; newxyz = histogram(xyz_bins, min=0,max=xyz_nbins-1,reverse=ri)
 ; 
 ; newxy = reform(newxy, xnbins,ynbins,/over)
 ; newxz = reform(newxz, xnbins,znbins,/over)
 ; newyz = reform(newyz, ynbins,znbins,/over)
 ; 
 ; newxyz = reform(newxyz, xnbins,ynbins,znbins,/over)
 ; 
 ; showxy = congrid(newxy, 800,800) 
 ; showxz = congrid(newxz, 800,800)
 ; showyz = congrid(newyz, 800,800);;

;3d check
;  hxy = histbins2d(x,y,xval,yval)
;;  hxz = histbins2d(x,z,xval,zval)
;  hyz = histbins2d(y,z,yval,zval)
;  
;  show_hxy = congrid(hxy,800,800)
;  show_hxz = congrid(hxz,800,800)
;  show_hyz = congrid(hyz,800,800)



;n_dimensional version

;  new_array = dblarr[total number of dimensions, total records]
;  new_vals = dblarr[total numebr of dimensions, some number]
;  number_bins = dblarr[total number of dimensions]
;  
;  loop over dimensions
;    new_array[i] = histogram[variable i,new_vals[i],/retbins,range=range[i],nbins=number_bins[i],binsize=binsize[i],log=xlog,shift=shift);;
;
;  total_bins = var 1 bin * var2bin *var3bin . . .var8bin
;  
;  indexed bins = new_array[0] + new_array[1]*number_bins[0] + new_array[2]*number_bins[0]*number_bins[1] + ... new_array[8]*number_bins[0-6]
;  
;  new data = reform(indexed bins, number_bins[0], . . . number_bins[8])

end