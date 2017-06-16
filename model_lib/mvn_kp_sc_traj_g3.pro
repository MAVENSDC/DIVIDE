;+
; Function to return the model output interpolated to a given spacecraft
; trajectory
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: Kevin McGouldrick (2015-Apr-15)
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
function mvn_kp_sc_traj_g3, tracer, dims, x, y, z
;
; Define the tracer dimensions
;
dim_x = (size(tracer,/dim))[0]
dim_y = (size(tracer,/dim))[1]
dim_z = (size(tracer,/dim))[2]
;
;  Create the NX x NY x NZ model dimension cubes
;
lon = rebin( dims.lon, dim_x, dim_y, dim_z )
lat = transpose( rebin( dims.lat, dim_y, dim_z, dim_x), [2,0,1] )
alt = transpose( rebin( dims.alt, dim_z, dim_x, dim_y), [1,2,0] )
;
;  Perform the grid3 interpolation
;
return,grid3( lon, lat, alt, tracer, x, y, z )
end