;+
;
; :Name: mvn_kp_make_basemap
;
; :Author: Kristopher Larsen
;
; :Description:
;   This routine, called by mvn_kp_map2d, creates the basemap to be used
;   in the subsequent plotting.  Removed to its own procedure in the interest
;   of maintaining modularity, and because mvn_kp_map2d had grown to over 
;   1000 lines.
;
; :Params:
;    kp_data: in, required, type=structure
;       the INSITU KP data structure from which to plot data.
;    iuvs: in, optional, type=structure
;       optional IUVS data structure for overplotting of relevant parameters.
;    time: in, optional, type=strarr(2)
;       an array that defines the start and end times to be plotted.
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
;    map_limit: in, optional, type=fltarr
;       An array that defines the limits of the user selected basemap.
;       It is defined as follows:
;         [lower left corner latitude, lower left corner longitude, $
;          upper right corner latitude, upper right corner longitude]
;    map_location: in, optional, type=fltarr
;       An array that defines the location of the user selected basemap.
;         [lower left corner latitude, lower left corner longitude]
;    map_projection: in, optional, type=string
;       The name of one of IDL's given map projections
;    alpha: in, optional, type=integer
;       the transparency of the basemap between 0(opaque) and
;       100(transparent), defaults to 0 (opaque).
;
;
; :Keywords:
;    mso: in, optional, type=boolean
;       switch between GEO and MSO map projections.
;       Basemaps are not projected into MSO coordinate systems so will display
;       only as lat/long grids.
;    apoapse_blend: in, optional, type=boolean
;       If an IUVS apaopase image is selected as the basemap, this keyword
;       will average all images into a single basemap, instead of plotting
;       only a single image.
;
;  TODO: Unsure whether I need to return the i (image) and mp (map) vars.
;
;  :Version:  1.1   April 20, 2015 (McGouldrick modifications)
;-

@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_range_select
@mvn_kp_tag_verify
@mvn_kp_map2d_iuvs_plot
@mvn_kp_3d_optimize
@mvn_kp_time_find
@mvn_kp_plotimage
@mvn_kp_oplotimage

pro MVN_KP_make_basemap, iuvs=iuvs, time=time, basemap=basemap, $
                         map_limit=map_limit, map_location=map_location, $
                         map_projection=map_projection, $
                         alpha = alpha, mso=mso, $
                         apoapse_blend=apoapse_blend

  ;DETERMINE THE INSTALL DIRECTORY SO THE BASEMAPS CAN BE FOUND
  install_result = routine_info('mvn_kp_map2d',/source)
  install_directory = strsplit(install_result.path,'mvn_kp_map2d.pro', $
    /extract,/regex)
  if !version.os_family eq 'unix' then begin
    install_directory = install_directory+'basemaps/'
  endif else begin
    install_directory = install_directory+'basemaps\'
  endelse
