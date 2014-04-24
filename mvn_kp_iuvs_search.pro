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

;pro MVN_KP_IUVS_TAG_PARSER, data, base_tag_count, first_level_count, second_level_count, $
;  base_tags,  first_level_tags, second_level_tags, common_block=common_block
;
;  ;DETERMINE WHETHER THE DATA INCLUDES IUVS DATA AS WELL AS INSITU
;  
;  base_tags = tag_names(data)
;  base_tag_count = n_elements(base_tags)
;
;
;  
;  
;  first_level_count = intarr(n_elements(base_tags))
;  for i=0,base_tag_count-1 do begin
;    tag_count = n_tags(data.(i))
;    if tag_count eq 0 then begin
;      first_level_count[i] = tag_count
;    endif else begin
;      temp1 = tag_names(data.(i))
;      first_level_count[i] = n_elements(temp1)
;    endelse
;  endfor
;  first_level_tags = strarr(total(first_level_count))
;  count1 = 0
;  count2 = 0
;  for i=0,base_tag_count-1 do begin
;    tag_count = n_tags(data.(i))
;    if tag_count ne 0 then begin
;      temp1 = tag_names(data.(i))
;      count2 = count1 + n_elements(temp1)-1
;      first_level_tags[count1:count2] = temp1
;      count1 = count2+1
;    endif
;  endfor
;end

pro MVN_KP_IUVS_TAG_PARSER, kp_data, input_tag, common_tag, level1_index, observation=observation

  iuvs_data_info = MVN_KP_CONFIG(/IUVS_DATA)
  common_tags_num = iuvs_data_info.num_common
  common_tag_names = tag_names(kp_data.(0)[0])
  common_tag_names = common_tag_names[0:common_tags_num-1]

   ;; If input_tag is an INT
   if size(input_tag, /type) eq 2 then begin
   
      ;; If input_tag number falls within the common tags range
      if input_tag le common_tags_num then begin
        level1_index = input_tag
        common_tag = 1 ;; Indicate common value

      ;; Check if tag matches observation
      endif else begin
        if not keyword_set(observation) then begin 
          errorStr = "Not valid tag number. If searching for observation specific tag, "
          errorStr += "ensure you provide OBSERVATION keyword indicating which observation"
          message, errorStr
        endif
        
        obs_tag_num = n_tags(observation)
        level1_index = input_tag
        common_tag = 0
        if (obs_tag_num ge n_tags(observation)) then message, "Not a valid tag number."

      endelse
    
    endif
    
    
   ;; IF input tag[i] is a STRING
   if size(input_tag, /type) eq 7 then begin
      level1_index = where(common_tag_names eq input_tag, counter)
      
      if counter gt 0 then begin
        common_tag = 1 ;; Indicate common value
      
      ;; Check if tag matches observation
      endif else begin
        
        if not keyword_set(observation) then begin
          errorStr = "Not valid tag. If searching for observation specific tag, "
          errorStr += "ensure you provide OBSERVATION keyword indicating which observation"
          message, errorStr
        endif
        
        obs_tag_names = tag_names(observation)
        level1_index =  where(input_tag eq obs_tag_names, counter)
        common_tag = 0
        if counter ne 1 then message, "Not a valid tag tag."
        
      endelse
      
        
   endif

  

end

pro MVN_KP_IUVS_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
  
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

  print,'USE ANY OF THESE TAG NAMES, OR ASSOCIATED INDICES, TO SEARCH ON THE KP DATA FILE.'
end


pro MVN_KP_IUVS_TAG_LIST_COMMON, data

  iuvs_data_info = MVN_KP_CONFIG(/IUVS_DATA)
  common_tags_num = iuvs_data_info.num_common
  common_tags = tag_names(data.(0))
  
  ;if dataset eq 'INSITU' then begin
  print, 'Common geometry fields available for searching accross all observations as follows'
  print,'*********************************************'
  print,''
  print,'-----------------------------'
  
  print, "Common Gemoetry Variables"
  for j=0, common_tags_num - 1 do begin
    print,'   #'+strtrim(string(j),2)+' '+strtrim(string(common_tags[j]) ,2)
  endfor
  print,'-----------------------------'
  
  
  print,'USE ANY OF THESE TAG NAMES, OR ASSOCIATED INDICES, TO SEARCH ACCROSS OBSERVATIONS.'
  print, ''
  
 
