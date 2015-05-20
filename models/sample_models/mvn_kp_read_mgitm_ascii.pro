pro mvn_kp_read_mgitm_ascii, filename, meta=meta, idensitys=idensitys, $
                             ndensitys=ndensitys, nvelocity=nvelocity, $
                             qeuvionrate=qeuvionrate, temperature=temperature
;+
;
; :Name:
;  mvn_kp_read_mgitm_ascii
;  
; :Description:
;  Code to read the ASCII data files from the Bougher group that represent
;  model output from MGITM.
;  
; :Author:
;   McGouldrick (2015-May-18)
;
; :Params:
;  filename: in, required, string
;   - the name of the ASCII file to be read in
;
; :Keywords:
;   - if any is not provided, that data will be read but not returned
;  meta
;   - the target for the metadata structure
;  idensitys
;   - the target for the ion density structure
;  ndensitys
;   - the target for the neutral density structure
;  nvelocity
;   - the target for the neutral velocity structure
;  qeuvionrate
;   - the target for the EUV ion rates(???)
;  temperature
;   - the target for the neutral, ion, and electron temperatures
;
;-
;
;  (Test for file existence and) open the file
;
if( file_test(filename) )then begin
  openr,luni,filename,/get_lun
endif else begin
  message, 'File '+filename+' not found.'
endelse
;
;  The first header line contains date info which must go to meta
;
line = 'junk'
readf,luni,line
date = (strsplit(line,' ', /extract))[3]
time = (strsplit(line,' ', /extract))[5]
year = fix( (strsplit( date,'-', /extract ))[0] )
month = fix( (strsplit( date,'-', /extract ))[1] )
day = fix( (strsplit( date,'-', /extract ))[2] )
hour = fix( (strsplit( time,':', /extract ))[0] )
minute = fix( (strsplit( time,':', /extract ))[1] )
second = fix( (strsplit( time,':', /extract ))[2] )
;
;  second header line is useless
;
readf,luni,line
;
;  third through fifth lines contain nlons, nlats, nalts
;  For now, assume the order is correct.  Later, will need to allow
;    for variations.  Will need to check on the names
;
readf,luni,line
nlons = fix((strsplit( line,':', /extract ))[1])
readf,luni,line
nlats = fix((strsplit( line,':', /extract ))[1])
readf,luni,line
nalts = fix((strsplit( line,':', /extract ))[1])
;
; Will have to wait for the data to add longitude, latitude, altitude,
;  and solar zenith angle arrays to the metadata structure
;

;
; LS can be gleaned from the filename
;

;
; Subsolar longitude cannot
;

;
; Coordinate system cannot
;

;
; Altitude_from cannot
;

;
; Mars radius cannot
;

;
; The sixth line of the header gives units of variables
;
readf,luni,line
;
;  The seventh line of the header identifies of contained variables
;
readf,luni,line
temp = strsplit( line, ' ', /extract )

stop
;
;  The next three lines contain nlats, nlons, nalts
;  Allow for changing the order
;
readf,luni,line

end
