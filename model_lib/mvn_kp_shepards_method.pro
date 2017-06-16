;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

;This function will interpolate a lat/lon/alt grid to new lat/lon/alt points

function mvn_kp_shepards_method, x, y, z , values, new_x, new_y, new_z, $
                                 p=p, nearest_neighbor=nearest_neighbor, alt_influence=alt_influence, $
                                 latlon_influence = latlon_influence

  if keyword_set(nearest_neighbor) then begin
    nearest_neighbor = nearest_neighbor
  endif else begin
    nearest_neighbor = 0
  endelse

  ;Power of two so it can be compared easier
  if keyword_set(latlon_influence) then begin
    distance_max = latlon_influence ^ 2
  endif else begin
    distance_max = 5.0 ^ 2
  endelse
  
  if keyword_set(alt_influence) then begin
    altitude_diff_to_include = alt_influence
  endif else begin
    altitude_diff_to_include = 10.0
  endelse
  
  if keyword_set(p) then begin
    power_parameter = p
  endif else begin
    power_parameter = 2.0
  endelse

  
  
  
  return_vals = replicate(0.0,n_elements(new_x))
  for i=0,n_elements(new_x)-1 do begin
    distance_x = (x-new_x[i])^2
    distance_y = (y-new_y[i])^2
    distance_z = (z-new_z[i])^2
    distance_total = distance_x + distance_y + distance_z
    indexes_to_use = where(distance_total lt distance_max)
    if [indexes_to_use] eq [-1] then begin
      return_vals[i] = !VALUES.F_NAN
      continue
    endif
    distance_total = distance_total[indexes_to_use]
    distance_total = sqrt(distance_total)
    data = values[indexes_to_use]
    if [indexes_to_use] eq [-1] then begin
      asdfasdf = 2
    endif
    if nearest_neighbor eq 1 then begin
      nearest_index = where(distance_total eq min(distance_total))
      return_vals[i] = data[nearest_index]
    endif else begin
      ;Only use data points that are approximately the same altitude
      alt_diff = abs(z - new_z)
      altitude_filter = where(alt_diff lt altitude_diff_to_include)
      data = data[altitude_filter]
      distance_total = distance_total[altitude_filter]    
      numerator = total(data/(distance_total^power_parameter))
      denominator = total((1.0/(distance_total^power_parameter)))
      return_vals[i] = numerator/denominator
    endelse
  endfor

return, return_vals

end
