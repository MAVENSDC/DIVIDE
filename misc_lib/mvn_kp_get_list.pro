;+
;
; :Name:
;  mvn_kp_get_list
;
; :Description:
;  Access the provided in-situ data structure and print a list of the
;  contained parameters
;
; :Author:
;   McGouldrick (2015-May-20)
;
; :Params:
;  insitu: in, structure
;  - the data strcture to be queried
;
; :History:
;  Pulled from mvn_kp_altplot and mvn_kp_plot
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
@mvn_kp_tag_list
@mvn_kp_tag_parser

pro mvn_kp_get_list, kp_data, list=list

  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, $
    second_level_count, base_tags,  first_level_tags, second_level_tags

  if( arg_present(list) )then begin
    list = strarr(250)
    index2=0
    for i=0,base_tag_count-1 do begin
      if first_level_count[i] ne 0 then begin
        for j=0,first_level_count[i]-1 do begin
          if first_level_count[i] ne 0 then begin 
             list[index2] = '#'+strtrim(string(index2+1),2)+' ' $
                          + base_tags[i]+'.' $
                          + strtrim(string(first_level_tags[index2]),2)
             index2 = index2+1
           endif 
        endfor
      endif
    endfor
    list = list[0:index2-1]
  endif else begin
    if keyword_set(list) then begin
      MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, $
                       base_tags,  first_level_tags
    endif
  endelse
return
end
