pro mvn_kp_logout_connection
  common mvn_kp_connection, netUrl, connection_time
  
  obj_destroy, netUrl
  netURL = 0
  dummy = temporary(netURL)
  dummy = temporary(connection_time)
end
