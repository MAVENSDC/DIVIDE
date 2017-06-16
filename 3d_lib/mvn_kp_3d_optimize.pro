;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

pro MVN_KP_3D_OPTIMIZE, in, out, optimize

  out=in

  index=0
  for i=0,n_elements(in)-1, optimize do begin
    out[index] = in[i]
    index++
  endfor

  out = out[0:index-1]

end