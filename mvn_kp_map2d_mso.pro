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
pro MVN_KP_MAP2D_MSO, mapimage, map_limit, map_location, center_lat, center_lon


 print,center_lat, center_lon
 print,map_limit
 print,map_location

 image_size = size(mapimage)
 resolution  = 360.0/image_size(2)        ;degrees/pixel
 
 
  delta_lon = (center_lon - map_limit[1])/resolution
  
  


  print,resolution


stop
END