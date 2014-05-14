;+
; ROUTINE TO LIST THE AVAILABLE TAGS IN A GIVEN STRUCTURE, CALLED BY THE /LIST KEYWORD IN HIGHER LEVEL ROUTINES
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
;-
pro  MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, $
                      base_tags,  first_level_tags

  index1 = 0 
  index2 = 1

  if base_tags[0] eq 'TIME_STRING' then begin
    dataset = 'INSITU'
  endif else begin
    dataset = 'IUVS'
  endelse

  ;if dataset eq 'INSITU' then begin
    print,'Fields available for searching are as follows'      
    print,'*********************************************'
    print,''
      print,dataset+' DATA SET VARIABLES'
      print,'-----------------------------' 
      for i=0,base_tag_count-1 do begin
        if first_level_count[i] ne 0 then begin
          print,strtrim(base_tags[i])
            for j=0,first_level_count[i]-1 do begin
              if first_level_count[i] ne 0 then begin 
                  print,'   #'+strtrim(string(index2),2)+' '+strtrim(string(first_level_tags[index2-1]),2)
                  index2 = index2+1
              endif 
            endfor
          print,'-----------------------------'
        endif
      endfor
;   endif
  
;  if dataset eq 'IUVS' then begin
;    print,'Fields available for searching are as follows'      
;    print,'*********************************************'
;    print,''
;      print,dataset+' DATA SET VARIABLES'
;      print,'-----------------------------' 
;      for i=0,base_tag_count-2 do begin
;      print,strtrim(base_tags[i])
;        for j=0,first_level_count[i]-1 do begin
;          if first_level_count[i] ne 0 then begin 
;              print,'   #'+strtrim(string(index2),2)+' '+strtrim(string(first_level_tags[index2-1]),2)
;              index2 = index2+1
;          endif 
;        endfor
;      print,'-----------------------------'
;    endfor
;   endif  
;  
  print,'USE ANY OF THESE TAG NAMES, OR ASSOCIATED INDICES, TO SEARCH ON THE KP DATA FILE.'


end