end


pro MVN_KP_IUVS_TAG_LIST_MODE, observation, observation_name

  iuvs_data_info = MVN_KP_CONFIG(/IUVS_DATA)
  common_tags_num = iuvs_data_info.num_common
  total_tags = tag_names(observation)
  total_tags_num = n_elements(total_tags)
  
  ;; Find instance of obesrvation that doesn't contain blank string for time. From this we
  ;; will assume this observation has data
  for i=0, n_elements(observation)-1 do begin
    if observation[i].time_start ne '' then begin
      ;; Use this observation (only need one for listing)
      observation_list = observation[i]      
    endif
  endfor
  
  ;; If we didnt' find an observation that contained data, return
  if not keyword_set(observation_list) then begin
    print, "Can't proceed with listing."
    message, "Couldn't find observation with data in input structure"
  endif
  
  
  print,'Observation specific fields and associated species available for searching as follows'
  print,'*********************************************'
  print,''
  print,'-----------------------------'
  
  print, string(observation_name)+" Variables"
  print, ''
  for j=common_tags_num, total_tags_num - 1 do begin
    print,'   #'+strtrim(string(j),2)+' '+strtrim(string(total_tags[j]) ,2)
    
    ;; If _ID array print out elements
    if stregex(string(total_tags[j]), '.*_ID', /BOOLEAN) then begin
        print, '         Species: ', observation_list.(j)
    endif
    
    ;; If ALT array print out elements
    if stregex(string(total_tags[j]), 'ALT', /BOOLEAN) then begin
      print, '         Altitudes: ', observation_list.(j)
    endif
  endfor
  print,'-----------------------------'
  
  
  print,'USE ANY OF THESE TAG NAMES, OR ASSOCIATED INDICES, TO SEARCH THIS OBSERVATION MODE.'
  print, ''


end

function MVN_KP_IUVS_SEARCH_COMMON, data, tag_index, min_value, max_value
  
 
  numObs = n_tags(data)
  tagNames = tag_names(data)
  
  ;; Determine how many total observations exsist, including arrays of observations (PERIAPSE)
  totalObsIncludingArrays = 0  
  totalObsTags = ["hack"]

  
  for i=0, numObs-1 do begin
    obsDim = size(data.(i), /DIMENSIONS)
    
    if (n_elements(obsDim) gt 1) then begin
      for innerDimI = 0, obsDim[0]-1 do begin
        totalObsIncludingArrays += 1
        
        ;; If observation has more than one entry (PERIAPSE), append index number onto tag name
        totalObsTags = [totalObsTags, strtrim(string(tagNames[i]),2) + strtrim(string(innerDimI), 2)] 
      endfor
 
    endif else begin
      totalObsIncludingArrays += 1
      totalObsTags = [totalObsTags, tagNames[i]]
    endelse
 
  endfor

  ;; Remove first entry - IDL 7 hack  
  totalObsTags = totalObsTags[1:-1]

  
  ;; 2 by 2 array to contain information about which observations matched the search criteria
  tagMatchesPerObs = make_array(n_elements(data), totalObsIncludingArrays, /integer)

  ;; Search accross all observations
  meets_criteria = [-1] ;; hack for idl 7
  tagsMatchesIndex = 0
  for i=0, numObs-1 do begin
     
    ;; Disclude stellar_occ, orbit, and matching_tags 
    if tagNames[i] ne 'STELLAR_OCC' and tagNames[i] ne 'ORBIT' and tagNames[i] ne 'MATCHING_OBS' then begin
      
      ;; Loop through multiple instances of observation (PERIAPSE)
      for j=0, n_elements(data[0].(i)) -1 do begin

        meets_criteria_temp = where((data.(i)[j].(tag_index) ge min_value) and (data.(i)[j].(tag_index) le max_value), counter)
      
        if counter gt 0 then begin
          meets_criteria = [meets_criteria, meets_criteria_temp] 
          tagMatchesPerObs[meets_criteria_temp, tagsMatchesIndex] = 1
    
        endif
        tagsMatchesIndex += 1

      endfor          
   endif
  endfor
  


  ;; Create array of uniq indicies of matches
  if n_elements(meets_criteria) gt 1 then begin
    meets_criteria = meets_criteria[1:*]  ;; remove first element for idl 7 hack
    meets_criteria = meets_criteria[uniq(meets_criteria, sort(meets_criteria))]
    
    
    ;;
    ;; If 'MATCHING_OBS' tag doesn't already exist in structure, we need to create a new
    ;; structure and a full new array of these structures.
    ;;
    tagMatchingI = where(tagNames eq 'MATCHING_OBS', counterTag)
    if (counterTag le 0) then begin
    
      data_temp = create_struct(data[meets_criteria[i]], 'matching_obs', '')
      matched_data = replicate(data_temp, n_elements(meets_criteria))
      
    
    ;; Else, tag already exists so can just update each matching_obs entry
    endif else begin
       
       matched_data = data[meets_criteria]
      
    endelse
  
  
    ;; Loop back through each orbit, create and add array of tags containing which observation matched the search
    for i=0L, n_elements(meets_criteria) -1 do begin
      
      matchingObsTags = where(tagMatchesPerObs[meets_criteria[i], *] eq 1, counter)

      ;; Counter should never be zero here
      if(counter le 0) then message, "Problem with searching, code should not be here. "

      ;; Create string of all matched observations:
      matchingObsString = ''      
      for tagI=0, n_elements(matchingObsTags)-1 do begin

        matchingObsString += totalObsTags[matchingObsTags[tagI]] + ' '  
      endfor
      

      ;; If 'MATCHING_OBS' didn't exist, need to copy over all observations into new structure
      ;;
      if (counterTag le 0) then begin
        ;; Add in all obesrvations from original data structure to new array of structures
        for j=0, numObs-1 do begin
          matched_data[i].(j) = data[meets_criteria[i]].(j)
        endfor
      
        ;; add in string with matching observationse
        matched_data[i].(j) = matchingObsString
      

      ;; If tag did exist, just update the structure
      endif else begin
        matched_data[i].(tagMatchingI) = matchingObsString
        
      endelse
      
      



             
    endfor
    

  
  endif else begin
    meets_criteria = -1
  endelse
  
  
  ;; Output structure ------------------------------------------------------------------------------------------- 
  ;;
  ;;
  ;;   Added this in now for testing...
  
  if meets_criteria[0] ne -1 then begin
    data = matched_data
  endif else begin
    data = -1
  endelse
  
  
  return, meets_criteria
