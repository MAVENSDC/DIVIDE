;+
; :Name: mvn_kp_3d
; 
; :Author: Kristopher Larsen
; 
; :Description: 
;   Interactive 3D visualization of MAVEN spacecraft trajectory 
;   and insitu/iuvs KP parameters.
;
; :Params:
;    insitu: in, required, type=structure
;       This is the full or maniuplated MAVEN KP insitu data structure. 
;       At a minimum, it must contain the SPACECRAFT substructure.
;    iuvs: in, optional, type=structure
;    time: in, optional, 
;       can be a scalar or a two or three item array of type:
;         long(s)        orbit number
;         string(s)      format:  YYYY-MM-DD/hh:mm:ss       
;       If only one time provided, that defines the initial display point of 
;       the visualization.
;       Two times provided are assumed to be start and stop times.
;       Three times provided are start/display/stop times.
;    
;    basemap: in, optional, type=string
;       the name of the basemap to display. If not included, then lat/lon
;       grid is shown .
;         'MDIM': The Mars Digital Image Model.
;         'MOLA': Mars Topography in color.
;         'MOLA_BW': Mars topography in black and white.
;         'MAG':  Mars crustal magnetism.
;         'DUST': IUVS Apopase Dust index image.
;         'OZONE': IUVS Apopase Ozone index image.
;         'RAD_H': IUVS Apopase H Radiance image.
;         'RAD_O': IUVS Apopase O Radiance image.
;         'RAD_CO': IUVS Apopase CO Radiance image.
;         'RAD_NO': IUVS Apopase NO Radiance image.
;         'USER': User definied basemap. Will open a file dialog window
;                 to select the image.
;    field: in, optional, type=string
;       The name of the field to initiall plot in the widget window
;    minimum: in, optional, type=float
;       THe minimum value to assign to color level 0
;    maximum: in, optional, type=float
;       The maximum value to assign to color level 255
;    bgcolor: in, optional, type=byte or bytarr(3)
;       Define the background color for the widget window.
;       If single byte value, assign a gray between 0(black) and 255(white)
;       If three-element bytarr, it is the RGB color vector
;    color_bar: in, optional, type=bytearr(3) or boolean
;       If provided as a boolean, display color bar upon opening window.
;       Define the text color for the color bar in the plotting subwindow
;       as an RGB vector.
;    parameterplot: in, optional, type=boolean or structure
;       If boolean, display the chosen parameter or S/C altitude at the 
;       bottom of the widget window.
;       If a structure, it provides the information to create the plot
;    ambient: in, optional, type=float
;       Define the intensity of the flashlight that mimics sunlight.
;       Be aware, a setting of 0.0 does NOT create a crisp terminator.
;    initialview: in, optional, type=fltarr(3) or fltarr(5)
;       Define the initial view of the planet.  The fields are:
;       latitude, longitude, radius [,x offset, y offset]
;    scale_factor: in, optional, type=float
;       Scale down the widget window for smaller screens.  As of now, this 
;       also reduces button sizes, so a small enough value could render 
;       the widget unuseable.
;    spacecraft_scale: in, optional, type=float
;       Change the scale size of the MAVEn S/C.  Default value is 0.03
;       
; :Keywords:
;    list: in, optional, type=boolean
;       if selected, will list the KP data fields included in kp_data.
;    range: in, optional, type=boolean
;       if selected, will list the beginning and end times of kp_data.
;    subsolar: in, optional, type=boolean
;       if selected, will plot the subsolar point with a yellow disk.
;    sunmodel: in, optional, type=boolean
;       if selected, will plot the Mars-Sun vector as a yellow line.
;    submaven: in, optional, type=boolean
;       if selected, will plot the sub S/C point with a blue disk.
;    grid: in, optional, type=boolean
;       if selected overplot lat/lon grid with 30/45 deg res respectively
;    mso: in, optional, type=boolean
;       if selected, plot the S/C track and data in MSO coordinates
;    axes: in, optional, type=boolean
;       if selected, plot the XYZ axes in the widget window.  MSO or GEO.
;    log: in, optional, type=boolean
;       if selected, use log scale for all visualizations
;    optimize: in, optional, type=boolean
;       For large data structures, the plotting of the orbital track can
;       get very slow. This keyword decimates the track to a managable size.
;    direct: in, optional, type=boolean
;       if selected, create direct graphics plots with no widget ability.
;    help: Invoke this list.
;
;  :Obsolete:
;    drawid: Undetermined and unused keyword or parameter
;    speckle: Undetermined and unused keyword or parameter
;-

pro MVN_KP_3D, insitu, iuvs=iuvs, time=time, basemap=basemap, grid=grid, $
               cow=cow, tron=tron, subsolar=subsolar, submaven=submaven, $
;               field=field, minimum=minimum, maximum=maximum, $
               field=field, $
               colorbar_min=colorbar_min, colorbar_max=colorbar_max, $
               log=log, color_table=color_table, bgcolor=bgcolor, $
               plotname=plotname, color_bar=color_bar,axes=axes,$
               whiskers=whiskers,parameterplot=parameterplot,$
               periapse_limb_scan=periapse_limb_scan, direct=direct, $
               ambient=ambient,view_size=view_size, camera_view=camera_view, $
               mso=mso, sunmodel=sunmodel, optimize=optimize, $
               initialview=initialview, drawid=drawid, $
               scale_factor=scale_factor, spacecraft_scale=spacecraft_scale, $
               speckle=speckle, range=range, list=list, help=help
  
  common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
  
  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_3d'
    return
  endif

  ;CHECK THE insitu1 DATA STRUCTURE FOR RELEVANT FIELDS
  MVN_KP_TAG_PARSER, insitu, base_tag_count, first_level_count, $
    second_level_count, base_tags,  first_level_tags, $
    second_level_tags
  
  ;variables to be added to command line at some points
  apoapse_image_choice = 'Ozone Depth' ; ????
  
  ;correction for IDL 'features' in 8.1

   if Float(!Version.Release) LE 8.1 THEN BEGIN
    ;USE DIRECT GRAPHICS IF USER HAS OLD VERSION OF IDL
    orbit_offset = 0.00001
   endif else begin
    orbit_offset = 0.001
   endelse
      
   ;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET

   if keyword_set(list) then begin
     if arg_present(list) then begin
       ; return the KP list to the provided variable
       mvn_kp_get_list, kp_data, list=list
     endif else begin
       ; print the KP list to screen
       mvn_kp_get_list, kp_data, /list
     endelse
     return
   endif

   ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS
   ;IF REQUESTED.
   if keyword_set(range) then begin
     mvn_kp_range,insitu,iuvs=iuvs
     return
   endif
  
   ;OPTIMIZATION OPTION

   if keyword_set(optimize) then begin
; For now, just use the optimization to ~5000 points
;     if( size(optimize,/type) eq 3 or size(optimize,/type) eq 4 or $
;         size(optimize,/type) eq 5 )then begin
       ; only proceed if the optimization value is given as an integer
       ; data type or integer-like data type (byte, int, long)
       ; May expand to uint, etc. at a future date
;       optimizer = optimize
;     endif else begin
;       print,"*****WARNING*****"
;       print,"Use of 'optimize=<value>' recognized ONLY if value is of '
;       print,"type BYTE, INT, or LONG."
       
 ;    endelse
     optimizer = round(n_elements(insitu[begin_index:end_index])/5000.)
     MVN_KP_3D_OPTIMIZE, insitu, insitu1, optimizer
   endif else begin
     insitu1 = insitu;[begin_index:end_index]
   endelse

  ;PARSE DATA STRUCTURES FOR BEGINNING, END, AND MID TIMES
    ;SET THE TIME BOUNDS BASED ON THE INSITU DATA STRUCTURE
    
   ;************************************************** 
   ; *******NEED TO RESIZE IUVS CORRECTLY AS WELL******
   ; ************************************************** 
    
      time_step_size = 10

      if( keyword_set(time) )then begin
        case size(time,/dim) of
          0: mvn_kp_range_select, insitu1, time, begin_index, end_index
          1: mvn_kp_range_select, insitu1, time, begin_index, end_index               
          2: mvn_kp_range_select, insitu1, time, begin_index, end_index
          3: begin
               ; can only accept this if input values are string or float date
               ; range_select takes care of types other than INT
               if( size(time,/type) ne 2)then begin
                 time=time[sort(time)] ; sort the three
                 ; Feed largest and smallest to range_select
                 mvn_kp_range_select, insitu1, [time[0],time[2]], $
                                      begin_index, end_index
               endif else begin
                 error_message = 'If three times are provided, ' $
                               + 'they must be either strings or floats.'
                 message, error_message
               endelse
             end
          else: begin
                  ; print error message and exit
                  error_message = 'Number of elements provided in time ' $
                                + 'variable cannot exceed 3.'
                  message, error_message
                end
        endcase
      endif else begin
      ;  time keyword is not set, use the whole data structure
        begin_index = 0L
        end_index = n_elements(insitu1)-1; if time keyword is used
      endelse
;
;  Use begin and end index to subset the input datra structure
;
      insitu1 = insitu1[begin_index:end_index]
;
;  Redefine the begin and end indices
;
      begin_index = 0L & end_index = n_elements(insitu1)-1
;
;  Now, define the opening view time for the widget window
;
      if( size(time,/dim) eq 3 )then begin
      ; open view time has been provided
        if( size(time,/type) eq 7 )then begin ; time is a string
          time_index = value_locate( insitu1.time_string, time[1] )
        endif else begin ; time is a UNIX time
          time_index = value_locate( insitu1.time, time[1] )
        endelse
      endif else begin
      ; open view time not provided: use mid-time
        time_index = end_index / 2L
      endelse
;
;  Now define the strings and times needed for widget display windows
;
      start_time = insitu1[begin_index].time
      end_time = insitu1[end_index].time
      start_time_string = time_string( start_time, format=0 )
      end_time_string = time_string( end_time, format=0 )
      initial_time = insitu1[time_index].time

  ;PARSE DATA STRUCTURES FOR KP DATA AVAILABILITY
  
    ;flags to indicate if a given instrumnet data is present
     instrument_array = intarr(19)
     
     tags=tag_names(insitu1)
     temp = where(tags eq 'LPW')
     if temp ne -1 then instrument_array[0] = 1
     temp = where(tags eq 'STATIC')
     if temp ne -1 then instrument_array[1] = 1
     temp = where(tags eq 'SWIA')
     if temp ne -1 then instrument_array[2] = 1
     temp = where(tags eq 'SWEA')
     if temp ne -1 then instrument_array[3] = 1
     temp = where(tags eq 'MAG')
     if temp ne -1 then instrument_array[4] = 1
     temp = where(tags eq 'SEP')
     if temp ne -1 then instrument_array[5] = 1
     temp = where(tags eq 'NGIMS')
     if temp ne -1 then instrument_array[6] = 1
     temp = where(tags eq 'EUV') 
     if temp ne -1 then instrument_array[18] = 1

     if keyword_set(iuvs) then begin
      instrument_array[7] = 1
      tags1 = tag_names(iuvs)
      temp = where(tags1 eq 'PERIAPSE')
      if temp ne -1 then instrument_array[8] = 1
      temp = where(tags1 eq 'APOAPSE')
      if temp ne -1 then instrument_array[9] = 1
      temp = where(tags1 eq 'CORONA_E_HIGH')
      if temp ne -1 then instrument_array[10] = 1
      temp = where(tags1 eq 'CORONA_E_DISK')
      if temp ne -1 then instrument_array[11] = 1
      temp = where(tags1 eq 'STELLAR_OCC')
      if temp ne -1 then instrument_array[12] = 1
      temp = where(tags1 eq 'CORONA_LO_HIGH')
      if temp ne -1 then instrument_array[13] = 1
      temp = where(tags1 eq 'CORONA_LO_LIMB')
      if temp ne -1 then instrument_array[14] = 1
      temp = where(tags1 eq 'CORONA_E_LIMB')
      if temp ne -1 then instrument_array[15] = 1
      temp = where(tags1 eq 'CORONA_LO_DISK')
      if temp ne -1 then instrument_array[16] = 1
     endif
     temp = where(tags eq 'USER') 
     if temp ne -1 then instrument_array[17] = 1
  
  
  ;PARSE COMMAND LINE OPTIONS FOR INITIAL CONDITIONS
  
    ;DEFINE THE BASEMAP
    install_result = routine_info('mvn_kp_3d',/source)
    install_directory = strsplit(install_result.path,'mvn_kp_3d.pro',$
                                 /extract,/regex)
    
    ;BACKGROUND COLORS
;-ToDo: these are gray scale bu they are being offered in widget as rainbow
    
    bg_colors = [[0,0,0],[15,15,15],[30,30,30],[45,45,45],[60,60,60],$
                 [75,75,75],[90,90,90],[105,105,105],[120,120,120],$
                 [135,135,135],[150,150,150],[165,165,165],[180,180,180],$
                 [195,195,195],[210,210,210],[225,225,225],[240,240,240],$
                 [255,255,255]]
  
    if keyword_set(bgcolor) then begin
      if n_elements(bgcolor) eq 3 then begin
        backgroundcolor = bgcolor
      endif else begin
        if( bgcolor lt 0 or bgcolor gt 255)then begin
          print,'** WARNING **'
          print,'  BGCOLOR supplied: ',bgcolor,' is invalid.'
          print,'  Must be either an integer between 0 and 255,'
          print,'  or a three-element [R,G,B] byte array'
          print,'  Code will now default to bgcolor=0 (black)'
          backgroundcolor = 0
        endif else begin
          backgroundcolor = replicate(bgcolor,3)
        endelse
      endelse
    endif else begin
      backgroundcolor = [15,15,15]
    endelse

    if keyword_set(field) then begin
      ;if parameter not selected, pass an invalid value
      MVN_KP_TAG_VERIFY, insitu1, field,base_tag_count, $
        first_level_count, base_tags,  $
        first_level_tags, check, level0_index, $
        level1_index, tag_array
      if check ne 0 then begin
        ;if requested parameter doesn't exist, default to none
        print,'REQUESTED PLOT PARAMETER, '+strtrim(string(field),2) $
          +' IS NOT PART OF THE DATA STRUCTURE.'
        plotted_parameter_name = ''
        current_plotted_value = ''
        level0_index = -9
        level1_index = -9
      endif else begin
        plotted_parameter_name = tag_array[0]+':'+tag_array[1]
        current_plotted_value = insitu1[time_index]$
          .(level0_index).(level1_index)
      endelse
    endif else begin
      ;if no parameter selected, default to spacecraft altitude
      field='spacecraft.altitude'
      MVN_KP_TAG_VERIFY, insitu1, field,base_tag_count, $
        first_level_count, base_tags,  $
        first_level_tags, check, level0_index, $
        level1_index, tag_array
        plotted_parameter_name = tag_array[0]+':'+tag_array[1]
        current_plotted_value = insitu1[time_index]$
          .(level0_index).(level1_index)
    endelse

    ;default colorbar settings
    if( ~arg_present(colorbar_max) )then $
      colorbar_max = max(insitu1.(level0_index).(level1_index),/NaN) ; 100.
    if (~arg_present(colorbar_min) )then $
      colorbar_min = min(insitu1.(level0_index).(level1_index),/NaN) ;0.0
    colorbar_stretch = keyword_set(log) ; 0

    ;camera viewpoint: 
    ;  0=default free view camera, 
    ;  1=spacecraft view locked camera
      if keyword_set(camera_view) ne 1 then begin
        camera_view = 0
      endif
  
    ;parse the input iuvs structure (if it exists) 
    ;to see which coronal observations are present

    if instrument_array[7] eq 1 then begin
      mvn_kp_3d_iuvs_parse, instrument_array, e_disk_list=e_disk_list, $
            e_limb_list=e_limb_list, e_high_list, lo_disk_list=lo_disk_list, $
            lo_limb_list=lo_limb_list, lo_high_list=lo_high_list
    endif

