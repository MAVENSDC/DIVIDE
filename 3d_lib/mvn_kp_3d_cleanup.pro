pro mvn_kp_3d_cleanup, tlb

  widget_control, tlb, get_uvalue=pstate
  
  obj_destroy, [(*pstate).view, (*pstate).window, (*pstate).track, $
                (*pstate).orbit_model, (*pstate).surfacemarks]
  obj_destroy, [(*pstate).window]
  ptr_free, pstate

end