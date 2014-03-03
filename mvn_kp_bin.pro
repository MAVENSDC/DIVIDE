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
pro mvn_kp_bin, kp_data, data, bins, min, max, res, output, density, loc, median=median

  ;CHECK THAT ALL INPUT FIELDS MATCH IN SIZE (DATA ,BINS, MIN, MAX, RES)
  
  if n_elements(data) ne n_elements(bins) then begin
    print,'The number of DATA fields and BINNING fields do not match.'
    goto,finish
  endif
  if n_elements(data) ne n_elements(min) then begin
    print,'The number of DATA fields and MINIMUM values do not match.'
    goto,finish
  endif
  if n_elements(data) ne n_elements(max) then begin
    print,'The number of DATA fields and MAXIMUM values do not match.'
    goto,finish
  endif  
  if n_elements(data) ne n_elements(res) then begin
    print,'The number of DATA fields and RESOLUTION values do not match.'
    goto,finish
  endif  
  if n_elements(bin) ne n_elements(min) then begin
    print,'The number of BINNING fields and MINIMUM values do not match.'
    goto,finish
  endif
  if n_elements(bin) ne n_elements(max) then begin
    print,'The number of BINNING fields and MAXIMUM values do not match.'
    goto,finish
  endif
  if n_elements(bin) ne n_elements(res) then begin
    print,'The number of BINNING fields and RESOLUTION values do not match.'
    goto,finish
  endif
  if n_elements(min) ne n_elements(max) then begin
    print,'The number of MINIMUM values and MAXIMUM values do not match.'
    goto,finish
  endif
  if n_elements(min) ne n_elements(res) then begin
    print,'The number of MINIMUM values and RESOLUTION values do not match.'
    goto,finish
  endif
  if n_elements(max) ne n_elements(res) then begin
    print,'The number of MAXIMUM values and RESOLUTION values do not match.'
    goto,finish
  endif


finish:
end