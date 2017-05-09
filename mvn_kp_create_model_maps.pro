;+
; Creates contour plots from model data
;
; :Author: Bryan Harter
;
; :Description:
;     Takes the 3 data structures from mvn_kp_model_results and takes a slice
;     from them at a certain altitude.  A contour plot is made from the data,
;     which can then be used in mvn_kp_map2d or mvn_kp_3d.  The contour plot
;     is saved as a png in the same directory as the model data.
;
; :Keywords:
;    altitude: in, required, type=integer
;       Height, in kilometers, that the user wants the data
;
;    file: in, optional, type=file path string
;       The path and file name to the model data you want to plot.  If this
;       is not specified, then a window will appear asking the user to select
;       a file
;
;    interp: in, optional, type=boolean
;       If this flag is set, the data will be interpolated if the user
;       specifies an altitude that is between two model layers.  Otherwise,
;       the contour plot will be of the closest altitude layer
;
;    numContourLines: in, optional, type=integer
;       The user can specify the number of contour lines in the output contour
;       Default is 25 contour lines
;
;    fill: in, optional, type=boolean
;       If this flag is selected, the contour plot fills in the levels
;       with a certain color.
;
;    ct: in, optional, type=integer array 256x3
;       The user can specify a color table for the contour plot.  The
;       default is the array given by COLORTABLE(72, /REVERSE)
;
;    basemap: in, optional, type=string
;       If either 'mdim', 'mola', 'mola_bw', or 'mag is specified, the
;       contour will be overlaid on one of these basemaps with 50%
;       transparency
;
;    contourtransparency: in, optional, type=integer
;       The user can specify the level of transparency in the contour plot.
;       Useful when plotting the contour over a basemap.  Must be a number
;       between 0 (no transparency) and 100 (completely transparent)
;
;
;-

pro MVN_KP_CREATE_MODEL_MAPS, altitude, $
  model=model, $
  file=file, $
  interp=interp, $
  numContourLines = numContourLines, $
  fill=fill, $
  ct=ct, $
  contourtransparency=contourtransparency, $
  grid3=grid3,$
  nearest_neighbor=nearest_neighbor



  ;CHECK ALL PARAMETERS BEFORE CONTINUING
  ;Check altitude
  if (~(size(altitude, /type) gt 1) and ~(size(altitude, /type) lt 6)) then begin
    print, "Please enter a valid number for altitude"
    return
  endif

  ; Check if filename, model, or nothing is specified
  ; These lines of code just return "model" with the model info
  if (keyword_set(model)) then begin
    model=model
  endif else begin
    if (keyword_set(file)) then begin
      if (not size(file, /type) eq 7) then begin
        print, "Please enter a valid file name."
        return
      endif
    endif else begin
      result = DIALOG_PICKFILE(/READ, FILTER='*.nc')
      if (result eq '') then begin
        print, "A simulation file must be selected."
        return
      endif
      file = result
    endelse
    mvn_kp_read_model_results, file, model
  endelse


  ;Check contour transparency value
  if not keyword_set(contourtransparency) then begin
    if (keyword_set(fill) and keyword_set(basemap)) then begin
      contourtransparency = 60
    endif else begin
      contourtransparency = 0
    endelse
  endif else begin
    if (~(size(contourtransparency, /type) gt 1) or $
      ~(size(contourtransparency, /type) lt 6)) then begin
      print, 'Please enter a valid value for the contour transparency.'
      return
    endif
    contourtransparency = fix(contourtransparency)
  endelse

  ;Check if colortable was set
  if (not keyword_set(ct)) then begin
    ct = COLORTABLE(72, /reverse)
  endif else begin
    if (~(size(ct, /type) eq 1)) then begin
      print, 'Please Enter a Valid Color table'
      return
    endif
    if (~((size(ct))(1) eq 256)) then begin
      print, 'Please Enter a Valid Color table'
      return
    endif
  endelse

  ;Check if the number of contour lines is set,
  ;otherwise select the default of 25
  if (not keyword_set(numContourLines)) then begin
    numContourLines = 25
  endif else begin
    if (~(size(numContourLines, /type) gt 1) or $
      ~(size(numContourLines, /type) lt 6)) then begin
      print, 'Please use an integer value for the number of contour lines.'
      return
    endif
    if (numContourLines gt 500) then numContourLines=500
    if (numContourLines lt 0) then begin
      print, "Please enter a positive value for the number of contour lines"
      return
    endif
    numContourLines = fix(numContourLines)
  endelse


  ;GET INSTALL DIRECTORY
  install_result = routine_info('mvn_kp_create_model_maps2',/source)
  install_directory = strsplit(install_result.path,$
    'mvn_kp_create_model_maps2.pro',$
    /extract,/regex)
  if !version.os_family eq 'unix' then begin
    basemap_directory = install_directory+'basemaps/'
  endif else begin
    basemap_directory = install_directory+'basemaps\'
  endelse

  simmeta = model.meta
  simdim = model.dim
  simdata = model.data

  ;ASK USER FOR A VARIABLE TO PLOT
  print, "Select a variable to plot"
  for i=0,n_elements(simdata)-1 do begin
    print, string(i+1)+" : "+(*simdata[i]).name
  endfor
  READ, input, PROMPT="Enter Selection: "
  input = fix(input)
  while ((input lt 0) or (input gt n_elements(simdata))) do begin
    print, "Invalid selection.  Please enter a number between 0 and " $
      + string(n_elements(simdata))
    READ, input, PROMPT="Enter Selection: "
    input = fix(input)
  endwhile
  dataname = strlowcase((*simdata[input-1]).name)

  lat = findgen(171)-85
  lon = findgen(351)-175
  
  sc_lon_array = replicate(0.0, n_elements(lat)*n_elements(lon))
  for i=1,n_elements(lat) do begin
    sc_lon_array[(i-1)*n_elements(lon) : i*n_elements(lon)-1] = lon
  endfor

  sc_lat_array = replicate(0.0, n_elements(lat)*n_elements(lon))
  for i=1,n_elements(lat) do begin
    sc_lat_array[(i-1)*n_elements(lon) : i*n_elements(lon)-1] = lat[i-1]
  endfor
