;+
; Function to return the model output interpolated to a given spacecraft
; trajectory
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: Kevin McGouldrick (2015-Apr-16)
;
; :Description:
;     Parse a NetCDF file with modeled data results and return in three data
;     structures.  In order to work correctly with the toolkit, modeled
;     data must conform to our modeled results file requirements
;     - FIXME say where this is hosted.
;
; :Keywords:
;    tracer: in, required, type=float
;       Array containing tracer from model to be interpolated
;
;    dims: in, required, type=struct
;       Structure containing relevant model dimension information.
;
;    x: in, required, type=float
;       array containing spacecraft longitudes or MSO_X.
;    y: in, required, type=float
;       array containing spacecraft latitudes or MSO_Y.
;    z: in, required, type=float
;       array containing spacecraft altitudes or MSO_Z
;
;  :Returns:
;    model_interpol: out, type=TBD
;       Object containing the model tracers interpolated to the provided
;       spacecraft trajectory from the kp_data
;
;-
function mvn_kp_sc_traj_nn, tracer, dims, x, y, z
;
; Find nearest neighbor
  if min(dims.lon lt 0, /NAN) then $
    dims.lon = dims.lon - 360 * floor(dims.lon/180. )
  ; Above fails to deal with 180 degrees properly (becomes -180)
  ; But already a problem since we have -180 and 180 in lon array
  ix = value_locate(dims.lon, x)
  iy = value_locate(dims.lat, y)
  iz = value_locate(dims.alt, z)
  model_interpol = tracer[ix,iy,iz]
  ; Post-processing corrections
  iz_hi = where( iz eq (n_elements(dims.alt)-1) and z gt max(dims.alt), count )
  if( count gt 0 ) then model_interpol[iz_hi] = !Values.F_NAN
  ;
  return, model_interpol
end