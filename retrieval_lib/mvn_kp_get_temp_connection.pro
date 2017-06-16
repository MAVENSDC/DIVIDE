;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

function mvn_kp_get_temp_connection, host, port, username, password, url_scheme, authentication

  ; Construct the IDLnetURL object and set the login properties.
  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST = host
  netUrl->SetProperty, URL_PORT = port

  netUrl->SetProperty, URL_SCHEME = url_scheme
  netUrl->SetProperty, SSL_VERIFY_HOST = 0 ;don't worry about certificate
  netUrl->SetProperty, SSL_VERIFY_PEER = 0
  netUrl->SetProperty, AUTHENTICATION = authentication
  netUrl->SetProperty, SSL_CERTIFICATE_FILE=''
  netUrl->SetProperty, URL_USERNAME = username
  netUrl->SetProperty, URL_PASSWORD = password


  return, netURL
end