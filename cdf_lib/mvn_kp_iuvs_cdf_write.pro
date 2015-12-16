pro mvn_kp_iuvs_cdf_write, iuvs, filename, overwrite=overwrite
;+
; :Name:
;   mvn_kp_iuvs_cdf_write
;
; :Description:
;   Temporary code to write a CDF file so that I can test the CDF reader
;
; :Author:
;   McGouldrick (2015-May-13)
;
; :Params:
;  iuvs: in, requires, structure
;   - the IUVS KP data structure to be written to a CDF file
;  filename: in, required, string
;   - the name of the file to be written
;   
; :Keywords:
;  overwrite: in, optional, boolean
;   - Overwrite an existing file
;
;-
;
;  Create the cdf file, overwriting if requested
;
  luno = keyword_set(overwrite) $
       ? cdf_create(filename,/clobber) $
       : cdf_create(filename)
;
;  Set the compression algorithm to GZIP
;
  cdf_compression, luno, set_compression=5 ; using gzip compression
;
;  Get the tag names for level 1 of the structure
;
  l1_name = tag_names(iuvs)
;
;  Loop over level 1 tags of the structure
;
stop
  for i1 = 0,n_tags(iuvs)-1 do begin
    if n_tags(iuvs.(i1)) gt 0 then begin
      ;
      ;  There are multiple level 2 tags
      ;  First, get their names
      ;
      l2_name = tag_names(iuvs.(i1))

      if n_elements(iuvs.(i1)) gt 1 then begin
        ;
        ;  The current tags is an array of structures
        ;  Loop over the sub-elements
        ;
        for s1 = 0,n_elements(iuvs.(i1))-1  do begin
          ;
          ;  Assign an index name for each sub-record
          ;
          s1_name = strtrim( string(s1+1), 2)
          ;
          ;  Loop over the level 2 tags in the current structure
          ;  Identify the variable, build a unique name, and 
          ;  write it to the provided CDF file.
          ;
          for i2 = 0,n_tags(iuvs.(i1))-1 do begin
            var = ((iuvs.(i1))[s1]).(i2)
            varname = l1_name[i1]+s1_name+'__'+l2_name[i2]
            mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], l2_name[i2]
          endfor
        endfor ; sub-records
      endif else begin
        ;
        ;  Only a single record, so just loop over the level 2 tags
        ;  and write the vairable to the file
        ;
        for i2 = 0,n_tags(iuvs.(i1))-1 do begin
          var = iuvs.(i1).(i2)
          varname = l1_name[i1]+'__'+l2_name[i2]
          mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], l2_name[i2]
        endfor
      endelse ; if nelem(level1) gt 1 else

    endif else begin 
      ; 
      ; There are no level 2 tags so write the level 1 structure
      ;
      if n_elements(iuvs.(i1)) gt 1 then begin
        ;
        ;  If the level 1 structure is an array, then loop through the
        ;  elements of that array
        ;
        for s1 = 0,n_elements(iuvs.(i1))-1 do begin
          ;
          ;  Define a unique name, get the variable, and write it 
          ;  to the CDF file.
          ;
          s1_name = strtrim(string(s1+1),2)
          var = (iuvs.(i1))[s1]
          varname = l1_name[i1]+s1_name
          mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], ''
        endfor
      endif else begin
        ;
        ;  Just one record so create a name, get the variable
        ;  and write it to the CDf file.
        ;
        var = iuvs.(i1)
        varname = l1_name[i1]
        mvn_kp_cdf_varwrite, luno, var, varname, l1_name[i1], ''
      endelse ; array or no array of level 1 tags
    endelse   ; check for existence of level 2 tags
  endfor      ; loop over level 1 tags
;
;  Close the CDF file
;
  cdf_close,luno
  return
end