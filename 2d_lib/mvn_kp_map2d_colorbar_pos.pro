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
pro  MVN_KP_MAP2D_COLORBAR_POS, total_colorbars, positions


    positions = fltarr(total_colorbars,4)

    if total_colorbars eq 1 then positions[0,*] = [0.3,0.1,0.7,0.15]

    if total_colorbars eq 2 then begin
      positions[0,*] = [0.1,0.1,0.4,0.15]
      positions[1,*] = [0.6,0.1,0.9,0.15]
    endif

    if total_colorbars eq 3 then begin
      positions[0,*] = [0.05,0.1,0.3,0.15]
      positions[1,*] = [0.35,0.1,0.65,0.15]
      positions[2,*] = [0.7,0.1,0.99,0.15]
    endif
    
    if total_colorbars eq 4 then begin
      positions[0,*] = [0.05,0.1,0.2,0.15]
      positions[1,*] = [0.25,0.1,0.45,0.15]
      positions[2,*] = [0.5,0.1,0.7,0.15]
      positions[3,*] = [0.75,0.1,0.95,0.15]
    endif
    
    if total_colorbars eq 5 then begin
      positions[0,*] = [0.1,0.2,0.4,0.25]
      positions[1,*] = [0.6,0.2,0.9,0.25]
      positions[3,*] = [0.05,0.1,0.3,0.15]
      positions[4,*] = [0.35,0.1,0.65,0.15]
      positions[5,*] = [0.7,0.1,0.99,0.15]
    endif
    
    if total_colorbars eq 6 then begin
      positions[0,*] = [0.05,0.2,0.3,0.25]
      positions[1,*] = [0.35,0.2,0.65,0.25]
      positions[2,*] = [0.7,0.2,0.99,0.25]
      positions[3,*] = [0.05,0.1,0.3,0.15]
      positions[4,*] = [0.35,0.1,0.65,0.15]
      positions[5,*] = [0.7,0.1,0.99,0.15]
    endif
    
    if total_colorbars eq 7 then begin
      positions[0,*] = [0.05,0.2,0.3,0.25]
      positions[1,*] = [0.35,0.2,0.65,0.25]
      positions[2,*] = [0.7,0.2,0.99,0.25]
      positions[3,*] = [0.05,0.1,0.2,0.15]
      positions[4,*] = [0.25,0.1,0.45,0.15]
      positions[5,*] = [0.5,0.1,0.7,0.15]
      positions[6,*] = [0.75,0.1,0.95,0.15]
    endif
    
    if total_colorbars eq 8 then begin
      positions[0,*] = [0.05,0.2,0.2,0.25]
      positions[1,*] = [0.25,0.2,0.45,0.25]
      positions[2,*] = [0.5,0.2,0.7,0.25]
      positions[3,*] = [0.75,0.2,0.95,0.25]
      positions[4,*] = [0.05,0.1,0.2,0.15]
      positions[5,*] = [0.25,0.1,0.45,0.15]
      positions[6,*] = [0.5,0.1,0.7,0.15]
      positions[7,*] = [0.75,0.1,0.95,0.15]
    endif
    
    if total_colorbars eq 9 then begin
      positions[0,*] = [0.05,0.2,0.3,0.25]
      positions[1,*] = [0.35,0.2,0.65,0.25]
      positions[2,*] = [0.7,0.2,0.99,0.25]
      positions[3,*] = [0.05,0.13,0.3,0.18]
      positions[4,*] = [0.35,0.13,0.65,0.18]
      positions[5,*] = [0.7,0.13,0.99,0.18]
      positions[6,*] = [0.05,0.06,0.3,0.11]
      positions[7,*] = [0.35,0.06,0.65,0.11]
      positions[8,*] = [0.7,0.06,0.99,0.11]
    endif
    
    if total_colorbars eq 10 then begin
      positions[0,*] = [0.05,0.2,0.3,0.25]
      positions[1,*] = [0.35,0.2,0.65,0.25]
      positions[2,*] = [0.7,0.2,0.99,0.25]
      positions[3,*] = [0.05,0.13,0.3,0.18]
      positions[4,*] = [0.35,0.13,0.65,0.18]
      positions[5,*] = [0.7,0.13,0.99,0.18]
      positions[6,*] = [0.05,0.06,0.2,0.11]
      positions[7,*] = [0.25,0.06,0.45,0.11]
      positions[8,*] = [0.5,0.06,0.7,0.11]
      positions[9,*] = [0.75,0.06,0.95,0.11]
    endif
    
    if total_colorbars eq 11 then begin
      positions[0,*] = [0.05,0.2,0.3,0.25]
      positions[1,*] = [0.35,0.2,0.65,0.25]
      positions[2,*] = [0.7,0.2,0.99,0.25]
      positions[3,*] = [0.05,0.13,0.2,0.18]
      positions[4,*] = [0.25,0.13,0.45,0.18]
      positions[5,*] = [0.5,0.13,0.7,0.18]
      positions[6,*] = [0.75,0.13,0.95,0.18]
      positions[7,*] = [0.05,0.06,0.2,0.11]
      positions[8,*] = [0.25,0.06,0.45,0.11]
      positions[9,*] = [0.5,0.06,0.7,0.11]
      positions[10,*] = [0.75,0.06,0.95,0.11]
    endif
    
    if total_colorbars eq 12 then begin
      positions[0,*] = [0.05,0.2,0.2,0.25]
      positions[1,*] = [0.25,0.2,0.45,0.25]
      positions[2,*] = [0.5,0.2,0.7,0.25]
      positions[3,*] = [0.75,0.2,0.95,0.25]
      positions[4,*] = [0.05,0.13,0.2,0.18]
      positions[5,*] = [0.25,0.13,0.45,0.18]
      positions[6,*] = [0.5,0.13,0.7,0.18]
      positions[7,*] = [0.75,0.13,0.95,0.18]
      positions[8,*] = [0.05,0.06,0.2,0.11]
      positions[9,*] = [0.25,0.06,0.45,0.11]
      positions[10,*] = [0.5,0.06,0.7,0.11]
      positions[11,*] = [0.75,0.06,0.95,0.11]
    endif
    
    




END