sc_alt_array = replicate(altitude, n_elements(sc_lat_array))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;
  ;  Set the keywords for the interpoaltion style
  ;
  grid3=keyword_set(grid3)
  nearest_neighbor=keyword_set(nearest_neighbor)
  if nearest_neighbor eq 0 then grid3=1
  ;
  ; Start the output model with the meta data
  ;
  model_interpol = model.meta
  mars_radius = model.meta.mars_radius

  ;Get the path of the "spacecraft"
  sc_alt_mso = sc_alt_array
  sc_lat_mso = sc_lat_array
  sc_lon_mso = sc_lon_array
  r = replicate(altitude + mars_radius, n_elements(sc_lat_array))
  sc_mso_x = r * sin((90-sc_lat_mso) * !dtor) * cos(sc_lon_mso * !dtor)
  sc_mso_y = r * sin((90-sc_lat_mso) * !dtor) * sin(sc_lon_mso * !dtor)
  sc_mso_z = r * cos((90-sc_lat_mso) * !dtor)
  ;
  ;Determine if the model is in lat/lon/alt or x/y/z
  ;
  if ((*model.data[0]).dim_order[0] eq 'longitude' || $
    (*model.data[0]).dim_order[0] eq 'latitude' || $
    (*model.data[0]).dim_order[0] eq 'altitude') then begin

    ;
    ; Determine the coordinate system for the input model
    ;
    coord_sys = strtrim(strtrim(model.meta[0].coord_sys, 1),0)
    case coord_sys of
      'MSO': begin
        mso = keyword_set(1B) & geo = keyword_set(0B)
      end
      'GEO': begin
        geo = keyword_set(1B) & mso = keyword_set(0B)
      end
      else: message, "Ill-defined or undefined coord_sys in meta structure"
    endcase

    ;
    ;  Get the appropriate spacecraft geometry
    ;
    if( mso )then begin
      lat_mso_model = model.dim.lat
      lon_mso_model = model.dim.lon
      alt_mso_model = model.dim.alt
      ;Create altitude Array
      alt_array = replicate(0.0, n_elements(lat_mso_model)*n_elements(lon_mso_model)*n_elements(alt_mso_model))
      for i=1,n_elements(alt_mso_model) do begin
        alt_array[(i-1)*n_elements(lat_mso_model)*n_elements(alon_mso_model) : i*n_elements(lat_mso_model)*n_elements(lon_mso_model)-1] = alt_mso_model[i-1]
      endfor

      ;Create Latitude Array
      lat_array = []
      for k=1,n_elements(alt_mso_model) do begin
        temp_lat_array = replicate(0.0, n_elements(lat_mso_model)*n_elements(lon_mso_model))
        for i=1,n_elements(lat_mso_model) do begin
          temp_lat_array[(i-1)*n_elements(lon_mso_model) : i*n_elements(lon_mso_model)-1] = lat_mso_model[i-1]
        endfor
        lat_array = [lat_array, temp_lat_array]
      endfor

      ;Create Longitude Array
      lon_array = replicate(0.0, n_elements(lat_mso_model)*n_elements(lon_mso_model)*n_elements(alt_mso_model))
      for i=1,n_elements(lat_mso_model)*n_elements(alt_mso_model) do begin
        lon_array[(i-1)*n_elements(lon_mso_model) : i*n_elements(lon_mso_model)-1] = lon_mso_model
      endfor

      data_points = transpose([[lon_array], [lat_array], [alt_array]])


      for i = 0,n_elements(model.data)-1 do begin
        if strlowcase((*model.data[i]).name) ne dataname then continue
        print, "Interpolating variable " + (*model.data[i]).name
        ;
        ;  First, ensure the data are in lon / lat / alt order
        ;
        dim_order_array = bytarr(3)
        for j = 0,2 do begin
          case (*model.data[i]).dim_order[j] of
            'longitude': dim_order_array[0] = j
            'latitude': dim_order_array[1] = j
            'altitude': dim_order_array[2] = j
            else: message, "Invalid dimension Identifier in model_data: ",i,j
          endcase
        endfor ; j=0,2
        data_new = transpose( (*model.data[i]).data, dim_order_array )

        index = 0.0
        values = replicate(0.0, n_elements(lat_mso_model)*n_elements(lon_mso_model), n_elements(alt_mso_model))
        for alt=0,n_elements(alt_mso_model)-1 do begin
          for lat=0,n_elements(lat_mso_model)-1 do begin
            for lon=0,n_elements(lon_mso_model)-1 do begin
              values[index, alt] = data_new[lon,lat,alt]
              if index eq 1966 then begin
                asdfdsa=2
              endif
              index++
            endfor
          endfor
          index=0
        endfor

        triangulate, lon_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], lat_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], tr
        tracer_interpol = replicate(!VALUES.F_NAN, n_elements(sc_lon_mso))
        for k=0,n_elements(sc_alt_mso)-1 do begin
          if sc_alt_mso[k] gt max(alt_mso_model) then continue
          if sc_alt_mso[k] lt min(alt_mso_model) then continue
          alti1_temp = min(abs(alt_mso_model - sc_alt_mso[k]), alti1)
          if k eq 689 then begin
            asdfdsafsdf=2
          endif
          if keyword_set(nearest_neighbor) then begin
            tracer_interpol[k] = griddata(lon_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], lat_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], values[*,alti1], xout = [sc_lon_mso[k]], yout = [sc_lat_mso[k]], /nearest_neighbor, triangles=tr)
          endif else begin
            if alti1-1 lt 0 then begin
              tracer_interpol[k] = !VALUES.F_NAN
              continue
            endif
            if alt_mso_model[alti1] lt sc_alt_mso[k] then begin
              alti2 = alti1 + 1
            endif else begin
              temp = alti1 - 1
              alti2 = alti1
              alti1 = temp
            endelse
            if alti2+1 gt n_elements(alt_mso_model) then begin
              tracer_interpol[k] = !VALUES.F_NAN
              continue
            endif
            first_val = griddata(lon_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], lat_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], values[*,alti1], xout = [sc_lon_mso[k]], yout = [sc_lat_mso[k]], /linear, triangles=tr)
            second_val = griddata(lon_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], lat_array[0:n_elements(lat_mso_model)*n_elements(lon_mso_model)-1], values[*,alti2], xout = [sc_lon_mso[k]], yout = [sc_lat_mso[k]], /linear, triangles=tr)
            delta_1 = sc_alt_mso[k] - alt_mso_model[alti1]
            delta_2 = alt_mso_model[alti2] - sc_alt_mso[k]
            delta_tot = (alt_mso_model[alti2] - alt_mso_model[alti1])
            tracer_interpol[k] = ((first_val*delta_2) + (second_val*delta_1)) / (delta_tot)
          endelse
        endfor

        expanded_model_data = tracer_interpol

      endfor
    endif
    if( geo )then begin


      modellon = - model.meta.longsubsol *!dtor
      ls_rad = model.meta.ls * !dtor
      rads_tilted_y = 25.19 * sin(ls_rad) * !dtor
      rads_tilted_x = -25.19 * cos(ls_rad) * !dtor

      z_rotation = [[cos(modellon), -sin(modellon), 0], $
        [sin(modellon), cos(modellon), 0], $
        [0,0,1]]
      y_rotation = [[cos(rads_tilted_y), 0, sin(rads_tilted_y)], $
        [0,1,0], $
        [-sin(rads_tilted_y), 0, cos(rads_tilted_y)]]
      x_rotation = [[1,0,0], $
        [0,cos(rads_tilted_x),-sin(rads_tilted_x)], $
        [0,sin(rads_tilted_x),cos(rads_tilted_x)]]
      geo_to_mso_matrix = x_rotation##(y_rotation##z_rotation)

      lat_geo_model = model.dim.lat
      lon_geo_model = model.dim.lon
      alt_geo_model = model.dim.alt
      ;Create altitude Array
      alt_array = replicate(0.0, n_elements(lat_geo_model)*n_elements(lon_geo_model)*n_elements(alt_geo_model))
      for i=1,n_elements(alt_geo_model) do begin
        alt_array[(i-1)*n_elements(lat_geo_model)*n_elements(lon_geo_model) : i*n_elements(lat_geo_model)*n_elements(lon_geo_model)-1] = alt_geo_model[i-1]
      endfor

      ;Create Latitude Array
      lat_array = []
      for k=1,n_elements(alt_geo_model) do begin
        temp_lat_array = replicate(0.0, n_elements(lat_geo_model)*n_elements(lon_geo_model))
        for i=1,n_elements(lat_geo_model) do begin
          temp_lat_array[(i-1)*n_elements(lon_geo_model) : i*n_elements(lon_geo_model)-1] = lat_geo_model[i-1]
        endfor
        lat_array = [lat_array, temp_lat_array]
      endfor

      ;Create Longitude Array
      lon_array = replicate(0.0, n_elements(lat_geo_model)*n_elements(lon_geo_model)*n_elements(alt_geo_model))
      for i=1,n_elements(lat_geo_model)*n_elements(alt_geo_model) do begin
        lon_array[(i-1)*n_elements(lon_geo_model) : i*n_elements(lon_geo_model)-1] = lon_geo_model
      endfor

      ;Convert lat/lon/alt to GEO, then to MSO
      data_points = transpose([[lon_array], [lat_array], [alt_array]])
      for i=0,n_elements(alt_array)-1 do begin
        r = data_points[2, i] + mars_radius
        x = r * sin((90-data_points[1,i]) * !dtor) * cos(data_points[0,i] * !dtor)
        y = r * sin((90-data_points[1,i]) * !dtor) * sin(data_points[0,i] * !dtor)
        z = r * cos((90-data_points[1,i]) * !dtor)
        data_points[*,i] = geo_to_mso_matrix##[x,y,z]
      endfor

      ;Convert everything in an MSO lat/lon/alt so that things are weighted properly
      r = sqrt(reform(data_points[0,*])^2 + reform(data_points[1,*])^2 + reform(data_points[2,*])^2)
      alt_mso = r - mars_radius
      lat_mso = 90.0 - (acos(reform(data_points[2,*])/r) / !dtor)
      lon_mso = atan(reform(data_points[1,*]) , reform(data_points[0,*])) / !dtor


      for i = 0,n_elements(model.data)-1 do begin
        if strlowcase((*model.data[i]).name) ne dataname then continue
        print, "Interpolating variable " + (*model.data[i]).name
        ;
        ;  First, ensure the data are in lon / lat / alt order
        ;
        dim_order_array = bytarr(3)
        for j = 0,2 do begin
          case (*model.data[i]).dim_order[j] of
            'longitude': dim_order_array[0] = j
            'latitude': dim_order_array[1] = j
            'altitude': dim_order_array[2] = j
            else: message, "Invalid dimension Identifier in model_data: ",i,j
          endcase
        endfor ; j=0,2
        data_new = transpose( (*model.data[i]).data, dim_order_array )

        index = 0.0
        values = replicate(0.0, n_elements(lat_geo_model)*n_elements(lon_geo_model), n_elements(alt_geo_model))

        for alt=0,n_elements(alt_geo_model)-1 do begin
          for lat=0,n_elements(lat_geo_model)-1 do begin
            for lon=0,n_elements(lon_geo_model)-1 do begin
              values[index, alt] = data_new[lon,lat,alt]
              index++
            endfor
          endfor
          index=0
        endfor

        triangulate, lon_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], lat_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], tr
        tracer_interpol = replicate(!VALUES.F_NAN, n_elements(sc_lon_mso))
        for k=0,n_elements(sc_alt_mso)-1 do begin
          if sc_alt_mso[k] gt max(alt_geo_model) then continue
          if sc_alt_mso[k] lt min(alt_geo_model) then continue
          alti1_temp = min(abs(alt_geo_model - sc_alt_mso[k]), alti1)
          if keyword_set(nearest_neighbor) then begin
            tracer_interpol[k] = griddata(lon_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], lat_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], values[*,alti1], xout = [sc_lon_mso[k]], yout = [sc_lat_mso[k]], /nearest_neighbor, triangles=tr)
          endif else begin
            if alti1-1 lt 0 then begin
              tracer_interpol[k] = !VALUES.F_NAN
              continue
            endif
            if alt_geo_model[alti1] lt sc_alt_mso[k] then begin
              alti2 = alti1 + 1
            endif else begin
              temp = alti1 - 1
              alti2 = alti1
              alti1 = temp
            endelse
            if alti2+1 gt n_elements(alt_geo_model) then begin
              tracer_interpol[k] = !VALUES.F_NAN
              continue
            endif
            first_val = griddata(lon_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], lat_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], values[*,alti1], xout = [sc_lon_mso[k]], yout = [sc_lat_mso[k]], /linear, triangles=tr)
            second_val = griddata(lon_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], lat_mso[0:n_elements(lat_geo_model)*n_elements(lon_geo_model)-1], values[*,alti2], xout = [sc_lon_mso[k]], yout = [sc_lat_mso[k]], /linear, triangles=tr)
            delta_1 = sc_alt_mso[k] - alt_geo_model[alti1]
            delta_2 = alt_geo_model[alti2] - sc_alt_mso[k]
            delta_tot = (alt_geo_model[alti2] - alt_geo_model[alti1])
            tracer_interpol[k] = ((first_val*delta_2) + (second_val*delta_1)) / (delta_tot)
          endelse
        endfor

        expanded_model_data = tracer_interpol

      endfor

    endif

  endif else begin


    for i = 0,n_elements(model.data)-1 do begin
      if strlowcase((*model.data[i]).name) ne dataname then continue
      print, "Interpolating variable " + (*model.data[i]).name
      dim_order_array = bytarr(3)
      for j = 0,2 do begin
        case (*model.data[i]).dim_order[j] of
          'x': dim_order_array[0] = j
          'y': dim_order_array[1] = j
          'z': dim_order_array[2] = j
          else: message, "Invalid dimension Identifier in model_data: ",i,j
        endcase
      endfor
      tracer = transpose( (*model.data[i]).data, dim_order_array )
      ;
      ;  Now, interpolate the model to the SC trajectory
      ;
      tracer_interpol = mvn_kp_sc_traj_xyz( tracer, model.dim, $
        sc_mso_x, $
        sc_mso_y, $
        sc_mso_z, $
        grid3=grid3, nn=nearest_neighbor)
      ;
      ;  Add the interpolated model data to the structure
      ;
      expanded_model_data = tracer_interpol
    endfor

  endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;CREATE THE CONTOUR PLOT
  ;Note: Background color is almost white, but not quite.
  ;      otherwise, when saving the image as a png, the function cuts out
  ;      an all white border
  contour1=contour(expanded_model_data, sc_lon_array, sc_lat_array, $
    RGB_TABLE=ct, N_LEVELS=numContourLines, $
    XRANGE = [-180,180], $
    YRANGE = [-90, 90], $
    ;ZRANGE = [-200, 200], $
    ASPECT_RATIO=1.0, BACKGROUND_COLOR = [254,254,254],$
    FILL=fill, FONT_SIZE=8, DIMENSIONS=[2000,1000], $
    OVERPLOT=keyword_set(basemap), $
    TRANSPARENCY=contourtransparency, grid_units='degrees', /IRREGULAR)

  ;HIDE THE AXES
  if (not keyword_set(basemap)) then begin
    contour1.axes[0].hide = 1
    contour1.axes[1].hide = 1
  endif

  ;SAVE IMAGE
  ;In same location as model data
  model_directory = FILE_DIRNAME(file)
  save_string = model_directory
  if !version.os_family eq 'unix' then begin
    save_string = save_string+"/"
  endif else begin
    save_string = save_string+"\"
  endelse
  save_string = save_string+"ModelData_"+dataname + $
    "_"+strtrim(string(altitude),1)+"km"
  if (keyword_set(fill)) then begin
    save_string = save_string+"_filled"
  endif
  if (keyword_set(basemap)) then begin
    save_string = save_string+"_"+basemap
  endif

  contour1.save, save_string+".png", BORDER=0, WIDTH=2500, HEIGHT=1250

END