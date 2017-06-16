;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

; Execute a IDLnetURL query with the given netURL, url_path and query.
; If 'filename' is set, this will download the result to the given filename
; and return the path to the downloaded file.
; If 'filename' is not set, this will return the results as an array of strings.
; If an error occurs, a message will be printed and an error code (LONG) returned.
;
function mvn_kp_execute_neturl_query, netURL, url_path, query, filename=filename, not_sdc_connection=not_sdc_connection

  ;FIXME clean up error handling. 
  exit_worthy = 0
  
  catch, error_status
  if (error_status ne 0) then begin
    ;; Check filename & query to ensure not empty
    if n_elements(query) le 0 then query = ''
    if n_elements(filename) le 0 then filename = ''
    
    netURL->GetProperty, RESPONSE_CODE=code
    ;TODO: let callers print messages?
    case code of
      6: printf, -2, "ERROR in mvn_kp_execute_neturl_query: Couldn't resolve remote host."
      52: printf, -2, "ERROR in mvn_kp_execute_neturl_query: Server returned nothing."
      200: printf, -1, "No files returned from server." ; FIXME - Can this error code mean somethign other than nothing returned?
      204: printf, -2, "WARNING in mvn_kp_execute_neturl_query: No results found."
      206: printf, -2, "WARNING in mvn_kp_execute_neturl_query: Only partial results were returned."
      404: begin
        printf, -2, "ERROR in mvn_kp_execute_neturl_query: Service not found."
        exit_worthy =1
      end
      35: begin
        printf, -2, "ERROR in mvn_kp_execute_neturl_query: SSL error or corrupted netrul objet. TRY AGAIN."
        printf, -2, ""
        exit_worthy = 1
      end
      401: begin
        printf, -2, "ERROR in mvn_kp_execute_neturl_query: Login failed. TRY AGAIN."
        printf, -2, ""
        exit_worthy = 1
      end
      500: printf, -2, "ERROR in mvn_kp_execute_neturl_query: Service failed to handle the query: " + query
      23: printf, -2, "ERROR in mvn_kp_execute_neturl_query: Not able to save result to: " + filename
      
      else: begin
        printf, -2, "ERROR in mvn_kp_execute_neturl_query: Service request failed with IDL error code: " + strtrim(error_status,2)  
        help, !error_state
      end
    endcase
    catch, /cancel ; Cancel catch so other errors don't get caught here.
    
    ;; If exit worthy, throw error here to end execution & logout of connection 
    if exit_worthy and not keyword_set(not_sdc_connection) then begin
      mvn_kp_logout_connection
      message, "Cannot proceed. Exiting.."
    endif
    
    return, code ;the http or other IDLnetURL error code (http://www.exelisvis.com/docs/IDLnetURL.html#objects_network_1009015_1417867)
  endif
  
   
  ; Set the path and query for the request.
  netURL->SetProperty, URL_PATH=url_path
  netURL->SetProperty, URL_QUERY=query
  ; Following line deals with bug (?) in Linux certificates
  ; Was not allowing self-signed certificates
  netURL->SetProperty, SSL_VERIFY_PEER=0

  ; Make the request.
  ; If the 'filename' parameter is set, assume we want to download a file.
  ; Otherwise, get the results as a string array.
  if (n_elements(filename) eq 1) then result = netURL->Get(filename=filename)  $  ;download file, result should be path of file
  else result = netURL->Get(/string_array)  ;get results as array of comma separated values
  
  ; Cancel catch so other errors don't get caught here.
  catch, /cancel
  
  return, result
end
