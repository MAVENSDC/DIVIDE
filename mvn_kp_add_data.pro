;+
; :Name: mvn_kp_add_data_obsolete
; 
; :Author: Kristopher Larsen
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
;    data1: in, required, type=dblarr
;       the first new data array to be added to the kp data structure
;    data2-data9: in, optional, type=dblarr
;       optional additional data arrays to be added to the new strucutre.
;       
;       
; :Version: 1.0     July 8, 2014
;-


pro mvn_kp_add_data_obsolete, kp_data, data_name, output, data1=data1, data2=data2, $
                     data3=data3, data4=data4, data5=data5, $
                     data6=data6, data7=data7, data8=data8, $
                     data9=data9, help=help

  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_add_data_obsolete'
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


  if n_elements(data_name) eq 1 then begin

    input_size = size(kp_data)
    data_size = size(data1)
        
print,data_size(1)
print,input_size(1)
    if data_size(1) ne input_size(1) then begin
      print,'Whoops, the data to be added to the INSITU KP structure '$
             +'must have the same number of elements.'
      return
    endif
    
    ;BASIC CHECKS ARE PASSED, SO ADD THE NEW DATA FIELD 
    ;TO THE INPUT DATA STRUCTURE

    a1 = create_struct(name='USER',data_name,0.0d)
    a1_temp = create_struct(['user'],a1)
    s = size(kp_data)
    a1a = replicate(a1_temp, s(1))
        
    mvn_combine_structs, kp_data, a1a, output
  
    ;POPULATE THE NEW STRUCTURE FIELD WITH THE INPUT DATA
    
    output.user.(0) = data1
  
  endif else begin
      
    case n_elements(data_name) of 
      2: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d)
      3: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d)
      4: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d, data_name[3], 0.0d)
      5: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d, data_name[3], 0.0d, data_name[4], 0.0d)
      6: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d, data_name[3], 0.0d, data_name[4], 0.0d, data_name[5], 0.0d)
      7: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d, data_name[3], 0.0d, data_name[4], 0.0d, data_name[5], 0.0d, $
                                  data_name[6], 0.0d)
      8: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d, data_name[3], 0.0d, data_name[4], 0.0d, data_name[5], 0.0d, $
                                  data_name[6], 0.0d, data_name[7], 0.0d)
      9: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d, data_name[3], 0.0d, data_name[4], 0.0d, data_name[5], 0.0d, $
                                  data_name[6], 0.0d, data_name[7], 0.0d, data_name[8], 0.0d)
     10: a1 = create_struct(name='USER', data_name[0], 0.0d, data_name[1], 0.0d, data_name[2], 0.0d, data_name[3], 0.0d, data_name[4], 0.0d, data_name[5], 0.0d, $
                                  data_name[6], 0.0d, data_name[7], 0.0d, data_name[8], 0.0d, data_name[9], 0.0d)
    endcase
          
    a1_temp = create_struct(['user'], a1)
    s = size(kp_data)
    a1a = replicate(a1_temp, s(1))
         
    mvn_combine_structs, kp_data, a1a, output
        
    ;POPULATE THE USER SUBSTRUCTURE WITH THE INPUT DATA  
    if keyword_set(data1) then output.user.(0) = data1
    if keyword_set(data2) then output.user.(1) = data2
    if keyword_set(data3) then output.user.(2) = data3
    if keyword_set(data4) then output.user.(3) = data4
    if keyword_set(data5) then output.user.(4) = data5
    if keyword_set(data6) then output.user.(5) = data6
    if keyword_set(data7) then output.user.(6) = data7
    if keyword_set(data8) then output.user.(7) = data8
    if keyword_set(data9) then output.user.(8) = data9
    if keyword_set(data10) then output.user.(9) = data10
        
  endelse

end



