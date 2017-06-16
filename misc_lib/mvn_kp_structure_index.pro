;+
; ROUTINE TO CONVERT A STRING NAMED KP PARAMETER TO A NUMERICAL INDEX
;
; :Params:
;    kp_data: in, required, type=structure
;       the data structure (not sure why this is passed, something to check later)
;    base_tag_count: in, required, type=integer
;       the number of base level tags in the data structure
;    first_level_count: in, required, type=integer
;       the number of first level tags in the data structure
;    base_tags: in, required, type=strarr(base_tag_count)
;       the names of the base level tags
;    first_level_tags: in, required, type=strarr(first_level_count)
;       the names of the first level tags.
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-


pro MVN_KP_STRUCTURE_INDEX, kp_data, new_param, new_index, first_level_tags

  ;parse the input parameter name
    
  tag_array = strsplit(new_param, '.', /extract)
  tag_array = strupcase(tag_array)
  
  ;FIND WHERE IN THE LIST THE REQUESTED FIELD FALLS
  
  new_index = where(first_level_tags eq tag_array[1]) + 1
  
  
end