;+
; :Name: mvn_kp_iuvs_search
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: Kristopher Larsen & John Martin
; 
; 
; :Description:
;    Searches input IUVS KP data structure based on min and/or max search parameters
;
; :Params:
;    iuvs_in: in, required, type=array of structures
;       IUVS KP data structure (data structure output from mvn_kp_read)
;    iuvs_out: out, required, type=array of structures
;       output KP data structure containing datat that met all search criteria
;
; :Keywords:
;    list: in, optional, type=boolean
;       List out possible parameters names to search (& index identifiers associated with parameters). No
;       search performed. If no observation keyword supplied, will only list "common" variables 
;       (geometry values which exist in all observation modes). If observation keyword supplied, 
;       will also list parameters for that observation mode. 
;    
;    parameter: in, optional, type=intarr/strarr
;       Required if /list keyword not supplied. The name, or names, of the IUVS data parameter
;       (or integer index) to search on. Use /list keyword to see possible names or index integers
;       to search on.
;    
;    observation: in, optional, type=string
;       Specify a specific observation to either list or search within.
;    
;    species: in, optional, type=string
;       Specify a species to search. Only applicable if searching a parameter which has multiple species 
;       (CO2, CO, H, O, C, N, N2 for periapse scale_height)
;    
;    min: in, optional, type=fltarr
;       the minimum value of the parameter to be searched on (or array of values).
;       One or more minimum values. If multiple parameters input & multiple min values input, each min
;       value will correspond with each parameter (by array position). If multiple parameters & one min value,
;       the min value is used for all parameters. Cannot enter more min values than parameters.
;    
;    max: in, optional, type=fltarr
;       the maximum value of the parameter to be searced on (or array of values)
;       One or more maximum values. If multiple parameters input & multiple max values input, each max
;       value will correspond with each parameter (by array position). If multiple parameters & one max value,
;       the max value is used for all parameters. Cannot enter more max values than parameters.
;    
;    altitude: in, optional, type=fltarr(2)
;       Narrow down altitude bins to search within. Provide min/max as two item array. Only 
;       applicable if searching for a parameter that is binned by altitude (e.g. Periapse radiance values)
;    
;    range: in, optional, type=boolean
;       Print out orbit number for first and last element of input data structure.
;       
;    debug:  in, optional, type=boolean
;       On error, - "Stop immediately at the statement that caused the error and print
;       the current program stack." If not specified, error message will be printed and
;       IDL with return to main program level and stop.
;       
;    help: in, optional, type=boolean
;       Prints the keyword descriptions to the screen.
;       
;       
;       
;       
;    Note: When searching for common geometry values, if any observation mode during an orbit matches
;    the search criteria, that orbit will be considered a match. All observation modes are kept and 
;    stored in the iuvs_out data structure for that matching orbit, even if only one observation mode 
;    had the common geometry value match the criteria. To see which observation mode matched the common 
;    search, a new structure parameter is added at the top level of the iuvs_out data structure 'MATCHING_OBS' 
;    with a string containing which observation modes matched the common search criteria. If an observation 
;    is sepcified (using the observation keyword), any common gemoetry value is still searched across all 
;    observation modes - not just the observation mode that was specified. If you want to search for a 
;    common geometry value, only in a specific set of observation modes, then use mvn_kp_read, with 
;    /iuvs_[mode] keywords to read in only the IUVS observation modes you want to search. Then use this 
;    IUVS data structure, which only contains the observation modes you want to search, as the input to
;    mvn_kp_iuvs_search. 
;
;-


