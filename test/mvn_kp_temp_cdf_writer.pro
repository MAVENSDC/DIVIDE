pro mvn_kp_temp_cdf_writer, iuvs, filename, overwrite=overwrite
;+
; :Name:
;   mvn_kp_temp_cdf_writer
;
; :Description:
;   Temporary code to write a CDF file so that I can test the CDF reader
;
; :Author:
;   McGouldrick (2015-May-13)
;
;-
;
;  Create the cdf file, overwriting if requested
;
luno = keyword_set(overwrite) $
     ? cdf_create(filename,/clobber) $
     : cdf_create(filename)
;
;  Get the tag names for level 1 of the structure
;
l1_name = tag_names(iuvs)
;
;  Loop over level 1 tags of the structure
;
for i1 = 0,n_tags(iuvs)-1 do begin
  if n_tags(iuvs.(i1)) gt 0 then begin
    l2_name = tag_names(iuvs.(i1))
    if n_elements(iuvs.(i1)) gt 1 then begin
      for s1 = 0,n_elements(iuvs.(i1))-1  do begin
        s1_name = strtrim( string(s1+1), 2)
        for i2 = 0,n_tags(iuvs.(i1))-1 do begin
          var = ((iuvs.(i1))[s1]).(i2)
          varname = l1_name[i1]+s1_name+'__'+l2_name[i2]
          mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], l2_name[i2]
        endfor
      endfor
    endif else begin
      for i2 = 0,n_tags(iuvs.(i1))-1 do begin
        var = iuvs.(i1).(i2)
        varname = l1_name[i1]+'__'+l2_name[i2]
        mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], l2_name[i2]
      endfor
    endelse
  endif else begin ; no level 2 tags
    if n_elements(iuvs.(i1)) gt 1 then begin
      for s1 = 0,n_elements(iuvs.(i1))-1 do begin
        s1_name = strtrim(string(s1+1),2)
        var = (iuvs.(i1))[s1]
        varname = l1_name[i1]+s1_name
        mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], ''
      endfor
    endif else begin
      var = iuvs.(i1)
      varname = l1_name[i1]
      mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], ''
    endelse
  endelse
endfor
;
;  Close the CDF file
;
cdf_close,luno
;
;  For now, leave it at just writing
;
end