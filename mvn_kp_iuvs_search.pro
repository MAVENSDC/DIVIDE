;+
; Searches the input line of INSITU kp data based on the search parameters
;
; :Params:
;    KP_data : in, required, type=structure
;       the named structure for the KP data 
;    kp_data_out: out, require, type=structure
;       the named structure with the data that meets search criteria
; :Keywords:
;    tag: in, required, type=intarr/strarr
;       the name, or names, of the IUVS data parameter (or integer index) to search on
;    min: in, optional, type=fltarr(ntags)
;       the minimum value of the parameter to be searched on (or array of values)
;    max: in, optional, type=fltarr(ntags)
;       the maximum value of the parameter to be searced on (or array of values)
;    range: in, optional, type=boolean
;       if present, will simply list the start and end times of the passed data structure
;    list: in, optional, type=boolean
;       if present, will simply list the available structure tags within the KP data structure
;    debug: in, optional, type=boolean
;       optional keyword to execute in "debug" mode. On errors, IDL will halt in place so the user can
;       have a chance to see what's going on. By default this will not occur, instead error handlers
;       are setup and errors will return to main.
;       ;-
pro MVN_KP_IUVS_SEARCH,  kp_data, kp_data_out, tag=tag, species=species, min=min_value, max=max_value, list=list, range=range, debug=debug

  ; IF NOT IN DEBUG, SETUP ERROR HANDLER
  if not keyword_set(debug) then begin
    ; Establish error handler. When errors occur, the index of the
    ; error is returned in the variable Error_status:
    CATCH, Error_status
    
    ;This statement begins the error handler:
    IF Error_status NE 0 THEN BEGIN
      ; Handle errors by returning to Main:
      PRINT, '**ERROR HANDLING - ', !ERROR_STATE.MSG
      PRINT, '**ERROR HANDLING - Cannot proceed. Returning to main'
      Error_status = 0
      CATCH, /CANCEL
      return
    ENDIF
  endif
  
  ; IF DEBUG SET, SET IT AS AN ENVIRONMENT VARIABLE SO ALL PROCEDURES/FUNCTIONS CALLED CAN CHECK FOR IT
  if keyword_set(debug) then begin
    setenv, 'MVNTOOLKIT_DEBUG=TRUE'
  endif


  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags


if keyword_set(list) then begin                              ;LIST ALL THE SUB-STRUCTURES INLUDED IN A GIVEN KP DATA STRUCTURE
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    return
endif

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    return
  endif

if keyword_set(min_value) eq 0 then begin             ;IF THE MINIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE -INFINITY
 if size(tag,/dimensions) eq 0 then begin
  min_value = -!values.f_infinity
 endif else begin
  min_value = fltarr(n_elements(tag))
  min_value[*] = -!values.f_infinity
 endelse
endif
if keyword_set(max_value) eq 0 then begin             ;IF THE MAXIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE INFINITY
 if size(tag,/dimensions) eq 0 then begin
  max_value = !values.f_infinity
 endif else begin
  max_value = fltarr(n_elements(tag))
  max_value[*] = !values.f_infinity
 endelse
endif
 
      MVN_KP_TAG_VERIFY, kp_data_temp, tag[0],base_tag_count, first_level_count, base_tags,  $
                         first_level_tags, check, level0_index, level1_index, tag_array 
 
 instrument_array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
 for i=0, n_elements(tag)-1 do begin
        MVN_KP_TAG_VERIFY, kp_data_temp, tag[i],base_tag_count, first_level_count, base_tags,  $
                         first_level_tags, check, level0_index, level1_index, tag_array
      print,tag_array
     case tag_array[0] of
        'APOAPSE': begin
                      instrument_array[8] = 1
                   end
        'PERIAPSE': begin
                      instrument_array[7] = 1
                    end
        'CORONA_LO_LIMB': begin
                            instrument_array[12] = 1   
                            instrument_array[13] = 1               
                          end
        'CORONA_LO_HIGH': begin
                            instrument_array[12] = 1          
                            instrument_array[13] = 1
                          end
        'CORONA_E_DISK':  begin
                            instrument_array[9] = 1
                            instrument_array[10] = 1
                          end
        'CORONA_E_HIGH':  begin
                            instrument_array[9] = 1
                            instrument_array[10] = 1
                          end
        'STELLAR_OCC':  begin
                          instrument_array[11] = 1
                        end  
     endcase
 
 endfor
 ;BUILD THE NEW DATA STRUCTURE TO HOLD THE STORED DATA
 
  MVN_KP_IUVS_STRUCT_INIT,iuvs_record, instrument_array
  kp_data_temp = replicate(iuvs_record, n_elements(kp_data))

stop    

