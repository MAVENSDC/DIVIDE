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
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
pro MVN_KP_3D_CORONA_DISK_COLORS, iuvs, min_val, max_val, d_color
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  range = max_val - min_val
  
  t = fix(254*((iuvs-min_val)/range))
  d_color[0] = r_orig[t]
  d_color[1] = g_orig[t]
  d_color[2] = b_orig[t]


end