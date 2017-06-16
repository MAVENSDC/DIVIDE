;+
; :Name: mvn_kp_relative_complement
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: John Martin
;
; :Description:
;     Return the relative complement of server in local (arrays of strings)
;
;
;-

function mvn_kp_relative_complement, local, server
  server_out = server
  for i=0, n_elements(local)-1 do begin
    ind = where(server_out NE local[i], count)
    
    ;; If no items are found, this means there are no new files on the server
    ;; to download, so return with an empty string.
    if(count eq 0) then return, ''
    server_out = server_out(ind)
  endfor
  return, server_out
end