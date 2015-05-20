filelist = file_search('3DALL*.bin')

if n_elements(ls) eq 0 then ls = 0
ls = fix(ask('LS: ',tostr(ls)))

if n_elements(subsolarlon) eq 0 then subsolarlon = 0
subsolarlon = fix(ask('subsolar longitude: ',tostr(subsolarlon)))

nFiles = n_elements(filelist)
if nFiles eq 1 then begin
	filename = filelist
endif else begin
	display, filelist
	if n_elements(fn) eq 0 then fn = 0
	fn = fix(ask('which file', tostr(fn)))
	filename = filelist(fn)
endelse	


read_thermosphere_file, filename, nvars, nalts, nlats, nlons, $
      vars, data, rb, cb, bl_cnt,time,version

latitude = data(1,0,2:nlats-3,0)
;display,latitude*180/!pi 
;if n_elements(whichlat) eq 0 then whichlat = 0
;whichlat = fix(ask('which latitude to save',tostr(whichlat)))

lon = reform(data(0,2:nlons-3,0,0))
lat = reform(data(1,0,2:nlats-3,0))
alt = reform(data(2,0,0,0:nalts-3))/1000.
ialtmin = min(where(alt ge 98))
ialtmax = max(where(alt le 252))
naltsprint = ialtmax - ialtmin+1

iSZA = where(vars eq 'SolarZenithAngle')

iCO2 = where(vars eq '[CO!D2!N]')
iCO = where(vars eq '[CO]')
iN2 = where(vars eq '[N!D2!N]')
iO2 = where(vars eq '[O!D2!N]')
iO = where(vars eq '[O]')
iOP = where(vars eq '[O!U+!N]')
iO2P = where(vars eq '[O!D2!U+!N]')
iCO2P = where(vars eq '[CO!D2!U+!N]')
ie = where(vars eq '[e-]')
iVeast = where(vars eq 'V!Dn!N(east)')
iVnorth = where(vars eq 'V!Dn!N(north)')
iVup = where(vars eq 'V!Dn!N(up)')
iTn = where(vars eq 'Temperature')
iTi = where(vars eq 'iTemperature')
iTe = where(vars eq 'eTemperature')
iQO = where(vars eq 'EUVIonizationRate(O!U+!N')
iQO2 = where(vars eq 'EUVIonizationRate(O!D2!U+!N')
iQCO2 = where(vars eq 'EUVIonizationRate(CO!D2!U+!N')
iQN2 = where(vars eq 'EUVIonizationRate(N!D2!U+!N')
iQNO = where(vars eq 'EUVIonizationRate(NO!U+!N')