pro MVN_KP_IUVS_TAG_PARSER, kp_data, input_tag, common_tag, level1_index, observation=observation, $
                            species=species, index_species=index_species


  iuvs_data_info = MVN_KP_CONFIG(/IUVS_DATA)
  common_tags_num = iuvs_data_info.num_common
  all_tag_names = tag_names(kp_data.(0)[0])
  common_tag_names = all_tag_names[0:common_tags_num-1]
  
  
  ;; If observation keyword supplied, find an orbit with data for that observation. We use this information
  ;; later when searching.
  if keyword_set(observation) then begin
  
  
    ;; Find instance of obesrvation that doesn't contain blank string for time. From this we
    ;; will assume this observation has data
    obsIndex = -1
    for i=0L, n_elements(observation)-1 do begin
      if observation[i].time_start ne '' then begin
        ;; Use this observation (only need one for listing)
        obsIndex = i
        break
      endif
    endfor
    
    ;; If we didnt' find an observation that contained data, return     -----------FIXME TEST THIS
    if obsIndex lt 0 then begin
      print, "Can't proceed with search."
      print, "Couldn't find observation with data in input structure"
      level1_index = -1
      return
    endif
    
    observationSample = observation[obsIndex]
    obs_tag_names = tag_names(observation)
    
  endif
  

   ;; If input_tag is an INT
   if size(input_tag, /type) eq 2 then begin
   
      ;; If input_tag number falls within the common tags range
      if input_tag lt common_tags_num then begin
        level1_index = input_tag
        common_tag = 1 ;; Indicate common value
        return

      ;; Check if tag matches observation
      endif else begin
        if not keyword_set(observation) then begin 
          errorStr = "Not valid tag number. If searching for observation specific tag, "
          errorStr += "ensure you provide OBSERVATION keyword indicating which observation"
          message, errorStr
        endif


        
        level1_index = input_tag
        common_tag = 0
        if (input_tag ge n_tags(observationSample)) then message, "Tag number out of bounds or nto valid for observation."

        measure_tag_name = obs_tag_names[input_tag]

      endelse
    
    
    endif
    
    
   ;; IF input tag[i] is a STRING
   if size(input_tag, /type) eq 7 then begin
      input_tag = strupcase(input_tag)
    
      level1_index = where(common_tag_names eq input_tag, counter)
      
      if counter gt 0 then begin
        common_tag = 1 ;; Indicate common value
        return
      
      ;; Check if tag matches observation
      endif else begin
        
        if not keyword_set(observation) then begin
          errorStr = "Not valid tag. If searching for observation specific tag, "
          errorStr += "ensure you provide OBSERVATION keyword indicating which observation"
          message, errorStr
        endif
        
        input_tag = strupcase(input_tag)
        level1_index =  where(input_tag eq obs_tag_names, counter)
        common_tag = 0
        if counter ne 1 then message, "Not a valid tag tag: "+string(input_tag)
        
        measure_tag_name = input_tag
        
      endelse
           
   endif
   
   
   ;; Handle observation specific tags & species
   ;-------------------------------------------------------
   
   ;; Check species valid
   if keyword_set (species) then species = strupcase(strtrim(species,2))
   measure_tag_name = strupcase(strtrim(measure_tag_name,2))
   
   
   switch measure_tag_name of
     'SCALE_HEIGHT_ERR': 
     'SCALE_HEIGHT': begin
       if not keyword_set(species) then message, "Must specify a species to search"
       index_species   = where(observationSample.scale_height_id eq species)
       break
     end
     'DENSITY_ERR':
     'DENSITY': begin
       if not keyword_set(species) then message, "Must specify a species to search"
       index_species   = where(observationSample.density_id eq species)
       break
     end
     'RADIANCE_ERR':
     'RADIANCE': begin
       if not keyword_set(species) then message, "Must specify a species to search"
       index_species   = where(observationSample.radiance_id eq species)
       break
     END
     'HALF_INT_DISTANCE_ERR':
     'HALF_INT_DISTANCE': begin
       if not keyword_set(species) then message, "Must specify a species to search"
       index_species   = where(observationSample.half_int_distance_id eq species)
       break
     end
     'TEMPERATURE_ERR':
     'TEMPERATURE': begin
       if not keyword_set(species) then message, "Must specify a species to search"
       index_species = where(observationSample.temperature_id eq species)
       break
     end
     
     ;; The following measurements don't have species associated with them, they are scalars and we can
     ;; use the same logic below by just setting the index_species to 0 (which shall access the scalar)
     'OZONE_DEPTH_ERR':
     'OZONE_DEPTH': 
     'AURORAL_INDEX':
     'DUST_DEPTH_ERR':
     'DUST_DEPTH':
     'SZA_BP':
     'LOCAL_TIME_BP':
     'LON_BINS':
     'LAT_BINS': begin
       index_species = 0
       if keyword_set(species) then print, "Warning - species option entered but intput tag doens't expect species"
       break
     end
     
     else: message, "Tag not found/allowed: "+string(measure_tag_name)       ;; FIXME
      
   endswitch
   
   ;; If species not found
   if index_species lt 0 then message, "Invalid species for: "+measure_tag_name
   
   
end


