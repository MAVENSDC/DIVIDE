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
  if( ~file_test(filename) )then $;begin
;    openr,luni,filename,/get_lun
;  endif else begin
    message, 'File '+filename+' not found.'
;  endelse
  ;
  ; Read the header and returm the metadata and the dimension descriptors
  ; Also return the header itself for debugging purposes.
  ;
  mvn_kp_read_mgitm_ascii_header, filename, header, meta, dims
  ;
  ;  Now, read the data
  ;

stop
;
; Now build the structures and read the data
;
end
