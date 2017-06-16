;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

pro mvn_kp_logout_connection
  common mvn_kp_connection, netUrl, connection_time
  
  obj_destroy, netUrl
  netURL = 0
  dummy = temporary(netURL)
  dummy = temporary(connection_time)
end
