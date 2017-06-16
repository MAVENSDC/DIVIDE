;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

function mvn_kp_get_filenames, query=query, private=private
  ;type: science, ancillary, sitl_selection
  
  ;Set to 0 for public release, 1 for team release
  private = mvn_kp_config_file(/check_access)
  
  ;Get server information
  sdc_server_spec = mvn_kp_config(/data_retrieval, private=private)


  url_path = sdc_server_spec.url_path_file_names

  if n_elements(query) eq 0 then query = ""

  connection = mvn_kp_get_connection(private=private)


  result = mvn_kp_execute_neturl_query(connection, url_path, query)
  ; Check for error (long integer code as opposed to array of strings)
  if (size(result, /type) eq 3) then return, result
  ;Note: empty array = !NULL not supported before IDL8

  names = strsplit(result, ",", /extract)
  
  return, names
end
