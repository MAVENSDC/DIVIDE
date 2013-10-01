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
pro MVN_KP_IUVS_CORONA, kp_data, low=low, echelle=echelle, density=density, radiance=radiance, limb=limb, corona=corona


;CREATE THE PLOTTABLE DATA ARRAY FOR RADIANCE 


    echelle_r = fltarr(n_elements(kp_data.orbit),3,82)
    altitude_e = (findgen(82) * 50.)-50.
    for i=0,n_elements(kp_data.orbit)-1 do begin
      echelle_r[i,*,0] = kp_data[i].corona_e_disk.radiance[*]
      echelle_r[i,*,1] = kp_data[i].corona_e_disk.radiance[*]
      echelle_r[i,*,2:81] = kp_data[i].corona_e_high.radiance[*]
    endfor 
    corona_r = fltarr(n_elements(kp_data.orbit),7,106)
    altitude_c = fltarr(106)
    for i=0,29 do begin
      altitude_c[i] = 100.+(i*4.)
    endfor
    for i=30, 105 do begin
      altitude_c[i] = 200. + ((i-30)*50)
    endfor

  if keyword_set(low) then begin
   if keyword_set(radiance) then begin
    low_r = fltarr(n_elements(kp_data.orbit),3,82)
   endif
   if keyword_set(density) then begin
    
   endif
  endif


;TEMPORARY ROUTINES TO FILL DATA ARRAYS TO TEST PLOTS
;DELETE BEFORE DISTRIBUTION

  echelle_r[*,0,0:1] = .8
  echelle_r[*,1,0:1] = .7
  echelle_r[*,2,0:1] = .6
  
  for i=0,79 do begin
   for j=0,n_elements(kp_data.orbit)-1 do begin
    echelle_r[j,0,2+i] = 0.8-(i*(.8/80))
    echelle_r[j,1,2+i] = 0.7-(i*(.7/80))
    echelle_r[j,2,2+i] = 0.6-(i*(.6/80))
   endfor
  endfor

  for i=0,29 do begin
    corona_r[*,0,i] = 1.0-(i*0.01)
    corona_r[*,1,i] = .99-(i*0.01)
    corona_r[*,2,i] = .98-(i*0.01)
    corona_r[*,3,i] = .97-(i*0.01)
    corona_r[*,4,i] = .96-(i*0.01)
    corona_r[*,5,i] = .95-(i*0.01)
    corona_r[*,6,i] = .94-(i*0.01)
  endfor
  for i=30,105 do begin
    corona_r[*,0,i] = .7-((i-30)*0.003)
    corona_r[*,1,i] = .69-((i-30)*0.003)
    corona_r[*,2,i] = .68-((i-30)*0.003)
    corona_r[*,3,i] = .67-((i-30)*0.003)
    corona_r[*,4,i] = .66-((i-30)*0.003)
    corona_r[*,5,i] = .65-((i-30)*0.003)
    corona_r[*,6,i] = .64-((i-30)*0.003)
  endfor
  

;DETERMINE THE TOTAL NUMBER OF PLOTS
  

  plot,corona_r[0,0,0:29],altitude_c[0:29],xrange=[min(corona_r[0,0,*]),max(corona_r[0,0,*])],ystyle=8,yrange=[0,300]
  plot,corona_r[0,0,30:105],altitude_c[30:105],linestyle=2,/noerase,xrange=!x.crange,yrange=!y.crange,ystyle=4,/ylog
  AXIS, YAXIS=1, YSTYLE = 1, YTITLE = 'log alt'

 ; !P.MULTI = [0, n_elements(kp_data.orbit), 1]
;PLOT THE PROFILES

;  for i=0,n_elements(kp_data.orbit)-1 do begin
;    plot,echelle_r[i,0,*],altitude_e,yrange=[-100,4000],ystyle=1,charsize=2,title=strtrim('Orbit #'+strtrim(string(kp_data[i].orbit),2),2),$
;        ytitle='Altitude, km',xtitle='Radiance'
;    oplot,echelle_r[i,1,*],altitude_e,linestyle=1
;    oplot,echelle_r[i,2,*],altitude_e,linestyle=2
;  endfor  





stop
end