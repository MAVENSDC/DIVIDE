; Execute a IDLnetURL query with the given netURL, url_path and query.
; If 'filename' is set, this will download the result to the given filename
; and return the path to the downloaded file.
; If 'filename' is not set, this will return the results as an array of strings.
; If an error occurs, a message will be printed and an error code (LONG) returned.
;
function mvn_kp_execute_neturl_query, netURL, url_path, query, filename=filename

  ;FIXME clean up error handling. 
  
  catch, error_status
  if (error_status ne 0) then begin
    ;; Check filename & query to ensure not empty
    if n_elements(query) le 0 then query = ''
    if n_elements(filename) le 0 then filename = ''
    
    netURL->GetProperty, RESPONSE_CODE=code
    ;TODO: let callers print messages?
    case code of
      200: printf, -1, "No files returned from server." ; FIXME - Can this error code mean somethign other than nothing returned?
      204: printf, -2, "WARNING in mvn_kp_execute_neturl_query: No results found."
      206: printf, -2, "WARNING in mvn_kp_execute_neturl_query: Only partial results were returned."
      404: printf, -2, "ERROR in mvn_kp_execute_neturl_query: Service not found."
      401: begin
        mvn_kp_logout_connection
        printf, -2, "ERROR in mvn_kp_execute_neturl_query: Login failed. Try again."
      end
      500: printf, -2, "ERROR in mvn_kp_execute_neturl_query: Service failed to handle the query: " + query
      23: printf, -2, "ERROR in mvn_kp_execute_neturl_query: Not able to save result to: " + filename
      else: begin
        printf, -2, "ERROR in mvn_kp_execute_neturl_query: Service request failed with IDL error code: " + strtrim(error_status,2)  
        help, !error_state
      end
    endcase
    catch, /cancel ; Cancel catch so other errors don't get caught here.
    return, code ;the http or other IDLnetURL error code (http://www.exelisvis.com/docs/IDLnetURL.html#objects_network_1009015_1417867)
  endif
  
   
  ; Set the path and query for the request.
  netURL->SetProperty, URL_PATH=url_path
  netURL->SetProperty, URL_QUERY=query


  ; Make the request.
  ; If the 'filename' parameter is set, assume we want to download a file.
  ; Otherwise, get the results as a string array.
  if (n_elements(filename) eq 1) then result = netURL->Get(filename=filename)  $  ;download file, result should be path of file
  else result = netURL->Get(/string_array)  ;get results as array of comma separated values
  
  ; Cancel catch so other errors don't get caught here.
  catch, /cancel
  
  return, result
end
