function mvn_kp_get_filenames, query=query
  ;type: science, ancillary, sitl_selection
  
  ;; Get server information
  sdc_server_spec = mvn_kp_config(/data_retrieval)

  url_path = sdc_server_spec.url_path_file_names
  
  if n_elements(query) eq 0 then query = ""
  
  connection = mvn_kp_get_connection(authentication=0) ; FIXME turned off authentication for testing)
  result = mvn_kp_execute_neturl_query(connection, url_path, query)
  ; Check for error (long integer code as opposed to array of strings)
  if (size(result, /type) eq 3) then return, result
  ;Note: empty array = !NULL not supported before IDL8

  names = strsplit(result, ",", /extract)
  
  return, names
end
