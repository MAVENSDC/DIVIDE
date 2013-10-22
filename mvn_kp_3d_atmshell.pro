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
pro MVN_KP_3D_ATMSHELL, atmModel, oPolygons, rplanet

  atmModel = obj_new('IDLgrModel')
  npoints = 361
  arr = REPLICATE(rplanet, npoints, npoints)
  mesh_obj, 4, vertices, polygons, arr
  image = bytarr(3,2048,1024)
  image[*,*,*] = 255
  oImage = OBJ_NEW('IDLgrImage', image)
  vector = FINDGEN(npoints)/(npoints-1.)
  texture_coordinates = fltarr(2,npoints,npoints)
  texture_coordinates[0,*,*] = vector#REPLICATE(1.,npoints)
  texture_coordinates[1,*,*] = REPLICATE(1.,npoints)#vector
  oPolygons = OBJ_NEW('IDLgrPolygon', $
        DATA = vertices, POLYGONS = polygons, $ 
        COLOR = [255, 255, 255], $ 
        TEXTURE_COORD = texture_coordinates, $ 
        TEXTURE_MAP = oImage, /TEXTURE_INTERP)
 atmModel -> add, oPolygons


END