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
  if( ~file_test(filename) )then begin
    print, 'File '+filename+' not found.'
    return
  endif
  ;
  ; Read the header and returm the metadata and the dimension descriptors
  ; Also return the header itself for debugging purposes.
  ;
  header = mvn_kp_read_mgitm_ascii_header( filename, meta=meta, $
                                           dim=dim, data=data )
  ;
  ;  Now, read the data
  ;
  openr,luni,filename,/get_lun
  ;
  ;  First, skip the header
  ;
  line = 'junk'
  for i = 0,n_elements(header)-1 do readf,luni,line
  ;
  ;  Now, the "real" data
  ;
  ascii_dat = fltarr(18,n_elements(dim.lon)*n_elements(dim.lat)*n_elements(dim.alt))
  readf,luni,ascii_dat
  close,luni
  ;
  ;  Assign the dim values
  ;  NB nlon = 72; nlat = 36; nalt = 62
  ;  SHould self-determine these
  ;
  temp = reform(ascii_dat[0,*],[72,36,62])
  dim.lon = reform(temp[*,0,0])
  temp = reform( ascii_dat[1,*],[72,36,62] )
  dim.lat = reform(temp[0,*,0])
  temp = reform( ascii_dat[2,*],[72,36,62])
  dim.alt = reform(temp[0,0,*])
  ;
  ;  Now, assign the data parameter values
  ;
  for i = 0,n_elements(data)-1 do begin
    (*data[i]).data = reform( ascii_dat[i+3,*], [72,36,62] )
  endfor
  stop
;
; Now build the structures and read the data
;
end
