pro mvn_kp_temp_cdf_reader, filename, iuvs
;+
; :Name:
;   mvn_kp_temp_cdf_reader
;
; :Description:
;   Temporary code to read a CDF IUVS KP file
;
; :Author:
;   McGouldrick (2015-May-15)
;
;-
;
;  Open the requested CDF file
;
luni = cdf_open(filename)
;
;  Get the number of variables contained within
;  For now, assume all vars are zvars (HACK)
;
nv = (cdf_inquire(luni)).nzvars
;
;  Get the names of all vards in CDF file
;
cdf_name = strarr(nv)
for i = 0,nv-1 do cdf_name[i] = (cdf_varinq(luni,i,/zvar)).name
;
;  Now, split the strings at the double-underscore (the convention
;  I used to indicate multiple levels of the sata structure in the
;  CDF data
;
name_list = strsplit( cdf_name, '__', /extract, /regex )
;
;  Figure out which vars have multiple levels
;
cdf_nlev = intarr(nv)
for i = 0,nv-1 do cdf_nlev[i] = n_elements(name_list[i])
;
; determine the unique level 1 tags
;
lev1_all = strarr(nv)
for i = 0,nv-1 do lev1_all[i] = (name_list[i])[0]
lev1 = lev1_all[ uniq(lev1_all) ]
;
;  Determine the level 2 tags
;  This could be made more flexible by using cdf_nlev to determine
;   how many levels of data exist.  Current hard wired to two.
;
lev2 = strarr(nv)
for i = 0,nv-1 do $
  lev2[i] = (n_elements(name_list[i]) gt 1 ) ? (name_list[i])[1] : ''
;
;  Determine the number of level 2 tags under each level 1 tag
;
nlev2 = intarr(n_elements(lev1))
for i1 = 0,n_elements(lev1)-1 do begin
  temp = where( lev1[i1] eq lev1_all, count )
  nlev2[i1] = count
endfor
;
;  For now, hard wire this bc we have only two levels
;
i2 = 0 ; initialize second level tag index
;
;  Loop over all tags
;
for itag = 0,nv-1 do begin
;
;  Determine whether next CDF variable is string or numeric
;
  intype = (cdf_varinq(luni, cdf_name[itag], /zvar )).datatype
;
;  Read the next variable from the CDF
;
  if( intype eq 'CDF_UCHAR' or intype eq 'CDF_CHAR' )then begin
    cdf_varget, luni, cdf_name[itag], var, /zvar, /string
  endif else begin
    cdf_varget, luni, cdf_name[itag], var, /zvar
  endelse
;
;  Determine level 1 tag index
;
  i1 = where( lev1 eq (name_list[itag])[0] )
  lev1_name = lev1[i1]
;
;  Determine if current structure is one level or two
;
  if( n_elements( name_list[itag]) gt 1 )then begin
;
;  Get the name of the level 2 index
;
    lev2_name = name_list[itag,1]
    if( i2 eq 0 )then begin
      ; First level 2 tag so create the structure
      s = create_struct( lev2_name, var )
;      s = create_struct( name = lev1_name, lev2_name, var )
;      s = struct_assign( name = lev1_name, lev2_name, var )
    endif else begin
      ; Otherwise, append the next variable to the existing structure
      s = create_struct( s, lev2_name, var )
    endelse
;
;  Increment the level 2 tag index
;
    i2 = i2 + 1
  endif else begin
;
;  If one level, just add the attribute
;
    s = create_struct( name = lev1_name, lev1_name, var )
    i2 = i2 + 1
  endelse
;
;  If the level 2 index is at the end of the list, reset it to zero
;
  if( i2 eq nlev2[i1] )then begin
    i2 = 0
;
;  And, append the substructure to the level 0 structure
;
    if( i1 eq 0 )then begin
      iuvs = create_struct( lev1_name, s )
    endif else begin
      iuvs = create_struct( iuvs, lev1_name, s )
    endelse
  endif
endfor ; loop over all tags
;
;  And close the CDF file
;
cdf_close,luni
;
;  And finish
;
end
