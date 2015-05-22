;+
;
; :Name:
;  mvn_kp_read_mgitm_ascii_header
;
; :Description:
;  Reads the header of MGITM ASCII data file.  Stores metadata and
;  dimensions in appropriate structures.  Also returns the header
;
; :Author:
;  McGouldrick (2015-May-22)
;
; :Version:
;  1.0
;
; :Params:
;  filename: in,string, required
;   - the name of the file to be read
;
; :Keywords:
;  meta: structure
;   - the structure containing all of the metadata
;  dims: structure
;   - the structure containing the dimensional information
;
; :Returns:
;  header: out, array, string
;   - the full text of the header
;
;-
function mvn_kp_read_mgitm_ascii_header, filename, meta=meta, dims=dims
;
; Temp hack: fill meta vars with dummies
;
LS = !VALUES.F_NAN
longsubsol = !VALUES.F_NAN
dec = !values.f_nan
mars_radius = !values.f_nan
coord_sys = 'UNK'
altitude_from = 'UNK'
  ;
  ; Open the file
  ;
  openr,luni,filename,/get_lun
  ;
  ; Determine the number of header lines
  ;
  line = 'junk'
  nlines = 0
  repeat begin
    readf,luni,line
    nlines++
  endrep until ~strmatch(line,'#*')
  nlines-- ; last line read is first of the data
  close,luni & free_lun,luni ; close and free the file
  ;
  ; Now, go and collect the header
  ;
  header = strarr(nlines)
  openr,luni,filename,/get_lun
  for i = 0,nlines-1 do begin
    readf,luni,line
    header[i] = line
  endfor
  close,luni & free_lun,luni ; close and free the file
  ;
  ;  Now, parse the header for the needed information
  ;
  for i = 0,nlines-1 do begin
    ;
    ;  SHould ask for a label/indicator for the date
    ;
    if strmatch( header[i], '*MGITM Results*' ) then begin
      date = (strsplit(header[i],' ', /extract))[3]
      time = (strsplit(header[i],' ', /extract))[5]
      year = fix( (strsplit( date,'-', /extract ))[0] )
      month = fix( (strsplit( date,'-', /extract ))[1] )
      day = fix( (strsplit( date,'-', /extract ))[2] )
      hour = fix( (strsplit( time,':', /extract ))[0] )
      minute = fix( (strsplit( time,':', /extract ))[1] )
      second = fix( (strsplit( time,':', /extract ))[2] )
      ;
      ;  Add date/time to meta?
      ;
    endif
    if strmatch( header[i], '*longitude points*' ) then begin
      nlons = fix((strsplit( header[i],':', /extract ))[1])
      lon = fltarr(nlons)
    endif
    if strmatch( header[i], '*latitude points*' ) then begin
      nlats = fix((strsplit( header[i],':', /extract ))[1])
      lat = fltarr(nlats)
    endif
    if strmatch( header[i], '*altitude points*' ) then begin
      nalts = fix((strsplit( header[i],':', /extract ))[1])
      alt = fltarr(nalts)
    endif
    if strmatch( header[i], '*LS*' ) then $
      LS = fix((strsplit( header[i],':', /extract ))[1])
    if strmatch( header[i], '*coord_sys*' ) then $
      coord_sys = (strsplit( header[i],':', /extract ))[1]
    if strmatch( header[i], '*altitude_from*' ) then $
      altitude_from = (strsplit( header[i],':', /extract ))[1]
    if strmatch( header[i], '*subsolar longitude*' ) then $
      longsubsol = fix((strsplit( header[i],':', /extract ))[1],type=4) ; float
    if strmatch( header[i], '*mars_radius*' ) then $
      mars_radius = fix((strsplit( header[i],':', /extract ))[1],type=4); float
    ;
    ; Punt on units for now
    ;
    if strmatch( header[i], '*Units*' ) then units = header[i]
    ;
    ; I do not like the assumption I make here that Longitude is 
    ; first and that there will be no space between the index and name
    ;
    if strmatch( header[i], '*1.Longitude*' ) then begin
      ;
      ;  First, split them according to the spaces
      ;
      temp = strsplit( line, ' ', /extract )
      ;
      ;  Now, to be consistent with existing code, I need to work out
      ;  how to deal with pointers in IDL
      ;
    endif
    ;
    ;  ANy other deets go here
    ;
  endfor
;
;  May wish to verify some header quantities with filename
;

;
;  Still need to incorporate units and parameter values
;

;
; LS can be gleaned from the filename
;
  ;
  ;  Create the metadate structure
  ;
  meta = {LS:LS, LONGSUBSOL: longsubsol, DECLINATION: dec, $
          MARS_RADIUS:mars_radius, COORD_SYS:coord_sys, $
          ALTITUDE_FROM: altitude_from }
  ;
  ;  Create the empty (all zeros) dims structure
  ;
  dims = {lon:lon, lat:lat, alt:alt}
  return, header
end