;If there is an error, replace above with the contents of 
; mvn_kp_3d_iuvs_parse, with an additional bracketing of 
; if instrument_array[7] eq 1 then begin
;   ...
; endif
    
    ;SET WHETHER GEO OR MSO COORDINATES ARE USED
    if keyword_set(mso) then begin
      coord_sys = 1
    endif else begin
      coord_sys = 0
    endelse
  
  
  ;BUILD THE WIDGET

    if keyword_set(scale_factor) then begin
      scale_factor = scale_factor
    endif else begin
      scale_factor = 1.0
    endelse

    ;set the size of the draw window
    if keyword_set(view_size) then begin
      draw_xsize = scale_factor*view_size[0]
      draw_ysize = scale_factor*view_size[1]
    endif else begin
        draw_xsize=scale_factor*800
        draw_ysize=scale_factor*800
   endelse
    
    base = widget_base(title='MAVEN Key Parameter Visualization',/column)
    subbase = widget_base(base,/row)

      ;BASE AND VISUALIZATION WINDOW
      subbaseL = widget_base(subbase)
      draw = widget_draw(subbaseL, xsize=scale_factor*draw_xsize, $
                         ysize=scale_factor*draw_ysize, graphics_level=2, $
                         /button_events, /motion_events, /wheel_events, $
                         uname='draw',retain=0, renderer=0)
    
      if keyword_set(direct) then drawid=base
    
    if keyword_set(direct) eq 0 then begin 
      ;SKIP THIS IF /DIRECT IS SET, SKIPPING THE GUI INTERFACE
      ;TOP LEVEL MENU                  
      subbaseR = widget_base(subbase)
      subbaseR1 = widget_base(subbaseR,/column)
      button1 = widget_button(subbaseR1, value='Mars/Label Options', $
                              uname='mars',xsize=scale_factor*300, $
                              ysize=scale_factor*30)
      button1 = widget_button(subbaseR1, value='In-Situ Scalar Data', $
                              uname='insitu', xsize=scale_factor*300, $
                              ysize=scale_factor*30)
      if( (instrument_array[1] eq 1) or $
          (instrument_array[2] eq 1) or $
          (instrument_array[4] eq 1) or $
          (instrument_array[5] eq 1) )then begin
        button1 = widget_button(subbaseR1, value='In-Situ Vector Data', $
                                uname='insitu_vector', $
                                xsize=scale_factor*300,ysize=scale_factor*30)
      endif
      if instrument_array[7] eq 1 then begin
        button1 = widget_button(subbaseR1, value='IUVS Data', uname='iuvs', $
                                xsize=scale_factor*300, ysize=scale_factor*30)
      endif
      button1 = widget_button(subbaseR1, value='Viewing Geometries', $
                              uname='views', xsize=scale_factor*300, $
                              ysize=scale_factor*30)
      button1 = widget_button(subbaseR1, value='Models', uname='models', $
                              xsize=scale_factor*300,ysize=scale_factor*30)
      button1 = widget_button(subbaseR1, value='Outputs', uname='output', $
                              xsize=scale_factor*300,ysize=scale_factor*30)
      button1 = widget_button(subbaseR1, value='Animation', $
                              uname='animation', xsize=scale_factor*300, $
                              ysize=scale_factor*30)
      widget_control,button1,sensitive=0
      button1 = widget_button(subbaseR1, value='Help', uname='help',$
                              xsize=scale_factor*300,ysize=scale_factor*30)       
 
      ;TIME BAR ACROSS THE BOTTOM

      tbase = widget_base(base,/row)
      timebarbase = widget_base(tbase, /column,/frame, /align_left, $
                                xsize=scale_factor*1000)

;PROVIDES LATER ABILITY TO CHANGE AND UPDATE START/END TIMES
      time_min=start_time
      time_max = end_time
      timelabelbase = widget_base(timebarbase, xsize=scale_factor*1000, $
                                  ysize=scale_factor*20, /row)
      label5 = $
        widget_label(timelabelbase, $
                     value=strtrim(string(time_string(time_min,format=4)),2), $ 
                     scr_xsize=scale_factor*200, /align_left)
      label6 = widget_label(timelabelbase, value='Time Range', /align_center, $
                            scr_xsize=scale_factor*590)
      label7 = $
        widget_label(timelabelbase, $
                     value=strtrim(string(time_string(time_max,format=4)),2), $
                     scr_xsize=scale_factor*200, /align_right)
      timeline = cw_fslider(timebarbase, /drag, maximum=time_max, $
                            minimum=time_min, /double, uname='time', $
                            title='Displayed Time',xsize=scale_factor*1000, $
                            /edit,/suppress_value)
      tbase1 = widget_base(tbase,/column,/align_center)
      label1 = widget_label(tbase1, value='Step Size')
      text1 = widget_text(tbase1, value=strtrim(string(time_step_size),2), $
                          uname='timestep_define',/editable,$
                          xsize=scale_factor*7,ysize=scale_factor*1,$
                          /align_center)
      tbase2 = widget_base(tbase1,/row)
      button1 = widget_button(tbase2, value='-', uname='timeminusone',$
                              xsize=scale_factor*50) 
      button1 = widget_button(tbase2, value='+', uname='timeplusone',$
                              xsize=scale_factor*50)                     
      widget_control,timeline,set_value=initial_time

      ;MARS GLOBE/LABEL OPTIONS MENU 
      subbaseR2 = widget_base(subbaseR,/column)
      marsbase = widget_base(subbaseR2,/column)
      ;BASEMAP OPTIONS
      button1 = widget_button(marsbase, value='Spacecraft Orbit Track', $
                              uname='orbit_onoff', xsize=scale_factor*300, $
                              ysize=scale_factor*30)
      label1 = widget_label(marsbase, value='Basemap')
      basemapbase = widget_base(marsbase, /column,/frame,/exclusive)
      button1 = widget_button(basemapbase, value='MDIM',uname='basemap1',$
                              xsize=scale_factor*300,ysize=scale_factor*30, $
                              /no_release)
