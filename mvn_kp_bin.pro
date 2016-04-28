;+
;
; :Name: mvn_kp_bin
; 
; :Description: 
;   This routine will rebin a Key Parameter from the input array in up 
;   to eight dimensions. 
;
; :Params:
;    kp_data: in, required, type=structure  
;       The insitu MAVEN KP data structure
;    to_bin: in, required, can be a single integer or string
;       The Key Parameter which will be binned 
;    bin_by: in, required, can be any of a single integer, string, or arrays.
;       Up to eight key parameter indices or names by which to bin the 
;       requested key parameter
;    mins: in, optional, type = dblarr
;       Optional minimum values for each of the binning dimensions
;    maxs: in, optional, type=dblarr
;       Optional maximum values for each of the binning dimensions
;    binsize: in, optional, type=dblarr
;       Optional array defining the binsize to use for each of the binning 
;       dimensions
;    output: out, required, type=dblarr
;       The requested Key Parameter binned in the desired dimensions. 
;       By default, this is the the number of data points within each bin.
;    std_out: out, optional, type=dblarr
;       Output array containing the standard deviation of the binned key 
;       parameter in each bin. 
;    avg_out: out, optional, type=dblarr
;       Output array containing the average value of the binned key 
;       parameter in each bin
;    density: in, optional, type=dblarr
;       An output array containing the 'density' of the binned parameter    
;    median: out, optional, type=dblarr
;       An output array containing the median value of each bin
;
; :Keywords:
;    std: in, optional, type=boolean
;       With this keyword, the routine will calculate the standard 
;       deviation within each bin and return in in std_out 
;    list: in, optional, type=boolean or dblarr
;       Used to print out the contents of the input data structure.
;           If set as a keyword, /list, this is printed to the screen.
;           If set as a variable, list=list, a string array is returned 
;           containing the structure index and tag names.
;           
; :Version:   0.9     July 8, 2014
; :Version:   1.0     Sept 15, 2014
;    
;-
pro mvn_kp_bin, kp_data, to_bin, bin_by, output, std_out, binsize=binsize, $
                list=list, avg_out=avg_out, mins=mins, maxs=maxs,  $
                std = std, density=density, help=help, median=median

  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_bin'
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
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, $
                     second_level_count, base_tags,  first_level_tags, $
                     second_level_tags

  ;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET
    if arg_present(list)  then begin  
      list = strarr(250)
      index2=0
      for i=0,base_tag_count-1 do begin
          if first_level_count[i] ne 0 then begin
              for j=0,first_level_count[i]-1 do begin
                if first_level_count[i] ne 0 then begin 
                    list[index2] = '#' + strtrim(string(index2+1),2) + ' ' $
                            + base_tags[i] + '.' $
                            + strtrim(string(first_level_tags[index2-1]),2)
                    index2 = index2+1
                endif 
              endfor
          endif
        endfor
      list = list[0:index2-1]
      return
    endif else begin
      if keyword_set(list) then begin
        MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, $
                         base_tags,  first_level_tags
        return
      endif
    endelse
  
  
  total_fields = n_elements(bin_by)
  level0_index = intarr(total_fields)
  level1_index = intarr(total_fields)
  
  for i=0, total_fields-1 do begin
    mvn_kp_tag_verify, kp_data, bin_by[i], base_tag_count, $
                       first_level_count,base_tags,$
                       first_level_tags, check, l0, l1, tag_array
    level0_index[i] = l0
    level1_index[i] = l1
    if check eq -1 then begin
      print,'Requested bin parameter '+strtrim(string(bin_by[i]),2) $
            +' is not included in the data structure.'
      print,'Use the /LIST flag to check your structure for ' $
            +'valid parameter names.'
      return
    endif
  endfor

  if keyword_set(mins) ne 1 then begin
    mins = dblarr(total_fields)
    mins[where(mins eq 0)] = !Values.F_NAN
    for i=0,total_fields-1 do begin
      mins[i] = min(kp_data.(level0_index[i]).(level1_index[i]), /NAN)
    endfor
  endif else begin
    if n_elements(mins) ne total_fields then begin
      print,'The minimum value array must have the same number of elements ' $
            +'as the bin array'
      return
    endif
  endelse

  if keyword_set(maxs) ne 1 then begin
    maxs = dblarr(total_fields)
    maxs[where(maxs eq 0)] = !Values.F_NAN
    for i=0, total_fields-1 do begin
      maxs[i] = max(kp_data.(level0_index[i]).(level1_index[i]), /NAN)
    endfor
  endif else begin
    if n_elements(maxs) ne total_fields then begin
      print,'The maximum value array must have the same number of elements ' $
            +'as the bin array'
      return
    endif
  endelse
  
  ranges = dblarr(total_fields)
  ranges[where(ranges eq 0)] = !Values.F_NAN
  total_bins = intarr(total_fields)
  total_bins[where(total_bins eq 0)] = !Values.F_NAN
  
  for i=0, total_fields -1 do begin
    ranges[i] = maxs[i] - mins[i]
    if ranges[i] lt 0 then begin
      print, "ERROR: Minimum value of " + string(mins[i]) + " is greater than the maximum value of " + string(maxs[i])
      print, "for bin-by parameter " + bin_by[i] + ".  Returning..."
      return
    endif
    total_bins[i] = ceil(ranges[i]/binsize[i])
  endfor
  
      mvn_kp_tag_verify, kp_data, to_bin, base_tag_count, $
                         first_level_count,base_tags,$
                         first_level_tags, check, input_level0, $
                         input_level1, tag_array
  
  ;BIN THE INPUT DATA ACCORDING TO THE VARIOUS FIELDS
      
      output = make_array(total_bins,/double)
      density = make_array(total_bins,/double)
      index = intarr(total_fields)
      index[where(index eq 0)] = !Values.F_NAN
      
      for i=0, n_elements(kp_data) -1 do begin
        bad_data_value = 0
        if ~finite(kp_data[i].(input_level0).(input_level1)) then begin
          continue
        endif
        for j=0, total_fields-1 do begin
          data_value = kp_data[i].(level0_index[j]).(level1_index[j])
          if ~finite(data_value) or data_value lt mins[j] or data_value gt maxs[j] then begin
            bad_data_value = 1
            continue
          endif
          dv = floor((data_value - mins[j])/binsize[j])
          index[j] = dv
        
        endfor ;end of the bin loop
        
        if bad_data_value then begin
          continue
        endif
        
        case total_fields of 
          1: begin
              output[index[0]] = output[index[0]] $
                               + kp_data[i].(input_level0).(input_level1)
              density[index[0]] = density[index[0]] + 1
             end
          2: begin
              output[index[0],index[1]] $
                = output[index[0],index[1]] $
                + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1]] = density[index[0],index[1]] + 1
             end
          3: begin
              output[index[0],index[1],index[2]] $
                = output[index[0],index[1],index[2]] $
                + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2]] $
                = density[index[0],index[1],index[2]] + 1
             end
          4: begin
              output[index[0],index[1],index[2],index[3]] $
                = output[index[0],index[1],index[2],index[3]] $
                + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3]] $
                = density[index[0],index[1],index[2],index[3]] + 1
             end
          5: begin
              output[index[0],index[1],index[2],index[3],index[4]] $
                = output[index[0],index[1],index[2],index[3],index[4]] $
                + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3],index[4]] $
                = density[index[0],index[1],index[2],index[3],index[4]] + 1
             end
          6: begin
              output[index[0],index[1],index[2],index[3],index[4],index[5]] $
                = output[index[0],index[1],index[2],index[3],index[4],index[5]] $
                + kp_data[i].(input_level0).(input_level1)
              density[index[0],index[1],index[2],index[3],index[4],index[5]] $
                = density[index[0],index[1],index[2],index[3],index[4],index[5]] + 1
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
      endfor  ;end of the data loop
     
   ;Set the total to NAN in places where we have no data, 
   ;because we can't say it is zero since zero could be an
   ;actual result  
   output[where(density eq 0)] = !Values.F_NAN
   
   
   ;CALCULATE THE MEDIAN VALUES AND STANDARD DEVIATIONS
   
   if arg_present(median) eq 1 then begin   
    
      bin_min = dblarr(n_elements(total_bins), max(total_bins, /NAN))
      bin_min[where(bin_min eq 0)] = !Values.F_NAN
      bin_max = dblarr(n_elements(total_bins), max(total_bins, /NAN))
      bin_max[where(bin_max eq 0)] = !Values.F_NAN
      
      if keyword_set(mins) eq 0 then begin
        mins = dblarr(n_elements(bin_by))
        mins[where(mins eq 0)] = !Values.F_NAN
        for i=0, n_elements(bin_by)-1 do begin
          mins[i] = min(kp_data.(level0_index[i]).(level1_index[i]), /nan)
        endfor
      endif 
    
      if keyword_set(maxs) eq 0 then begin
        maxs = dblarr(n_elements(bin_by))
        maxs[where(maxs eq 0)] = !Values.F_NAN
        for i=0, n_elements(bin_by)-1 do begin
          maxs[i] = max(kp_data.(level0_index[i]).(level1_index[i]), /nan)
        endfor
      endif
    
      for i=0,n_elements(total_bins)-1 do begin
       for j=0, total_bins[i] -1 do begin
        bin_min[i,j] = mins[i] + (binsize[i] * j)
        
       endfor
      endfor
   
      bin_index = fltarr(n_elements(bin_by), n_elements(kp_data))
      bin_index[where(bin_index eq 0)] = !Values.F_NAN
   
      for i=0, n_elements(kp_data) - 1 do begin
        bad_data_value=0
        for j=0, n_elements(total_bins) -1 do begin
          value = kp_data[i].(level0_index[j]).(level1_index[j])
          if ~finite(value) or value lt mins[j] or value gt maxs[j] then begin
            bad_data_value = 1
            continue
          endif
          temp_min = max(where(value-bin_min[j,*] ge 0.0),temp_min_index, /NAN)
          bin_index[j,i] = temp_min_index
        endfor
        if bad_data_value eq 1 then begin
          continue
        endif
      endfor
   
      medians = make_array(total_bins, /double) 
      medians[where(medians eq 0)] = !Values.F_NAN
      
     case n_elements(bin_by) of 
      1: begin
          for i=0, total_bins[0] -1 do begin
          print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2) $
                +'% complete'
          temp = where((bin_index[0,*] eq i))
            if temp[0] ne -1 then begin
              if n_elements(temp) gt 1 then begin
                medians[i] $
                  = median(kp_data[temp].(input_level0).(input_level1),/double)
              endif else begin
                medians[i] = kp_data[temp[0]].(input_level0).(input_level1)
              endelse
            endif
         endfor
         end
      2: begin
         for i=0, total_bins[0]-1 do begin
          print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2)$
                +'% complete'
          for j=0, total_bins[1] -1 do begin
            temp = where((bin_index[0,*] eq i) and (bin_index[1,*] eq j))
            if temp[0] ne -1 then begin
              if n_elements(temp) gt 1 then begin
                medians[i,j] $
                  = median(kp_data[temp].(input_level0).(input_level1),/double)
              endif else begin
                medians[i,j] = kp_data[temp[0]].(input_level0).(input_level1)
              endelse
            endif
          endfor
         endfor
         end
      3: begin
          print,'The binning rountine is currently not that efficient. 
          for i=0, total_bins[0]-1 do begin
            print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2)+'% complete'
            for j=0, total_bins[1] -1 do begin
             for k=0, total_bins[2] -1 do begin
              temp = where((bin_index[0,*] eq i) and (bin_index[1,*] eq j) and (bin_index[2,*] eq k))
              if temp[0] ne -1 then begin
                if n_elements(temp) gt 1 then begin
                  medians[i,j,k] = median(kp_data[temp].(input_level0).(input_level1),/double)
                endif else begin
                  medians[i,j,k] = kp_data[temp[0]].(input_level0).(input_level1)
                endelse
              endif
             endfor
            endfor
           endfor
         end
      4: begin
        print,'Due to the inefficient nature of this routine, it might take a while. Bear with us and complain to Kris.'    
         for i=0, total_bins[0]-1 do begin
          print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2)+'% complete'
          for j=0, total_bins[1] -1 do begin
           for k=0, total_bins[2] -1 do begin
            for l=0, total_bins[3] -1 do begin
              temp = where((bin_index[0,*] eq i) and (bin_index[1,*] eq j) and (bin_index[2,*] eq k) and (bin_index[3,*] eq l))
              if temp[0] ne -1 then begin
                if n_elements(temp) gt 1 then begin
                  medians[i,j,k,l] = median(kp_data[temp].(input_level0).(input_level1),/double)
                endif else begin
                  medians[i,j,k,l] = kp_data[temp[0]].(input_level0).(input_level1)
                endelse
              endif
            endfor
           endfor
          endfor
         endfor
        end
       5: begin
             print,'Due to the inefficient nature of this routine, it might take a while. Bear with us and complain to Kris.'    
             for i=0, total_bins[0]-1 do begin
              print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2)+'% complete'
              for j=0, total_bins[1] -1 do begin
               for k=0, total_bins[2] -1 do begin
                for l=0, total_bins[3] -1 do begin
                  for m=0, total_bins[4] - 1 do begin
                    temp = where((bin_index[0,*] eq i) and (bin_index[1,*] eq j) and (bin_index[2,*] eq k) and (bin_index[3,*] eq l) and (bin_index[4,*] eq m))
                    if temp[0] ne -1 then begin
                      if n_elements(temp) gt 1 then begin
                        medians[i,j,k,l,m] = median(kp_data[temp].(input_level0).(input_level1),/double)
                      endif else begin
                        medians[i,j,k,l,m] = kp_data[temp[0]].(input_level0).(input_level1)
                      endelse
                    endif
                   endfor 
                endfor
               endfor
              endfor
             endfor
          end
          
       6: begin
             print,'Due to the inefficient nature of this routine, it might take a while. Bear with us and complain to Kris.'    
             for i=0, total_bins[0]-1 do begin
              print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2)+'% complete'
              for j=0, total_bins[1] -1 do begin
               for k=0, total_bins[2] -1 do begin
                for l=0, total_bins[3] -1 do begin
                  for m=0, total_bins[4] - 1 do begin
                    for n=0, total_bins[5] - 1 do begin
                      temp = where((bin_index[0,*] eq i) and (bin_index[1,*] eq j) and (bin_index[2,*] eq k) and (bin_index[3,*] eq l) and (bin_index[4,*] eq m) and (bin_index[5,*] eq n))
                      if temp[0] ne -1 then begin
                        if n_elements(temp) gt 1 then begin
                          medians[i,j,k,l,m,n] = median(kp_data[temp].(input_level0).(input_level1),/double)
                        endif else begin
                          medians[i,j,k,l,m,n] = kp_data[temp[0]].(input_level0).(input_level1)
                        endelse
                      endif
                    endfor  
                   endfor 
                endfor
               endfor
              endfor
             endfor
          end
          
       7: begin
          print,'Due to the inefficient nature of this routine, it might take a while. Bear with us and complain to Kris.'    
             for i=0, total_bins[0]-1 do begin
              print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2)+'% complete'
              for j=0, total_bins[1] -1 do begin
               for k=0, total_bins[2] -1 do begin
                for l=0, total_bins[3] -1 do begin
                  for m=0, total_bins[4] - 1 do begin
                    for n=0, total_bins[5] - 1 do begin
                     for p=0, total_bins[6] -1 do begin 
                        temp = where((bin_index[0,*] eq i) and (bin_index[1,*] eq j) and (bin_index[2,*] eq k) and (bin_index[3,*] eq l) and (bin_index[4,*] eq m) and (bin_index[5,*] eq n) and (bin_index[6,*] eq p))
                        if temp[0] ne -1 then begin
                          if n_elements(temp) gt 1 then begin
                            medians[i,j,k,l,m,n,p] = median(kp_data[temp].(input_level0).(input_level1),/double)
                          endif else begin
                            medians[i,j,k,l,m,n,p] = kp_data[temp[0]].(input_level0).(input_level1)
                          endelse
                        endif
                      endfor  
                    endfor  
                   endfor 
                endfor
               endfor
              endfor
             endfor
          end
          
       8: begin
          print,'Due to the inefficient nature of this routine, it might take a while. Bear with us and complain to Kris.'    
             for i=0, total_bins[0]-1 do begin
              print,'Now '+strtrim(string(float(i)/(total_bins[0]-1)*100.0 ),2)+'% complete'
              for j=0, total_bins[1] -1 do begin
               for k=0, total_bins[2] -1 do begin
                for l=0, total_bins[3] -1 do begin
                  for m=0, total_bins[4] - 1 do begin
                    for n=0, total_bins[5] - 1 do begin
                     for p=0, total_bins[6] -1 do begin 
                      for q=0, total_bins[7] -1 do begin
                          temp = where((bin_index[0,*] eq i) and (bin_index[1,*] eq j) and (bin_index[2,*] eq k) and (bin_index[3,*] eq l) and (bin_index[4,*] eq m) and (bin_index[5,*] eq n) and (bin_index[6,*] eq p) and (bin_index[7,*] eq q))
                          if temp[0] ne -1 then begin
                            if n_elements(temp) gt 1 then begin
                              medians[i,j,k,l,m,n,p,q] = median(kp_data[temp].(input_level0).(input_level1),/double)
                            endif else begin
                              medians[i,j,k,l,m,n,p,q] = kp_data[temp[0]].(input_level0).(input_level1)
                            endelse
                          endif
                        endfor  
                      endfor  
                    endfor  
                   endfor 
                endfor
               endfor
              endfor
             endfor        
          end
        
        
     endcase
    median = medians
   endif 
    
   if arg_present(avg_out) then begin
          average_out= output/density
          avg_out = average_out ; hack for now to preserve wonky nomenclature
   endif
  
  ;REDO FOR STANDARD DEVIATION CALCULATION
  
  if keyword_set(std) then begin
    if arg_present(avg_out) ne 1 then begin
      average_out= output/density
      avg_out = average_out ; hack for now to preserve wonky nomenclature
    endif
    std_out = make_array(total_bins,/double)
    for i=0, n_elements(kp_data) -1 do begin
      if ~finite(kp_data[i].(input_level0).(input_level1)) then begin
        continue
      endif
      bad_data_value = 0
     for j=0, total_fields-1 do begin
       data_value = kp_data[i].(level0_index[j]).(level1_index[j])
       if ~finite(data_value) or data_value lt mins[j] or data_value gt maxs[j] then begin
         bad_data_value = 1
         continue
       endif
       dv = floor((data_value - mins[j])/binsize[j])
       index[j] = dv
     endfor    
     if bad_data_value eq 1 then begin
       continue
     endif
        case total_fields of 
          1: begin
              std_out[index[0]] = std_out[index[0]] $
                + ( kp_data[i].(input_level0).(input_level1) $
                  - average_out[index[0]])^2
             end
          2: begin
              std_out[index[0],index[1]] = std_out[index[0],index[1]] $
                + ( kp_data[i].(input_level0).(input_level1) $
                  - average_out[index[0],index[1]])^2
             end
          3: begin
              std_out[index[0],index[1],index[2]] $
                = std_out[index[0],index[1],index[2]] $
                + ( kp_data[i].(input_level0).(input_level1) $
                  - average_out[index[0],index[1],index[2]])^2
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
    
    
    
    ;Set the total to NAN in places where we have no data,
    ;because we can't say it is zero since zero could be an
    ;actual result
    std_out[where(density eq 0)] = !Values.F_NAN
    
    std_out = sqrt(std_out/density)
        
  endif

end