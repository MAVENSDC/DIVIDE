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