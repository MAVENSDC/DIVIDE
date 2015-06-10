pro mvn_kp_iuvs_cdf_read, iuvs, infiles, instruments=instruments, debug=debug
;+
; :Name:
;   mvn_kp_iuvs_cdf_read
;
; :Description:
;   Temporary code to read a CDF IUVS KP file
;
; :Params:
;  filename: in, required, string
;   - the name of the CDF file to be read
;  iuvs: out, required, structure
;   - the data structure to contain the contents of the CDF file
;
; :Author:
;   McGouldrick (2015-May-15)
;
; :Version:
;   1.1 (2015-Jun-09) - accept list/array of files and create an array
;     of structures containing the requested data
;
; :History:
;   v1.0: original: read in single cdf file and output data structure
;
;-
;
;  Determine exit strategy depending upon debug status
;
  if ~keyword_set(debug) then on_error,1
  ;
  ;  Define an empty array to store the output iuvs array of data
  ;  structures
  ;
  iuvs = []
  ;
  ;  Initialize counter for progress bar
  ;
  ifile=0
  ;
  ; Cycle through the supplied files using cool new python-like 
  ;  iteration style; code not liking this....  Crashed if only a single
  ;  filename is provided....
  ;
  foreach filename, infiles do begin
    ;
    ; Update progress bar
    ;
    MVN_KP_LOOP_PROGRESS,ifile,0,n_elements(infiles)-1,$
                         message='IUVS KP File Read Progress'
    ifile++
    ;
    ; Open the requested CDF file 
    ;
    luni = cdf_open(filename)
    ;
    ; Get the number of variables contained within
    ; For now, assume all vars are zvars (HACK)

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
      ; Apply the conditional instrument check.  This is unfortunately 
      ; a bit hard wired, but it will work for now.  If the current tag 
      ; name relates to a particular instrument that has been selected 
      ; to be read in, then get it, otherwise, move along
      ;
      if ( strmatch( lev1_name, 'PERIAPSE*' ) and $
           instruments.periapse eq 1 ) or $
         ( strmatch( lev1_name, 'CORONA_E_DISK' ) and $
           instruments.c_e_disk eq 1 ) or $
         ( strmatch( lev1_name, 'CORONA_E_LIMB' ) and $
           instruments.c_e_limb eq 1 ) or $
         ( strmatch( lev1_name, 'CORONA_E_HIGH' ) and $
           instruments.c_e_high eq 1 ) or $
         ( strmatch( lev1_name, 'CORONA_LO_DISK' ) and $
           instruments.c_l_disk eq 1 ) or $
         ( strmatch( lev1_name, 'CORONA_LO_LIMB' ) and $
           instruments.c_l_limb eq 1 ) or $
         ( strmatch( lev1_name, 'CORONA_LO_HIGH' ) and $
           instruments.c_l_high eq 1 ) or $
         ( strmatch( lev1_name, 'APOAPSE' ) and $
           instruments.apoapse eq 1 ) or $
         ( strmatch( lev1_name, 'STELLAR_OCC*' ) and $
           instruments.stellarocc eq 1 ) or $
         ( strmatch( lev1_name, 'ORBIT' ) ) then begin
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
            if n_elements(name_list[itag]) eq 1 then begin
              iuvs_temp = create_struct( lev1_name, s.(0) )
            endif else begin
              iuvs_temp = create_struct( lev1_name, s )
            endelse
          endif else begin
            if n_elements(name_list[itag]) eq 1 then begin
              iuvs_temp = create_struct( iuvs_temp, lev1_name, s.(0) )
            endif else begin
              iuvs_temp = create_struct( iuvs_temp, lev1_name, s )
            endelse
          endelse
        endif
      endif ; big instrument check conditional
    endfor ; loop over all tags
    ;
    ;  And close the CDF file 
    ;
    cdf_close,luni
    ;
    ;  Go back to make arrays of the indexed attributes
    ;
    temp_name = tag_names(iuvs_temp)
    base_name = strsplit( temp_name, '[0123456789]+', /regex, /extract )
    ;
    ;  Cycle through the level 1 tags in the structure
    ;
    i1=0
    while i1 lt n_tags(iuvs_temp) do begin
      ;
      ;  Find out how many level1 tags are present for each mode
      ;
      sub = where( base_name eq base_name[i1], nsub )
      if nsub gt 1 then begin
        ;
        ;  If there is more than one observational structure associated 
        ;  with the current observing mode, then first create an array
        ;
        temp = [iuvs_temp.(i1)]
        i1++ ; increment the index of the original structure
        ;
        ;  Now, cycle through the remaining observations for the current mode
        ;
        for isub = 1,nsub-1 do begin
          temp = [temp,iuvs_temp.(i1)] ; Then append structures to the array
          i1++                         ; increment index of original structure
        endfor
      endif else begin
        ;
        ;  There is only one instance of current observing mode
        ;
        temp = iuvs_temp.(i1) ; identify the sub-structure
        i1++                  ; increment the orig structure index
      endelse
      ;
      ;  Now, create the final structure of IUVS KP data for output
      ;
      if min(sub) eq 0 then begin
        ;
        ;  We are in the first observational mode so we must create the
        ;  output structure from scratch
        ;
        iuvs_record = create_struct( base_name[i1-1], temp )
      endif else begin
        ;
        ;  We already have started the output structure, so append the
        ;  current observational mode/structure to that one.
        ;
        iuvs_record = create_struct( iuvs_record, base_name[i1-1], temp )
      endelse
    endwhile ; keep going until we run out of level 1 tags
    iuvs = [iuvs, iuvs_record]
  endforeach ; end of cycle through all input files
;
;  And finish
;
return
end
