;+
;-
pro mvn_kp_cdf_write_var, luno, var, varname, i1, i2, l1_name, l2_name

  nd = size( var, /n_dim) ; number of dimensions of var
  dims = size( var, /dim ) ; the dimensions of var
  ;
  ;  Now, define var id which depends on data type
  ;  It may be more efficient to remove this to a separate routine
  ;
  case size(var, /type) of
    1: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
      /zvar, /cdf_byte, dim=dims>1 )
    2: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
      /zvar, /cdf_int2, dim=dims>1 )
    3: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
      /zvar, /cdf_int4, dim=dims>1 )
    4: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
      /zvar, /cdf_float, dim=dims>1 )
    5: vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
      /zvar, /cdf_double, dim=dims>1 )
    6: begin
      print,'Currently cannot handle complex data type'
      print,'Converting iuvs.' + strtrim(l1_name,2) + '.'$
        + strtrim(l2_name,2) + ' into float.'
      vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
        /zvar, /cdf_double, dim=dims>1 )
       end
    7: begin
      len = max(strlen(var))
      if( len gt 0 )then begin
        vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
          /zvar, /cdf_uchar, numelem=len, dim=dims>1  )
      endif else begin
        vid = cdf_varcreate( luno, varname, replicate( 'vary', nd>1 ), $
          /zvar, /cdf_char, numelem=1, dim=dims>1 )
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
return
end
