;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

;; This procedure takes model data from a cube and converts it into spherical coordinates

pro mvn_kp_model_cube_to_sphere, old_model, new_model, alt=alt

;Find minimum and maximum altitude
min_altitude = 100
max_altitude = min(abs([old_model.dim.x[0], $
                       old_model.dim.x[n_elements(old_model.dim.x)-1], $
                       old_model.dim.y[0], $
                       old_model.dim.y[n_elements(old_model.dim.y)-1], $
                       old_model.dim.z[0], $
                       old_model.dim.z[n_elements(old_model.dim.z)-1]]), /NAN) $
                       - old_model.meta[0].mars_radius
                       
altitude = (((max_altitude - min_altitude) / 99) * dindgen(100)) + min_altitude 
longitude = (2*dindgen(180)) - 180
latitude = (2*dindgen(90)) - 90
  
if (keyword_set(alt)) then begin
  altitude=alt
endif
  
data = make_array(180, 90, n_elements(altitude))

data_ptrs =[]

for i=0,n_elements(old_model.data)-1 do begin
  var_ptr = create_struct('name',(*(old_model.data[i])).name, $
                          'data', data, $
                          'dim_order', ['lon', 'lat', 'alt'])
  data_ptrs=[data_ptrs, var_ptr]
endfor

  
for i=0,n_elements(longitude)-1 do begin
  for j=0,n_elements(latitude)-1 do begin
    for k=0, n_elements(altitude)-1 do begin
      
      ;Reset all "out of bounds" errors
      x_out_of_bounds_error=0
      y_out_of_bounds_error=0
      z_out_of_bounds_error=0
      
      ;Convert MSO lat/lon/alt to MSO x,y,z 
      tempx=(altitude[k]+old_model.meta[0].mars_radius)*(sin(!dtor*(90-latitude[j]))*cos(!dtor*longitude[i]))
      tempy=(altitude[k]+old_model.meta[0].mars_radius)*(sin(!dtor*(90-latitude[j]))*sin(!dtor*longitude[i]))
      tempz=(altitude[k]+old_model.meta[0].mars_radius)*(cos(!dtor*(90-latitude[j])))
      
      ;Find the closest values to tempx, tempy and tempz in the model, 
      ;Box the point in a cube bounded by the points (xindex1,yindex1,zindex1) and (xindex2,yindex2,zindex2)
      xindex1 = value_locate(old_model.dim.x, tempx)
      if ((xindex1-1) lt 0) then begin
        xindex2 = xindex1+1
        x_out_of_bounds_error=1
      endif
      if ((xindex1+1) ge n_elements(old_model.dim.x)) then begin
        xindex2 = xindex1-1
        x_out_of_bounds_error=1
      endif
      if (x_out_of_bounds_error eq 0) then begin
        if (abs(old_model.dim.x[xindex1+1]-tempx) le abs(old_model.dim.x[xindex1-1]-tempx)) then begin
          xindex2=xindex1+1
        endif else begin
          xindex2=xindex1-1
        endelse
        if (old_model.dim.x[xindex2] lt old_model.dim.x[xindex1]) then begin
          temp=xindex2
          xindex2=xindex1
          xindex1=temp
        endif
      endif
      
      yindex1 = value_locate(old_model.dim.y, tempy)
      if ((yindex1-1) lt 0) then begin
        yindex2 = yindex1+1
        y_out_of_bounds_error=1
      endif
      if ((yindex1+1) ge n_elements(old_model.dim.y)) then begin
        yindex2 = yindex1-1
        y_out_of_bounds_error=1
      endif
      if (y_out_of_bounds_error eq 0) then begin
        if (abs(old_model.dim.y[yindex1+1]-tempy) le abs(old_model.dim.y[yindex1-1]-tempy)) then begin
          yindex2=yindex1+1
        endif else begin
          yindex2=yindex1-1
        endelse
        if (old_model.dim.y[yindex2] lt old_model.dim.y[yindex1]) then begin
          temp=yindex2
          yindex2=yindex1
          yindex1=temp
        endif
      endif
      
      zindex1 = value_locate(old_model.dim.z, tempz)
      if ((zindex1-1) lt 0) then begin
        zindex2 = zindex1+1
        z_out_of_bounds_error=1
      endif
      if ((zindex1+1) ge n_elements(old_model.dim.z)) then begin
        zindex2 = zindex1-1
        z_out_of_bounds_error=1
      endif
      if (z_out_of_bounds_error eq 0) then begin    
        if (abs(old_model.dim.z[zindex1+1]-tempz) le abs(old_model.dim.z[zindex1-1]-tempz)) then begin
          zindex2=zindex1+1
        endif else begin
          zindex2=zindex1-1
        endelse
        if (old_model.dim.z[zindex2] lt old_model.dim.z[zindex1]) then begin
          temp=zindex2
          zindex2=zindex1
          zindex1=temp
        endif
      endif
      
      ;Transform the cube into a unit cube so we can determine the relative weights of each of the 8 points
      x = (tempx-old_model.dim.x[xindex1])/(old_model.dim.x[xindex2]-old_model.dim.x[xindex1])
      y = (tempy-old_model.dim.y[yindex1])/(old_model.dim.y[yindex2]-old_model.dim.y[yindex1])
      z = (tempz-old_model.dim.z[zindex1])/(old_model.dim.z[zindex2]-old_model.dim.z[zindex1])
      
      ; Calculate the new interpolated number for each data point
      for n=0,n_elements(old_model.data)-1 do begin
        data_ptrs[n].data[i,j,k] = (*(old_model.data[n])).data[xindex1, yindex1, zindex1]*(1-x)*(1-y)*(1-z) $
                                    + (*(old_model.data[n])).data[xindex2, yindex1, zindex1]*(x)*(1-y)*(1-z) $
                                    + (*(old_model.data[n])).data[xindex1, yindex2, zindex1]*(1-x)*(y)*(1-z) $
                                    + (*(old_model.data[n])).data[xindex1, yindex1, zindex2]*(1-x)*(1-y)*(z) $
                                    + (*(old_model.data[n])).data[xindex2, yindex1, zindex2]*(x)*(1-y)*(z) $
                                    + (*(old_model.data[n])).data[xindex1, yindex2, zindex2]*(1-x)*(y)*(z) $
                                    + (*(old_model.data[n])).data[xindex2, yindex2, zindex1]*(x)*(y)*(1-z) $
                                    + (*(old_model.data[n])).data[xindex2, yindex2, zindex2]*(x)*(y)*(z)
      endfor
      
    endfor
  endfor
endfor

; Return a new model structure
data_struct=[]
meta_struct = create_struct( 'ls',old_model.meta.ls, $
                             'longsubsol', old_model.meta.longsubsol, $
                             'declination', old_model.meta.declination, $
                             'mars_radius', old_model.meta.mars_radius, $
                             'coord_sys', old_model.meta.coord_sys, $
                             'altitude_from', old_model.meta.altitude_from)
dim_struct = create_struct( 'lon',longitude, $
                            'lat', latitude, $
                            'alt',altitude)                     
for i=0,n_elements(old_model.data)-1 do begin
  var_ptr = ptr_new(create_struct('name',(*(old_model.data[i])).name, $
                      'data', data_ptrs[i].data, $
                      'dim_order', ['longitude', 'latitude', 'altitude']) )
  data_struct = [data_struct, var_ptr]
endfor
                            
new_model = {meta:meta_struct, dim:dim_struct, data:data_struct}
  
  
;; TODO: MAKE A NEW MODEL FOR THIS PROCEDURE TO RETURN  
;;
;; AND IN INTERPOL MODEL, CONVERT MSO LAT/LON/ALT to XYZ TO COMPARE TO MODEL 

return
end