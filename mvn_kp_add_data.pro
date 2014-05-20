;+
; A simple routine for adding a SINGLE user defined data field to the INSITU KP data structure
;    This may get generalized in the future to allow multiple additions
;
; :Params:
;    kp_data : in, required, type="structure"
;       the original insitu KP data structure
;    data_name : in, required, type="string"
;       the name of the new data to be added onto the USER substructure
;    data_in : in, required, type="dblarr"
;       the data array that you are adding onto the structure
;    output : out, required, type="structure"
;       the name of the newly created data structure
;-


pro mvn_kp_add_data, kp_data, data_name, output, data1=data1, data2=data2, data3=data3, data4=data4

    MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
    
    check = where(base_tags eq 'USER')
    if check ne -1 then begin
      PRINT, 'Whoops, the input structure already contains a USER substructure.'
      Print, 'For now, this routine will only work with structures that do not contain the USER substructure, sorry.'
      return
    endif


 if n_elements(data_name) eq 1 then begin

        input_size = size(kp_data)
        data_size = size(data1)
        
        if data_size(1) ne input_size(1) then begin
          print,'Whoops, the data to be added to the INSITU KP structure must have the same number of elements.'
          return
        endif
    
        ;BASIC CHECKS ARE PASSED, SO ADD THE NEW DATA FIELD TO THE INPUT DATA STRUCTURE
    
    

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



