;+
; :Name:
;  mvn_kp_cdf_varwrite
;  
; :Description:
;  Given a variable found within an IUVS data structure, write 
;  the variable to a CDF file
;  
; :Params:
;  luno: in, required, long
;   - Unit Number or file ID for the CDF file being written
;  var: in, required
;   - the variable to be written to the CDF data file
;  varname: in, required, string
;   - the name of the variable to be written to the CDF file.
;  l1_name: in, required, string
;   - the level 1 name in the IUVS data structure of the variable 
;     to be written
;  l2_name: in, required, string
;   - the level 2 name in the IUVS data structure of the variable to be
;     writtem.  NB, if the current variable has only one level of tags in 
;     the structure, this code expects a null string as this argument.
;
; :Author:
;  McGouldrick (2015-Jun-01)
;
;-
pro mvn_kp_cdf_varwrite, luno, var, varname, l1_name, l2_name

  nd = size( var, /n_dim) > 1  ; number of dimensions of var
  dims = size( var, /dim ) > 1 ; the dimensions of var
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
         print,'Converting iuvs.' + strtrim(l1_name,2) + '.'$
               + strtrim(l2_name,2) + ' into float.'
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
                  + strtrim(iuvs.(i1).(i2),2) $
                  + 'will NOT be written to CDF file '+filename
          end
  endcase
  ;
  ; Now write the variable to the CDF file
  ;
  cdf_varput, luno, vid, var, /zvar
return
end
