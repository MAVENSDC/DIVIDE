;+
; A simple scaling function borrowed from Modern IDL: A Guide to IDL Programming 
;   by Michael Galloy
;   modernidl.idldev.com
;
;
; :Keywords:
;     in_range : in, required, float array
;       Input maximim and minimum values
;     out_range: out, required, float array
;       Output scaled values
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
function mg_linear_function, in_range, out_range
    compile_opt strictarr
    
    slope = float(out_range[1] - out_range[0]) / float(in_range[1] - in_range[0])
    return, [out_range[0] - slope * in_range[0], slope]
end