if keyword_set(tag) then begin
  if size(tag,/type) eq 2 then begin            ;INTEGER TAG INDICES
    count = intarr(n_elements(tag))
    species_count = 0
    for i=0,n_elements(tag) -1 do begin
      MVN_KP_TAG_VERIFY, kp_data_temp, tag[i],base_tag_count, first_level_count, base_tags,  $
                         first_level_tags, check, level0_index, level1_index, tag_array
      if check eq 1 then begin
        print,'Tag #',strtrim(string(tag[i]),2),' is not included in the KP data structure.'
        return
      endif      
      
      ;CHECK IF RADIANCE OR DENSITIES ARE REQUESTED AND IF PROPER SPECIES LISTED
      if (tag_array[1] eq 'SCALE_HEIGHT') or (tag_array[1] eq 'DENSITY') or (tag_array[1] eq 'RADIANCE') then begin
        if keyword_set(species) ne 1 then begin
          print, 'Please identify the atmospheric species of interest.'
          return
        endif
          MVN_KP_IUVS_SPECIES, tag_array, species[species_count], species_index
      endif else begin 
        species_index = -9
      endelse
      if species_index eq -1 then begin
        print, 'Invalid species profile to search on. Try again.'
        return
      endif
      if species_index eq -9 then begin
        print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
      endif else begin
        print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
        print,'Additionally, species index '+strtrim(string(species_index),2)+' will be the searched parameter'
      endelse      
      
      
    endfor 

  endif       ;END INTEGER OPTION
endif 
 
kp_data_out = kp_data_temp
 
      
;;if keyword_set(tag) then begin                  ;IF A TAG NAME OR NUMBER IS SET, RUN A SEARCH ON THAT DATA FIELD BETWEEN MIN AND MAX
;   tag_size = size(tag,/type)
;   if tag_size eq 2 then begin 
;    count = intarr(n_elements(tag))
;    kp_data_temp = kp_data
;    for i=0,n_elements(tag) -1 do begin
;                 MVN_KP_TAG_VERIFY, kp_data, tag[i],base_tag_count, first_level_count, base_tags,  $
;                      first_level_tags, check, level0_index, level1_index, tag_array
;            if check eq 1 then begin
;              print,'Tag #',strtrim(string(tag[i]),2),' is not included in the KP data structure.'
;              return
;            endif
;            
;            ;CHECK IF RADIANCE OR DENSITIES ARE REQUESTED AND IF PROPER SPECIES LISTED
;            if (tag_array[1] eq 'SCALE_HEIGHT') or (tag_array[1] eq 'DENSITY') or (tag_array[1] eq 'RADIANCE') then begin
;                MVN_KP_IUVS_SPECIES, tag_array, species[i], species_index
;            endif else begin 
;              species_index = -9
;            endelse
;            if species_index eq -1 then begin
;              print, 'Invalid species profile to search on. Try again.'
;              return
;            endif
;            if species_index eq -9 then begin
;              print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
;            endif else begin
;              print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
;              print,'Additionally, species index '+strtrim(string(species_index),2)+' will be the searched parameter'
;            endelse
;  
;            ;FIRST THE SIMPLE CASE OF A NON-SPECIES SEARCH ON KP DATA
;            if specs_index eq -9 then begin
;              meets_criteria = where(kp_data_temp.(level0_index).(level1_index) ge min_value[i] and kp_data_temp.(level0_index).(level1_index) le max_value[i],counter)
;              count[i] = counter
;              kp_data_temp = kp_data_temp[meets_criteria]
;            endif
;    endfor            ;END THE LOOP OVER THE VARIOUS SEARHC PARAMETERS
;    print,strtrim(string(counter),2),' records found that meet the search criteria.'      
;    kp_data_out = kp_data_temp
;   endif
;   if tag_size eq 7 then begin
;    count = intarr(n_elements(tag))
;    kp_data_temp = kp_data
;    for i=0,n_elements(tag)-1 do begin
;                       MVN_KP_TAG_VERIFY, kp_data, tag[i],base_tag_count, first_level_count, base_tags,  $
;                      first_level_tags, check, level0_index, level1_index, tag_array
;             print,'Retrieving records which have ',tag_array[0]+'.'+tag_array[1],' values between ',strtrim(string(min_value[i]),2),' and ',strtrim(string(max_value[i]),2)
;              ;SPLIT THE SEARCH TAG INTO UPPER AND LOWER LEVEL COMPONENTS
;                
;             meets_criteria = where(kp_data_temp.(level0_index).(level1_index) ge min_value[i] and kp_data_temp.(level0_index).(level1_index) le max_value[i], counter)
;             count[i] = counter
;             kp_data_temp = kp_data_temp[meets_criteria]             
;    endfor
;    print,strtrim(string(counter),2),' records found that meet the search criteria.'      
;    kp_data_out = kp_data_temp
 ;  endif
;
;endif       ;END OF ALL SEARCH ROUTINES

; UNSET DEBUG ENV VARIABLE
setenv, 'MVNTOOLKIT_DEBUG='


end




 