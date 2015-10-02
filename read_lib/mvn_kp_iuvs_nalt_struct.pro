;+
; :Name:
;  mvn_kp_iuvs_nalt_struct
;  
; :Description:
;  Given a filename, read through it to find the number of altitude bins 
;  associated with each observation mode and return that information 
;  as a structure.
;
; :Params:
;    filename: in, required, string
;       Name of the input ASCII file
;    nalts: out, required, structure
;       The collection of number of altitude bins for data file
;
; :Author:
;    McGouldrick (2015-Oct-02)
;
; :Version: 1.0
;-

pro mvn_kp_iuvs_nalt_struct, filename, nalts
  ;
  ; Create the dummy nalt structure
  ;
  nalts = {periapse:-1, c_l_limb:-1, c_l_high:-1, c_e_limb:-1, c_e_high:-1}
  ;
  ;  Open the file for reading
  ;
  openr, lun, filename, /get_lun
  ;
  ; Initialize number of periapse records
  ;
  periapse_i = 0
  ;
  ;  Read each line
  ;
  while not eof(lun) do begin
    temp = ''
    readf,lun,temp
    line = strsplit( temp, ' ', /extract )
    
    if line[0] eq 'OBSERVATION_MODE' then begin

      ; PERIAPSE MODE
      
      if line[2] eq 'PERIAPSE' then begin
        ;
        ;  Only interested in number of altitude bins for now
        ;
        obs_mode = line[2]
        repeat begin
          readf,lun,temp
          if strmatch( temp, '*N_ALT_BINS*' )then begin
            nalt_line = strsplit( temp, '=', /extract )
;            if nalts eq !NULL then begin
;              nalts = create_struct( obs_mode, $
;                                     fix( nalt_line[1], type=2 ) )
;            endif else begin
;              if not tag_exist( nalts, 'periapse' ) then $
;                nalts = create_struct( nalts, $
;                                       obs_mode, $
;                                       fix( nalt_line[1], type=2 ) )
;            endelse
            nalts.periapse = fix( nalt_line[1], type=2 )
          endif
        endrep until stregex( temp, '[*]{100}' ) eq 0 ; Awful hack; better way?
      endif ; periapse mode
      
      ; 
      if line[2] eq 'CORONA_LORES_HIGH' then begin
        ;
        ;  Only interested in number of altitude bins for now
        ;
        obs_mode = 'c_l_high' ; reset obs_mode to that used by toolkit
        repeat begin
          readf,lun,temp
          if strmatch( temp, '*N_ALT_BINS*' )then begin
            nalt_line = strsplit( temp, '=', /extract )
;            if nalts eq !NULL then begin
;              nalts = create_struct( obs_mode, fix(nalt_line[1], type=2 ) )
;            endif else begin
;              nalts = create_struct( nalts, obs_mode, fix( nalt_line[1], type=2 ) )
;            endelse
            nalts.c_l_high = fix( nalt_line[1], type=2 )
          endif
        endrep until stregex( temp, '[*]{100}' ) eq 0 ; Awful hack; better way?
      endif ; obs mode

      if line[2] eq 'CORNOA_LORES_LIMB' then begin
        ;
        ;  Only interested in number of altitude bins for now
        ;
        obs_mode = 'c_l_limb' ; reset obs_mode to that used by toolkit
        repeat begin
          readf,lun,temp
          if strmatch( temp, '*N_ALT_BINS*' )then begin
            nalt_line = strsplit( temp, '=', /extract )
;            if nalts eq !NULL then begin
;              nalts = create_struct( obs_mode, fix(nalt_line[1], type=2 ) )
;            endif else begin
;              nalts = create_struct( nalts, obs_mode, fix( nalt_line[1], type=2 ) )
;            endelse
            nalts.c_l_limb = fix( nalt_line[1], type=2 )
          endif
        endrep until stregex( temp, '[*]{100}' ) eq 0 ; Awful hack; better way?
      endif ; obs mode

      if line[2] eq 'CORONA_ECHELLE_HIGH' then begin
        ;
        ;  Only interested in number of altitude bins for now
        ;
        obs_mode = 'c_e_high' ; reset obs_mode to that used by toolkit
        repeat begin
          readf,lun,temp
          if strmatch( temp, '*N_ALT_BINS*' )then begin
            nalt_line = strsplit( temp, '=', /extract )
            nalts.c_e_high = fix( nalt_line[1], type=2 )
;            if nalts eq !NULL then begin
;              nalts = create_struct( obs_mode, fix(nalt_line[1], type=2 ) )
;            endif else begin
;              nalts = create_struct( nalts, obs_mode, fix( nalt_line[1], type=2 ) )
;            endelse
          endif
        endrep until stregex( temp, '[*]{100}' ) eq 0 ; Awful hack; better way?
      endif ; obs mode

      if line[2] eq 'CORONA_ECHELLE_LIMB' then begin
        ;
        ;  Only interested in number of altitude bins for now
        ;
        obs_mode = 'c_e_limb' ; reset obs_mode to that used by toolkit
        repeat begin
          readf,lun,temp
          if strmatch( temp, '*N_ALT_BINS*' )then begin
            nalt_line = strsplit( temp, '=', /extract )
            nalts.c_e_limb = fix( nalt_line[1], type=2 )
;            if nalts eq !NULL then begin
;              nalts = create_struct( obs_mode, fix(nalt_line[1], type=2 ) )
;            endif else begin
;              nalts = create_struct( nalts, obs_mode, fix( nalt_line[1], type=2 ) )
;            endelse
          endif
        endrep until stregex( temp, '[*]{100}' ) eq 0 ; Awful hack; better way?
      endif ; obs mode

    endif  ; if it is an observation mode
  endwhile ; check for EOF
  close, lun & free_lun, lun
  ;
  ;  Go back through; if expected obs mode(s) do(es) not exist, set it to -1
  ;
;stop
;  if not tag_exist(nalts, 'peripase') then $
;    nalts = create_struct( nalts, 'periapse', -1)
;  if not tag_exist(nalts, 'c_l_limb') then $
;    nalts = create_struct( nalts, 'c_l_limb', -1)
;  if not tag_exist(nalts, 'c_l_high') then $
;    nalts = create_struct( nalts, 'c_l_high', -1)
;  if not tag_exist(nalts, 'c_e_limb') then $
;    nalts = create_struct( nalts, 'c_e_limb', -1)
;  if not tag_exist(nalts, 'c_e_high') then $
;    nalts = create_struct( nalts, 'c_e_high', -1)

end