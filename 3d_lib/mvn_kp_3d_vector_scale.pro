;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

pro MVN_KP_3D_VECTOR_SCALE, old_data, old_scale, new_scale


    true_scale = old_scale/new_scale

    for i=0,(n_elements(old_data[0,*])-1) do begin
      old_data[0, i] = old_data[0, i]/true_scale
      old_data[1, i] = old_data[1, i]/true_scale
      old_data[2, i] = old_data[2, i]/true_scale
    endfor


END