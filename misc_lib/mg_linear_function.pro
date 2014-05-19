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
;-
function mg_linear_function, in_range, out_range
    compile_opt strictarr
    
    slope = float(out_range[1] - out_range[0]) / float(in_range[1] - in_range[0])
    return, [out_range[0] - slope * in_range[0], slope]
end