;+
;
; :Name: mvn_kp_bin
; 
; :Description: 
;   This routine will rebin a Key Parameter from the input array in up to eight dimensions. 
;
; :Params:
;    kp_data: in, required, type=structure  
;       The insitu MAVEN KP data structure
;    to_bin: in, required, can be a single integer or string
;       The Key Parameter which will be binned 
;    bin_by: in, required, can be a single integer, string, or arrays or either.
;       Up to eight key parameter indices or names by which to bin the requested key parameter
;    mins: in, optional, type = dblarr
;       Optional minimum values for each of the binning dimensions
;    maxs: in, optional, type=dblarr
;       Optional maximum values for each of the binning dimensions
;    binsize: in, optional, type=dblarr
;       Optional array defining the binsize to use for each of the binning dimensions
;    output: out, required, type=dblarr
;       The requested Key Parameter binned in the desired dimensions. By default, this is the the number of data points within each bin.
;    std_out: out, optional, type=dblarr
;       Output array containing the standard deviation of the binned key parameter in each bin. 
;    avg_out: out, optional, type=dblarr
;       Output array containing the average value of the binned key parameter in each bin
;    density: in, optional, type=dblarr
;       An output array containing the 'density' of the binned parameter    
;
; :Keywords:
;    std: in, optional, type=boolean
;       With this keyword, the routine will calculate the standard deviation within each bin and return in in std_out 
;    list: in, optional, type=boolean or dblarr
;       Used to print out the contents of the input data structure.
;           If set as a keyword, /list, this is printed to the screen.
;           If set as a variable, list=list, a string array is returned containing the structure index and tag names.
;           
; :Version:   0.9     July 8, 2014
;    
;-
pro mvn_kp_bin, kp_data, to_bin, bin_by, output, std_out, binsize=binsize, list=list, avg_out=avg_out, mins=mins, maxs=maxs,  $
                std = std, density=density, help=help

  if keyword_set(help) then begin
    print,'MVN_KP_BIN'
    print,'  This routine will rebin a Key Parameter from the input array in up to eight dimensions. 
    print,''
    print,'mvn_kp_bin, kp_data, to_bin, bin_by, output, std_out, binsize=binsize, list=list, avg_out=avg_out, mins=mins, maxs=maxs,  $
    print,'            std = std, density=density, help=help
    print,''
    print,'REQUIRED FIELDS'
    print,'**************'
    print,'  kp_data: In-situ Key Parameter Data Structure'
    print,'  to_bin: The Key Parameter which will be binned '
    print,'  bin_by: Up to eight key parameter indices or names by which to bin the requested key parameter'
    print,'  output: The requested Key Parameter binned in the desired dimensions. By default, this is the the number of data points within each bin.'
    print,'  std_out:
    print,''
    print,'OPTIONAL FIELDS'
    print,'***************'
    print,'    mins: Optional minimum values for each of the binning dimensions'
    print,'    maxs:  Optional maximum values for each of the binning dimensions'
    print,'    binsize: Optional array defining the binsize to use for each of the binning dimensions'
    print,'    output: The requested Key Parameter binned in the desired dimensions. By default, this is the the number of data points within each bin.'
    print,'    std_out: Output array containing the standard deviation of the binned key parameter in each bin. '
    print,'    avg_out: Output array containing the average value of the binned key parameter in each bin'
    print,'    density:  An output array containing the density of the binned parameter   '
    print,'    std: With this keyword, the routine will calculate the standard deviation within each bin and return in in std_out '
    print,'    list: Used to print out the contents of the input data structure.'
    print,'    help: Invoke this list.'
    return
  endif





  ;CHECK THAT ALL INPUT FIELDS MATCH IN SIZE (fields ,BINS,)
  
  if keyword_set(binsize) then begin
    if n_elements(bin_by) ne n_elements(binsize) then begin
      print,'The number of fields fields and BINNING fields do not match.'
      return
    endif
  endif


  ;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags

  ;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET
    if arg_present(list)  then begin  
      list = strarr(250)
      index2=0
      for i=0,base_tag_count-1 do begin
          if first_level_count[i] ne 0 then begin
              for j=0,first_level_count[i]-1 do begin
                if first_level_count[i] ne 0 then begin 
                    list[index2] = '#'+strtrim(string(index2+1),2)+' '+base_tags[i]+'.'+strtrim(string(first_level_tags[index2-1]),2)
                    index2 = index2+1
                endif 
              endfor
          endif
        endfor
      list = list[0:index2-1]
      return
    endif else begin
      if keyword_set(list) then begin
        MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
        return
      endif
    endelse
  
  
  total_fields = n_elements(bin_by)
  level0_index = intarr(total_fields)
  level1_index = intarr(total_fields)
  
  for i=0, total_fields-1 do begin
    mvn_kp_tag_verify, kp_data, bin_by[i], base_tag_count, first_level_count,base_tags,$
                       first_level_tags, check, l0, l1, tag_array
    level0_index[i] = l0
    level1_index[i] = l1
    if check eq -1 then begin
      print,'Requested bin parameter '+strtrim(string(bin_by[i]),2)+' is not included in the data structure.'
      print,'Use the /LIST flag to check your structure for valid parameter names.'
      return
    endif
  endfor

  if keyword_set(mins) ne 1 then begin
    mins = dblarr(total_fields)
    for i=0,total_fields-1 do begin
      mins[i] = min(kp_data.(level0_index[i]).(level1_index[i]))
    endfor
  endif else begin
    if n_elements(mins) ne total_fields then begin
      print,'The minimum value array must have the same number of elements as the bin array'
      return
    endif
  endelse

  if keyword_set(maxs) ne 1 then begin
    maxs = dblarr(total_fields)
    for i=0, total_fields-1 do begin
      maxs[i] = max(kp_data.(level0_index[i]).(level1_index[i]))
    endfor
  endif else begin
    if n_elements(maxs) ne total_fields then begin
      print,'The maximum value array must have the same number of elements as the bin array'
      return
    endif
  endelse
  
  ranges = dblarr(total_fields)
  total_bins = intarr(total_fields)
  
  for i=0, total_fields -1 do begin
    ranges[i] = maxs[i] - mins[i]
    total_bins[i] = ceil(ranges[i]/binsize[i])
  endfor
  
      mvn_kp_tag_verify, kp_data, to_bin, base_tag_count, first_level_count,base_tags,$
                       first_level_tags, check, input_level0, input_level1, tag_array
  
  
  ;BIN THE INPUT DATA ACCORDING TO THE VARIOUS FIELDS
  
      
      output = make_array(total_bins+1,/double)
      density = make_array(total_bins+1,/double)
      index = intarr(total_fields+1)
      
      for i=0, n_elements(kp_data) -1 do begin
        for j=0, total_fields-1 do begin
          data_value = kp_data[i].(level0_index[j]).(level1_index[j])
          dv = floor((data_value - mins[j])/binsize[j])
          index[j] = dv
        
        endfor                                                ;end of the bin loop
        
        case total_fields of 
          1: begin
              output[index[0]] = output[index[0]] + kp_data[i].(input_level0).(input_level1)
              density[index[0]] = density[index[0]] + 1
             end
          2: begin
              output[index[0],index[1]] = output[index[0],index[1]] + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1]] = density[index[0],index[1]] + 1
             end
          3: begin
              output[index[0],index[1],index[2]] = output[index[0],index[1],index[2]] + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2]] = density[index[0],index[1],index[2]] + 1
             end
          4: begin
              output[index[0],index[1],index[2],index[3]] = output[index[0],index[1],index[2],index[3]] + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3]] = density[index[0],index[1],index[2],index[3]] + 1
             end
          5: begin
              output[index[0],index[1],index[2],index[3],index[4]] = output[index[0],index[1],index[2],index[3],index[4]] + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3],index[4]] = density[index[0],index[1],index[2],index[3],index[4]] + 1
             end
          6: begin
              output[index[0],index[1],index[2],index[3],index[4],index[5]] = output[index[0],index[1],index[2],index[3],index[4],index[5]] + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3],index[4],index[5]] = density[index[0],index[1],index[2],index[3],index[4],index[5]] + 1
             end
          7: begin
              output[index[0],index[1],index[2],index[3],index[4],index[5],index[6]] = output[index[0],index[1],index[2],index[3],index[4],index[5],index[6]] + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3],index[4],index[5],index[6]] = density[index[0],index[1],index[2],index[3],index[4],index[5],index[6]] + 1
             end
          8: begin
              output[index[0],index[1],index[2],index[3],index[4],index[5],index[6],index[7]] = output[index[0],index[1],index[2],index[3],index[4],index[5],index[6],index[7]] + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3],index[4],index[5],index[6],index[7]] = density[index[0],index[1],index[2],index[3],index[4],index[5],index[6],index[7]] + 1
             end
        endcase
      endfor                                                  ;end of the data loop
      
   ;CALCULATE THE MEDIAN VALUES AND STANDARD DEVIATIONS
   
   
   if keyword_set(avg_out) then begin
          average_out= output/density
   endif
  
  ;REDO FOR STANDARD DEVIATION CALCULATION
  
  if keyword_set(std) then begin
    if keyword_set(avg_out) ne 1 then begin
      average_out= output/density
    endif
    std_out = make_array(total_bins,/double)
    for i=0, n_elements(kp_data) -1 do begin
     for j=0, total_fields-1 do begin
       data_value = kp_data[i].(level0_index[j]).(level1_index[j])
       dv = floor((data_value - mins[j])/binsize[j])
       index[j] = dv
        
     endfor    
  
        case total_fields of 
          1: begin
              std_out[index[0]] = std_out[index[0]] + (kp_data[i].(input_level0).(input_level1) - average_out[index[0]])^2
             end
          2: begin
              std_out[index[0],index[1]] = std_out[index[0],index[1]] + (kp_data[i].(input_level0).(input_level1) - average_out[index[0],index[1]])^2
             end
          3: begin
              std_out[index[0],index[1],index[2]] = std_out[index[0],index[1],index[2]] + (kp_data[i].(input_level0).(input_level1) - $
                                                    average_out[index[0],index[1],index[2]])^2
             end
          4: begin
              std_out[index[0],index[1],index[2],index[3]] = std_out[index[0],index[1],index[2],index[3]] + (kp_data[i].(input_level0).(input_level1) - $
                                                    average_out[index[0],index[1],index[2],index[3]])^2
             end
          5: begin
              std_out[index[0],index[1],index[2],index[3],index[4]] = std_out[index[0],index[1],index[2],index[3],index[4]] + (kp_data[i].(input_level0).(input_level1) - $
                                                    average_out[index[0],index[1],index[2],index[3],index[4]])^2
             end
          6: begin
              std_out[index[0],index[1],index[2],index[3],index[4],index[5]] = std_out[index[0],index[1],index[2],index[3],index[4],index[5]] + (kp_data[i].(input_level0).(input_level1) - $
                                                    average_out[index[0],index[1],index[2],index[3],index[4],index[5]])^2
             end
          7: begin
              std_out[index[0],index[1],index[2],index[3],index[4],index[5],index[6]] = std_out[index[0],index[1],index[2],index[3],index[4],index[5],index[6]] + (kp_data[i].(input_level0).(input_level1) - $
                                                    average_out[index[0],index[1],index[2],index[3],index[4],index[5],index[6]])^2
             end
          8: begin
              std_out[index[0],index[1],index[2],index[3],index[4],index[5],index[6],index[7]] = std_out[index[0],index[1],index[2],index[3],index[4],index[5],index[6],index[7]] + (kp_data[i].(input_level0).(input_level1) - $
                                                    average_out[index[0],index[1],index[2],index[3],index[4],index[5],index[6],index[7]])^2
             end
        endcase
  
  
    endfor
       
       std_out = sqrt(std_out/density)
        
  endif
  
  




end