pro MVN_KP_IUVS_TAG_LIST_COMMON, data

  iuvs_data_info = MVN_KP_CONFIG(/IUVS_DATA)
  common_tags_num = iuvs_data_info.num_common
  common_tags = tag_names(data.(0))
  

  print, 'Common geometry fields available for searching across all observations as follows'
  print,'*********************************************'
  print,''
  print,'-----------------------------'
  
  print, "Common Geometry Variables"
  for j=0, common_tags_num - 1 do begin
    print,'   #'+strtrim(string(j),2)+' '+strtrim(string(common_tags[j]) ,2)
  endfor
  print,'-----------------------------'
  
  
  print,'USE ANY OF THESE TAG NAMES, OR ASSOCIATED INDICES, TO SEARCH across OBSERVATIONS.'
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
  

  ;; FIXME --
  ;; Currently don't support searching on 3 common variables - spacecraft_geo, spacecraft_mso
  ;; and sun_geo. This is because these are 3 item arrays and break the mold for all other 
  ;; common searchs. Currently not sure how to best suupport this type of search
  if (tag_index eq 10) or (tag_index eq 11) or (tag_index eq 12) then begin
    message, "Error. Currently don't support searching IUVS on spacecraft_geo, spacecraft_mso, or sun_geo.
  endif
  
  
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

  ;; Search across all observations
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
    
      data_temp = create_struct(data[0], 'matching_obs', '')
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


function MVN_KP_IUVS_SEARCH_MEASUREMENTS, observation, observation_name, measureI, speciesID, min=min_value, max=max_value, altitude=altitude


    
   ;; Find instance of obesrvation that doesn't contain blank string for time. From this we
    ;; will assume this observation has data
    obsIndex = -1
    for i=0L, n_elements(observation)-1 do begin
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
  
  
  ;; Treat Apoapse special (Breaks the pattern of all other observations) 
  if observation_name ne 'APOAPSE' then begin
  
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
    
  
  
  endif else begin
    ;; APOAPSE OBSERVATION - Special logic to search here because data form is 
    ;; different than the rest of the observations
    
    obs_tag_names = tag_names(observation[obsIndex])
    measure_name = obs_tag_names[measureI]
    numOrbits = n_elements(observation)
    
    
    ;; RADIANCE OR RADIANCE ERR - search based on SPECIES ID 
    if measure_name eq 'RADIANCE' or measure_name eq 'RADIANCE_ERR' then begin
    
      ;; Loop through each orbit and search for criteria
      ;-----------------------------------------------------------
      meets_criteria_hack=[-1]
      for i = 0L, numOrbits-1 do begin
        where_results = where(observation[i].(measureI)[speciesID, *, *] ge min_value and $
          observation[i].(measureI)[speciesID, *, *] le max_value, counter)
          
        if (counter gt 0) then meets_criteria_hack = [meets_criteria_hack, i]
        
      endfor
      
      ;; Remove first element - idl 7 compatibility 
      if n_elements(meets_criteria_hack) gt 1 then begin
        meets_criteria=meets_criteria_hack[1:*]
      endif else begin
        meets_criteria=meets_criteria_hack
      endelse
    
    
    ;; Anything other than radiance
    endif else begin
      numDimMeasure = size(observation[obsIndex].(measureI), /N_DIMENSIONS)
      
      
      ;; Loop through each orbit and search for criteria
      ;-------------------------------------------------------
      ;
      
      ;; If one dimension
      if (numDimMeasure eq 1) then begin
      
        meets_criteria_hack=[-1]
        for i = 0L, numOrbits-1 do begin
          where_results = where(observation[i].(measureI)[*] ge min_value and $
            observation[i].(measureI)[*] le max_value, counter)
            
          if (counter gt 0) then meets_criteria_hack = [meets_criteria_hack, i]
          
        endfor
        
        ;; If two dimensions
      endif else if (numDimMeasure eq 2) then begin
      
        meets_criteria_hack=[-1]
        for i = 0L, numOrbits-1 do begin
          where_results = where(observation[i].(measureI)[*, *] ge min_value and $
            observation[i].(measureI)[*, *] le max_value, counter)
            
          if (counter gt 0) then meets_criteria_hack = [meets_criteria_hack, i]
          
        endfor
        
        
      endif else begin
        message, "Problem. found more than 2 dimensions for a search item in APOPASE other than periapse"
      endelse
      
      ;; Remove first element - idl 7 compatibility
      if n_elements(meets_criteria_hack) gt 1 then begin
        meets_criteria=meets_criteria_hack[1:*]
      endif else begin
        meets_criteria=meets_criteria_hack
      endelse
      
    endelse

  endelse 
  
  return, meets_criteria
end


