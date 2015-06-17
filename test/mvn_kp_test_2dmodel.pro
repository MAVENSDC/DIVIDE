;+
;
; :Name:
;  mvn_kp_2dmodel
;  
; :Description:
;  Create a contour plot of a 2d slice in either xy,yz,or xz plane of 
;  the provided model data.  For now, maintain consistency with provided
;  coordinate system.  I.e., for LATMOS, stay in MSO, but convert 
;  alt,lon,lat into x,y,z; for MGITM, stay in GEO, and convert.
;  Will wish to overplot a space craft tracjectory in model coordinates.
;  Will wish to show subsolar position in model?
;  
; :Params:
;  TBD: model, kp_data, plane to view
;  
; :Keywords:
;  TBD
;
; :Author:
;  McGouldrick (v0.1) 2015-Jun-16
;  
;-
pro mvn_kp_test_2dmodel, model, tracer, list=list
;
;  ToDo: Add a /list keyword to list the params in supplied model
;
if keyword_set(list) then begin
  print,'Available parameter tracers in supplied model are:'
  for i = 0,n_elements(model.data)-1 do print,(*model.data[i]).name
  return
endif
;
;  Get the index of the chosen parameter
;
  ntracer = n_elements(model.data)
  names = strarr(ntracer)
  for i = 0,ntracer-1 do names[i]=(*model.data[i]).name
  if total( strmatch( names, tracer ) ) gt 0 then begin
    itag = (where( names eq tracer ))[0]
  endif else begin
    print,'****Error****'
    print,'Provided tracer name: ',tracer
    print,'  does not match any parameter in supplied model.'
    print,'Suggest using /list keyword to see contents of model.'
    print,'Exiting....'
    return
  endelse
;
; Get number of elements in each dimensions in model
;
nalt = n_elements(model.dim.alt)
nlat = n_elements(model.dim.lat)
nlon = n_elements(model.dim.lon)
;
;  make alt, lat, lon arrays of size nlon x nlat x nalt
;
alt = transpose(rebin(model.dim.alt,nalt,nlon,nlat),[1,2,0]) $
    + model.meta.mars_radius
lat = transpose(rebin(model.dim.lat,nlat,nlon,nalt),[1,0,2])
lon = rebin(model.dim.lon,nlon,nlat,nalt)
;
;  Ensure the dims of tracers are in lon / lat / alt order
;
dim_order_array = bytarr(3)
for j = 0,2 do begin
  case (*model.data[itag]).dim_order[j] of
    'longitude': dim_order_array[0] = j
    'latitude' : dim_order_array[1] = j
    'altitude' : dim_order_array[2] = j
    else: message, "Imvalid dimension identifier in model.data: ",itag,j
  endcase
endfor
tracer = transpose( (*model.data[itag]).data, dim_order_array )
;
; Procedure differes whether MSO or GEO r, lon, lat
;
if model.meta.coord_sys eq 'MSO' then begin
  ;
  ;  First, convert model coords to MSO x,y,z
  ;
  x = alt * cos( lon * !dtor ) * sin( ( 90. - lat ) * !dtor )
  y = alt * sin( lon * !dtor ) * sin( ( 90. - lat ) * !dtor )
  z = alt * cos( ( 90. - lat ) * !dtor )
  ;
  ;  Make a contour plot of the selected plane
  ;
stop
;  case plane of
;    xy: begin
;      c1 = contour(tracer
;  endcase
endif
;
;  For GEO coordinates
;
if model.meta.coord_sys eq 'GEO' then begin
;
;  Now, create x,y,z from lon,lat,alt
;
  x = alt * sin( lat*!dtor ) * cos( lon*!dtor )
  y = alt * sin( lat*!dtor ) * sin( lon*!dtor )
  z = alt * cos( lat*!dtor )
endif
;
;  pause here to test
;
stop
end
