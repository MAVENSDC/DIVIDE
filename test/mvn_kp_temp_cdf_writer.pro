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
  ;
  ;  If there is a 2nd levels to the structure, descend and repeat
  ;
  if( n_tags(iuvs.(i1)) gt 0 )then begin
    ;
    ;  get the tag names of level 2
    ;
    l2_name = tag_names(iuvs.(i1))
    ;
    ;  Loop over the level 2 tags
    ;
    for i2 = 0,n_tags(iuvs.(i1))-1 do begin
      var = iuvs.(i1).(i2) ; The next variable to be written to CDF file
      varname = l1_name[i1]+'__'+l2_name[i2] ; name of the var in CDF file
      nd = size( var, /n_dim) ; number of dimensions of var
      dims = size( var, /dim ) ; the dimensions of var
      ;
      ;  Now, define var id which depends on data type
      ;  It may be more efficient to remove this to a separate routine
      ;
      case size(var, /type) of
        1: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                /zvar, /cdf_byte, dim=dims )
        2: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                /zvar, /cdf_int2, dim=dims )
        3: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                /zvar, /cdf_int4, dim=dims )
        4: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                /zvar, /cdf_float, dim=dims )
        5: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                /zvar, /cdf_double, dim=dims )
        6: begin
             print,'Currently cannot handle complex data type'
             print,'Converting iuvs.' + strtrim(l1_name[i1],2) + '.'$
                                      + strtrim(l2_name[i2],2) + ' into float.'
             vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                  /zvar, /cdf_double, dim=dims )
           end
        7: begin
             len = max(strlen(var))
             if( len gt 0 )then begin
               vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                    /zvar, /cdf_uchar, numelem=len, dim=dims  )
             endif else begin
               vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                    /zvar, /cdf_char, numelem=1, dim=dims )
             endelse
           end
        else: begin
                print,'Currently cannot handle IDL data type ' $
                     + typename( iuvs.(i1).(i2) )
                print,'iuvs.'+strtrim(l1_name[i1],2) + '.' $
                      + strtrim(iuvs.(i1).(i2),2) + $
                      'will NOT be written to CDF file '+filename
              end
      endcase
      ;
      ; Now write the variable to the CDF file
      ;
      cdf_varput, luno, vid, var, /zvar
    endfor ; loop over the level 2 tags
  endif else begin ; there is only one level to the present tag
    var = iuvs.(i1)
    varname = l1_name[i1]
    nd = size( var, /n_dim )
    dims = size( var, /dim )
    case size(var, /type) of
      1: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                              /zvar, /cdf_byte, dim=dims )
      2: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                              /zvar, /cdf_int2, dim=dims )
      3: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                              /zvar, /cdf_int4, dim=dims )
      4: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                              /zvar, /cdf_float, dim=dims )
      5: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                              /zvar, /cdf_double, dim=dims )
      6: begin
           print,'Currently cannot handle complex data type'
           print,'Converting iuvs.' + strtrim(l1_name[i1],2) + '.'$
                 + strtrim(l2_name[i2],2) + ' into float.'
           vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                                /zvar, /cdf_double, dim=dims )
         end
      7: begin
           len = max(strlen(var))
           vid = cdf_varcreate( luno, varname, replicate( 'vary', nd ), $
                               /zvar, /cdf_uchar, numelem=len, dim=dims )
         end
; Converting all strings to ints and will restore them in the reader
      else: begin
              print,'Currently cannot handle IDL data type ' $
                    + typename( iuvs.(i1) )
              print,'iuvs.' + strtrim(l1_name[i1],2) + '.' $
                    + strtrim(iuvs.(i1),2) $
                    + 'will NOT be written to CDF file '+filename
            end
    endcase
    ;
    ;  Write this variable to the CDF file
    ;
;    if( size( var, /type ) ne 7 )then begin
      cdf_varput, luno, vid, var, /zvar
;    endif else begin
;      cdf_varput, luno, vid, byte(var), /zvar
;    endelse
  endelse
endfor ; loop over level 1 tags
;
;  Close the CDF file
;
cdf_close,luno
;
;  For now, leave it at just writing
;
end