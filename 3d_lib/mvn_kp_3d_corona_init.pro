;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds 
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;       input for start argument to H5S_SELECT_HYPERSLAB
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to H5S_SELECT_HYPERSLAB
;    block : out, optional, type=lonarr(ndims)
;       input for block keyword to H5S_SELECT_HYPERSLAB
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to H5S_SELECT_HYPERSLAB
;       
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-
pro MVN_KP_3D_CORONA_INIT, data, insitu_time, insitu_alt, x_orbit, y_orbit, z_orbit, x, y, z, poly_out, vert_colors

  mars_radius = 3396.2


  ;CREATE THE LOCATIONS OF THE POLYGON CORNERS FROM THE ORBITAL DATA (ROUGHLY RECTANGULAR POLYGONS)
  corona_index = 0
  for i=0, n_elements(data) -1 do begin
    if finite(data[i].alt[0]) then begin
      
      t1 = time_double(data[i].time_start,tformat="YYYY-MM-DDThh:mm:ss")
      t2 = time_double(data[i].time_stop,tformat="YYYY-MM-DDThh:mm:ss")
      
      m1 = min((insitu_time-t1) ,t1_index,/absolute, /NAN)
      m2 = min((insitu_time-t2) ,t2_index,/absolute, /NAN)
      
      delta_x = (x_orbit[t2_index*2] - x_orbit[t1_index*2])/n_elements(data[i].alt)
      delta_y = (y_orbit[t2_index*2] - y_orbit[t1_index*2])/n_elements(data[i].alt)
      delta_z = (z_orbit[t2_index*2] - z_orbit[t1_index*2])/n_elements(data[i].alt)
  
      ;DETERMINE THE TIME INDEX OF THE ORBITAL LOCATION AT THE SAME ALTITUDE ON THE INBOUND SIDE
      alt1 = insitu_alt[t1_index]
      alt2 = insitu_alt[t2_index]
      
      if (t1_index+1500) gt n_elements(insitu_alt) then begin
        opp1 = n_elements(insitu_alt)-1
      endif else begin
        opp1 = t1_index+1500
      endelse
      if (t2_index+1500) gt n_elements(insitu_alt) then begin
        opp2 = n_elements(insitu_alt)-1
      endif else begin
        opp2 = t2_index+1500
      endelse
      
      a1 = min((insitu_alt[t1_index+1:opp1]) - alt1, alt1_index, /absolute, /NAN)
      a2 = min((insitu_alt[t2_index+1:opp2]) - alt2, alt2_index, /absolute, /NAN)
      
      alt1_index = alt1_index + 1 + t1_index
      alt2_index = alt2_index + 1 + t2_index
      
      delta_x1 = (x_orbit[alt2_index*2] - x_orbit[alt1_index*2])/n_elements(data[i].alt)
      delta_y1 = (y_orbit[alt2_index*2] - y_orbit[alt1_index*2])/n_elements(data[i].alt)
      delta_z1 = (z_orbit[alt2_index*2] - z_orbit[alt1_index*2])/n_elements(data[i].alt)
      
      for j=0, n_elements(data[i].alt) -1 do begin
        ;FIRST CORNER OF THE POLYGON (LOW POINT START SIDE)
          x[corona_index] = x_orbit(t1_index*2) + (delta_x*j)
          y[corona_index] = y_orbit(t1_index*2) + (delta_y*j)
          z[corona_index] = z_orbit(t1_index*2) + (delta_z*j)
          
        ;SECOND CORNER OF THE POLYGON (LOW POINT ACROSS ORBIT)
         x[corona_index+1] = x_orbit(alt1_index*2) + (delta_x1*j)
         y[corona_index+1] = y_orbit(alt1_index*2) + (delta_y1*j)
         z[corona_index+1] = z_orbit(alt1_index*2) + (delta_z1*j)
         
        ;THIRD CORNER OF THE POLYGON (HIGH POINT ACROSS ORBIT)
         x[corona_index+2] = x_orbit(alt1_index*2) + (delta_x1*(j+1))
         y[corona_index+2] = y_orbit(alt1_index*2) + (delta_y1*(j+1))
         z[corona_index+2] = z_orbit(alt1_index*2) + (delta_z1*(j+1))
         
        ;FOURTH CORNER OF THE POLYGON (HIGH POINT START SIDE)
          x[corona_index+3] = x_orbit(t1_index*2) + (delta_x*(j+1))
          y[corona_index+3] = y_orbit(t1_index*2) + (delta_y*(j+1))
          z[corona_index+3] = z_orbit(t1_index*2) + (delta_z*(j+1))
        
        corona_index = corona_index+4
      endfor
    endif
  endfor


  ;CREATE THE POLYGON CONNECTION VECTOR
    obs_index = 0
     poly_index = 0
    for i=0, n_elements(data) -1 do begin     
      if finite(data[i].alt[0]) then begin
        for j=0, n_elements(data[i].alt)-1 do begin
            poly_out[(obs_index*5*n_elements(data[i].alt)) + (j*5)] = 4
          for k=0,3 do begin
            poly_out[(obs_index*5*n_elements(data[i].alt)) + (j*5) + (k+1)] = poly_index
            poly_index = poly_index+1    
          endfor
        endfor
        obs_index = obs_index+1
      endif  
    endfor
  
  ;DEFINE THE VERT_COLORS FOR THE POLYGONS
  
  corona_index=0
  for i=0, n_elements(data) -1 do begin
    if finite(data[i].alt[0]) then begin
      for j=0,n_elements(data[i].alt)-1 do begin
        vert_colors[0,corona_index:corona_index+3] = 0
        vert_colors[1,corona_index:corona_index+3] = 0
        vert_colors[2,corona_index:corona_index+3] = 0

        corona_index= corona_index+4
      endfor
    endif
  endfor
  
  


  
END