;
;  This is the code snipped from mvn_kp_map2d
;
if keyword_set(mso) eq 0 then begin  ;only bother if plotting geo coordinates
  mso = 0
  ;DETERMINE IF THE BASEMAP IS TO BE MADE PARTIALLY TRANSPARENT
  if keyword_set(alpha) eq 0 then alpha=0
  ;IF THE BASEMAP HAS BEEN SELECTED, LOAD IT FIRST
  if keyword_set(basemap) then begin
    if basemap eq 'mdim' then begin
      mapimage = FILEPATH('MDIM_2500x1250.jpg',root_dir=install_directory)
      read_jpeg,mapimage,mapimage
      if (~keyword_set(map_limit) )then map_limit = [-90,0,90,360]
      map_location = [0,-90]
      map_projection  = 'Equirectangular'
    endif
    if basemap eq 'mola' then begin
      mapimage = FILEPATH('MOLA_color_2500x1250.jpg',$
        root_dir=install_directory)
      read_jpeg,mapimage,mapimage
      if ~keyword_set(map_limit) then map_limit=[-90,0,90,360]
      if ~keyword_set(map_location) then map_location = [-180,-90]
      if ~keyword_set(map_projection) then map_projection  = 'Equirectangular'
    endif
    if basemap eq 'mola_bw' then begin
      mapimage = FILEPATH('MOLA_BW_2500x1250.jpg',root_dir=install_directory)
      read_jpeg,mapimage,mapimage
      if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
      if ~keyword_set(map_location) then map_location = [-180,-90]
      if ~keyword_set(map_projection) then map_projection  = 'Equirectangular'
    endif
    if basemap eq 'mag' then begin
      mapimage = FILEPATH('MAG_Connerny_2005.jpg',root_dir=install_directory)
      read_jpeg,mapimage,mapimage
      if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
      if ~keyword_set(map_location) then map_location = [0,-90]
      if ~keyword_set(map_projection) then map_projection  = 'Equirectangular'
    endif
    if basemap eq 'dust' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'DUST_DEPTH')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory)
          read_jpeg,mapimage,mapimage
          if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
          if ~keyword_set(map_location) then map_location = [0,-90]
        endif else begin
          mapimage = bytarr(3,90,45)
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.dust_depth, mapimage, 1, $
              time, iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.dust_depth, mapimage, 0, $
              apoapse_time_index, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endelse
          if ~keyword_set(map_limit) then map_limit = [-90,-180,90,180]
          if ~keyword_set(map_location) then map_location = [-180,-90]
        endelse
      endif
    endif
    if basemap eq 'ozone' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'OZONE_DEPTH')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory)
          read_jpeg,mapimage,mapimage
          if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
          if ~keyword_set(map_location) then map_location = [0,-90]
        endif else begin
          mapimage = bytarr(3,90,45)
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.ozone_depth, mapimage, 1, $
              time, iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.ozone_depth, mapimage, 0, $
              apoapse_time_index, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endelse
          if ~keyword_set(map_limit) then map_limit = [-90,-180,90,180]
          if ~keyword_set(map_location) then map_location = [-180,-90]
        endelse
      endif
    endif
    if basemap eq 'rad_h' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory)
          read_jpeg,mapimage,mapimage
          if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
          if ~keyword_set(map_location) then map_location = [0,-90]
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[0,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, $
              apoapse_time_index, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endelse
          if ~keyword_set(map_limit) then map_limit = [-90,-180,90,180]
          if ~keyword_set(map_location) then map_location = [-180,-90]
        endelse
      endif
    endif
    if basemap eq 'rad_o' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory)
          read_jpeg,mapimage,mapimage
          if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
          if ~keyword_set(map_location) then map_location = [0,-90]
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[1,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, $
              apoapse_time_index, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endelse
          if ~keyword_set(map_limit) then map_limit = [-90,-180,90,180]
          if ~keyword_set(map_location) then map_location = [-180,-90]
        endelse
      endif
    endif
    if basemap eq 'rad_co' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory)
          read_jpeg,mapimage,mapimage
          if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
          if ~keyword_set(map_location) then map_location = [0,-90]
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[2,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, $
              apoapse_time_index, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endelse
          if ~keyword_set(map_limit) then map_limit = [-90,-180,90,180]
          if ~keyword_set(map_location) then map_location = [-180,-90]
        endelse
      endif
    endif
    if basemap eq 'rad_no' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory)
          read_jpeg,mapimage,mapimage
          if ~keyword_set(map_limit) then map_limit = [-90,0,90,360]
          if ~keyword_set(map_location) then map_location = [0,-90]
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[3,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, $
              apoapse_time_index, $
              iuvs.apoapse.time_start, $
              iuvs.apoapse.time_stop, 1
          endelse
          if ~keyword_set(map_limit) then map_limit = [-90,-180,90,180]
          if ~keyword_set(map_location) then map_location = [-180,-90]
        endelse
      endif
    endif
    if basemap eq 'user' then begin
      input_file = dialog_pickfile(path=install_directory)
      if input_file ne '' then begin
        if (STRMID(input_file,3,4, /REVERSE_OFFSET) eq '.jpg') then read_jpeg,input_file,mapimage
        if (STRMID(input_file,3,4, /REVERSE_OFFSET) eq '.png') then mapimage=input_file
      endif
      if keyword_set(map_limit) eq 0 then begin
        map_limit = [-90,0,90,360]
      endif
      if keyword_set(map_location) eq 0 then begin
        map_location = [-180,-90]
      endif
      if keyword_set(map_projection) eq 0 then begin
        map_projection  = 'Equirectangular'
      endif
    endif
    ; plotting is done here if a basemap has been chosen
    if keyword_set(direct) eq 0 then begin
      xmin = map_limit[1] & xmax = map_limit[3] 
      ymin = map_limit[0] & ymax = map_limit[2]
;-TODO: I am unclear whether image_location values must change with map
      i = image( mapimage, image_dimensions=[360,180], $
                 image_location=[0,-90], $ 
                 xrange=[xmin,xmax], yrange=[ymin,ymax] )
      mp = map( map_projection, limit = map_limit, /box_axes, /current )
      mp.limit = map_limit
      plot_color = "White"
    endif
  endif else begin
    ; BASEMAP keyword NOT SET, use this default(?)
    mapimage = FILEPATH('MDIM_2500x1250.jpg',root_dir=install_directory)
    if (~keyword_set(map_limit)) then map_limit=[-90,0,90,360]
    if keyword_set(map_projection) eq 0 then begin
      map_projection  = 'Equirectangular'
    endif
    xmin = map_limit[1] & xmax = map_limit[3]
    ymin = map_limit[0] & ymax = map_limit[2]
    if keyword_set(direct) eq 0 then begin
      i = image( mapimage, axis_style=2,LIMIT=map_limit, $
        GRID_UNITS=2, IMAGE_LOCATION=[-180,-90], $
        IMAGE_DIMENSIONS=[360,180],$
        map_projection  = 'Equirectangular', margin=0, $
        window_title="MAVEN Orbital Path", /nodata, $
        transparency=alpha, xrange=[xmin,xmax], yrange=[ymin,ymax])
      mp = map( map_projection, limit = map_limit, /box_axes, /current )
      
      plot_color = "Black"
    endif
  endelse
endif else begin      ;blank canvas for the MSO plot
  if keyword_set(basemap) then begin
    if basemap eq 'user' then begin
      input_file = dialog_pickfile(path=install_directory)
      if (strmatch(input_file, '*.jpg')) then begin
        read_jpeg,input_file,mapimage
      endif
      if (strmatch(input_file, '*.png')) then begin
        read_png,input_file,mapimage
      endif
      if keyword_set(map_limit) eq 0 then begin
        map_limit = [-90,-180,90,180]
      endif
      if keyword_set(map_location) eq 0 then begin
        map_location = [0,0]
      endif
      i = image(mapimage, image_dimensions=[360,180], $
        window_title="MAVEN Orbital Path",transparency=alpha)
      mp = map('Equirectangular', limit = map_limit, /box_axes, /current)
      mp.limit = map_limit
      plot_color = "Black"
    endif
  endif else begin
    mapimage = FILEPATH('MDIM_2500x1250.jpg',root_dir=install_directory)
    if keyword_set(direct) eq 0 then begin
      i = image(mapimage, image_dimensions=[360,180], $
        window_title="MAVEN Orbital Path",/nodata,transparency=alpha)
      mp = map('Equirectangular', limit = map_limit, /box_axes, /current)
      mp.limit = [-90,-180,90,180]
      plot_color = "Black"
    endif
  endelse
endelse
return
end