;+
; :Name: mvn_kp_add_data
; 
; :Author: Kevin McGouldrick
; 
; :Description: 
;    A simple routine for adding up to 9 user defined data arrays to the 
;    insitu KP data structure
;    RESTRICTIONS: The new data arrays must be of the same length and 
;    time cadence as the input structure.  If this is not the case, 
;    use mvn_kp_resample first to build a new data structure that 
;    matches the data field.
;       
;    All new data fields will be added to a USER substructure. 
;    This name is required for later use by the 3d vis. routine.   
;
; :Params:
;    kp_data : in, required, type="structure"
;       the original insitu KP data structure
;    data_name : in, required, type="string"
;       the name of the new data to be added onto the USER substructure, 
;       either a single string or an array of strings equal in length to 
;       the number of new data fields.
;    output : out, required, type="structure"
;       the name of the newly created data structure
;    data : in, required, type=array
;       The variable(s) to be appended to the input data structure.
;       Number of added variables MUST equal the number of elements
;       in data_name
;
; :Keywords:
;     help: in, optional, type=byte
;       Invoke the help listing
;       
; :Version: 1.0     April 30, 2015
;-


pro mvn_kp_add_data, kp_data, data_name, output, _extra = e, help=help

  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_add_data'
    return
  endif


  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, $
                     second_level_count, base_tags,  $
                     first_level_tags, second_level_tags
    
  check = where(base_tags eq 'USER')
  if check ne -1 then begin
    PRINT, 'Whoops, the input structure already contains '$
            +'a USER substructure.'
    Print, 'For now, this routine will only work with structures that '$
            +'do not contain the USER substructure, sorry.'
    return
  endif

;  Verify that the number of tags names equals the number of variables
;  to be added to the data structure

  if( n_elements(data_name) ne n_tags(e) )then begin
    print,'*****ERROR*****'
    print,'Mismatch between tag_names and input vairables.'
    print,'Number of tag names provided (2nd argument): '$
          + strtrim(n_elements(data_name),1)
    print,'Number of variables provided (4th through Nth arguments): '$
          + strtrim(n_tags(e),1)
    print,'Unable to proceed.  Exiting....'
    return
  endif
  
;  Verify that the sizes of the provided variables match that of the 
;  input data structure

  for i = 0,n_tags(e)-1 do begin
    ; I will keep testing on dim 1 of the vars, though I am not certain 
    ;  that is the best thiing to do.  Should the code be prepared to 
    ;  expect ntime x nx x ny x nz data, for example?
    if( (size(kp_data))[1] ne (size(e.(i)))[1] )then begin
      print,'*****ERROR*****'
      print,'Size mismatch'
      print,'Input variable: '+(tag_names(e))[i]$
          +' has dimensions: '+size(e.(i),/dim)
      print,'Input KP structure has time dimension: '+(size(kp_data))[1]
      print,'Exiting....
      return
    endif
  endfor

;  First, build a dummy structure with the appropriate names and 
;  number of tags.  Temporarily fill with scalar zeros to save memory.
  a1 = create_struct( data_name[0], 0.d0 )
  for i = 1,n_elements(data_name)-1 do begin
    a1 = create_struct( a1, data_name[i], 0.d0 )
  endfor

;  Next, make an array of structures in parallel shape to that of the 
;  input KP data, and with a head tag name of USER
  a1_temp = create_struct(['user'],a1)
  a1a = replicate( a1_temp, (size(kp_data))[1] )

;  Combine the new USER data structure with the existing kp_data structure
;  and produce a new structure called OUTPUT
  mvn_combine_structs, kp_data, a1a, output
  
;  Now, cycle through the tags and vairables, filling them one by one
  for i = 0,n_tags(e)-1 do begin
    output.user.(i) = e.(i)
  endfor
  
;  And that should be that...
end



