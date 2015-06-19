; Get an IDLnetUrl object with login credentials.
; The user should only be prompted once per IDL session to login.
; Use common block to manage a singleton instance of a IDLnetURL
; so it will remain alive in the IDL session unless it has expired.
; Read a password from stdin echoing '*'s.
; Note, backspace will not work.


;----------------------------------------------------------------
; Helper functions
function mvn_kp_read_password, prompt=prompt
  password = ''
  
  ; Print prompt, without new line.
  if n_elements(prompt) gt 0 then print, format='($, A)', prompt
  
    ; Gather characters until the user hits <return>.
    while (1) do begin
    ch = get_kbrd(/ESCAPE) ;read a character from the keyboard
    b = byte(ch)
    if (b eq 13 or b eq 10) then begin ;return
      print, '' ;get our new line back
      break ;get out of here
    endif
    password += ch ;append character to the password
    print, format='($, A)', '*' ;echo '*', no new line
    endwhile
    
  return, password
end


;----------------------------------------------------------------
; Main Routine
function mvn_kp_get_connection, host=host, port=port, authentication=authentication, private = private
  common mvn_kp_connection, netUrl, connection_time, private_connection
  
  ;; Define the variable private_connection if not defined 
  if (~ISA(private_connection)) then private_connection = 0
  
  ;; Get SDC server configuration information
  if (keyword_set(private)) then begin
    sdc_server_spec = mvn_kp_config(/data_retrieval, /private)
  endif else begin
    sdc_server_spec = mvn_kp_config(/data_retrieval)
    private_connection = 0
  endelse

  ; Define the length of time the login will remain valid, in seconds.
  expire_duration = sdc_server_spec.expire_duration
  
  ; Test if login has expired. If so, destroy the IDLnetURL object and replace it with -1
  ; so the login will be triggered below.
  if (n_elements(connection_time) eq 1) then begin
    duration = systime(/seconds) - connection_time
    if (duration gt expire_duration) then mvn_kp_logout_connection
  endif
  
  ;Check if we're switching from a public or private connection
  if (keyword_set(private) && (private_connection eq 0)) then begin
    if ((size(netUrl, /type) eq 11)) then begin
      mvn_kp_logout_connection
    endif
    private_connection = 1
  endif
  
  if n_elements(host) eq 0 then host = sdc_server_spec.host
  if n_elements(port) eq 0 then port = sdc_server_spec.port
  if n_elements(authentication) eq 0 then authentication = sdc_server_spec.authentication

  ;Make sure the singleton instance has been created
  ;TODO: consider error cases, avoid leaving incomplete netURL in common block
  type = size(netUrl, /type) ;will be 11 if object has been created
  if (type ne 11) then begin
    ; Construct the IDLnetURL object and set the login properties.
    netUrl = OBJ_NEW('IDLnetUrl')
    netUrl->SetProperty, URL_HOST = host
    netUrl->SetProperty, URL_PORT = port

    ;If authentication is requested, get login from user and add to netURL properties
    if authentication gt 0 then begin
      username = ''
      password = ''
      print, ""
      print, "Login credentials for LASP SDC Web - "
      read, username, prompt='username: '
      ;read, password, prompt='password: '
      password = mvn_kp_read_password(prompt='password: ') ;don't echo password
      
      netUrl->SetProperty, URL_SCHEME = sdc_server_spec.url_scheme
      netUrl->SetProperty, SSL_VERIFY_HOST = 0 ;don't worry about certificate
      netUrl->SetProperty, SSL_VERIFY_PEER = 0
      netUrl->SetProperty, AUTHENTICATION = authentication
      ;1: basic only, 2: digest
      netURL->SetProperty, SSL_CERTIFICATE_FILE=''
      netUrl->SetProperty, URL_USERNAME = username
      netUrl->SetProperty, URL_PASSWORD = password
    endif
    
    ; Set the time of the login so we can make it expire.
    connection_time = systime(/seconds)
  endif
  
  ;TODO: if parameters are set and netURL already exists, reset properties

  return, netUrl
end