pro MVN_KP_IUVS_SEARCH,  iuvs_in, iuvs_out, parameter=parameter, species=species, observation=observation, $
                          min=min_value, max=max_value, list=list, range=range, debug=debug, altitude=altitude, help=help
                          

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_iuvs_search'
;    print,'MVN_KP_IUVS_SEARCH'
;    print,'  Searches input iuvs KP data structure based on min and/or max search parameters.'
;    print,''
;    print,'mvn_kp_iuvs_search, iuvs_in, iuvs_out, parameter=parameter, species=species, observation=observation, $'
;    print,'                    min=min_value, max=max_value, list=list, range=range, debug=debug, altitude=altitude, help=help
;    print,''
;    print,'REQUIRED FIELDS'
;    print,'***************'
;    print,'  iuvs_in: iuvs KP data structure (data structure output from mvn_kp_read)'
;    print,'  iuvs_out: output KP data structure containing datat that met all search criteria'
;    print,''
;    print,'OPTIONAL FIELDS'
;    print,'***************'
;    print,'  parameter: Required if /list keyword not supplied. The name, or names, of the IUVS data parameter'
;    print,'       (or integer index) to search on. Use /list keyword to see possible names or index integers to search on.'
;    print,'  species:Specify a species to search. Only applicable if searching a parameter which has multiple species '
;    print,'          (CO2, CO, H, O, C, N, N2 for periapse scale_height)'
;    print,'  observation: Specify a specific observation to either list or search within.
;    print,'  list: List out possible parameters names to search (& index identifiers associated with parameters). No search performed.'
;    print,'        parameter: Required if /list keyword not supplied. The name, or names, of the INSITU data parameter'
;    print,'        (or integer index) to search on. Use /list keyword to see possible names or index integers to search on.'
;    print,'  min: the minimum value of the parameter to be searched on (or array of values).'
;    print,'       One or more minimum values. If multiple parameters input & multiple min values input, each min'
;    print,'       value will correspond with each parameter (by array position). If multiple parameters & one min value,'
;    print,'       the min value is used for all parameters. Cannot enter more min values than parameters.'
;    print,'  max: the maximum value of the parameter to be searced on (or array of values)'
;    print,'       One or more maximum values. If multiple parameters input & multiple max values input, each max'
;    print,'       value will correspond with each parameter (by array position). If multiple parameters & one max value,'
;    print,'       the max value is used for all parameters. Cannot enter more max values than parameters.'
;    print,'  range: Print out TIME_STRING for first and last element of input data structure. Also prints corresponding orbit numbers.'
;    print,'  debug: On error, - "Stop immediately at the statement that caused the error and print'
;    print,'         the current program stack." If not specified, error message will be printed and'
;    print,'         IDL with return to main program level and stop.'
;    print,'  altitude: Narrow down altitude bins to search within. Provide min/max as two item array. Only '
;    print,'            applicable if searching for a parameter that is binned by altitude (e.g. Periapse radiance values)'
;    print,'  help: Invoke this list.'
    return
  endif                          

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
    
    observation_name = strupcase(strtrim(observation,2))
    observation_tags = tag_names(iuvs_in)
   
    
    case observation_name of
      'PERIAPSE': begin
        kp_data_obs = iuvs_in.periapse
        kp_data_obs_index = where(observation_tags eq 'PERIAPSE',  counter)
        kp_data_str = "Periapse"
      end
      'CORONAECHELLEHIGH': begin
        kp_data_obs = iuvs_in.corona_e_high
        kp_data_obs_index = where(observation_tags eq 'CORONA_E_HIGH',  counter)
        kp_data_str = "Corona Echelle High"
      end
      'CORONAECHELLELIMB': begin
        kp_data_obs = iuvs_in.corona_e_limb
        kp_data_obs_index = where(observation_tags eq 'CORONA_E_LIMB',  counter)
        kp_data_str = "Corona Echelle Limb"
      end
      'CORONAECHELLEDISK': begin
        kp_data_obs = iuvs_in.corona_e_disk
        kp_data_obs_index = where(observation_tags eq 'CORONA_E_DISK',  counter)
        kp_data_str = "Corona Echelle Disk"
      end
      'CORONALORESHIGH': begin
        kp_data_obs = iuvs_in.corona_lo_high
        kp_data_obs_index = where(observation_tags eq 'CORONA_LO_HIGH',  counter)
        kp_data_str = "Corona Lores High"
      end
      'CORONALORESLIMB': begin
         kp_data_obs = iuvs_in.corona_lo_limb
         kp_data_obs_index = where(observation_tags eq 'CORONA_LO_LIMB',  counter)
         kp_data_str = "Corona Lores Limb"
      end
      'CORONALORESDISK': begin
        kp_data_obs = iuvs_in.corona_lo_disk
        kp_data_obs_index = where(observation_tags eq 'CORONA_LO_DISK',  counter)
        kp_data_str = "Corona Lores Disk"
      end
      'APOAPSE': begin
         kp_data_obs = iuvs_in.apoapse
         kp_data_obs_index = where(observation_tags eq 'APOAPSE',  counter)
         kp_data_str = "Apoapse"
      end
      'STELLAROCC' : begin
         kp_data_obs = iuvs_in.stellarocc
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
    
    MVN_KP_IUVS_TAG_LIST_COMMON, iuvs_in
       
    if keyword_set(observation) then begin
      MVN_KP_IUVS_TAG_LIST_MODE, kp_data_obs, kp_data_str
    endif 
    
    if keyword_set(parameter) or keyword_set(species) or keyword_set(min) or $
       keyword_set(max) or keyword_set(min) or keyword_set(max) then begin
        print, "NOTE: /LIST keyword entered. No searching done when /LIST keyword present, only a listing of variables to search on"
    end
    
  endif
  

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, iuvs_in
  endif
  
  ;; If either list or range specified, return (no actual seraching done).
  if keyword_set(list) or keyword_set(range) then begin
    return
  endif
 
  ;; Only proceed if parameter specified
  if not keyword_set(parameter) then begin
    message, "Must input parameter to search"
  endif
  

  ;IF THE MINIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE -INFINITY
  if keyword_set(min_value) eq 0 then begin             
    if size(parameter,/dimensions) eq 0 then begin
      min_value = -!values.f_infinity
    endif else begin
      min_value = fltarr(n_elements(parameter))
      min_value[*] = -!values.f_infinity
    endelse
  endif

  ;IF THE MAXIMUM VALUE KEYWORD IS NOT SET, THEN ASSUME IT TO BE INFINITY
  if keyword_set(max_value) eq 0 then begin            
    if size(parameter,/dimensions) eq 0 then begin
      max_value = !values.f_infinity
    endif else begin
      max_value = fltarr(n_elements(parameter))
      max_value[*] = !values.f_infinity
    endelse
  endif
  
  ;; If multiple parameters input, check that correct number of min/max values present. If multiple parameters
  ;; and only one min and/or max, use that min/max for all parameters. If the number doesn't match
  ;; error out - don't know how to interpret that.
  if (n_elements(parameter) ne n_elements(min_value)) then begin
    if(n_elements(min_value) eq 1) then begin
      min_value = make_array(n_elements(parameter), value=min_value)
    endif else begin
      message, "If input multiple parameters, number of minimum values input must be either 1 or equal to number of parameters"
    endelse
  endif
  
  if (n_elements(parameter) ne n_elements(max_value)) then begin
    if(n_elements(max_value) eq 1) then begin
      max_value = make_array(n_elements(parameter), value=max_value)
    endif else begin
      message, "If input multiple parameters, number of maximum values input must be either 1 or equal to number of parameters"
    endelse
  endif


  ;; Loop through all input parameters and search for each
  meets_criteria = [-1]
  kp_data_temp = iuvs_in
  
  for i=0, n_elements(parameter)-1 do begin

    ;; Find out if common parameter and level1 index if applicable
    mvn_kp_iuvs_tag_parser, iuvs_in, parameter[i], common_tag, level1_index, observation = kp_data_obs, species=species, index_species=index_species
    
    ;; If common value/parameter
    if common_tag then begin
      meets_criteria = MVN_KP_IUVS_SEARCH_COMMON(kp_data_temp, level1_index, min_value[i], max_value[i])
    
      ;; If there were no matches, break out now with no results
      if meets_criteria[0] eq -1 then begin
        kp_data_temp = -1
        break 
       endif
    
    ;; Observation specific search
    endif else begin
      
      if not keyword_set(observation) then message, "If searching observation specific parameter, must specify which observation"
      meets_criteria = MVN_KP_IUVS_SEARCH_MEASUREMENTS(kp_data_temp.(kp_data_obs_index[0]), observation_name, level1_index, index_species, min=min_value[i], max=max_value[i], altitude=altitude)
      
      
      
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
 
  ;; If kp_data_temp is not an integer (-1 from search) then there are results.
  if size(kp_data_temp, /type) ne 2 then begin
    iuvs_out = kp_data_temp
    
    ;; Fill output structure with matches
    print, "Total matching records: "+string(n_elements(iuvs_out))
  endif else begin
  
    ;; If no matches, return 0 iuvs_outout
    print, "No records match input range"
    iuvs_out = 0
  endelse
  
  
  
  ; UNSET DEBUG ENV VARIABLE
  setenv, 'MVNTOOLKIT_DEBUG='
  
  
end

  
  
  