SZA = reform(data(iSZA,2:nlons-3,2:nlats-3,0))
nCO2 = reform(data(iCO2,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
nCO = reform(data(iCO,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
nN2 = reform(data(iN2,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
nO2 = reform(data(iO2,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
nO = reform(data(iO,2:nlons-3,2:nlats-3,ialtmin:ialtmax))

nOP = reform(data(iOP,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
nO2P = reform(data(iO2P,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
nCO2P = reform(data(iCO2P,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
if ie ge 0 then begin
	n_e = reform(data(ie,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
endif else begin
	n_e = nOP + nO2P + nCO2P
endelse

vEast = reform(data(iVeast,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
vNorth = reform(data(iVNorth,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
vUp= reform(data(iVup,2:nlons-3,2:nlats-3,ialtmin:ialtmax))

Tn = reform(data(iTn,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
Ti = reform(data(iTi,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
Te = reform(data(iTe,2:nlons-3,2:nlats-3,ialtmin:ialtmax))

QOP1 = reform(data(iQO,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
QO2 = reform(data(iQO2,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
QN2 = reform(data(iQN2,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
QCO2 = reform(data(iQCO2,2:nlons-3,2:nlats-3,ialtmin:ialtmax))
QOP2 = reform(data(iQNO,2:nlons-3,2:nlats-3,ialtmin:ialtmax))

l = strpos(filename,'.bin',/reverse_search,/reverse_offset)-13
date = strmid(filename(0),l,13)
cyear = strmid(date,0,2)
if cyear gt 50 then year = 1900 + fix(cyear) else year = 2000 + fix(cyear)
month = fix(strmid(date,2,2))
day = fix(strmid(date,4,2))
hour = fix(strmid(date,7,2))
min = fix(strmid(date,9,2))
sec = fix(strmid(date,11,2))

openw,1,'gitm_'+date+'.dat'

printf, 1, '#MGITM Results on '+tostr(year)+'-'+chopr('0'+tostr(month),2)+'-'+chopr('0'+tostr(day),2)+' at '+ $
	chopr('0'+tostr(hour),2)+':'+chopr('0'+tostr(min),2)+':'+chopr('0'+tostr(sec),2) + ' UT.'  
printf, 1, '#Each column contains the following variables at the given longitude, latitude, and altitude.'
printf,1,'#Number of longitude points: '+tostr(nlons-4)
printf,1,'#Number of Altitude points:  '+tostr(nAltsprint)
printf,1,'#Units are SI- Densities: #/m3, temperatures: K, wind velocities : m/s. '
printf,1,'#1.Longitude 2.Latitude 3.Altitude 4.Tn 5.Ti 6.Te 7.nCO2 8.nO 9.nN2 10.nCO, 11.nO2, 12.nO2P 13.nOP 14.nCO2P 15.Ne 16.UN 17.VN 18.WN ' 
printf,1, '#Start'

for ialt = 0, naltsprint - 1 do begin
   for ilat = 0, nlats - 5 do begin
      for ilon = 0,nlons - 5 do begin

		printf, 1, lon(ilon)*180/!pi,lat(ilat)*180/!pi,alt(ialtmin+ialt),$
                        tn(ilon,ilat,ialt),ti(ilon,ilat,ialt),te(ilon,ilat,ialt),$ 
			nCO2(ilon,ilat,iAlt),$
                        nO(ilon,ilat,ialt),$
                        nN2(ilon,ilat,ialt),$
                        nCO(ilon,ilat,ialt),$
                        nO2(ilon,ilat,ialt),$
                        nO2P(iLon,ilat,iAlt),$
                        nOP(iLon,ilat,iAlt),$
                        nCO2P(iLon,ilat,iAlt),$
			n_e(iLon,ilat,iAlt),$
                        vEast(iLon,ilat,iAlt), vNorth(iLon,ilat,iAlt), vUp(iLon,ilat,iAlt),$
			format='(18G12.5)'
             endfor
     endfor
endfor
close,1



meta = {year:year,month:month,day:day,hour:hour,min:min,sec:sec,nAlts:naltsprint,nLons:nLons-4,$
       latitude : data(1,0,2:nlats-3,0)*180/!pi, Altitude:reform(data(2,0,0,ialtmin:ialtmax)/1000.0),$
        Longitude:reform(data(0,2:nlons-3,0,0))*180/!pi,SZA:SZA,LS:LS,LONGSUBSOL:subsolarlon,$
        coordinate_system:'GEO',altitude_from:'surface',Mars_Radius:3388.25}
NDS = {CO2:reform(nCO2(0,*)),CO:reform(nCO(0,*)),N2:reform(nN2(0,*)),O2:reform(nO2(0,*)),O:reform(nO(0,*))}
IDS = {O2P:reform(nO2P(0,*)),OP:reform(nOP(0,*)),CO2P:reform(nCO2P(0,*)),n_e:reform(n_e(0,*))}
NV = {VEast:reform(VEast(0,*)),VNorth:reform(Vnorth(0,*)),VUp:reform(Vup(0,*))}
T = {Tn:reform(Tn(0,*)),Ti:reform(Ti(0,*)),Te:reform(Te(0,*))}
QI = {O:reform(QOP1(0,*)),O2:reform(QOP2(0,*)),N2:reform(QN2(0,*)),CO2:reform(QCO2(0,*))}


NDensityS = replicate(NDS,nlons-4)
IDensityS = replicate(IDS,nlons-4)
NVelocity = replicate(NV,nlons-4)
Temperature = replicate(T,nlons-4)
QEUVIonRate = replicate(QI,nlons-4)

for iLon = 1, nlons - 5 do begin
   NDensityS(ilon,*) =  {CO2:nCO2(iLon,*),CO:nCO(iLon,*),N2:nN2(iLon,*),O2:nO2(iLon,*),O:nO(iLon,*)}
   IDS = {O2P:nO2P(iLon,*),OP:nOP(iLon,*),CO2P:nCO2P(iLon,*),n_e:n_e(iLon,*)}
   NV = {VEast:VEast(iLon,*),VNorth:Vnorth(iLon,*),VUp:Vup(iLon,*)}
   T = {Tn:Tn(iLon,*),Ti:Ti(iLon,*),Te:Te(iLon,*)}
   QI = {O:QOP1(iLon,*),O2:QOP2(iLon,*),N2:QN2(iLon,*),CO2:QCO2(iLon,*)}
endfor

save_filename = 'gitm_'+date+'.sav'
save,meta,Ndensitys,iDensityS,NVelocity,Temperature,QEUVIonRate,filename=save_filename

end