end


function MVN_KP_IUVS_SEARCH_MEASUREMENTS, observation, measure=measure, species=species, min=min_value, max=max_value, altitude=altitude

  
  ;; Find instance of obesrvation that doesn't contain blank string for time. From this we
  ;; will assume this observation has data
  obsIndex = -1
  for i=0, n_elements(observation)-1 do begin
    if observation[i].time_start ne '' then begin
      ;; Use this observation (only need one for listing)
      obsIndex = i
      break
    endif
  endfor
  
  ;; If we didnt' find an observation that contained data, return
  if obsIndex lt 0 then begin
    print, "Can't proceed with search."
    print, "Couldn't find observation with data in input structure"
    return, -1
  endif
  
    ;; Check species valid
  if not keyword_set(measure) then message, "Must specifcy a measurement (measure keyword) to search(e.g. RADIANCE or OZONE_DEPTH)"
  if keyword_set (species) then species = strupcase(strtrim(species,2))
  measure = strupcase(strtrim(measure,2))
  measureI = where(tag_names(observation[obsIndex]) eq measure)


  case measure of
    'SCALE_HEIGHT': begin
      if not keyword_set(species) then message, "Must specify a species to search"
      speciesID   = where(observation[obsIndex].scale_height_id eq species)
    end
    'DENSITY': begin
      if not keyword_set(species) then message, "Must specify a species to search"
      speciesID   = where(observation[obsIndex].density_id eq species)
    end
    'RADIANCE': begin
      if not keyword_set(species) then message, "Must specify a species to search"
      speciesID   = where(observation[obsIndex].radiance_id eq species)
    end
    'HALF_INT_DISTANCE': begin
      if not keyword_set(species) then message, "Must specify a species to search"
      speciesID   = where(observation[obsIndex].half_int_distance_id eq species)
    end
    'TEMPERATURE': begin
      if not keyword_set(species) then message, "Must specify a species to search"
      speciesID = where(observation[obsIndex].temperature_id eq species)
    end
    
    ;; The following measurements don't have species associated with them, they are scalars and we can
    ;; use the same logic below by just setting the speciesID to 0 (which shall access the scalar)
    'OZONE_DEPTH': begin
      speciesID = 0
    end
    'AURORAL_INDEX': begin
      speciesID = 0
    end
    'DUST_DEPTH': begin
      speciesID = 0
    end
      
    else: message, "Measure option not found/allowed"
    
  endcase

  ;; If tag not found
  if measureI  lt 0 then message, "Invalid measure+ "+measure+" for mode PERIAPSE"
  if speciesID lt 0 then message, "Invalid species for: "+measure
  

  ;; decipher alitutde if input
  ;;------------------------------------------------------
  if keyword_set(altitude) then begin

    obs_tags = tag_names(observation)
    
    ;; Ensure this observation contains an altitude tag
    altitude_tagI = where(obs_tags eq 'ALT', counter)
    if counter le 0 then message, "Altitude option provided, but no altitude tag for observation"
    
    ;; Make sure altitude has two entries
    if n_elements(altitude) ne 2 then message, "Altitude option must be array of two items, min and max. Example: ALTITUDE=[1000,1600]"
    
    altInd = where((observation[obsIndex].alt ge altitude[0]) and (observation[obsIndex].alt le altitude[1]), counter)
    
    if counter le 0 then message, "No altitude entries found for input altitude range"

    ;; Ensure altitude index entries are sorted, save off start and end index
    altInd = altInd[sort(altInd)]
    altStartI = altInd[0]
    altEndI   = altInd[-1]
    
  endif else begin
    ;; If no altitude keyword, assume search full altitude range if applicable
    altStartI = 0
    altEndI = -1
    
  endelse


  
  ;; Search for all instances of input species for a measure within min/max and within altitude min/max
  ;; ---------------------------------------------------------------------------------------------------
  
  ;; If dimension of observation is two, this is periapse and treat as such
  if size(observation, /N_DIMENSIONS) eq 2 then begin
    ;;obsLastI = n_elements(observation[*,0])
    measureDim = size(observation[obsIndex].(measureI), /N_DIMENSIONS)
    numDimOne = (size(observation, /DIMENSION))[0]
    numOrbits = n_elements(observation[0,*])
    
    meets_criteria=[-1]
    for i=0, numDimOne-1 do begin
      
      ;; If scalar or one dimensional array of measurements
      if (measureDim le 1) then begin
      
        meets_criteria_hack=[-1]
        for x=0L, numOrbits-1 do begin
          where_results = where(observation[i,x].(measureI)[speciesID] ge min_value and $
            observation[i,x].(measureI)[speciesID] le max_value ,counter)
            
          if (counter gt 0) then meets_criteria_hack = [meets_criteria_hack, x]
        endfor
        
        if n_elements(meets_criteria_hack) gt 1 then begin
          meets_criteria=[meets_criteria, meets_criteria_hack[1:*]]
        endif 
        
      endif
      
      ;; If Two dimensional array of measurements  (assume 2nd dim is altitude)
      if (measureDim eq 2) then begin
        meets_criteria_hack=[-1]
        for x=0L, numOrbits-1 do begin
          where_results = where(observation[i,x].(measureI)[speciesID,altStartI:altEndI] ge min_value and $
            observation[i,x].(measureI)[speciesID,altStartI:altEndI] le max_value ,counter)
            
          if (counter gt 0) then meets_criteria_hack = [meets_criteria_hack, x]
        endfor
        
        if n_elements(meets_criteria_hack) gt 1 then begin
          meets_criteria=[meets_criteria, meets_criteria_hack[1:*]]
        endif 
        
      endif
      
    endfor
    
    if n_elements(meets_criteria) gt 1 then begin
      meets_criteria=meets_criteria[1:*]
      meets_criteria = meets_criteria[uniq(meets_criteria, sort(meets_criteria))]  ;; Only keep unique values
    endif else begin
      meets_criteria = -1
    endelse
      
    
    
  endif else if size(observation, /N_DIMENSIONS) eq 1 then begin
    
    
    measureDim = size(observation[obsIndex].(measureI), /N_DIMENSIONS)
    numObs = n_elements(observation)
    
    
    ;; If scalar or one dimensional array of measurements
    if (measureDim le 1) then begin
      
      meets_criteria_hack=[-1]
      for x=0L, numObs-1 do begin
        where_results = where(observation[x].(measureI)[speciesID] ge min_value and $
          observation[x].(measureI)[speciesID] le max_value ,counter)
          
        if (counter gt 0) then meets_criteria_hack = [meets_criteria_hack, x]
      endfor
      
      if n_elements(meets_criteria_hack) gt 1 then begin
        meets_criteria=meets_criteria_hack[1:*]
      endif else begin
        meets_criteria=meets_criteria_hack
      endelse    
    endif
 
    ;; If Two dimensional array of measurements  (assume 2nd dim is altitude)
    if (measureDim eq 2) then begin
      meets_criteria_hack=[-1]
      for x=0L, numObs-1 do begin
        where_results = where(observation[x].(measureI)[speciesID,altStartI:altEndI] ge min_value and $
          observation[x].(measureI)[speciesID,altStartI:altEndI] le max_value ,counter)
        
        if (counter gt 0) then meets_criteria_hack = [meets_criteria_hack, x]
      endfor
      
      if n_elements(meets_criteria_hack) gt 1 then begin 
        meets_criteria=meets_criteria_hack[1:*]
      endif else begin
        meets_criteria=meets_criteria_hack
      endelse        
    endif
    
  endif else begin
    message, "Problem with input data, too many dimensions in observation"
  endelse
  
  return, meets_criteria
