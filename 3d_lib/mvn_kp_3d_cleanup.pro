;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

pro mvn_kp_3d_cleanup, tlb

  widget_control, tlb, get_uvalue=pstate
  
  obj_destroy, [(*pstate).view, (*pstate).window, (*pstate).track, $
                (*pstate).orbit_model, (*pstate).surfacemarks]
  obj_destroy, [(*pstate).window]
  ptr_free, pstate

end