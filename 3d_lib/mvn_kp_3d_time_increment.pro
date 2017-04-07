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
;-

pro mvn_kp_3d_time_increment, state1, direction

t_index = state1.time_index+direction
    if t_index gt 0 then begin
      if t_index lt n_elements(state1.insitu.time)-1 then begin
                  state1.orbit_path -> getproperty, data=data
                  state1.orbit_model->GetProperty,transform=curtrans
                  cur_x = data[0,state1.time_index*2]
                  cur_y = data[1,state1.time_index*2]
                  cur_z = data[2,state1.time_index*2]
                  new = fltarr(1,3)
                  new[0,0] = data[0,t_index*2]-cur_x
                  new[0,1] = data[1,t_index*2]-cur_y
                  new[0,2] = data[2,t_index*2]-cur_z
                  delta = new # curtrans[0:2,0:2]
                  state1.maven_model -> translate, delta[0],delta[1],delta[2]
                  state1.maven_location[0] = state1.maven_location[0]+delta[0]
                  state1.maven_location[1] = state1.maven_location[1]+delta[1]
                  state1.maven_location[2] = state1.maven_location[2]+delta[2]
                  
                ;UPDATE THE PARAMETERS ON SCREEN
                  state1.paratext1->setProperty,strings='Distance to Sun:'+strtrim(string(state1.insitu(t_index).spacecraft.mars_sun_distance),2)+' AU'
                  state1.paratext2->setProperty,strings='Mars Season:'+strtrim(string(state1.insitu(t_index).spacecraft.mars_season),2)
                  state1.paratext3->setProperty,strings='MAVEN Altitude:'+strtrim(string(state1.insitu(t_index).spacecraft.altitude),2)
                  state1.paratext4->setProperty,strings='Solar Zenith Angle:'+strtrim(string(state1.insitu(t_index).spacecraft.sza),2)
                  state1.paratext5->setProperty,strings='Local Time:'+strtrim(string(state1.insitu(t_index).spacecraft.local_time),2)
                  state1.paratext6->setProperty,strings='SubMaven Lat:'+strtrim(string(state1.insitu(t_index).spacecraft.sub_sc_latitude),2)
                  state1.paratext7->setProperty,strings='SubMaven Lon:'+strtrim(string(state1.insitu(t_index).spacecraft.sub_sc_longitude),2)
                  state1.timetext->setProperty,strings=time_string(state1.insitu(t_index).time,format=0)
                  state1.plottext1->getproperty,strings=temp_string
                  if temp_string ne '' then begin
                    state1.plottext2->setProperty, strings = strtrim(string(state1.insitu(t_index).(state1.level0_index).(state1.level1_index)),2)
                  endif
                  
                ;MOVE THE SUN'S LIGHT SOURCE TO THE PROPER LOCATION
                if state1.coord_sys eq 0 then begin        ;GEO COORDINATE SYSTEM
                  state1.dirlight->setProperty,location=[state1.solar_x_coord(t_index),state1.solar_y_coord(t_index),state1.solar_z_coord(t_index)]
                ;UPDATE THE SUBSOLAR POINT
                 state1.sub_solar_line->setProperty,data=[state1.subsolar_x_coord[t_index],state1.subsolar_y_coord[t_index],state1.subsolar_z_coord[t_index]]
                ;UPDATE THE SUBMAVEN POINT  
                 state1.sub_maven_line->setProperty,data=[state1.submaven_x_coord[t_index],state1.submaven_y_coord[t_index],state1.submaven_z_coord[t_index]]
                ;UPDATE THE SUN VECTOR
                  state1.sun_vector -> getproperty, data=data1
                  data1[0,1] = state1.solar_x_coord(t_index)
                  data1[1,1] = state1.solar_y_coord(t_index)
                  data1[2,1] = state1.solar_z_coord(t_index)
                  state1.sun_vector->setProperty,data=data1
  

                endif else begin                              ;MSO COORDINATE DISPLAY
                  ;Rotate the mars globe back zero (so that 0 lat/lon is on the x axis)
                  state1.mars_globe -> rotate, [-1,0,0], 25.19 * (-cos(state1.insitu[state1.time_index].spacecraft.mars_season*!dtor))
                  state1.mars_globe -> rotate, [0,-1,0], state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_latitude
                  state1.mars_globe -> rotate, [0,0,-1], -state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_longitude
    
                  ;Rotate the globe so that the subsolar point aligns with the x axis
                  state1.mars_globe -> rotate, [0,0,1], -state1.insitu(t_index).spacecraft.subsolar_point_geo_longitude
                  state1.mars_globe -> rotate, [0,1,0], state1.insitu(t_index).spacecraft.subsolar_point_geo_latitude
                  state1.mars_globe -> rotate, [1,0,0], 25.19 * (-cos(state1.insitu[state1.time_index].spacecraft.mars_season*!dtor))
 
                  
                  ;Same logic as above, but with the axes model instead of the globe
                  state1.axesmodel -> rotate, [-1,0,0], 25.19 * (-cos(state1.insitu[state1.time_index].spacecraft.mars_season*!dtor))
                  state1.axesmodel -> rotate, [0,-1,0], state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_latitude
                  state1.axesmodel -> rotate, [0,0,-1], -state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_longitude
                  state1.axesmodel -> rotate, [0,0,1], -state1.insitu(t_index).spacecraft.subsolar_point_geo_longitude
                  state1.axesmodel -> rotate, [0,1,0], state1.insitu(t_index).spacecraft.subsolar_point_geo_latitude
                  state1.axesmodel -> rotate, [1,0,0], 25.19 * (-cos(state1.insitu[t_index].spacecraft.mars_season*!dtor))


                  ;Same logic as above, but with the grid lines instead of the globe
                  state1.gridlines -> rotate, [-1,0,0], 25.19 * (-cos(state1.insitu[state1.time_index].spacecraft.mars_season*!dtor))
                  state1.gridlines -> rotate, [0,-1,0], state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_latitude
                  state1.gridlines -> rotate, [0,0,-1], -state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_longitude
                  state1.gridlines -> rotate, [0,0,1], -state1.insitu(t_index).spacecraft.subsolar_point_geo_longitude
                  state1.gridlines -> rotate, [0,1,0], state1.insitu(t_index).spacecraft.subsolar_point_geo_latitude
                  state1.gridlines -> rotate, [1,0,0], 25.19 * (-cos(state1.insitu[t_index].spacecraft.mars_season*!dtor))

                  ;Same logic as above, but with the orbit projection instead of the globe
                  state1.orb_projection -> rotate, [-1,0,0], 25.19 * (-cos(state1.insitu[state1.time_index].spacecraft.mars_season*!dtor))
                  state1.orb_projection -> rotate, [0,-1,0], state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_latitude
                  state1.orb_projection -> rotate, [0,0,-1], -state1.insitu(state1.time_index).spacecraft.subsolar_point_geo_longitude
                  state1.orb_projection -> rotate, [0,0,1], -state1.insitu(t_index).spacecraft.subsolar_point_geo_longitude
                  state1.orb_projection -> rotate, [0,1,0], state1.insitu(t_index).spacecraft.subsolar_point_geo_latitude
                  state1.orb_projection -> rotate, [1,0,0], 25.19 * (-cos(state1.insitu[t_index].spacecraft.mars_season*!dtor))
    
                  ;Change submaven point to the mso coordinates
                  state1.sub_maven_line_mso->setproperty,$
                  data=[state1.submaven_x_coord_mso[t_index],$
                  state1.submaven_y_coord_mso[t_index],$
                  state1.submaven_z_coord_mso[t_index]]
                 
                endelse
                
                
                ;UPDATE THE SUN VECTOR POINTING  
                
                ;UPDATE THE TERMINATOR LOCATION
                
 

                  
                ;UPDATE THE PARAMETER PLOT COLORS
                 state1.parameter_plot->getproperty,vert_colors=colors
                 for i=0,n_elements(colors[0,*])-1 do begin
                  if i lt t_index then begin
                    colors[*,i] = state1.parameter_plot_before_color
                  endif else begin
                    colors[*,i] = state1.parameter_plot_after_color
                  endelse
                 endfor
        
                 state1.parameter_plot->setproperty,vert_colors=colors 
                  
                 if state1.instrument_array[8] eq 1 then begin
   ;               ;UPDATE THE IUVS PERIAPSE ALTITUDE PLOT
                   MVN_KP_3D_CURRENT_PERIAPSE, state1.iuvs.periapse, state1.insitu[t_index].time, peri_data, state1.periapse_limb_scan, xlabel
                   state1.alt_xaxis_title->setproperty,strings=xlabel
                   state1.alt_plot->setproperty,datax=peri_data[1,*]
                   state1.alt_plot->setproperty,datay=peri_data[0,*]
                   state1.alt_plot->setproperty,xrange=[min(peri_data[1,*], /NAN),max(peri_data[1,*], /NAN)]
                   state1.alt_plot->getproperty, xrange=xr, yrange=yr
                   xc = mg_linear_function(xr, [-1.75,-1.5])
                   yc = mg_linear_function(yr, [-1.3,1.0])
                   state1.alt_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
                   state1.alt_xaxis_ticks->setproperty,strings=strtrim(string([min(peri_data[1,*], /NAN),max(peri_data[1,*], /NAN)], format='(E8.2)'),2)       
                 endif
                  
                 state1.time_index = t_index
                  
                 ;IF THE SCENE IS SPACECRAFT LOCKED, ROTATE EVERYTHING TO KEEP MAVEN CENTERED
                 if state1.camera_view eq 1 then begin

                     v1 = [0.0,0.0,1.0]
                     v2 = state1.maven_location[0:2]

                     axis = crossp(v1,v2)
                     angle = acos( transpose(v1)#v2 / sqrt(total(v1^2)) / sqrt(total(v2^2)) ) * 180./!pi 
      ;              print,axis
      ;              print,angle
                     ;rotate everything around to the right location
                      state1.maven_model->rotate,axis,-angle
                      state1.model->rotate,axis,-angle
                      state1.atmModel1->rotate,axis,-angle
                      state1.atmModel2->rotate,axis,-angle
                      state1.atmModel3->rotate,axis,-angle
                      state1.atmModel4->rotate,axis,-angle
                      state1.atmModel5->rotate,axis,-angle
                      state1.atmModel6->rotate,axis,-angle
                      state1.gridlines -> rotate,axis,-angle
                      state1.orbit_model -> rotate,axis,-angle
                      state1.sub_solar_model->rotate,axis,-angle
                      state1.sub_maven_model->rotate,axis,-angle
                      state1.vector_model->rotate,axis,-angle
                      state1.axesmodel -> rotate,axis,-angle
                      if state1.instrument_array[8] eq 1 then begin
                        state1.periapse_limb_model ->rotate,axis,-angle
                      endif;;
;
;                      ;update the maven location 
                     state1.maven_location[0:2] = [0.0,0.0,1.0]
                 endif 
              
                 ;IF APOAPSE IMAGES ARE DISPLAYED AS A SINGLE FRAME (APOPAPSE_BLEND = 0) THEN UPDATE
                 if state1.instrument_array[9] eq 1 then begin
                   if state1.apoapse_blend eq 0 then begin
                    if state1.mars_base_map eq 'apoapse' then begin
                      image = bytarr(3,90,45)
                      time = state1.insitu[state1.time_index].time_string
                      case state1.apoapse_image_choice of 
                                'Ozone Depth': MVN_KP_3D_APOAPSE_IMAGES, state1.iuvs.apoapse.ozone_depth, image, state1.apoapse_blend, time, state1.iuvs.apoapse.time_start
                                'Dust Depth' : MVN_KP_3D_APOAPSE_IMAGES, state1.iuvs.apoapse.dust_depth, image, state1.apoapse_blend, time, state1.iuvs.apoapse.time_start
                                'Radiance Map: H': begin
                                                      sizes = size(state1.iuvs.apoapse.radiance[0,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = state1.iuvs[i].apoapse.radiance[0,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, state1.apoapse_blend, time, state1.iuvs.apoapse.time_start
                                                   end
                                'Radiance Map: O_1304': begin
                                                            sizes = size(state1.iuvs.apoapse.radiance[1,*,*])
                                                            input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                            for i=0,sizes(4)-1 do begin
                                                              input_data[*,*,i] = state1.iuvs[i].apoapse.radiance[1,*,*]
                                                            endfor
                                                            MVN_KP_3D_APOAPSE_IMAGES, input_data, image, state1.apoapse_blend, time, state1.iuvs.apoapse.time_start
                                                         end  
                                'Radiance Map: CO': begin
                                                      sizes = size(state1.iuvs.apoapse.radiance[2,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = state1.iuvs[i].apoapse.radiance[2,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, state1.apoapse_blend, time, state1.iuvs.apoapse.time_start
                                                   end
                                'Radiance Map: NO': begin
                                                      sizes = size(state1.iuvs.apoapse.radiance[3,*,*])
                                                      input_data = fltarr(sizes(2),sizes(3),sizes(4))
                                                      for i=0,sizes(4)-1 do begin
                                                        input_data[*,*,i] = state1.iuvs[i].apoapse.radiance[3,*,*]
                                                      endfor
                                                      MVN_KP_3D_APOAPSE_IMAGES, input_data, image, state1.apoapse_blend, time, state1.iuvs.apoapse.time_start
                                                   end
                              endcase                           
                      oImage = OBJ_NEW('IDLgrImage', image )
                      state1.opolygons -> setproperty, texture_map=oimage
                     endif  
                   endif
                 endif
         endif         
    endif

end