end


pro MVN_KP_IUVS_SEARCH,  kp_data, kp_data_out, tag=tag, measure=measure, species=species, observation=observation, $
                          min=min_value, max=max_value, list=list, range=range, debug=debug, altitude=altitude

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

 
  ;; If user supplied the observation keyword, parse it to decide which observation
  if keyword_set(observation) then begin
    
    observation_up = strupcase(strtrim(observation,2))
    observation_tags = tag_names(kp_data)
   
    
    case observation_up of
      'PERIAPSE': begin
        kp_data_obs = kp_data.periapse
        kp_data_obs_index = where(observation_tags eq 'PERIAPSE',  counter)
        kp_data_str = "Periapse"
      end
      'CORONAECHELLEHIGH': begin
        kp_data_obs = kp_data.corona_e_high
        kp_data_obs_index = where(observation_tags eq 'CORONA_E_HIGH',  counter)
        kp_data_str = "Corona Echelle High"
      end
      'CORONAECHELLELIMB': begin
        kp_data_obs = kp_data.corona_e_limb
        kp_data_obs_index = where(observation_tags eq 'CORONA_E_LIMB',  counter)
        kp_data_str = "Corona Echelle Limb"
      end
      'CORONAECHELLEDISK': begin
        kp_data_obs = kp_data.corona_e_disk
        kp_data_obs_index = where(observation_tags eq 'CORONA_E_DISK',  counter)
        kp_data_str = "Corona Echelle Disk"
      end
      'CORONALORESHIGH': begin
        kp_data_obs = kp_data.corona_lo_high
        kp_data_obs_index = where(observation_tags eq 'CORONA_LO_HIGH',  counter)
        kp_data_str = "Corona Lores High"
      end
      'CORONALORESLIMB': begin
         kp_data_obs = kp_data.corona_lo_limb
         kp_data_obs_index = where(observation_tags eq 'CORONA_LO_LIMB',  counter)
         kp_data_str = "Corona Lores Limb"
      end
      'CORONALORESDISK': begin
        kp_data_obs = kp_data.corona_lo_disk
        kp_data_obs_index = where(observation_tags eq 'CORONA_LO_DISK',  counter)
        kp_data_str = "Corona Lores Disk"
      end
      'APOAPSE': begin
         kp_data_obs = kp_data.apoapse
         kp_data_obs_index = where(observation_tags eq 'APOPASE',  counter)
         kp_data_str = "Apoapse"
      end
      'STELLAROCC' : begin
         kp_data_obs = kp_data.stellarocc
         kp_data_obs_index = where(observation_tags eq 'STELLAR_OCC',  counter)
         kp_data_str = "Stellar Occultation"
      end 
      
      else: begin
         print, "Error: Unknown observation input: "+string(observation)
         print, "Accepted observations are: "
         print, "  Periapse"
         print, "  CoronaEchelleHigh"
         print, "  CoronaEchelleLimb"
         print, "  CoronaEchelleDisk"
         print, "  CoronaLoresHigh"
         print, "  CoronaLoresLimb"
         print, "  CoronaLoresDisk"
         print, "  Apoapse"
         print, "  StellarOcc"
         print, ""
         
         message, "Error: Unknown observation input. Cannot Proceed."
      end
    endcase
    
    ;; Make sure kp_data_obs_index was found
    if counter le 0 then begin
      message, "Could not find observation: "+str(observation)+" in input data."
    endif
    
  endif


  ;; If keyword list supplied, only list the searchable fields and return.
  if keyword_set(list) then begin
    
    MVN_KP_IUVS_TAG_LIST_COMMON, kp_data
       
    if keyword_set(observation) then begin
      MVN_KP_IUVS_TAG_LIST_MODE, kp_data_obs, kp_data_str
    endif 
    
    if keyword_set(tag) or keyword_set(measure) or keyword_set(species) or keyword_set(min) or $
       keyword_set(max) or keyword_set(min) or keyword_set(max) then begin
        print, "NOTE: /LIST keyword entered. No searching done when /LIST keyword present, only a listing of variables to search on"
    end
    
  endif
  

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
  endif
  
  ;; If either list or range specified, return (no actual seraching done).
  if keyword_set(list) or keyword_set(range) then begin
    return
  endif
 
  ;; Only proceed if tag specified
  if not keyword_set(tag) then begin
    message, "Must input TAG paramater to search"
  endif
  

  ;IF THE MINIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE -INFINITY
  if keyword_set(min_value) eq 0 then begin             
    if size(tag,/dimensions) eq 0 then begin
      min_value = -!values.f_infinity
    endif else begin
      min_value = fltarr(n_elements(tag))
      min_value[*] = -!values.f_infinity
    endelse
  endif

  ;IF THE MAXIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE INFINITY
  if keyword_set(max_value) eq 0 then begin            
    if size(tag,/dimensions) eq 0 then begin
      max_value = !values.f_infinity
    endif else begin
      max_value = fltarr(n_elements(tag))
      max_value[*] = !values.f_infinity
    endelse
  endif
  
  

  ;; Loop through all input tags and search for each
  meets_criteria = [-1]
  kp_data_temp = kp_data
  
  for i=0, n_elements(tag)-1 do begin
  
    ;; Find out if common tag and level1 index if applicable
    mvn_kp_iuvs_tag_parser, kp_data, tag[i], common_tag, level1_index, observation = kp_data_obs
    
    ;; If common value/tag
    if common_tag then begin
      meets_criteria = MVN_KP_IUVS_SEARCH_COMMON(kp_data_temp, level1_index, min_value[i], max_value[i])
    
      ;; If there were no matches, break out now with no results
      if meets_criteria[0] eq -1 then begin
        kp_data_temp = -1
        break 
       endif
    
    ;; Observation specific search
    endif else begin
      
      if not keyword_set(observation) then message, "If searching observation specific measurement, must specify which observation"
      meets_criteria = MVN_KP_IUVS_SEARCH_MEASUREMENTS(kp_data_temp.(kp_data_obs_index[0]), measure=tag[i], species=species, min=min_value[i], max=max_value[i], altitude=altitude)
      
      
      
      ;;
      ;;;
      ;;;  Updated here - Moved meets_criteria logic into here, search_common now returns updated kp_data_temp
      ;;;  instead of meets_critiera. 
      ;;;
      ;;;
      ;
      
      ;; If there were no matches, break out now with no results
      if meets_criteria[0] eq -1 then begin
        kp_data_temp = -1
        break
        
        ;; Otherwise, trim down kp_data_temp with meets_criteria index, and continue on with search
      endif else begin
        kp_data_temp = kp_data_temp[meets_criteria]
      endelse
      
      
    endelse
   
    
  endfor
  
  
  
  ;; Fill in output and inform user of results
  ;-----------------------------------------------
  
  if n_elements(kp_data_temp) gt 1 then begin
    kp_data_out = kp_data_temp
    
    ;; Fill output structure with matches
    print, "Total matching records: "+string(n_elements(kp_data_out))
  endif else begin
  
    ;; If no matches, return 0 in kp_data_out
    print, "No records match input range"
    kp_data_out = 0
  endelse
  
  
  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
  
end

  
  
  
