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
                              file=file, $
                              interp=interp, $
                              numContourLines = numContourLines, $
                              fill=fill, $
                              ct=ct, $
                              basemap=basemap, $
                              contourtransparency=contourtransparency

;TODO: MAKE SURE ALL MAPS HAVE THE LONGITUDES IN THE CORRECT PLACE

;CHECK ALL PARAMETERS BEFORE CONTINUING
;Check altitude
if (~(size(altitude, /type) gt 1) and ~(size(altitude, /type) lt 6)) then begin
  print, "Please enter a valid number for altitude"
  return
endif

;Check filename
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

;Check basemap name
if (keyword_set(basemap)) then begin
  if basemap eq 'mdim' then begin
    mapimage = 'MDIM_2500x1250.jpg'
  endif else if basemap eq 'mola' then begin
    mapimage = 'MOLA_color_2500x1250.jpg'
  endif else if basemap eq 'mola_bw' then begin
    mapimage = 'MOLA_BW_2500x1250.jpg'
  endif else if basemap eq 'mag' then begin
    mapimage = 'MAG_Connerny_2005.jpg'
  endif else begin
    print, "Unrecognized basemap type, using mars_2k_color.jpg"
    mapimage = 'mars_2k_color.jpg'
  endelse
endif

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
install_result = routine_info('mvn_kp_create_model_maps',/source)
install_directory = strsplit(install_result.path,$
                    'mvn_kp_create_model_maps.pro',$
                    /extract,/regex)
if !version.os_family eq 'unix' then begin
  basemap_directory = install_directory+'basemaps/'
endif else begin
  basemap_directory = install_directory+'basemaps\'
endelse


;READ THE MODEL RESULTS SPECIFIED
mvn_kp_read_model_results, file, simmeta, simdim, simdata


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
dataindex = input - 1


;CALCULATE RANGE OF LONGITUDE AND LATITUDE
;Some models have longitude from 0 to 360, others go from -180 to 180
if ((min(simdim.lon) gt 0) or (min(simdim.lon) eq 0)) then begin
  lonrange = [0, 360]
endif else begin
  lonrange = [-180, 180]
endelse
latrange=[-90,90]


;Find closest altitude without going over
temp = where(simdim.alt[*] gt altitude)
if (temp[0] eq -1) then begin
  print, "The is no data at this altitude.  Please chose a height between " $
    + string(simdim.alt[0]) + " and " + $
    string(simdim.alt[n_elements(simdim.alt)-1])
  return
endif else begin
  altitude_index = temp[0]-1
endelse


;Populate "modeldata"
if (keyword_set(interp)) then begin
  ;Calculate the interpolated data
  interpfactor = (altitude - simdim.alt[altitude_index]) $
                 / (simdim.alt[altitude_index+1] - simdim.alt[altitude_index])
  if (interpfactor lt 0 or interpfactor gt 1) then begin
    interpfactor = 0
  endif
  modeldata = (1-interpfactor)*(*simdata[dataindex]).data[*,*,altitude_index] $
    + (interpfactor)*(*simdata[dataindex]).data[*,*,altitude_index+1]
endif else begin
  modeldata = (*simdata[dataindex]).data[*,*,altitude_index]
endelse


;PLOT THE BASEMAP FIRST IF NEEDED
if (keyword_set(basemap)) then begin
  myImage1=IMAGE(basemap_directory+mapimage, /CURRENT, $
                 IMAGE_DIMENSIONS=[360,180], $
                 IMAGE_LOCATION=[min(lonrange),-90], $
                 XRANGE=lonrange, YRANGE=latrange, $
                 DIMENSIONS=[2500,1250])
endif

;CREATE THE CONTOUR PLOT
;Note: Background color is almost white, but not quite.
;      otherwise, when saving the image as a png, the function cuts out
;      an all white border
contour1=contour(modeldata, simdim.lon, simdim.lat, $
                 RGB_TABLE=ct, N_LEVELS=numContourLines, $
                 XRANGE = lonrange, $
                 YRANGE = latrange, $
                 ASPECT_RATIO=1.0, BACKGROUND_COLOR = [254,254,254],$
                 FILL=fill, FONT_SIZE=8, DIMENSIONS=[2000,1000], $
                 OVERPLOT=keyword_set(basemap), $
                 TRANSPARENCY=contourtransparency)

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
save_string = save_string+"ModelData_"+(*simdata[dataindex]).name + $
              "_"+strtrim(string(altitude),1)+"km"
if (keyword_set(fill)) then begin
  save_string = save_string+"_filled"
endif
if (keyword_set(basemap)) then begin
  save_string = save_string+"_"+basemap
endif

contour1.save, save_string+".png", BORDER=0, WIDTH=2500, HEIGHT=1250

END