;      mars_base_map = 'mdim' ;-km I think this is unnecessary.
;-km The following control command sets the MDIM button.
;-km  This is in error if the basemap keyword is set.
;-km  It should set the button of the chosen basemap; default to MDIM.
      widget_control,button1, /set_button                  
      button1 = widget_button(basemapbase, value='MOLA',uname='basemap1',$
                              xsize=scale_factor*300,ysize=scale_factor*30, $
                              /no_release)                  
      button1 = widget_button(basemapbase, value='MOLA_BW',uname='basemap1',$
                              xsize=scale_factor*300,ysize=scale_factor*30, $
                              /no_release)                  
      button1 = widget_button(basemapbase, value='CRUSTAL MAG',$
                              uname='basemap1',xsize=scale_factor*300,$
                              ysize=scale_factor*30, /no_release)
      button1 = widget_button(basemapbase, value='BLANK',uname='basemap1',$
                              xsize=scale_factor*300,ysize=scale_factor*30, $
                              /no_release) 
      button1 = widget_button(basemapbase, value='User Defined',$
                              uname='basemap1',xsize=scale_factor*300,$
                              ysize=scale_factor*30, /no_release)                                          
      ;LABEL OPTIONS
      label2 = widget_label(marsbase, value='Label Options')
      gridbase = widget_base(marsbase, /column,/frame)
      button2 = widget_button(gridbase, value='Grid',uname='grid', $
                              xsize=scale_factor*300,ysize=scale_factor*30)
      button2 = widget_button(gridbase, value='Sub-Solar Point', $
                              uname='subsolar',xsize=scale_factor*300,$
                              ysize=scale_factor*30)
      button2 = widget_button(gridbase, value='Sub-Spacecraft', $
                              uname='submaven', xsize=scale_factor*300,$
                              ysize=scale_factor*30)
      button2 = widget_button(gridbase, value='Terminator', $
                              uname='terminator', xsize=scale_factor*300,$
                              ysize=scale_factor*30,sensitive=0)
      button2 = widget_button(gridbase, value='Sun Vector', $
                              uname='sunvector', xsize=scale_factor*300, $
                              ysize=scale_factor*30)
      button2 = widget_button(gridbase, value='Planet Axes', uname='axes', $
                              xsize=scale_factor*300, ysize=scale_factor*30)
      button2 = widget_button(gridbase, value='Parameters', $
                              uname='parameters', xsize=scale_factor*300, $
                              ysize=scale_factor*30)
      button2 = widget_button(gridbase, value='Plotted Values', $
                              uname='orbitPlotName', xsize=scale_factor*300, $
                              ysize=scale_factor*30)

      ;COLOR OPTIONS
      label2 = widget_label(marsbase, value='Background Color Options')
      gridbase1 = widget_base(marsbase,/column,/frame)
      loadct,13,/silent
      bgcolor = cw_clr_index(gridbase1, uname ='background_color',$
                             color_values=bg_colors,xsize=scale_factor*210,$
                             ysize=scale_factor*30)
        
      ;ambient light slider
      label2 = widget_label(marsbase, value='Ambient Light Level')
      slider2 = widget_slider(marsbase, frame=2, maximum=100, minimum=0, $
                              xsize=scale_factor*300,ysize=scale_factor*33,$
                              uname='ambient', value=50)
         
      button2 = widget_button(marsbase, value='Return',uname='mars_return', $
                              xsize=scale_factor*300,ysize=scale_factor*30)             

      ;VIEWING GEOMETRY OPTIONS MENU
      subbaseR3 = widget_base(subbaseR,/column)
      label3 = widget_label(subbaseR3, value='Camera Options', /align_center)
      subbaseR3a = widget_base(subbaseR3,/column,/exclusive,/frame)
      button3a = widget_button(subbaseR3a, value='Free-view Camera', $
                               uname='camera', xsize=scale_factor*300, $
                               ysize=scale_factor*30, /no_release)
      if camera_view eq 0 then widget_control, button3a, /set_button
      button3b = widget_button(subbaseR3a, value='Spacecraft Camera', $
                               uname='camera', xsize=scale_factor*300, $
                               ysize=scale_factor*30, /no_release)
      if camera_view eq 1 then widget_control, button3b, /set_button
      label3 = widget_label(subbaseR3,value='Coordinate Systems', $
                            /align_center)
      subbaseR3b = widget_base(subbaseR3,/column,/exclusive,/frame)
      button3c = widget_button(subbaseR3b, value='Planetocentric', $
                               uname='coordinates', xsize=scale_factor*300,$
                               ysize=scale_factor*30,/no_release)
      if coord_sys eq 0 then widget_control,button3c, /set_button
      button3d = widget_button(subbaseR3b, value='Mars-Sun', $
                               uname='coordinates', xsize=scale_factor*300,$
                               ysize=scale_factor*30,/no_release)
      if coord_sys eq 1 then widget_control, button3d, /set_button
      
      widget_control,subbaseR3a, sensitive=0
          
      button3 = widget_button(subbaseR3, value='Return',uname='view_return', $
                              xsize=scale_factor*300,ysize=scale_factor*30)
 
      ;MODEL DISPLAY OPTIONS
      subbaseR4 = widget_base(subbaseR, /column)
      label4 = widget_label(subbaseR4, value='Atmosphere Shells', $
                            /align_center)
      modbase1 = widget_base(subbaseR4, /row,/frame)
      button4 = widget_button(modbase1, value='Level 1', uname='atmLevel1', $
                              xsize=scale_factor*70, ysize=scale_factor*30)
      button41c = widget_button(modbase1, value='Load', $
                                uname='atmLevel1Load',xsize=scale_factor*50, $
                                ysize=scale_factor*30,sensitive=0)
      atmLevel1height = 100
      button41a = widget_text(modbase1, $
                              value=strtrim(string(atmlevel1height),2), $
                              uname='atmLevel1height',/editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase1, value='km')
      atmlevel1alpha = 100
      button41b = widget_text(modbase1, $
                              value=strtrim(string(atmlevel1alpha),2), $
                              uname='atmLevel1alpha', /editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase1, value='%')
      modbase2 = widget_base(subbaseR4, /row,/frame)
      button4 = widget_button(modbase2, value='Level 2', uname='atmLevel2', $
                              xsize=scale_factor*70, ysize=scale_factor*30)
      button42c = widget_button(modbase2, value='Load', $
                                uname='atmLevel2Load',xsize=scale_factor*50, $
                                ysize=scale_factor*30,sensitive=0)
      atmLevel2height = 200
      button42a = widget_text(modbase2, $
                              value=strtrim(string(atmlevel2height),2), $
                              uname='atmLevel2height',/editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase2, value='km')
      atmlevel2alpha = 100
      button42b = widget_text(modbase2, $
                              value=strtrim(string(atmlevel2alpha),2), $
                              uname='atmLevel2alpha', /editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase2, value='%')       
      modbase3 = widget_base(subbaseR4, /row,/frame)
      button4 = widget_button(modbase3, value='Level 3', uname='atmLevel3', $
                              xsize=scale_factor*70, ysize=scale_factor*30)
      button43c = widget_button(modbase3, value='Load', $
                                uname='atmLevel3Load',xsize=scale_factor*50, $
                                ysize=scale_factor*30,sensitive=0)
      atmLevel3height = 300
      button43a = widget_text(modbase3, $
                              value=strtrim(string(atmlevel3height),2), $
                              uname='atmLevel3height',/editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase3, value='km')
      atmlevel3alpha = 100
      button43b = widget_text(modbase3, $
                              value=strtrim(string(atmlevel3alpha),2), $
                              uname='atmLevel3alpha', /editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase3, value='%')    
      modbase4 = widget_base(subbaseR4, /row,/frame)
      button4 = widget_button(modbase4, value='Level 4', uname='atmLevel4', $
                              xsize=scale_factor*70, ysize=scale_factor*30)
      button44c = widget_button(modbase4, value='Load', $
                                uname='atmLevel4Load',xsize=scale_factor*50, $
                                ysize=scale_factor*30,sensitive=0)
      atmLevel4height = 400
      button44a = widget_text(modbase4, $
                              value=strtrim(string(atmlevel4height),2), $
                              uname='atmLevel4height',/editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase4, value='km')
      atmlevel4alpha = 100
      button44b = widget_text(modbase4, $
                              value=strtrim(string(atmlevel4alpha),2), $
                              uname='atmLevel4alpha', /editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase4, value='%') 
      modbase5 = widget_base(subbaseR4, /row,/frame)
      button4 = widget_button(modbase5, value='Level 5', uname='atmLevel5', $
                              xsize=scale_factor*70, ysize=scale_factor*30)
      button45c = widget_button(modbase5, value='Load', $
                                uname='atmLevel5Load',xsize=scale_factor*50, $
                                ysize=scale_factor*30,sensitive=0)
      atmLevel5height = 500
      button45a = widget_text(modbase5, $
                              value=strtrim(string(atmlevel5height),2), $
                              uname='atmLevel5height',/editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase5, value='km')
      atmlevel5alpha = 100
      button45b = widget_text(modbase5, $
                              value=strtrim(string(atmlevel5alpha),2), $
                              uname='atmLevel5alpha', /editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase5, value='%') 
      modbase6 = widget_base(subbaseR4, /row,/frame)
      button4 = widget_button(modbase6, value='Level 6', uname='atmLevel6', $
                              xsize=scale_factor*70, ysize=scale_factor*30)
      button46c = widget_button(modbase6, value='Load', $
                                uname='atmLevel6Load',xsize=scale_factor*50, $
                                ysize=scale_factor*30,sensitive=0)
      atmLevel6height = 600
      button46a = widget_text(modbase6, $
                              value=strtrim(string(atmlevel6height),2), $
                              uname='atmLevel6height',/editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase6, value='km')
      atmlevel6alpha = 100
      button46b = widget_text(modbase6, $
                              value=strtrim(string(atmlevel6alpha),2), $
                              uname='atmLevel6alpha', /editable,$
                              xsize=scale_factor*7,ysize=scale_factor*1,$
                              sensitive=0)
      label4 = widget_label(modbase6, value='%') 
      button4 = widget_button(subbaseR4, value='Return',uname='model_return', $
                              xsize=scale_factor*300,ysize=scale_factor*30)
        
        ;OUTPUT OPTIONS
        subbaseR5 = widget_base(subbaseR, /column)
        
        button5 = widget_button(subbaseR5, value='Save Configuration',$
                                uname='config_save',xsize=scale_factor*300, $
                                ysize=scale_factor*30)
        button5 = widget_button(subbaseR5, value='Load Configuration',$
                                uname='config_load',xsize=scale_factor*300, $
                                ysize=scale_factor*30)
        button5 = widget_button(subbaseR5, value='Export View',$
                                uname='save_view',xsize=scale_factor*300,$
                                ysize=scale_factor*30)
        button5 = widget_button(subbaseR5, value='Return',$
                                uname='output_return', $
                                xsize=scale_factor*300,ysize=scale_factor*30)             
        
        ;HELP MENU
        subbaseR6 = widget_base(subbaseR, /column)
        text = widget_text(subbaseR6, /scroll,xsize=scale_factor*45,$
                           ysize=scale_factor*25)
        button6 = widget_button(subbaseR6, value='Return', $
                                uname='help_return',xsize=scale_factor*300, $
                                ysize=scale_factor*30)
        
        ;insitu1 SCALAR DATA MENU
        subbaseR7 = widget_base(subbaseR, /column)
        subbaseR7a = widget_base(subbaseR7, /column,/frame)
        label7 = widget_label(subbaseR7a, value='Orbital Track Plots')
        vert_align = 15
        if instrument_array[0] eq 1 then begin
          lpw_list = tag_names(insitu1.lpw)
          drop1=widget_droplist(subbaseR7a, value=lpw_list, uname='lpw_list', $
                                title='LPW',frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[18] eq 1 then begin
          euv_list = tag_names(insitu1.euv)
          drop1=widget_droplist(subbaseR7a, value=euv_list, uname='euv_list', $
                                title='EUV',frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[1] eq 1 then begin
          static_list = tag_names(insitu1.static)
          drop1=widget_droplist(subbaseR7a, value=static_list, $
                                uname='static_list', title='STATIC', $
                                frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[2] eq 1 then begin
          swia_list = tag_names(insitu1.swia)
          drop1=widget_droplist(subbaseR7a, value=swia_list, $
                                uname='swia_list', title='SWIA', frame=5, $
                                yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[3] eq 1 then begin
          swea_list = tag_names(insitu1.swea)
          drop1=widget_droplist(subbaseR7a, value=swea_list, $
                                uname='swea_list', title='SWEA', frame=5, $
                                yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[4] eq 1 then begin
          mag_list = tag_names(insitu1.mag)
          drop1=widget_droplist(subbaseR7a, value=mag_list, uname='mag_list', $
                                title='MAG', frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[5] eq 1 then begin
          sep_list = tag_names(insitu1.sep)
          drop1=widget_droplist(subbaseR7a, value=sep_list, $
                                uname='sep_list', title='SEP', frame=5, $
                                yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[6] eq 1 then begin
          ngims_list = tag_names(insitu1.ngims)
          drop1=widget_droplist(subbaseR7a, value=ngims_list, $
                                uname='ngims_list', title='NGIMS', frame=5, $
                                yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[17] eq 1 then begin
          user_list = tag_names(insitu1.user)
          drop1=widget_droplist(subbaseR7a, value=user_list, $
                                uname='user_list', title='User', frame=5, $
                                yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        button7 = widget_button(subbaseR7a, value='Reset Orbit Colors', $
                                uname='orbit_reset', yoffset=vert_align)
             
        button7 = widget_button(subbaseR7, value='Plot',uname='overplots', $
                                xsize=scale_factor*300,ysize=scale_factor*30) 
        subbaseR7c = widget_base(subbaseR7, /column, /frame)
        button7 = widget_button(subbaseR7c, value='ColorTable',$
                                uname='colortable',xsize=scale_factor*300,$
                                ysize=scale_factor*30)
        button7 = widget_button(subbaseR7c, value = 'Color Bar', $
                                uname='ColorBarPlot', xsize=scale_factor*300, $
                                ysize=scale_factor*30)
        subbaseR7d = widget_base(subbaseR7c, /row)
        label7 = widget_label(subbaseR7d, value='Min')
        text7 = widget_text(subbaseR7d, value=strtrim(string(colorbar_min),2), $
                            /editable,xsize=scale_factor*3,$
                            uname='colorbar_min', scr_xsize=60)
        label7 = widget_label(subbaseR7d, value='Max')
        text7 = widget_text(subbaseR7d, value=strtrim(string(colorbar_max),2), $
                            /editable,xsize=scale_factor*3,$
                            uname='colorbar_max', scr_xsize=60)
        button7 = widget_button(subbaseR7d, value='Reset', $
                                uname='colorbar_reset')
        subbaseR7e = widget_base(subbaseR7d, /row,/exclusive)
        button7a = widget_button(subbaseR7e, value='Linear', $
                                 uname='colorbar_stretch', /no_release)
        widget_control, button7a, /set_button
        button7 = widget_button(subbaseR7e, value='Log', $
                                uname='colorbar_stretch', /no_release)
        button7 = widget_button(subbaseR7, value='Return',$
                                uname='insitu_return',$
                                xsize=scale_factor*300,ysize=scale_factor*30)

        ;insitu1 VECTOR DATA MENU
        subbaseR10 = widget_base(subbaseR, /column)
            
        button10 = widget_button(subbaseR10, value='Display Vector Data', $
                                 uname='vector_display',$
                                 xsize=scale_factor*300,ysize=scale_factor*30)
        subbaseR10a = widget_base(subbaseR10, /column)
        subbaseR10b = widget_base(subbaseR10a, /column,/frame)
        vector_list = strarr(9)
        vector_list_index = 0
        if instrument_array[4] eq 1 then begin
          vector_list[vector_list_index] = 'Magnetic Field'
          vector_list_index = vector_list_index + 1
        endif
        if instrument_array[2] eq 1 then begin
          vector_list[vector_list_index] = 'SWIA H+ Flow Velocity'
          vector_list_index = vector_list_index + 1
        endif
        if instrument_array[1] eq 1 then begin
          vector_list[vector_list_index] = 'STATIC O2+ Flow Velocity'
          vector_list_index = vector_list_index + 1
          vector_list[vector_list_index] = 'STATIC H+ Char Dir'
          vector_list_index = vector_list_index + 1
          vector_list[vector_list_index] = 'STATIC Dom Ion Char Dir'
          vector_list_index = vector_list_index + 1
        endif
        if instrument_array[5] eq 1 then begin
          vector_list[vector_list_index] = 'SEP Look Direction 1 Front'
          vector_list_index = vector_list_index + 1
          vector_list[vector_list_index] = 'SEP Look Direction 1 Back'
          vector_list_index = vector_list_index + 1
          vector_list[vector_list_index] = 'SEP Look Direction 2 Front'
          vector_list_index = vector_list_index + 1
          vector_list[vector_list_index] = 'SEP Look Direction 2 Back'
          vector_list_index = vector_list_index + 1
        endif
        vector_list = vector_list[0:vector_list_index-1]
        drop1=widget_droplist(subbaseR10b, value=vector_list, $
                              uname='vector_field',title='Vector Field',$
                              frame=5)           

        label10 = widget_label(subbaseR10a, $
                               value='Vector Scale Factor, Percent')
        slider10 = widget_slider(subbaseR10a, frame=2, maximum=100, $
                                 minimum=1, xsize=scale_factor*300, $
                                 ysize=scale_factor*33,uname='vec_scale', $
                                 value=10)
        vector_scale = 1.0
                   
        subbaseR10c = widget_base(subbaseR10, /column,/frame)
        label10 = widget_label(subbaseR10c, value='Vector Magnitude Colors')
        vert_align = 15
        if instrument_array[0] eq 1 then begin
          lpw_list = tag_names(insitu1.lpw)
          drop1=widget_droplist(subbaseR10c, value=lpw_list, $
                                uname='lpw_list_vec',title='LPW',frame=5, $
                                yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[18] eq 1 then begin
          euv_list = tag_names(insitu1.euv)
          drop1=widget_droplist(subbaseR10c, value=euv_list, $
                                uname='euv_list_vec', title='EUV', frame=5, $
                                yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[1] eq 1 then begin
          static_list = tag_names(insitu1.static)
          drop1=widget_droplist(subbaseR10c, value=static_list, $
                                uname='static_list_vec', title='STATIC', $
                                frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[2] eq 1 then begin
          swia_list = tag_names(insitu1.swia)
          drop1=widget_droplist(subbaseR10c, value=swia_list, $
                                uname='swia_list_vec', title='SWIA', $
                                frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[3] eq 1 then begin
          swea_list = tag_names(insitu1.swea)
          drop1=widget_droplist(subbaseR10c, value=swea_list, $
                                uname='swea_list_vec', title='SWEA', $
                                frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[4] eq 1 then begin
          mag_list = tag_names(insitu1.mag)
          drop1=widget_droplist(subbaseR10c, value=mag_list, $
                                uname='mag_list_vec', title='MAG', $
                                frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[5] eq 1 then begin
          sep_list = tag_names(insitu1.sep)
          drop1=widget_droplist(subbaseR10c, value=sep_list, $
                                uname='sep_list_vec', title='SEP', $
                                frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        if instrument_array[6] eq 1 then begin
          ngims_list = tag_names(insitu1.ngims)
          drop1=widget_droplist(subbaseR10c, value=ngims_list, $
                                uname='ngims_list_vec', title='NGIMS', $
                                frame=5, yoffset=vert_align)
          vert_align = vert_align + 15
        endif
        vector_color_source = ['','']   
                   
        subbaseR10d = widget_base(subbaseR10, /column,/frame)
        label10 = widget_label(subbaseR10d, $
                               value='Vector Magnitude Color Method',$
                               /align_center)
        subbaseR10e = widget_base(subbaseR10d, /row,/exclusive)
        button10a = widget_button(subbaseR10e, value='All', $
                                  uname='vector_color_method',/no_release)
        widget_control,button10a,/set_button
        vector_color_method = 0
        button10b = widget_button(subbaseR10e, value='Proximity', $
                                  uname='vector_color_method',/no_release)
        widget_control,subbaseR10d,sensitive=0
                   
        if keyword_set(whiskers) ne 1 then $
          widget_control,subbaseR10a, sensitive=0
        if keyword_set(whiskers) ne 1 then $
          widget_control, subbaseR10c, sensitive=0
        if keyword_set(whiskers) ne 1 then $
          widget_control, subbaseR10d, sensitive=0
                       
        button1c = widget_button(subbaseR10, value='Return',$
                                 uname='insitu_vector_return',$
                                 xsize=scale_factor*300,ysize=scale_factor*30)


        ;IUVS MENU
        subbaseR8 = widget_base(subbaseR, /column)
        if instrument_array[8] eq 1 then begin 
          ;PERIAPSE LIMB SCAN OPTIONS
          subbaseR8a = widget_base(subbaseR8, /column,/frame) 
          label8 = widget_label(subbaseR8a, value='Periapse Limb Scans', $
                                /align_center)
          button8b = widget_button(subbaseR8a, value='Display All Profiles', $
                                   uname='periapse_all', $
                                   xsize=scale_factor*300, $
                                   ysize=scale_factor*30)
          subbaseR8b = widget_base(subbaseR8a, /column,sensitive=0)
          peri_den_list = 'Density: '+strtrim(iuvs[0].periapse[0].density_id,2)
          drop1=widget_droplist(subbaseR8b,value=peri_den_list,$
                                uname='peri_select',title='Density Profiles', $
                                frame=5)
          peri_rad_list = 'Radiance: '$
                        + strtrim(iuvs[0].periapse[0].radiance_id,2)
          drop1=widget_droplist(subbaseR8b,value=peri_rad_list,$
                                uname='peri_select',title='Radiance Profiles', $
                                frame=5)
          button8 = widget_button(subbaseR8b, $
                                  value='Display Altitude Profile', $
                                  uname='peri_profile', $
                                  xsize=scale_factor*300, $
                                  ysize=scale_factor*30)                  
          button8 = widget_button(subbaseR8b, value='Select Individual Scans', $
                                  uname='periapse_some', $
                                  xsize=scale_factor*300, $
                                  ysize=scale_factor*30)
          slider8 = widget_slider(subbaseR8b, Title='Limb Scale Factor', $
                                  uname='periapse_scaler', $
                                  xsize=scale_factor*300, $
                                  ysize=scale_factor*35,minimum=1,maximum=20)
        endif
        if instrument_array[9] eq 1 then begin
          ;APOAPSE IMAGING OPTIONS
          subbaseR8c = widget_base(subbaseR8, /column, /frame)
          button8a = widget_button(subbaseR8c, $
                                   value='Display Apoapse Images', $
                                   uname='apoapse_image', $
                                   xsize=scale_factor*300, $
                                   ysize=scale_factor*30)
          subbaseR8d = widget_base(subbaseR8c, /row, sensitive=0)
          subbaseR8e = widget_base(subbaseR8d, /column, /exclusive,/frame)
          button8 = widget_button(subbaseR8e, value='Ozone Depth', $
                                  uname='apoapse_select', $
                                  xsize=scale_factor*150, $
                                  ysize=scale_factor*15, /no_release)
          widget_control,button8,/set_button
          button8 = widget_button(subbaseR8e, value='Dust Depth', $
                                  uname='apoapse_select', $
                                  xsize=scale_factor*150, $
                                  ysize=scale_factor*15, /no_release)
          apo_rad_list = 'Radiance Map: '$
                       + strtrim(iuvs[0].apoapse[0].radiance_id, 2)
          for i=0,n_elements(apo_rad_list)-1 do begin
            button8 = widget_button(subbaseR8e, value=apo_rad_list[i], $
                                    uname='apoapse_select', $
                                    xsize=scale_factor*150, $
                                    ysize=scale_factor*15)
          endfor
          subbaseR8f = widget_base(subbaseR8d, /column, /frame)
          label8 = widget_label(subbaseR8f, value='Blend Options', $
                                /align_center)
          subbaseR8g = widget_base(subbaseR8f, /exclusive,/column)
          button8g = widget_button(subbaseR8g, uname='apo_blend', $
                                   value='None',xsize=scale_factor*150, $
                                   ysize=scale_factor*15,/no_release)
          widget_control,button8g,/set_button
          apoapse_blend=0
          button8g = widget_button(subbaseR8g, uname='apo_blend', $
                                   value='Average', xsize=scale_factor*150, $
                                   ysize=scale_factor*15, /no_release)
          label8 = widget_label(subbaseR8f, value='Time Blend', /align_center)
          subbaseR8gb = widget_base(subbaseR8f, /exclusive, /column)
          button8ga = widget_button(subbaseR8gb, uname='apo_time', $
                                    value='Exact', xsize=scale_factor*150, $
                                    ysize=scale_factor*15, /no_release)
          widget_control, button8ga, /set_button
          apo_time_blend = 0
          button8ga = widget_button(subbaseR8gb, uname='apo_time', $
                                    value='Nearest', xsize=scale_factor*150, $
                                    ysize=scale_factor*15, /no_release) 
        endif

        ;CORONAL SCAN DISPLAY
        if( (instrument_array[10] eq 1) or $
            (instrument_array[11] eq 1) or $
            (instrument_array[13] eq 1) or $
            (instrument_array[14] eq 1) or $
            (instrument_array[15] eq 1) or $
            (instrument_array[16] eq 1) )then begin
          subbaseR8h = widget_base(subbaseR8, /column, /frame)
          label8 = widget_label(subbaseR8h, value='Coronal Scans', $
                                /align_center)
          subbaseR8h1 = widget_base(subbaseR8h, /row)
          subbaseR8ha = widget_base(subbaseR8h1, /column)
          subbaseR8i = widget_base(subbaseR8ha, /column, /frame)
          subbaseR8i1 = widget_base(subbaseR8i, /row)
          if instrument_array[16] eq 1 then begin
            drop8a = widget_droplist(subbaseR8i1, value=lo_disk_list, $
                                     uname='corona_lo_disk', $
                                     ysize=scale_factor*28)
            button8a = widget_button(subbaseR8i1, value='LoadCT', $
                                     uname='loadct_cld', ysize=scale_factor*28)
            label8a = widget_label(subbaseR8i1, value='Alpha')
            text8a = widget_text(subbaseR8i1, value='100', uname='alpha_cld', $
                                 xsize=3, /editable)
            corona_lo_disk_alpha=100
          endif
          subbaseR8i2 = widget_base(subbaseR8i, /row)
          if instrument_array[14] eq 1 then begin
            drop8b = widget_droplist(subbaseR8i2, value=lo_limb_list, $
                                     uname='corona_lo_limb', $
                                     ysize=scale_factor*28)
            button8b = widget_button(subbaseR8i2, value='LoadCT', $
                                     uname='loadct_cll', ysize=scale_factor*28)
            label8b = widget_label(subbaseR8i2, value='Alpha')
            text8b = widget_text(subbaseR8i2, value='100', uname='alpha_cll', $
                                 xsize=3, /editable)
            corona_lo_limb_alpha = 100
          endif
          subbaseR8i3 = widget_base(subbaseR8i, /row)
          if instrument_array[13] eq 1 then begin
            drop8c = widget_droplist(subbaseR8i3, value=lo_high_list, $
                                     uname='corona_lo_high', $
                                     ysize=scale_factor*28)
            button8c = widget_button(subbaseR8i3, value='LoadCT', $
                                     uname='loadct_clh', ysize=scale_factor*28)
            label8c = widget_label(subbaseR8i3, value='Alpha')
            text8c = widget_text(subbaseR8i3, value='100', uname='alpha_clh', $
                                 xsize=3, /editable)
            corona_lo_high_alpha=100
          endif
          subbaseR8j = widget_base(subbaseR8ha, /column, /frame)
          subbaseR8j1 = widget_base(subbaseR8j, /row)
          if instrument_array[11] eq 1 then begin
            drop8d = widget_droplist(subbaseR8j1, value=e_disk_list, $
                                     uname='corona_e_disk', $
                                     ysize=scale_factor*28)
            button8d = widget_button(subbaseR8j1, value='LoadCT', $
                                     uname='loadct_ced', ysize=scale_factor*28)
            label8d = widget_label(subbaseR8j1, value='Alpha')
            text8d = widget_text(subbaseR8j1, value='100', uname='alpha_ced', $
                                 xsize=3, /editable)
            corona_e_disk_alpha = 100
          endif
          subbaseR8j2 = widget_base(subbaseR8j, /row)
          if instrument_array[15] eq 1 then begin
            drop8e = widget_droplist(subbaseR8j2, value=e_limb_list, $
                                     uname='corona_e_limb', $
                                     ysize=scale_factor*28)
            button8e = widget_button(subbaseR8j2, value='LoadCT', $
                                     uname='loadct_cel', ysize=scale_factor*28)
            label8e = widget_label(subbaseR8j2, value='Alpha')
            text8e = widget_text(subbaseR8j2, value='100', uname='alpha_cel', $
                                 xsize=3, /editable)
            corona_e_limb_alpha = 100
          endif
          subbaseR8j3 = widget_base(subbaseR8j, /row)
          if instrument_array[10] eq 1 then begin
            drop8f = widget_droplist(subbaseR8j3, value=e_high_list, $
                                     uname='corona_e_high', $
                                     ysize=scale_factor*28)  
            button8f = widget_button(subbaseR8j3, value='LoadCT', $
                                     uname='loadct_ceh', ysize=scale_factor*28)
            label8f = widget_label(subbaseR8j3, value='Alpha')
            text8f = widget_text(subbaseR8j3, value='100', uname='alpha_ceh', $
                                 xsize=3, /editable)
            corona_e_high_alpha = 100
          endif               
            ;   subbaseR8h2 = widget_base(subbaseR8h1, /column)
            ;   label8 = widget_label(subbaseR8h2, value='Options')
            ;    subbaseR8hb = widget_base(subbaseR8h2, /column, /exclusive)
            ;    button8h = widget_button(subbaseR8hb, value='Erase Orbit', uname='coronal_reset',/no_release)
            ;    widget_control,button8h,/set_button
            ;    coronal_reset = 1
            ;    button8h = widget_button(subbaseR8hb, value='Keep Orbit', uname='coronal_reset', /no_release)
         endif
          
         button8 = widget_button(subbaseR8, value='Return', $
                                 uname='iuvs_return',xsize=scale_factor*300, $
                                 ysize=scale_factor*30)
          
         ;ANIMATION MENU
         subbaseR9 = widget_base(subbaseR, /column)
         label9 = widget_label(subbaseR9, value='Animation Options', $
                               /align_center)
            
         label9 = widget_label(subbaseR9, value='Full Time Animation', $
                               /align_center)
         subbaseR9a = widget_base(subbaseR9, /row,/align_center)
         label9 = widget_label(subbaseR9a, value='Step Size')
         text9 = widget_text(subbaseR9a, value='10', uvalue='animation_step', $
                             /editable, xsize=10)
         button9a = widget_button(subbaseR9, value='Forward', $
                                  uname='full_time_anim_begin')
         button9b = widget_button(subbaseR9, value='Backward', $
                                  uname='full_time_anim_end',sensitive=0)
            
         button9 = widget_button(subbaseR9, value='Return', $
                                 uname='anim_return', xsize=scale_factor*300, $
                                 ysize=scale_factor*30)
            
       endif         ;END OF THE WIDGET CREATION LOOP (SKIPPED IF /DIRECT SET)      
          
       widget_control, base,/realize
       widget_control, draw, get_value=window  
  
  ;SET THE INITIAL VIEWING DETAILS

       view = obj_new('IDLgrView', color=backgroundcolor, $
                      viewplane_rect=[-2,-2,4,4], eye=5.1,projection=2)
       view -> SetProperty, zclip = [5.0,-5.0]
       model = obj_new('IDLgrModel')
       view -> add, model
    
      ;DEFINE THE BASEMAP
      if keyword_set(basemap) eq 0 then begin
        if !version.os_family eq 'unix' then begin
          bm_install_directory = install_directory+'/basemaps/'
        endif else begin
          bm_install_directory = install_directory+'\basemaps\'
        endelse
        ;USE MDIM AS DEFAULT BASEMAP FOR NOW
        read_jpeg,bm_install_directory+'MDIM_2500x1250.jpg',image     
        mars_base_map = 'mdim'
      endif else begin
        if !version.os_family eq 'unix' then begin
          bm_install_directory = install_directory+'/basemaps/'
        endif else begin
          bm_install_directory = install_directory+'\basemaps\'
        endelse
        case basemap of 
          'mdim':begin
                  read_jpeg,bm_install_directory+'MDIM_2500x1250.jpg',image
                  mars_base_map = 'mdim
                 end
          'mola': begin
                   read_jpeg,bm_install_directory+'MOLA_color_2500x1250.jpg', $
                             image
                   mars_base_map = 'mola'
                  end
          'mola_bw': begin
                      read_jpeg,bm_install_directory+'MOLA_BW_2500x1250.jpg', $
                                image
                      mars_base_map = 'mola_bw'
                     end
          'mag': begin
                  read_jpeg,bm_install_directory+'MAG_Connerny_2005.jpg',$
                            image
                  mars_base_map = 'mag'
                 end
          else: begin
                 read_jpeg, basemap,image
                 mars_base_map = 'user'
                end
        endcase
      endelse
    
      ;BUILD THE GLOBE
      mars_globe = obj_new('IDLgrModel')
      model -> add, mars_globe
      npoints=361
      rplanet = .33962
      arr = REPLICATE(rplanet,npoints,npoints)
      mesh_obj, 4, vertices, polygons, arr
      oImage = OBJ_NEW('IDLgrImage', image )
      vector = FINDGEN(npoints)/(npoints-1.) 
      texure_coordinates = FLTARR(2, npoints, npoints) 
      texure_coordinates[0, *, *] = vector # REPLICATE(1., npoints) 
      texure_coordinates[1, *, *] = REPLICATE(1., npoints) # vector 
      oPolygons = OBJ_NEW('IDLgrPolygon', $ 
                          DATA = vertices, POLYGONS = polygons, $ 
                          COLOR = [255, 255, 255], reject=1, shading=1,$ 
                          TEXTURE_COORD = texure_coordinates, $ 
                          TEXTURE_MAP = oImage, /TEXTURE_INTERP)
      mars_globe -> ADD, oPolygons  
     
      ;ADD ADDITIONAL 'GLOBES' WITH TEMPORARY TEXTURE FOR LATER ATM MODELS
      ;Note: These will always be in MSO coordinates 
      MVN_KP_3D_ATMSHELL, atmModel1, oPolygons1, .34962
      MVN_KP_3D_ATMSHELL, atmModel2, oPolygons2, .35962
      MVN_KP_3D_ATMSHELL, atmModel3, oPolygons3, .36962
      MVN_KP_3D_ATMSHELL, atmModel4, oPolygons4, .37962
      MVN_KP_3D_ATMSHELL, atmModel5, oPolygons5, .38962
      MVN_KP_3D_ATMSHELL, atmModel6, oPolygons6, .39962
    
      view -> add, atmModel1
      view -> add, atmModel2
      view -> add, atmModel3
      view -> add, atmModel4
      view -> add, atmModel5
      view -> add, atmModel6
      atmModel1->setproperty,hide=1
      atmModel2->setproperty,hide=1
      atmModel3->setproperty,hide=1
      atmModel4->setproperty,hide=1
      atmModel5->setproperty,hide=1
      atmModel6->setproperty,hide=1
      
      ;Need to rotate 180 degrees
      atmModel1 -> rotate, [0,0,1], 180
      atmModel2 -> rotate, [0,0,1], 180
      atmModel3 -> rotate, [0,0,1], 180
      atmModel4 -> rotate, [0,0,1], 180
      atmModel5 -> rotate, [0,0,1], 180
      atmModel6 -> rotate, [0,0,1], 180
      
     
      ;ADD LINES   DEFAULT THAT GRIDLINES ARE NOT SHOWN
      ;LATITUDE
      if keyword_set(grid) then begin
        if n_elements(grid) eq 3 then begin
          grid_color = grid
        endif else begin
          grid_color = [0,0,0]
        endelse
      endif
      xcenter = 0
      ycenter = 0
      rplanet = .33962
      ogridarr =objarr(13)
      points = (2*!pi/359.0) * FINDGEN(360)
      radius = rplanet+(rplanet*0.0001)
      for i=0,4 do begin
        x = (xcenter + radius * cos(points))*cos((-60.+(30.*i))*!dtor)
        y = (ycenter + radius * sin(points))*cos((-60.+(30.*i))*!dtor)
        z = (points*0.)+(ycenter + (radius * sin((-60.+(30.*i))*!dtor)))
        arr = transpose ([[x],[y],[z]])
        ogridarr[i] = obj_new('IDLgrPolyline',arr,linestyle=2,thick=2,$
                              color=grid_color)
      endfor
     ;LONGITUDE
      for i=0,7 do begin
        x = xcenter + radius * cos((45.*i)*!dtor) * cos(points)
        y = ycenter + radius * sin((45.*i)*!dtor) * cos(points)
        z = ycenter + radius * sin(points)
        arr = transpose([[x],[y],[z]])
        ogridarr[5+i] = obj_new('IDLgrPolyline',arr,linestyle=2,thick=2,$
                                color=grid_color)
      endfor
      gridlines = obj_new('IDLgrModel')
      for i = 0, n_elements(ogridarr) - 1 do gridlines -> ADD, ogridarr[i]
      mytext_north = OBJ_NEW('IDLgrText', 'N', $
                             LOCATION=[0,0,rplanet+0.00001], $
                             COLOR=[255,255,255],onglass=1,$
                             char_dimensions=[10,10],$
                             render_method=render_method)
      gridlines->Add, mytext_north  
      mytext_south = OBJ_NEW('IDLgrText', 'S', $
                             LOCATION=[0,0,-rplanet-0.00001], $
                             COLOR=[255,255,255],onglass=1,$
                             char_dimensions=[10,10],$
                             render_method=render_method)
      gridlines->Add, mytext_south
      view -> add, gridlines
      gridlines -> setProperty, hide=1
      
      if keyword_set(grid) then gridlines -> setProperty,hide=0

    ;ADD THE LIGHTING
      lightModel = obj_new('IDLgrModel')
      model->add, lightModel
      
    ;LIGHT FROM THE SUN (CALCULATED TO BE IN THE RIGHT PLACE)
      ;CONVERT SOLAR POSITION TO X,Y,Z
      solar_x_coord $
        = 10000. $
        * cos(insitu1.spacecraft.subsolar_point_geo_latitude*!dtor) $
        * cos(insitu1.spacecraft.subsolar_point_geo_longitude*!dtor)
      solar_y_coord $
        = 10000. $
        * cos(insitu1.spacecraft.subsolar_point_geo_latitude*!dtor) $
        * sin(insitu1.spacecraft.subsolar_point_geo_longitude*!dtor)
      solar_z_coord $
        = 10000. $
        * sin(insitu1.spacecraft.subsolar_point_geo_latitude*!dtor)
      
      dirLight = obj_new('IDLgrLight', type=2, $
                         location=[solar_x_coord[time_index],$
                         solar_y_coord[time_index],solar_z_coord[time_index]])
      lightModel->add, dirLight
      
      ;OVERALL LIGHTING FOR THE DARKSIDE
      
      ambientLight = obj_new('IDLgrLight', type=0, intensity=0.5)
      lightModel->add, ambientLight
      if keyword_set(ambient) then begin
        ambientLight->setproperty, intensity=ambient
      endif

    ;ADD A VECTOR POINTING TO THE SUN, IF REQUESTED 
      sun_model = obj_new('IDLgrModel')
      view->add, sun_model
      
      sun_vector = obj_new('IDLgrPolyline',$
                           [0,solar_x_coord[time_index]],$
                           [0,solar_y_coord[time_index]],$
                           [0,solar_z_coord[time_index]],$
                           color=[255,255,0],thick=1)
      for i=0, n_elements(sun_vector) -1 do sun_model->add, sun_vector[i]
      sun_model->setproperty,hide=1
      if keyword_set(sunmodel) then sun_model->setproperty,hide=0
      
    ;ADD THE TERMINATOR 
  
    ;ADD THE SUB-SOLAR POINT
    
      sub_solar_model = obj_new('IDLgrModel')
      view->add,sub_solar_model
      sub_solar_point = obj_new('IDLgrSymbol',data=24, color=[255,255,0], $
                                fill_color=[255,255,0], filled=1, $
                                size=[0.02,0.02,0.02])
      subsolar_x_coord $
        = rplanet $
        * cos(insitu1.spacecraft.subsolar_point_geo_latitude*!dtor) $
        * cos(insitu1.spacecraft.subsolar_point_geo_longitude*!dtor)
      subsolar_y_coord $
        = rplanet $
        * cos(insitu1.spacecraft.subsolar_point_geo_latitude*!dtor) $
        * sin(insitu1.spacecraft.subsolar_point_geo_longitude*!dtor)
      subsolar_z_coord $
        = rplanet $
        * sin(insitu1.spacecraft.subsolar_point_geo_latitude*!dtor)
      
      sub_solar_line = obj_new('IDLgrPolyline', $
                               [subsolar_x_coord[time_index],$
                                subsolar_x_coord[time_index]],$
                               [subsolar_y_coord[time_index],$
                                subsolar_y_coord[time_index]],$
                               [subsolar_z_coord[time_index],$
                                subsolar_z_coord[time_index]],$
                               color=[255,255,0],thick=1,$
                               symbol=sub_solar_point)
      for i=0,n_elements(sub_solar_line) -1 do $ ; note continued for loop line
        sub_solar_model -> add,sub_solar_line[i]
      sub_solar_model -> setproperty,hide=1
      if keyword_set(subsolar) then sub_solar_model ->setproperty,hide=0
    
    ;ADD THE SUB-SPACECRAFT POINT IN GEO COORDINATES
      sub_maven_model = obj_new('IDLgrModel')
      view->add,sub_maven_model
      submaven_point = obj_new('IDLgrSymbol',data=18, color=[0,0,255], $
                               fill_color=[0,0,255], filled=1, $
                               size=[0.02,0.02,0.02])
      submaven_x_coord $
        = rplanet $
        * cos(insitu1.spacecraft.sub_sc_latitude*!dtor) $
        * cos(insitu1.spacecraft.sub_sc_longitude*!dtor)
      submaven_y_coord $
        = rplanet $
        * cos(insitu1.spacecraft.sub_sc_latitude*!dtor) $
        * sin(insitu1.spacecraft.sub_sc_longitude*!dtor)
      submaven_z_coord $
        = rplanet * sin(insitu1.spacecraft.sub_sc_latitude*!dtor)
         
      sub_maven_line = obj_new('IDLgrPolyline', $
                               [submaven_x_coord[time_index],$
                                submaven_x_coord[time_index]],$
                               [submaven_y_coord[time_index],$
                                submaven_y_coord[time_index]],$
                               [submaven_z_coord[time_index],$
                                submaven_z_coord[time_index]],$
                               color=[0,0,255],thick=1,symbol=submaven_point)
      for i=0,n_elements(sub_maven_line) -1 do $ ; note continued for loop
        sub_maven_model -> add,sub_maven_line[i]
      sub_maven_model -> setproperty,hide=1
      if( keyword_set(submaven) and (keyword_set(mso) eq 0) )then $
        sub_maven_model ->setproperty,hide=0    
    
    ;ADD THE SUB-SPACECRAFT POINT IN MSO COORDINATES
      sub_maven_model_mso = obj_new('IDLgrModel')
      view->add, sub_maven_model_mso
      alt_scale = ( insitu1.spacecraft.altitude + (rplanet*10000.0) ) $
                / ( rplanet*10000.0 )
      submaven_x_coord_mso = (insitu1.spacecraft.mso_x/10000.0)/alt_scale
      submaven_y_coord_mso = (insitu1.spacecraft.mso_y/10000.0)/alt_scale
      submaven_z_coord_mso = (insitu1.spacecraft.mso_z/10000.0)/alt_scale
      
      sub_maven_line_mso = obj_new('IDLgrPolyline', $
                                   [submaven_x_coord_mso[time_index],$
                                    submaven_x_coord_mso[time_index]],$
                                   [submaven_y_coord_mso[time_index],$
                                    submaven_y_coord_mso[time_index]],$
                                   [submaven_z_coord_mso[time_index],$
                                    submaven_z_coord_mso[time_index]],$
                                   color=[0,0,255],thick=1,$
                                   symbol=submaven_point)
      for i=0, n_elements(sub_maven_line_mso) -1 do $
        sub_maven_model_mso->add,sub_maven_line_mso[i]
      sub_maven_model_mso -> setproperty,hide=1
      if( keyword_set(submaven) and keyword_set(mso) )then $
        sub_maven_model_mso->setproperty,hide=0
   
    ;ADD THE GEOCENTRIC AXES TO THE PLANET
      if keyword_set(axes) then begin
        if n_elements(axes) eq 3 then begin
          axes_color = axes
        endif else begin
          axes_color = [255,255,255]
        endelse
      endif else begin
          axes_color = [255,255,255]
      endelse
      axesModel = obj_new('IDLgrModel')
      xticks = obj_new('idlgrtext',['1','2','3'])
      yticks = obj_new('idlgrtext',['1','2','3'])
      zticks = obj_new('idlgrtext',['1','2','3'])
      xticktitle=obj_new('idlgrtext','GEO-X')
      yticktitle=obj_new('idlgrtext','GEO-Y')
      zticktitle=obj_new('idlgrtext','GEO-Z')
      Xaxis = obj_new('IDLgraxis',0, thick=2,$
                      tickvalues=[.33962,.67924,1.01886],ticktext=Xticks,$
                      ticklen=0.1,title=xticktitle,color=axes_color)
      Yaxis = obj_new('IDLgraxis',1, thick=2,$
                      tickvalues=[.33962,.67924,1.01886],ticktext=Yticks,$
                      ticklen=0.1,title=yticktitle,color=axes_color)
      Zaxis = obj_new('IDlgraxis',2, thick=2,$
                      tickvalues=[.33962,.67924,1.01886],ticktext=Zticks,$
                      ticklen=0.1,title=zticktitle,color=axes_color)
      axesModel->add, Xaxis
      axesModel->add, Yaxis
      axesModel->add, Zaxis
      view->add, axesModel
      axesmodel->setproperty,hide=1
      if keyword_set(axes) and (keyword_set(mso) ne 1) then $
        axesmodel->setproperty,hide=0

    ;ADD THE MSO COORDINATE AXES
      axesModel_mso = obj_new('IDLgrModel')
      axesModel_msox = obj_new('IDLgrModel')
      axesModel_msoy = obj_new('IDLgrModel')
      axesModel_msoz = obj_new('IDLgrModel')
      xticktitle_mso = obj_new('IDLgrtext','MSO-X')
      yticktitle_mso = obj_new('IDLgrText','MSO-Y')
      zticktitle_mso = obj_new('IDLgrText','MSO-Z')
      xtemp = [[0,0,0],[1.5,0,0]]
      ztemp = [[0,0,0],[0,0,1.5]]
      ytemp = crossp(ztemp[*,1],xtemp[*,1])
      xaxis_mso = obj_new('IDLgrpolyline',1.5*xtemp,color=[255,255,255],$
                          thick=2,label_objects=xticktitle_mso)
      yaxis_mso = obj_new('IDLgrpolyline',$
                          [0,ytemp[0]],[0,ytemp[1]],[0,ytemp[2]],$
                          color=[255,255,255],thick=2,$
                          label_objects=yticktitle_mso)
      zaxis_mso = obj_new('IDLgrpolyline',ztemp,color=[255,255,255],$
                          thick=2,label_objects=zticktitle_mso)      
      for i=0,n_elements(xaxis_mso)-1 do axesmodel_msox->add,xaxis_mso[i]
      for i=0,n_elements(yaxis_mso)-1 do axesmodel_msoy->add,yaxis_mso[i]
      for i=0,n_elements(zaxis_mso)-1 do axesmodel_msoz->add,zaxis_mso[i]
      axesModel_mso->add,axesModel_msox
      axesModel_mso->add,axesModel_msoy
      axesModel_mso->add,axesModel_msoz
      view->add, axesModel_mso
      axesModel_mso->setproperty,hide=1
      if keyword_set(axes) and keyword_set(mso) then begin
        axesModel_mso->setproperty,hide=0
      endif
      
      
   
    ;ADD THE MOUSE CONTROL
      track = obj_new('Trackball', [draw_xsize, draw_ysize] / 2, $
                      (draw_xsize < draw_ysize) / 2)


    ;ADD TEXT LABELS 
      textModel = obj_new('IDLgrModel')
      timetext = OBJ_NEW('IDLgrText',time_string(initial_time,format=0), $
                         color=[0,255,0], locations=[-2,1.9,0] )
      textModel->add, timetext
      view->add,textModel

    ;CREATE THE PARAMETER LABELS
      parameterModel = obj_new('IDLgrModel')
      tmp_str = 'Distance to Sun:' $
              + strtrim(string(insitu1(time_index)$
                               .spacecraft.mars_sun_distance),2) $
              +' AU'
      paraText1 = obj_new('IDLgrText', tmp_str, $
                          color=[0,255,0], locations=[-1.99,1.7,0])
      parameterModel->add, paraText1

      tmp_str = 'Mars Season:' $
              + strtrim(string(insitu1(time_index).spacecraft.mars_season),2)
      paraText2 = obj_new('IDLgrText',tmp_str, $
                          color=[0,255,0], locations=[-1.99,1.6,0])
      parameterModel->add,paraText2

      tmp_str = 'MAVEN Altitude:' $
              + strtrim(string(insitu1(time_index).spacecraft.altitude),2)
      paraText3 = obj_new('IDLgrText',tmp_str,$
                          color=[0,255,0], locations=[-1.99,1.5,0])
      parameterModel->add,paraText3
      
      tmp_str = 'Solar Zenith Angle:' $
              + strtrim(string(insitu1(time_index).spacecraft.sza),2)
      paraText4 = obj_new('IDLgrText',tmp_str,$
                          color=[0,255,0], locations=[-1.99,1.4,0])
      parameterModel->add,paraText4

      tmp_str = 'Local Time:' $
               + strtrim(string(insitu1(time_index).spacecraft.local_time),2)
      paraText5 = obj_new('IDLgrText',tmp_str,$
                          color=[0,255,0], locations=[-1.99,1.3,0])
      parameterModel->add,paraText5    

      tmp_str = 'SubMaven Lat:' $
              + strtrim(string(insitu1(time_index)$
                               .spacecraft.sub_sc_latitude),2)
      paraText6 = obj_new('IDLgrText',tmp_str,$
                          color=[0,255,0], locations=[-1.99,1.2,0])
      parameterModel->add,paraText6

      tmp_str = 'SubMaven Lon:' $
              + strtrim(string(insitu1(time_index)$
                               .spacecraft.sub_sc_longitude),2)
      paraText7 = obj_new('IDLgrText',tmp_str,$
                          color=[0,255,0], locations=[-1.99,1.1,0])
      parameterModel->add,paraText7

      view->add,parameterModel
      parameterModel->setproperty,hide=1

    ;CREATE THE ORBITAL PATH

      if coord_sys eq 0 then begin
        x_orbit = fltarr(n_elements(insitu1.spacecraft.geo_x)*2)
        y_orbit = fltarr(n_elements(insitu1.spacecraft.geo_y)*2)
        z_orbit = fltarr(n_elements(insitu1.spacecraft.geo_z)*2)
        path_connections = lonarr(n_elements(insitu1.spacecraft.geo_x)*3)
        for i=0L,n_elements(insitu1.spacecraft.geo_x)-1 do begin
          x_orbit[i*2] = insitu1[i].spacecraft.geo_x/10000.0
          x_orbit[(i*2)+1] = insitu1[i].spacecraft.geo_x/10000.0+orbit_offset
          y_orbit[i*2] = insitu1[i].spacecraft.geo_y/10000.0
          y_orbit[(i*2)+1] = (insitu1[i].spacecraft.geo_y/10000.0)+orbit_offset
          z_orbit[i*2] = (insitu1[i].spacecraft.geo_z/10000.0)
          z_orbit[(i*2)+1] = (insitu1[i].spacecraft.geo_z/10000.0)+orbit_offset
          path_connections[i*3] = 2
          path_connections[(i*3)+1] = (i*2L)
          path_connections[(i*3)+2] = (i*2L)+1L
        endfor
      endif else begin
        x_orbit = fltarr(n_elements(insitu1.spacecraft.mso_x)*2)
        y_orbit = fltarr(n_elements(insitu1.spacecraft.mso_y)*2)
        z_orbit = fltarr(n_elements(insitu1.spacecraft.mso_z)*2)
        path_connections = lonarr(n_elements(insitu1.spacecraft.mso_x)*3)
        for i=0L,n_elements(insitu1.spacecraft.mso_x)-1 do begin
          x_orbit[i*2] = insitu1[i].spacecraft.mso_x/10000.0
          x_orbit[(i*2)+1] = insitu1[i].spacecraft.mso_x/10000.0+orbit_offset
          y_orbit[i*2] = insitu1[i].spacecraft.mso_y/10000.0
          y_orbit[(i*2)+1] = (insitu1[i].spacecraft.mso_y/10000.0)+orbit_offset
          z_orbit[i*2] = (insitu1[i].spacecraft.mso_z/10000.0)
          z_orbit[(i*2)+1] = (insitu1[i].spacecraft.mso_z/10000.0)+orbit_offset
          path_connections[i*3] = 2
          path_connections[(i*3)+1] = (i*2L)
          path_connections[(i*3)+2] = (i*2L)+1L
        endfor
      endelse
      

      ;DEFINE THE COLORS ALONG THE FLIGHT PATH

; IDENTIFY THE FIELD TO BE PLOTTED
          
;        if keyword_set(field) then begin      
;          ;if parameter not selected, pass an invalid value
;          MVN_KP_TAG_VERIFY, insitu1, field,base_tag_count, $
;                             first_level_count, base_tags,  $
;                             first_level_tags, check, level0_index, $
;                             level1_index, tag_array
;          if check ne 0 then begin         
;            ;if requested parameter doesn't exist, default to none
;            print,'REQUESTED PLOT PARAMETER, '+strtrim(string(field),2) $
;                  +' IS NOT PART OF THE DATA STRUCTURE.'
;            plotted_parameter_name = ''
;            current_plotted_value = ''
;            level0_index = -9
;            level1_index = -9
;          endif else begin
;            plotted_parameter_name = tag_array[0]+':'+tag_array[1]
;            current_plotted_value = insitu1[time_index]$
;                                    .(level0_index).(level1_index)
;          endelse             
;        endif else begin  
;          ;if no parameter selected, default to spacecraft altitude
;          plotted_parameter_name = 'altitude'
;          current_plotted_value = insitu1[time_index].spacecraft.altitude
;          level0_index = 12
;          level1_index = 10
;        endelse 

; DEFINE THE COLOR TABLE AND MAX AND MIN PLOT VALUES

      ; First, define and load the color table
        if( keyword_set( color_table ) )then begin
          if( n_elements (color_table) gt 1 )then begin
            print,'Invalid entry for keyword color_table.'
            print,'Should only be single integer.'
            print,'Will revert to default (Rainbow: IDL-13)'
            path_color_table = 13
          endif else begin
            path_color_table = color_table
          endelse
        endif else begin
          ; Default color table is Rainbow (IDL-13)
          path_color_table = 13
        endelse
        loadct,path_color_table,/silent

      ; Next, define max and min values of color table
        if( keyword_set( minimum ) )then begin
          if( minimum gt $
              min( insitu1.(level0_index).(level1_index), /NaN ) )then begin
            print,'Provided minimum value: ',minimum
            print,'Minimum value of '+plotted_parameter_name+' is: ',$
                  min( insitu1.(level0_index).(level1_index), /NaN )
            print,'For visualization purposes, provided min must be smaller '$
                  +'than data minimum'
            print,'Resetting mininum plot value.'
          endif
          if( keyword_set(log) )then begin
            path_color_min $
              = minimum $
              < 10.^(min(alog10(insitu1.(level0_index).(level1_index)),/NaN ))
          endif else begin
            path_color_min $
              = minimum < min( insitu1.(level0_index).(level1_index), /NaN )
          endelse
        endif else begin
          path_color_min = keyword_set( colorbar_stretch ) $
            ? min( alog10(insitu1.(level0_index).(level1_index) ), /NaN ) $
            : min( insitu1.(level0_index).(level1_index), /NaN )
        endelse

        if( keyword_set( maximum ) )then begin
          if( maximum lt $
            max( insitu1.(level0_index).(level1_index), /NaN ) )then begin
            print,'Provided maximum value: ',maximum
            print,'Maximum value of '+plotted_parameter_name+' is: ',$
                  max( insitu1.(level0_index).(level1_index), /NaN )
            print,'For visualization purposes, provided max must be smaller '$
                  +'than data maximum'
            print,'Resetting maximum plot value.'
          endif
          if( keyword_set( colorbar_stretch ) )then begin
            path_color_max $
              = maximum $
              > 10.^(max(alog10(insitu1.(level0_index).(level1_index)),/NaN))
          endif else begin
            path_color_max $
              = maximum > max( insitu1.(level0_index).(level1_index), /NaN )
          endelse
        endif else begin
          path_color_max = keyword_set( colorbar_stretch ) $
            ? max( alog10(insitu1.(level0_index).(level1_index) ), /NaN ) $
            : max( insitu1.(level0_index).(level1_index), /NaN )
        endelse

      ; finally, explicitly assign the stretch value if log
        path_color_stretch = keyword_set( colorbar_stretch )

        vert_color = intarr(3,n_elements(insitu1.spacecraft.geo_x)*2)        
        MVN_KP_3D_PATH_COLOR, insitu1, level0_index, level1_index, $
                              path_color_table, vert_color,colorbar_ticks,$
                              path_color_min,path_color_max,path_color_stretch   
        orbit_model = obj_new('IDLgrModel')
        view -> add, orbit_model
        orbit_path = obj_new('IDLgrPolyline', x_orbit,y_orbit,z_orbit, $
                             polylines=path_connections, thick=2,$
                             vert_color=vert_color,shading=1)
        for i=0,n_elements(orbit_path) -1 do orbit_model -> add,orbit_path[i]

    ;CREATE THE VECTOR MODEL TO HOLD SUCH DATA
    
        ;IF SET, FILL THE VECTOR MODEL AND DISPLAY
        if keyword_set(whiskers) ne 1 then begin
          vector_scale = 1.0
          vector_color = [255,0,0]
          vector_data = ''
          vector_level1 = 0
          vector_level2 = 0
        endif else begin
           if size(whiskers,/type) ne 8 then begin
            vector_scale = 1.0
            vector_color = [255,0,0]
            vector_data = ''
            vector_level1 = 0
            vector_level2 = 0
           endif else begin
            vector_scale = whiskers.vector_scale
            vector_color = whiskers.vector_color
            vector_name = whiskers.vector_data
            
           endelse
        endelse
    
      vector_model = obj_new('IDLgrModel')
      x_vector = fltarr(n_elements(insitu1.spacecraft.geo_x)*2)
      y_vector = fltarr(n_elements(insitu1.spacecraft.geo_y)*2)
      z_vector = fltarr(n_elements(insitu1.spacecraft.geo_z)*2)
      vector_polylines = lonarr(3*n_elements(insitu1.spacecraft.geo_x))
      for i=0L,n_elements(insitu1.spacecraft.geo_x)-1 do begin
        x_vector[i*2] = x_orbit[i*2]
        y_vector[i*2] = y_orbit[i*2]
        z_vector[i*2] = z_orbit[i*2]       
        x_vector[(i*2)+1] = x_orbit[i*2]
        y_vector[(i*2)+1] = y_orbit[i*2]+orbit_offset
        z_vector[(i*2)+1] = z_orbit[i*2]
        vector_polylines[i*3] = 2l
        vector_polylines[(i*3)+1] = (i*2l)
        vector_polylines[(i*3)+2] = (i*2l)+1l  
      endfor 
      vector_path = obj_new('IDLgrPolyline', x_vector, y_vector, z_vector, $
                            polylines=vector_polylines, thick=1, $
                            vert_color=vert_color,shading=1,alpha_channel=0.2)
      for i=0l,n_elements(vector_path)-1 do vector_model->add,vector_path[i]
      view -> add,vector_model
      vector_model->setProperty,hide=1  
      if keyword_set(whiskers) then begin
        if size(whiskers,/type) eq 8 then begin
          vector_path->getproperty,data=old_data
          MVN_KP_3D_VECTOR_INIT, old_data, vector_name, vector_scale, $
                                 coord_sys, insitu1
          vector_path->setproperty,data=old_data
          vector_path->getproperty, vert_color=vert_color
          for i=0l,(n_elements(insitu1.spacecraft.geo_x)*2)-1 do begin
            vert_color[*,i] = vector_color
          endfor
          vector_path->setproperty, vert_color=vert_color
        endif
        vector_model->setproperty,hide=0
      endif
      
    ;CREATE A LABEL FOR WHAT IS PLOTTED ALONG THE SPACECRAFT ORBIT
      if keyword_set(plotname) then begin
        if n_elements(plotname) eq 3 then begin
          plotname_color = plotname
        endif else begin
          plotname_color = [0,255,0]
        endelse
      endif else begin
        plotname_color = [0,255,0]
      endelse
      plottedNameModel = obj_new('IDLgrModel')
      plotText1 = obj_new('IdlgrText',plotted_parameter_name, $
                          color=plotname_color,locations=[1.99,1.9,0],$
                          alignment=1.0)
      plotText2 = obj_new('IdlgrText',$
                          strtrim(string(current_plotted_value),2), $
                          color=plotname_color, locations=[1.99,1.82,0],$
                          alignment=1.0)
      plottedNameModel->add,plotText1 
      plottedNameModel->add,plotText2
      view->add,plottedNameModel
      plottedNameModel->setproperty,hide=0
      if keyword_set(plotname) then plottedNameModel->setproperty,hide=0
      
    ;CREATE A COLORBAR FOR THE ALONG TRACK PLOTS
      if keyword_set(color_bar) then begin
        if n_elements(color_bar) eq 3 then begin
          colorbar_color = color_bar
        endif else begin
          colorbar_color = [0,255,0]
        endelse
      endif else begin
        colorbar_color = [0,255,0]
      endelse
      colorbarmodel = obj_new('IDLgrModel')
      barDims = [0.1, 0.4]
      colorbar_ticktext = obj_new('idlgrtext',$
                                  string(colorbar_ticks,format='(e7.0)'),$
                                  color=colorbar_color)
      colorbar1 = obj_new('IdlgrColorbar', dimensions=barDims, $
                          r_curr,g_curr, b_curr, $
                          /show_axis, /show_outline, $
                          ticktext=colorbar_ticktext,major=5,$
                          color=colorbar_color)
      colorbarmodel->add,colorbar1
      view->add,colorbarmodel
      colorbarmodel->translate,1.9,-1.9,0
      colorbarmodel->setproperty, hide=1
      if keyword_set(color_bar) then colorbarmodel->setproperty,hide=0
      
     ;CREATE THE SPACECRAFT 
     
        maven_model = obj_new('IDLgrModel')
        maven_location = fltarr(4)
        if keyword_set(tron) then begin
          model_style=1
        endif else begin
          model_style=2
        endelse
        if keyword_set(spacecraft_scale) then begin
          model_scale = spacecraft_scale
        endif else begin
          if keyword_set(cow) then begin
            model_scale = 0.1
          endif else begin
            model_scale = 0.03
          endelse
        endelse
 
    ;ROUTINE TO LOAD A MODEL OF THE MAVEN SPACECRAFT (WHEN AVAILABLE)
        MVN_KP_3D_MAVEN_MODEL, x,y,z,polylist,model_scale,cow=cow,$
                               install_directory
    ;MOVE THE MAVEN MODEL TO THE CORRECT ORBITAL LOCATION
        x = x + x_orbit[time_index*2]
        y = y + y_orbit[time_index*2]
        z = z + z_orbit[time_index*2]
        ;add its position to the camera tracking variable
        maven_location[0] = x_orbit[time_index*2]
        maven_location[1] = y_orbit[time_index*2]
        maven_location[2] = z_orbit[time_index*2]
        maven_location[3] = 1.0                        ;default scale factor
        maven_poly = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, $
                             color=[255,102,0], shading=1,reject=1,$
                             specular=[0,255,255],style=model_style)
        maven_model -> add, maven_poly
        view -> add, maven_model

    ;ROTATE THE SPACECRAFT TO ITS INITIAL POSITION
      


      ;CREATE THE PARAMETER PLOT ALONG THE BOTTOM EDGE OF THE DISPLAY
      
        if keyword_set(parameterplot) ne 1 then begin
          parameter_plot_connected = 1
          parameter_plot_axis_color = [0,128,0]
          parameter_plot_before_color = [255,0,0]
          parameter_plot_after_color = [0,0,255]
          parameter_plot_hide = 0
        endif else begin
           if size(parameterplot,/type) ne 8 then begin
            parameter_plot_connected = 1
            parameter_plot_axis_color = [0,128,0]
            parameter_plot_before_color = [255,0,0]
            parameter_plot_after_color = [0,0,255]
            parameter_plot_hide = 1
           endif else begin
            parameter_plot_connected = parameterplot.plot_connected
            parameter_plot_axis_color = parameterplot.axes_color
            parameter_plot_before_color = parameterplot.before_color
            parameter_plot_after_color = parameterplot.after_color
            parameter_plot_hide = 1
           endelse
        endelse

        plot_model = obj_new('IDLgrModel')
        view->add,plot_model
        plot_x = insitu1.time
        if keyword_set(field) then begin
          plot_y = insitu1.(level0_index).(level1_index)
        endif else begin
          plot_y = insitu1.spacecraft.altitude
        endelse

        plot_colors = intarr(3,n_elements(plot_x))
        for i=0, n_elements(plot_x) -1 do begin
          if i lt time_index then begin
            plot_colors[*,i] = parameter_plot_before_color
          endif else begin
            plot_colors[*,i] = parameter_plot_after_color
          endelse
        endfor

        if parameter_plot_connected eq 1 then begin
          parameter_plot_symbol=0
          parameter_plot_linestyle=0
        endif else begin
          parameter_plot_symbol = obj_new('IDLgrSymbol',data=3,size=50)
          parameter_plot_linestyle=6
        endelse

; Force the maximum and minimum values outside of the data bounds.
; I do not like this, but it may be the only way that IDL widget 
;  plotting will work properly...
;
        if( arg_present( colorbar_min ) )then begin
          yrmin = keyword_set(colorbar_stretch) $
                ? colorbar_min < 10.^(min(alog10(plot_y),/NaN)) $
                : colorbar_min < min( plot_y, /NaN )
        endif else begin
          yrmin = keyword_set(colorbar_stretch) $
                ? 10.^(min(alog10(plot_y),/NaN))$
                : min( plot_y,/NaN)
        endelse
        if( arg_present( colorbar_max ) )then begin
          yrmax = keyword_set(colorbar_stretch) $
            ? colorbar_max < 10.^(max(alog10(plot_y),/NaN)) $
            : colorbar_max < max( plot_y, /NaN )
        endif else begin
          yrmax = keyword_set(colorbar_stretch) $
            ? 10.^(max(alog10(plot_y),/NaN))$
            : max( plot_y,/NaN)
        endelse

        yr = [yrmin, yrmax]
        xr = [min(plot_x),max(plot_x)]

        
; Now make the data log if requested
; ToDo: May need to use signum to preserve sign of data

        if( keyword_Set( colorbar_stretch ) )then begin
;
;  Possible hack: force all plot_y NaNs to the minimum plotted value 
;  so that the IDLgrPlot command correctly matches the number of plotted 
;  indices to the number of indices in the time array.  
;  Using minimum so that the red line for data remains on the screen
;  May need to fix the location of the x-axis a few lines later.
;
          temp = where( ~finite(plot_y) or plot_y lt 0, num_nan )
          if( num_nan gt 0 )then plot_y[temp] = minimum; 1e-40
          parameter_plot = obj_new('IDLgrPlot', plot_x-plot_x[0], $
                                   alog10(plot_y), $
                                   color=[0,255,0],$
                                   vert_colors=plot_colors,$
                                   linestyle=parameter_plot_linestyle,$
                                   symbol=parameter_plot_symbol,thick=1)
        endif else begin
;
;  Possible hack: force all plot_y NaNs to -1e-40 so that the IDLgrPlot
;   command correctly mayches the number of plotted indices to the number
;   of indices in the time array.  Can use this in linear plot because
;   the plot tool will plot this as basivcally zero.
;
          temp = where( ~finite(plot_y), num_nan )
          if( num_nan gt 0 )then plot_y[temp] = -1e-40

          parameter_plot = obj_new('IDLgrPlot', plot_x-plot_x[0], plot_y, $
                                   color=[0,255,0],$
                                   vert_colors=plot_colors,$
                                   linestyle=parameter_plot_linestyle,$
                                   symbol=parameter_plot_symbol,thick=1)
        endelse

        plot_model -> add, parameter_plot
;        parameter_plot->getproperty, xrange=xr;, yrange=yr (only need xrange)

        xc = mg_linear_function(xr-xr[0], [-1.7,1.4])
;
;  If log plots then we need to scale the log of the y-values
;
        yc = keyword_set(colorbar_stretch) $
           ? mg_linear_function(alog10(yr), [-1.9,-1.5]) $
           : mg_linear_function(yr, [-1.9,-1.5])

        parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
        ya = strtrim( string( yr, format='(e7.0)' ), 2)
        parameter_yaxis_ticktext = obj_new('idlgrtext',ya)

        parameter_yaxis = obj_new('IDLgrAxis', 1, range=yr, log=log,$
                                  color=parameter_plot_axis_color,thick=2,$
                                  tickdir=1,$
                                  ticktext=parameter_yaxis_ticktext,$
                                  /exact,major=2)
                                  ; can add more axis vals by chaging major
        parameter_xaxis = obj_new('IDLgrAxis', 0, range=xr,$
                                  color=parameter_plot_axis_color,thick=2,$
                                  tickdir=1,/exact,notext=1)
        plot_model->add,parameter_yaxis
        plot_model->add,parameter_xaxis
        parameter_yaxis->setproperty,xcoord_conv=[-1.7,xc[1]],ycoord_conv=yc
        parameter_xaxis->setproperty,xcoord_conv=xc,ycoord_conv=yc
        plot_model->setproperty,hide=1
        if parameter_plot_hide eq 1 then plot_model->setproperty,hide=0

      ;CREATE THE PERIAPSE LIMB SCANS
        if instrument_array[8] eq 1 then begin

        ;CREATE THE PERIAPSE LIMB SCAN ALTITUDE PLOT
          if keyword_set(periapse_limb_scan) ne 1 then begin
             periapse_limb_scan = 'Density: H'
             peri_axis_color = [0,255,0]
             peri_line_color = [255,255,255]
             peri_line_thick = 2
             peri_axes_thick = 1
             peri_scale_factor = 1
             periapse_hide = 1
          endif else begin
            if size(periapse_limb_scan,/type) ne 8 then begin
             periapse_limb_scan = 'Density: H'
             peri_axis_color = [0,255,0]
             peri_line_color = [255,255,255]
             peri_line_thick = 2
             peri_axes_thick = 1
             peri_scale_factor = 1
             periapse_hide = 0
             widget_control,subbaseR8b, sensitive=1
            endif else begin
              peri_axis_color = periapse_limb_scan.axes_color
              peri_line_color = periapse_limb_scan.line_color
              peri_line_thick = periapse_limb_scan.line_thick
              peri_axes_thick = periapse_limb_scan.axes_thick
              peri_scale_factor = periapse_limb_scan.scale
              periapse_limb_scan = periapse_limb_scan.name
              widget_control,subbaseR8b, sensitive=1
             periapse_hide = 0
            endelse 
          endelse       
             
          periapse_limb_model =  obj_new('IDLgrModel')
          view->add, periapse_limb_model
          periapse_x = fltarr(n_elements(iuvs.periapse.time_start)$
                              *2*n_elements(iuvs[0].periapse[0].alt))
          periapse_y = fltarr(n_elements(iuvs.periapse.time_start)$
                              *2*n_elements(iuvs[0].periapse[0].alt))
          periapse_z = fltarr(n_elements(iuvs.periapse.time_start)$
                              *2*n_elements(iuvs[0].periapse[0].alt))
          periapse_polyline = lonarr(n_elements(iuvs.periapse.time_start)$
                                     *3*n_elements(iuvs[0].periapse[0].alt))
          peri_vert_colors = intarr(3,n_elements(iuvs[0].periapse[0].alt)$
                                      *n_elements(iuvs.periapse.time_start))
          peri_vert_colors[2,*] = 255
          
          if keyword_set(periapse_limb_scan) then begin
            peri_data = fltarr(n_elements(iuvs.periapse.time_start), $
                               n_elements(iuvs[0].periapse[0].alt))
            peri_temp_index=0
            p1 = strmid(periapse_limb_scan,0,1) 
            p2 = strmid(periapse_limb_scan,$
                        strpos(periapse_limb_scan,':')+1,$
                        strlen(periapse_limb_scan)$
                        -strpos(periapse_limb_scan,':'))
            
             for i=0,n_elements(iuvs)-1 do begin
              for j=0,n_elements(iuvs[i].periapse)-1 do begin
                if p1 eq 'D' then begin
; TODO: This needs a count eq 0 check
                  p_ind $
                    = where(iuvs[i].periapse[j].density_id eq strtrim(p2,2))
                  peri_data[peri_temp_index,*] $
                    = iuvs[i].periapse[j].density[p_ind,*]
                endif
                if p1 eq 'R' then begin
                  p_ind = where(iuvs[i].periapse[j].radiance_id eq p2)
                  peri_data[peri_temp_index,*] $
                    = iuvs[i].periapse[j].radiance[p_ind,*]
                endif
                peri_temp_index++
              endfor
             endfor
            MVN_KP_3D_PERI_COLOR, peri_vert_colors, peri_data
          endif 
            
          peri_index = 0
          for i=0,n_elements(iuvs)-1 do begin
            for j=0, n_elements(iuvs[i].periapse)-1 do begin
              for k=0,n_elements(iuvs[i].periapse[j].alt)-1 do begin
                periapse_x[peri_index] $
                  = ( rplanet $
                    + ( ( iuvs[i].periapse[j].alt[k]*peri_scale_factor ) $
                        / 10000.0 ) ) $
                  * cos(iuvs[i].periapse[j].lat*!dtor) $
                  * cos(iuvs[i].periapse[j].lon*!dtor)
                periapse_y[peri_index] $
                  = ( rplanet $
                    + ( ( iuvs[i].periapse[j].alt[k]*peri_scale_factor ) $
                        / 10000.0 ) ) $
                  * cos(iuvs[i].periapse[j].lat*!dtor) $
                  * sin(iuvs[i].periapse[j].lon*!dtor)
                periapse_z[peri_index] $
                  = ( rplanet $
                    + ( ( iuvs[i].periapse[j].alt[k]*peri_scale_factor ) $
                        / 10000.0 ) ) $
                  * sin(iuvs[i].periapse[j].lat*!dtor) 
                peri_index = peri_index+1
              endfor
            endfor
          endfor
          
          for i=0,n_elements(iuvs.periapse.time_start)-1 do begin
            periapse_polyline[i*(n_elements(iuvs[0].periapse[0].alt)+1)] $
              = n_elements(iuvs[0].periapse[0].alt)
            for j=1,n_elements(iuvs[0].periapse[0].alt) do begin
              periapse_polyline[(i*(n_elements(iuvs[0].periapse[0].alt)+1))+j] $
                = (i*(n_elements(iuvs[0].periapse[0].alt)))+(j-1)
            endfor
          endfor
          
          periapse_vectors = obj_new('IDLgrPolyline', $
                                     periapse_x, periapse_y, periapse_z, $
                                     polylines=periapse_polyline, $
                                     vert_colors=peri_vert_colors, thick=3,$
                                     color=[0,0,255])
          for i=0, n_elements(periapse_vectors)-1 do $
            periapse_limb_model->add,periapse_vectors[i]
          
          periapse_limb_model->setproperty,hide=1
          if (periapse_hide eq 0) then periapse_limb_model->setproperty,hide=0
          
          MVN_KP_3D_CURRENT_PERIAPSE, iuvs.periapse, initial_time, $
                                      current_periapse, periapse_limb_scan, $
                                      xlabel
          
          alt_plot_model = obj_new('IDLgrModel')
          view->add,alt_plot_model
          alt_plot = obj_new('IDLgrPlot', current_periapse[1,*], $
                             current_periapse[0,*],color=[0,255,0],$
                             vert_colors=peri_line_color,linestyle=0,$
                             thick=peri_line_thick)
          alt_plot_model -> add, alt_plot
  
          alt_plot->getproperty, xrange=xr, yrange=yr
          xc = mg_linear_function(xr, [-1.75,-1.4])
          yc = mg_linear_function(yr, [-1.3,1.0])
          alt_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
          alt_xaxis_title = obj_new('IDLgrText', xlabel, color=peri_axis_color)
          alt_xaxis_ticks $
            = obj_new('idlgrtext', $
                      [strtrim(string(min(current_periapse[1,*]), $
                                      format='(E8.2)'),2),$
                       strtrim(string(max(current_periapse[1,*]), $
                                      format='(E8.2)'),2)] )
          
          alt_yaxis = obj_new('IDLgrAxis', 1, range=yr,color=peri_axis_color, $
                              thick=peri_axes_thick,tickdir=1,/exact,major=5)
          alt_xaxis = obj_new('IDLgrAxis', 0, range=xr,color=peri_axis_color, $
                              thick=peri_axes_thick,tickdir=1,/exact,major=2, $
                              title=alt_xaxis_title,ticktext=alt_xaxis_ticks)
          alt_plot_model->add,alt_yaxis
          alt_plot_model->add,alt_xaxis
          alt_yaxis->setproperty,xcoord_conv=[-1.76,xc[1]],ycoord_conv=yc
          alt_xaxis->setproperty,xcoord_conv=[-1.75,xc[1]],$
                                 ycoord_conv=[-1.3,yc[1]]
          alt_plot_model->setproperty,hide=1
          if (periapse_hide eq 0) then alt_plot_model->setproperty,hide=0

        endif 

  ;CREATE THE MODEL FOR THE CORONA DISPLAYS
    if keyword_set(iuvs) then begin
      if instrument_array[15] eq 1 then begin
       
        ;CREATE THE MODEL FOR THE ECHELLE LIMB DATA
        corona_e_limb_model = obj_new('IDLgrModel')
        total_e_limb = n_elements(where(finite(iuvs.corona_e_limb.alt[0])))
        total_e_limb_alt = n_elements(iuvs[0].corona_e_limb.alt)
        
        corona_e_limb_x = fltarr(4*total_e_limb*total_e_limb_alt)
        corona_e_limb_y = fltarr(4*total_e_limb*total_e_limb_alt)
        corona_e_limb_z = fltarr(4*total_e_limb*total_e_limb_alt)
        corona_e_limb_connect = intarr(5*total_e_limb*total_e_limb_alt)
        corona_e_limb_colors = intarr(3,4*total_e_limb*total_e_limb_alt)
        
        mvn_kp_3d_corona_init, iuvs.corona_e_limb, insitu.time, $
                               insitu.spacecraft.altitude, $
                               x_orbit, y_orbit, z_orbit, $
                               corona_e_limb_x, $
                               corona_e_limb_y, corona_e_limb_z, $
                               corona_e_limb_connect, corona_e_limb_colors

        corona_e_limb_poly = obj_new('IDLgrPolygon', corona_e_limb_x, $
                                     corona_e_limb_y, corona_e_limb_z, $
                                     polygons=corona_e_limb_connect, $
                                     vert_colors=corona_e_limb_colors, $
                                     shading=1)
        corona_e_limb_model->add, corona_e_limb_poly
    
        view->add, corona_e_limb_model
        corona_e_limb_model->setproperty,hide=1
      endif
      
      if instrument_array[10] eq 1 then begin
        ;CREATE THE MODEL FOR THE ECHELLE HIGH ALT DATA
        corona_e_high_model = obj_new('IDLgrModel')
        total_e_high = n_elements(where(finite(iuvs.corona_e_high.alt[0])))
        total_e_high_alt = n_elements(iuvs[0].corona_e_high.alt)
        
        corona_e_high_x = fltarr(4*total_e_high*total_e_high_alt)
        corona_e_high_y = fltarr(4*total_e_high*total_e_high_alt)
        corona_e_high_z = fltarr(4*total_e_high*total_e_high_alt)
        corona_e_high_connect = intarr(5*total_e_high*total_e_high_alt)
        corona_e_high_colors = intarr(3,4*total_e_high*total_e_high_alt)
        
        mvn_kp_3d_corona_init, iuvs.corona_e_high, insitu.time, $
                               insitu.spacecraft.altitude, $
                               x_orbit, y_orbit, z_orbit, $
                               corona_e_high_x, $
                               corona_e_high_y, corona_e_high_z, $
                               corona_e_high_connect, corona_e_high_colors                              
    
        corona_e_high_poly = obj_new('IDLgrPolygon', corona_e_high_x, $
                                     corona_e_high_y, corona_e_high_z, $
                                     polygons=corona_e_high_connect, $
                                     vert_colors=corona_e_high_colors, $
                                     shading=1)
        corona_e_high_model->add, corona_e_high_poly
    
        view->add, corona_e_high_model         
        corona_e_high_model-> setproperty,hide=1    
      endif
      
      if instrument_array[14] eq 1 then begin
        ;CREATE THE MODEL FOR THE LORES LIMB DATA
        corona_lo_limb_model = obj_new('IDLgrModel')
        total_lo_limb = n_elements(where(finite(iuvs.corona_lo_limb.alt[0])))
        total_lo_limb_alt = n_elements(iuvs[0].corona_lo_limb.alt)
        
        corona_lo_limb_x = fltarr(4*total_lo_limb*total_lo_limb_alt)
        corona_lo_limb_y = fltarr(4*total_lo_limb*total_lo_limb_alt)
        corona_lo_limb_z = fltarr(4*total_lo_limb*total_lo_limb_alt)
        corona_lo_limb_connect = intarr(5*total_lo_limb*total_lo_limb_alt)
        corona_lo_limb_colors = intarr(3,4*total_lo_limb*total_lo_limb_alt)
        
        mvn_kp_3d_corona_init, iuvs.corona_lo_limb, insitu.time, $
                               insitu.spacecraft.altitude, $
                               x_orbit, y_orbit, z_orbit, $
                               corona_lo_limb_x, $
                               corona_lo_limb_y, corona_lo_limb_z, $
                               corona_lo_limb_connect, corona_lo_limb_colors
    
        corona_lo_limb_poly = obj_new('IDLgrPolygon', corona_lo_limb_x, $
                                      corona_lo_limb_y, corona_lo_limb_z, $
                                      polygons=corona_lo_limb_connect, $
                                      vert_colors=corona_lo_limb_colors, $
                                      shading=1)
        corona_lo_limb_model->add, corona_lo_limb_poly
    
        view->add, corona_lo_limb_model
         corona_lo_limb_model->setproperty,hide=1
      endif
      if instrument_array[13] eq 1 then begin
        ;CREATE THE MODEL FOR THE LORES HIGH ALT DATA
        corona_lo_high_model = obj_new('IDLgrModel')
        total_lo_high = n_elements(where(finite(iuvs.corona_lo_high.alt[0])))
        total_lo_high_alt = n_elements(iuvs[0].corona_lo_high.alt)
        
        corona_lo_high_x = fltarr(4*total_lo_high*total_lo_high_alt)
        corona_lo_high_y = fltarr(4*total_lo_high*total_lo_high_alt)
        corona_lo_high_z = fltarr(4*total_lo_high*total_lo_high_alt)
        corona_lo_high_connect = intarr(5*total_lo_high*total_lo_high_alt)
        corona_lo_high_colors = intarr(3,4*total_lo_high*total_lo_high_alt)
        
        mvn_kp_3d_corona_init, iuvs.corona_lo_high, insitu.time, $
                               insitu.spacecraft.altitude, $
                               x_orbit, y_orbit, z_orbit, $
                               corona_lo_high_x, $
                               corona_lo_high_y, corona_lo_high_z, $
                               corona_lo_high_connect, corona_lo_high_colors
    
        corona_lo_high_poly = obj_new('IDLgrPolygon', corona_lo_high_x, $
                                      corona_lo_high_y, corona_lo_high_z, $
                                      polygons=corona_lo_high_connect, $
                                      vert_colors=corona_lo_high_colors, $
                                      shading=1)
        corona_lo_high_model->add, corona_lo_high_poly
    
        view->add, corona_lo_high_model  
         corona_lo_high_model->setproperty,hide=1
      endif
      
      if instrument_array[16] eq 1 then begin
        ;create the model for the lores disk data
        corona_lo_disk_model = obj_new('IDLgrModel')
        total_lo_disk = n_elements(where(finite(iuvs.corona_lo_disk.lat)))
        
        npoints = 11
        temp_rad = 0.01
        arr = replicate(temp_rad, npoints, npoints)
             
        corona_lo_disk_poly = objarr(total_lo_disk)
        disk_index = 0
        for i=0, n_elements(iuvs.corona_lo_disk)-1 do begin
          ;push each marker to the proper place on the globe
          if finite(iuvs[i].corona_lo_disk.lat) then begin
              
              mesh_obj, 4, vertices, polygons, arr
              disk_x_offset = rplanet $
                            * cos(iuvs[i].corona_lo_disk.lat*!dtor) $
                            * cos(iuvs[i].corona_lo_disk.lon*!dtor)
              disk_y_offset = rplanet $
                            * cos(iuvs[i].corona_lo_disk.lat*!dtor) $
                            * sin(iuvs[i].corona_lo_disk.lon*!dtor)
              disk_z_offset = rplanet $
                            * sin(iuvs[i].corona_lo_disk.lat*!dtor)
            
              vertices[0,*] = vertices[0,*] + disk_x_offset
              vertices[1,*] = vertices[1,*] + disk_y_offset
              vertices[2,*] = vertices[2,*] + disk_z_offset
              
            ;build the spheres
            corona_lo_disk_poly[disk_index] $
              = obj_new('idlgrpolygon', data=vertices, polygons=polygons, $
                        color=[0,50*i,0])
            disk_index = disk_index+1
          endif
        endfor
      
        for i=0, total_lo_disk-1 do begin
          corona_lo_disk_model->add,corona_lo_disk_poly[i]
        endfor
        
        
        
        view->add, corona_lo_disk_model
        corona_lo_disk_model->setproperty, hide=1
        
      endif 
      if instrument_array[11] eq 1 then begin
        ;create the model for the echelle disk data
        corona_e_disk_model = obj_new('IDLgrModel')
        total_e_disk = n_elements(where(finite(iuvs.corona_e_disk.lat)))
        
        npoints = 11
        temp_rad = 0.01
        arr = replicate(temp_rad, npoints, npoints)
             
        corona_e_disk_poly = objarr(total_e_disk)
        disk_index = 0
        for i=0, n_elements(iuvs.corona_e_disk)-1 do begin
          ;push each marker to the proper place on the globe
          if finite(iuvs[i].corona_e_disk.lat) then begin
              
              mesh_obj, 4, vertices, polygons, arr
              disk_x_offset = rplanet $
                            * cos(iuvs[i].corona_e_disk.lat*!dtor) $
                            * cos(iuvs[i].corona_e_disk.lon*!dtor)
              disk_y_offset = rplanet $
                            * cos(iuvs[i].corona_e_disk.lat*!dtor) $
                            * sin(iuvs[i].corona_e_disk.lon*!dtor)
              disk_z_offset = rplanet $
                            * sin(iuvs[i].corona_e_disk.lat*!dtor)
            
              vertices[0,*] = vertices[0,*] + disk_x_offset
              vertices[1,*] = vertices[1,*] + disk_y_offset
              vertices[2,*] = vertices[2,*] + disk_z_offset
              
            ;build the spheres
            corona_e_disk_poly[disk_index] $
              = obj_new('idlgrpolygon', data=vertices, polygons=polygons, $
                        color=[0,0,50*i])
            disk_index = disk_index+1
          endif
        endfor
      
        for i=0, total_e_disk-1 do begin
          corona_e_disk_model->add,corona_e_disk_poly[i]
        endfor
                
        view->add, corona_e_disk_model
        corona_e_disk_model->setproperty, hide=1
      endif       
      
      
    endif


    z_position = [0.0,0.0,1.0,1.0]
    
  ;ROTATE EVERYTHING TO THE PREFERRED INITIAL VIEW
  if keyword_set(initialview) then begin
    
    if n_elements(initialview) eq 3 then begin
    ;set the latitude rotation angle
      if initialview[0] ge 0.0 then rot_angle = (90.-initialview[0])
      if initialview[0] lt 0.0 then rot_angle = (90.+initialview[0]) 
    ;set the longitude rotation angle
      lon_angle = -90. + initialview[1] 
    ;set the default height (km)
      s = 5./(initialview[2]/10000.)
    ;set the x_offset (km)
      xtrans = 0.0
    ;set the y_offset (km)
      ytrans = 0.0
    endif
    if n_elements(initialview) eq 5 then begin
    ;set the latitude rotation angle
      if initialview[0] ge 0.0 then rot_angle = (90.-initialview[0])
      if initialview[0] lt 0.0 then rot_angle = (90.+initialview[0])
    ;set the longitude rotation angle 
      lon_angle = -90. + initialview[1] 
    ;set the default height (km)
       s = 5./(initialview[2]/10000.)
    ;set the x_offset (km)
      xtrans = initialview[3]/10000.
    ;set the y_offset (km)
      ytrans = initialview[4]/10000.
    endif
    if( (n_elements(initialview) ne 5) and $
        (n_elements(initialview) ne 3) )then begin
      print, 'Wrong number of parameters input for INITIALVIEW '
      print, '(expected either 3 or 5). '
      print,'Check your input and try again. Using default values for now.'
    ;set the latitude rotation angle (degrees north)
      rot_angle = 90.0
    ;set the longitude rotation angle (degrees west)
      lon_angle = -90.
    ;set the default height (km)
       s = 2.
    ;set the x_offset (km)
       xtrans = 0.0
    ;set the y_offset (km)
       ytrans = 0.0
    endif
    
      ;TRANSLATE THE ENTIRE SCENE
        
    model->translate, xtrans,ytrans,0
    atmModel1 ->translate, xtrans,ytrans,0
    atmModel2->translate, xtrans,ytrans,0
    atmModel3->translate, xtrans,ytrans,0
    atmModel4->translate, xtrans,ytrans,0
    atmModel5->translate, xtrans,ytrans,0
    atmModel6->translate, xtrans,ytrans,0
    gridlines->translate, xtrans,ytrans,0
    orbit_model->translate, xtrans,ytrans,0
    maven_model->translate, xtrans,ytrans,0
    sub_solar_model->translate, xtrans,ytrans,0
    sub_maven_model->translate, xtrans,ytrans,0
    sub_maven_model_mso->translate, xtrans,ytrans,0
    vector_model->translate, xtrans,ytrans,0
    axesmodel->translate, xtrans,ytrans,0
    sun_model->translate, xtrans,ytrans,0
    axesmodel_mso->translate, xtrans,ytrans,0
    if instrument_array[8] eq 1 then begin
      periapse_limb_model->translate, xtrans,ytrans,0
    endif
      ;ROTATE SCENE TO REQUESTED SUB-CAMERA POINT
        ;latitude
                    
    model->rotate,[1,0,0],-rot_angle
    atmModel1->rotate,[1,0,0],-rot_angle
    atmModel2->rotate,[1,0,0],-rot_angle
    atmModel3->rotate,[1,0,0],-rot_angle
    atmModel4->rotate,[1,0,0],-rot_angle
    atmModel5->rotate,[1,0,0],-rot_angle
    atmModel6->rotate,[1,0,0],-rot_angle
    gridlines->rotate,[1,0,0],-rot_angle
    orbit_model -> rotate,[1,0,0],-rot_angle
    maven_model ->rotate,[1,0,0],-rot_angle
    sub_solar_model->rotate,[1,0,0],-rot_angle
    sub_maven_model->rotate,[1,0,0],-rot_angle
    sub_maven_model_mso->rotate,[1,0,0],-rot_angle
    vector_model->rotate,[1,0,0],-rot_angle
    axesmodel ->rotate,[1,0,0],-rot_angle
    sun_model ->rotate,[1,0,0],-rot_angle
    axesmodel_mso->rotate,[1,0,0],-rot_angle
    if instrument_array[8] eq 1 then begin
      periapse_limb_model ->rotate,[1,0,0],-rot_angle
    endif
    ;longitude
          
    model->rotate,[0,1,0],lon_angle
    atmModel1->rotate,[0,1,0],lon_angle
    atmModel2->rotate,[0,1,0],lon_angle
    atmModel3->rotate,[0,1,0],lon_angle
    atmModel4->rotate,[0,1,0],lon_angle
    atmModel5->rotate,[0,1,0],lon_angle
    atmModel6->rotate,[0,1,0],lon_angle
    gridlines->rotate,[0,1,0],lon_angle
    orbit_model ->rotate,[0,1,0],lon_angle
    maven_model ->rotate,[0,1,0],lon_angle
    sub_solar_model->rotate,[0,1,0],lon_angle
    sub_maven_model->rotate,[0,1,0],lon_angle
    sub_maven_model_mso->rotate,[0,1,0],lon_angle
    vector_model->rotate,[0,1,0],lon_angle
    axesmodel ->rotate,[0,1,0],lon_angle
    sun_model ->rotate,[0,1,0],lon_angle
    axesmodel_mso->rotate,[0,1,0],lon_angle
    if instrument_array[8] eq 1 then begin
      periapse_limb_model ->rotate,[0,1,0],lon_angle
    endif
          
    ;SET THE ALTITUDE OF THE CAMERA
       
    model->scale, s, s, s
    atmModel1->scale,s,s,s
    atmModel2->scale,s,s,s
    atmModel3->scale,s,s,s
    atmModel4->scale,s,s,s
    atmModel5->scale,s,s,s
    atmModel6->scale,s,s,s
    gridlines->scale,s,s,s
    orbit_model->scale,s,s,s
    maven_model->scale,s,s,s
    sub_solar_model->scale,s,s,s
    sub_maven_model->scale,s,s,s
    sub_maven_model_mso->scale,s,s,s
    axesmodel->scale,s,s,s
    vector_model->scale,s,s,s
    sun_model -> scale,s,s,s
    axesmodel_mso->scale, s,s,s
    if instrument_array[8] eq 1 then begin
      periapse_limb_model->scale,s,s,s
    endif
    maven_location = maven_location*s
    z_position = z_position*s

  endif

  window->draw, view

  ;SET THE GLOBAL VARIABLES TO KEEP EVERYTHING IN CHECK

    if keyword_set(direct) eq 0 then begin
    ;SKIP ALL THIS IF /DIRECT IS SET, SKIPPING THE GUI INTERFACE

        if keyword_set(iuvs) then begin 
          ;IF IUVS STRUCTURE IS INCLUDED, SET UP ITS PARAMETERS
          iuvs_begin = {iuvs: iuvs}
          if instrument_array[8] eq 1 then begin
            ;SET THE IUVS PERIAPSE STRUCTURES
            iuvs_peri_state = {periapse_limb_model:periapse_limb_model, $
                               periapse_vectors:periapse_vectors, $
                               current_periapse:current_periapse, $
                               periapse_limb_scan:periapse_limb_scan, $
                               peri_scale_factor:peri_scale_factor, $
                               alt_plot_model:alt_plot_model, $
                               alt_plot:alt_plot, $
                               alt_yaxis:alt_yaxis, $
                               alt_xaxis:alt_xaxis, $
                               alt_xaxis_title:alt_xaxis_title, $
                               alt_xaxis_ticks:alt_xaxis_ticks, $
                               subbaseR8b:subbaseR8b, $
                               button8a:button8a, $
                               button8b:button8b}
            iuvs1 = create_struct(iuvs_begin, iuvs_peri_state)
          endif else begin
            iuvs1 = iuvs_begin
          endelse
          
          if instrument_array[9] eq 1 then begin 
            ;SET THE IUVS APOAPSE STRUCTURES
            iuvs_apo_state = {subbaseR8d:subbaseR8d,$
                              apoapse_blend:apoapse_blend, $
                              apoapse_image_choice:apoapse_image_choice, $
                              apo_time_blend:apo_time_blend}
            iuvs2 = create_struct(iuvs1, iuvs_apo_state)          
          endif else begin
            iuvs2 = iuvs1
          endelse
          
          if( (instrument_array[10] eq 1) or $
              (instrument_array[11] eq 1) or $
              (instrument_array[13] eq 1) or $
              (instrument_array[14] eq 1) or $
              (instrument_array[15] eq 1) or $
              (instrument_array[16] eq 1) )then begin
                
              cstate1 = {subbaseR8h:subbaseR8h}
              if instrument_array[16] eq 1 then begin
                 coronal1 = {drop8a:drop8a, $
                             corona_lo_disk_alpha:corona_lo_disk_alpha, $
                             corona_lo_disk_model:corona_lo_disk_model, $
                             corona_lo_disk_poly:corona_lo_disk_poly}
                 cstate2 = create_struct(cstate1, coronal1) 
               endif else begin
                 cstate2 = cstate1
              endelse
              if instrument_array[14] eq 1 then begin 
                 coronal2 = {drop8b:drop8b, $
                             corona_lo_limb_model:corona_lo_limb_model, $
                             corona_lo_limb_poly:corona_lo_limb_poly, $
                             corona_lo_limb_alpha:corona_lo_limb_alpha}
                 cstate3 = create_struct(cstate2, coronal2) 
               endif else begin
                cstate3 = cstate2
              endelse
              if instrument_array[13] eq 1 then begin 
                 coronal3 = {drop8c:drop8c, $
                             corona_lo_high_model:corona_lo_high_model, $
                             corona_lo_high_poly:corona_lo_high_poly, $
                             corona_lo_high_alpha:corona_lo_high_alpha}
                 cstate4 = create_struct(cstate3, coronal3) 
               endif else begin
                cstate4 = cstate3
              endelse
              if instrument_array[11] eq 1 then begin 
                 coronal4 = {drop8d:drop8d, $
                             corona_e_disk_alpha:corona_e_disk_alpha, $
                             corona_e_disk_model:corona_e_disk_model, $
                             corona_e_disk_poly:corona_e_disk_poly}
                 cstate5 = create_struct(cstate4, coronal4) 
               endif else begin
                 cstate5 = cstate4
              endelse
              if instrument_array[15] eq 1 then begin 
                coronal5 = {drop8e:drop8e, $
                            corona_e_limb_model:corona_e_limb_model, $
                            corona_e_limb_poly:corona_e_limb_poly, $
                            corona_e_limb_alpha:corona_e_limb_alpha}
                cstate6 = create_struct(cstate5, coronal5) 
               endif else begin
                cstate6 = cstate5
              endelse
              if instrument_array[10] eq 1 then begin 
                coronal6 = {drop8f:drop8f, $
                            corona_e_high_model:corona_e_high_model, $
                            corona_e_high_poly:corona_e_high_poly, $
                            corona_e_high_alpha:corona_e_high_alpha}
                cstate7 = create_struct(cstate6, coronal6) 
               endif else begin
                cstate7 = cstate6
              endelse
            iuvs3 = create_struct(iuvs2, cstate7)  
          endif else begin
            iuvs3 = iuvs2
          endelse 
          iuvs_state = iuvs3
        endif
        
        insitu_state = $
          {button1: button1, button2: button2, button3: button3, $
           button4: button4, button5: button5, button6: button6, $
           button41a: button41a, button41b: button41b, button41c: button41c, $
           button42a: button42a, button42b: button42b, button42c: button42c, $
           button43a: button43a, button43b: button43b, button43c: button43c, $
           button44a: button44a, button44b: button44b, button44c: button44c, $
           button45a: button45a, button45b: button45b, button45c: button45c, $
           button46a: button46a, button46b: button46b, button46c: button46c, $
           button9a:button9a, button9b:button9b, button10:button10,  $
           window: window, draw: draw, backgroundcolor: backgroundcolor, $
           subbaseR: subbaseR, subbaseR1: subbaseR1, subbaseR2: subbaseR2, $
           subbaseR3: subbaseR3, subbaseR4: subbaseR4, subbaseR5: subbaseR5, $
           subbaseR6: subbaseR6, subbaseR7: subbaseR7, subbaseR8: subbaseR8, $
           subbaseR9:subbaseR9, subbaseR10:subbaseR10, $
           subbaseR10a:subbaseR10a, subbaseR10b: subbaseR10B, $
           subbaseR10c:subbaseR10c, subbaseR10d:subbaseR10d, $
           text: text, view: view, model: model, mars_globe:mars_globe,$
           opolygons: opolygons, mars_base_map:mars_base_map, $
           atmModel1: atmModel1, atmModel2: atmModel2, atmModel3: atmModel3, $
           atmModel4: atmModel4, atmModel5: atmModel5, atmModel6: atmModel6, $
           opolygons1: opolygons1, opolygons2: opolygons2, $
           opolygons3: opolygons3, opolygons4: opolygons4, $
           opolygons5: opolygons5, opolygons6: opolygons6, $
           atmLevel1alpha: atmLevel1alpha, atmLevel2alpha: atmLevel2alpha, $
           atmLevel3alpha: atmLevel3alpha, atmLevel4alpha: atmLevel4alpha, $
           atmLevel5alpha: atmLevel5alpha, atmLevel6alpha: atmLevel6alpha, $
           atmLevel1height: atmLevel1height, atmLevel2height: atmLevel2height, $
           atmLevel3height: atmLevel3height, atmLevel4height: atmLevel4height, $
           atmLevel5height: atmLevel5height, atmLevel6height: atmLevel6height, $
           gridlines: gridlines, axesmodel: axesmodel, dirlight: dirlight, $
           lightmodel: lightmodel, ambientlight: ambientlight, track: track, $
           coord_sys: coord_sys, textModel: textModel, timetext: timetext, $
           timeline:timeline, orbit_model: orbit_model, $
           orbit_path: orbit_path, path_color_table: path_color_table, $
           orbit_offset:orbit_offset, vector_model:vector_model, $
           vector_path: vector_path, vector_scale: vector_scale, $
           vector_color_method:vector_color_method, $
           vector_color_source:vector_color_source, $
           maven_model: maven_model, $
           sun_model: sun_model, sun_vector: sun_vector, $
           axesModel_mso:axesModel_mso, axesModel_msox:axesModel_msox, $
           axesModel_msoy:axesModel_msoy, axesModel_msoz:axesModel_msoz, $
           sub_solar_line: sub_solar_line, sub_solar_model: sub_solar_model, $
           sub_maven_line: sub_maven_line, sub_maven_model: sub_maven_model, $
           sub_maven_line_mso: sub_maven_line_mso, $
           sub_maven_model_mso: sub_maven_model_mso, $
           parametermodel:parametermodel, plottednamemodel:plottednamemodel, $
           colorbarmodel: colorbarmodel, colorbar_ticks: colorbar_ticks, $
           colorbar_ticktext: colorbar_ticktext, colorbar1: colorbar1, $
           colorbar_min:colorbar_min, colorbar_max:colorbar_max, $
;           log:log, $
           colorbar_stretch:colorbar_stretch, $
           plot_model: plot_model, parameter_plot: parameter_plot, $
           plot_colors:plot_colors, parameter_yaxis:parameter_yaxis, $
           parameter_plot_before_color:parameter_plot_before_color, $
           parameter_plot_after_color:parameter_plot_after_color, $
           parameter_yaxis_ticktext:parameter_yaxis_ticktext,$
           paratext1: paratext1, paratext2: paratext2, paratext3: paratext3, $
           paratext4: paratext4, paratext5: paratext5, paratext6:paratext6, $
           paratext7:paratext7, plottext1: plottext1, plottext2: plottext2, $
           plotted_parameter_name: plotted_parameter_name, $
           current_plotted_value: current_plotted_value, $
           x_orbit: x_orbit, y_orbit: y_orbit, z_orbit: z_orbit,$
           solar_x_coord: solar_x_coord, solar_y_coord: solar_y_coord, $
           solar_z_coord: solar_z_coord, subsolar_x_coord: subsolar_x_coord, $
           subsolar_y_coord: subsolar_y_coord, $
           subsolar_z_coord: subsolar_z_coord, $
           submaven_x_coord: submaven_x_coord, $
           submaven_y_coord: submaven_y_coord, $
           submaven_z_coord: submaven_z_coord, $
           submaven_x_coord_mso: submaven_x_coord_mso, $
           submaven_y_coord_mso: submaven_y_coord_mso, $
           submaven_z_coord_mso: submaven_z_coord_mso, $
           insitu: insitu1, time_index:time_index, initial_time:initial_time, $
           time_step_size:time_step_size, base: base, $
           level0_index: level0_index, level1_index: level1_index, $
           install_directory: install_directory, $
           bm_install_directory:bm_install_directory, $
           instrument_array:instrument_array, camera_view: camera_view, $
           maven_location:maven_location, z_position:z_position $
           }
     
      
        if keyword_set(iuvs) then begin
          state = create_struct(insitu_state, iuvs_state)
        endif else begin
          state = insitu_state
        endelse
                          
      pstate = ptr_new(state, /no_copy)
    
      
        ;set menu visibilities
          widget_control,(*pstate).subbaseR2, map=0
          widget_control,(*pstate).subbaseR3, map=0
          widget_control,(*pstate).subbaseR4, map=0
          widget_control,(*pstate).subbaseR5, map=0
          widget_control,(*pstate).subbaseR6, map=0
          widget_control,(*pstate).subbaseR7, map=0
          widget_control,(*pstate).subbaseR8, map=0
          widget_control,(*pstate).subbaseR9, map=0
          widget_control,(*pstate).subbaseR10, map=0
          
      widget_control, base, set_uvalue=pstate

      xmanager, 'MVN_KP_3D', base,/no_block, cleanup='MVN_KP_3D_cleanup', $
                event_handler='MVN_KP_3D_event'



  endif               ;END OF THE /DIRECT KEYWORD CHECK LOOP

end
