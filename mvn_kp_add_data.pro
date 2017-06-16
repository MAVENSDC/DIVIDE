;+
; :Name: mvn_kp_add_data
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
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
;
;  Verify that the number of tags names equals the number of variables
;  to be added to the data structure
;
  if( size(e.(0),/type) eq 8 )then begin
  ;
  ;  The passed data is in the form of a structure
  ;  Compare the numebr of level2 tags to the number of names
  ;  
    if( n_elements(data_name) ne n_tags(e.(0)) )then begin
      print,'*****ERROR*****'
      print,'Number of names provided in <data_name>'
      print,'does not match number of tags in given model structure.'
      print,'Number of tag names provided (2nd argument): '$
        + strtrim(n_elements(data_name),1)
      print,'Number of tags in the structure provided: '$
        + strtrim(n_tags(e.(0)),1)
      print,'Unable to proceed.  Exiting....'
      return
    endif
  endif else begin
  ;
  ;  The passed data are captured in the extra keyword and were provided
  ;  as a finite list of variables.
  ;
    if( n_elements(data_name) ne n_tags(e) )then begin
      print,'*****ERROR*****'
      print,'Mismatch between tag_names and input variables.'
      print,'Number of tag names provided (2nd argument): '$
            + strtrim(string(n_elements(data_name)),1)
      print,'Number of variables provided (4th through Nth arguments): '$
            + strtrim(string(n_tags(e)),1)
      print,'Unable to proceed.  Exiting....'
      return
    endif
  endelse
;
;  Verify that the sizes of the provided variables match that of the 
;  input data structure.
;  NB, this does not consider multi-dimensional variables
;
;  For now, skip the time check because we are currently passing
;   some meta data that is not dimensional to the data structure
;
;goto,skip_time_check
;  if( size(e.(0),/type) eq 8 )then begin
;    ;
;    ;  Verify that each attribute of the passed structure has right
;    ;  size of the time dimension
;    ;
;    for i = 0,n_tags(e.(0))-1 do begin
;      if( (size(kp_data))[1] ne (size(e.(0).(i)))[1] )then begin
;        print,'*****ERROR*****'
;        print,'Size mismatch'
;        print,'Input variable: '+(tag_names(e.(0)))[i]$
;          +' has dimensions: '+strtrim(string(size(e.(0).(i),/dim)),1)
;        print,'Input KP structure has time dimension: '$
;              +strtrim(string((size(kp_data))[1]),1)
;        print,'Exiting....
;        return
;      endif
;    endfor
;  endif else begin
;    ;
;    ;  Verify that each passed variable has the right size of the
;    ;  time dimension
;    ;
;    for i = 0,n_tags(e)-1 do begin
;      if( (size(kp_data))[1] ne (size(e.(i)))[1] )then begin
;        print,'*****ERROR*****'
;        print,'Size mismatch'
;        print,'Input variable: '+(tag_names(e))[i]$
;            +' has dimensions: '+size(e.(i),/dim)
;        print,'Input KP structure has time dimension: '+(size(kp_data))[1]
;        print,'Exiting....
;        return
;      endif
;    endfor
;  endelse
;skip_time_check: wait,1e-6
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
  
;  Now, cycle through the tags and variables, filling them one by one
;  If we wish to keep the metadata here, we'll need some datatype checks
  if( size(e.(0),/type) eq 8 )then begin
    for i = 0,n_tags(e.(0))-1 do begin
      output.user.(i) = e.(0).(i)
    endfor
  endif else begin
    for i = 0,n_tags(e)-1 do begin
      output.user.(i) = e.(i)
    endfor
  endelse
;  And that should be that...
end



