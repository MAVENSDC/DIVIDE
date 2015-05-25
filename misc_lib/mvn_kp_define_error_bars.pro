;+
;
; :Name:
;  mvn_kp_define_error_bars
;  
; :Description:
;  Given a parameter and error designation, determine how to calculate 
;  the error bars and plot them.
;  
; :Params:
;  kp_data: in, structure
;   The strcture of the KP datacontaining the params and errors
;   
;  parameter: Need to include parameter inforation
;  error: Need to include error in formation
;  
; :Author:
;  McGouldrick (2015-May-23)
;   
; :Version:
;   1.0
;-
pro mvn_kp_define_error_bars, kp_data, level0_index, level1_index, $
                              base_tags, err0_index, err1_index, $
                              temp_tag, error_bars
  ;
  ;  Create the empty error bars array
  ;
  error_bars = fltarr(2,n_elements(kp_data))
  ;
  ;  Cycle through the level0 options
  ;
  ; strmatch(base_tags,base_tags[level0_index],/fold) returns an
  ;  array of all zeros and a single 1 at the relevant index of the base tag
  ;  indicated by level0_index.  So, this looks a little conoluted
  ;  but it works for ID'ing regardless of case (or we can just make the all CAPS
  ;
;  case base_tags[where(strmatch(base_tags,'lpw',/fold_case))] of
  case base_tags[level0_index] of
    'SEP': $
      begin
        ;
        ;  All sep error params are sinple error bars
        ;
        error_bars[0,*] = kp_data.(level0_index).(level1_index) $
                        - kp_data.(err0_index).(err1_index)
        error_bars[1,*] = kp_data.(level0_index).(level1_index) $
                        + kp_data.(err0_index).(err1_index)
      end

    'SWEA': $
      begin
        if temp_tag[1] eq 'electron_spectrum_shape_qual' then begin
          ; Make this a str match to deal with cases
          ; May wish to make more robust
          print,'Error parameter '+strjoin(temp_tag,'.')+' cannot be plotted.'
          print,"See Users' Guide and/or In-situ KP data SIS for details"
          print,'  on the meaning of this error parameter.'
        endif else begin
          ;
          ;  All other SWEA error params are siple error bars
          ;
          error_bars[0,*] = kp_data.(level0_index).(level1_index) $
            - kp_data.(err0_index).(err1_index)
          error_bars[1,*] = kp_data.(level0_index).(level1_index) $
            + kp_data.(err0_index).(err1_index)
        endelse
      end

    'LPW': $
      begin
        if strmatch( temp_tag[1], '*ewave*' )then begin
          ;
          ;  error params are percentage of data parameters
          ;
          error_bars[0,*] = kp_data.(level0_index).(level1_index) $
                          * ( 1.d0 - kp_data.(err0_index) * 0.01 )
          error_bars[1,*] = kp_data.(level0_index).(level1_index) $
                          * ( 1.d0 + kp_data.(err0_index) * 0.01 )
        endif else begin
          ;
          ; The others contain min and max in the subsequent two tags
          ;
          error_bars[0,*] = kp_data.(level0_index).(level1_index+1)
          error_bars[1,*] = kp_data.(level0_index).(level1_index+2)
        endelse
      end

    'EUV': $
      begin
        ;
        ;  If quality flag is 0 it is good so return 0
        ;  If quality flag is 1 pointing is questionable to return -3
        ;  If quality flag is 2 aperture closed so return -2
        ;
        good = where( kp_data.(err0_index).(err1_index) eq 0, ngood )
        bad = where( kp_data.(err0_index).(err1_index) eq 2, nbad )
        poor = where( kp_data.(err0_index).(err1_index) eq 1, npoor )
        if ngood gt 0 then error_bars[*,good] = 0.d0
        if nbad gt 0 then error_bars[*,bad] = -2.d0
        if npoor gt 0 then error_bars[*,poor] = -3.d0
      end

    'MAG': $
      begin
        ;
        ;  If quality flag is 1 it is abnormal so return -2
        ;    (may want to return -3 for 'unreliable'
        ;  If quality flag is 0 it is good so return 0
        ;
        good = where( kp_data.(err0_index).(err1_index) eq 0, $
                      ngood, complement=bad, n_complement=nbad )
        if ngood gt 0 then error_bars[*,good] = 0.d0
        if nbad gt 0 then error_bars[*,bad] = -2.d0
      end

    'SWIA': $
      begin
        ;
        ;  If quality flag is 0 it is bad so return -2
        ;  If quality flag is 1 it is good so return 0
        ;
        good = where( kp_data.(err0_index).(err1_index) eq 1, $
                      ngood, complement=bad, ncomplement=nbad )
        if ngood gt 0 then error_bars[*,good] = 0.d0
        if nbad gt 0 then error_bars[*,bad] = -2.d0
      end

    'NGIMS': $
      begin
        ;
        ;  First, calculate error brs assuming no flags
        ;
        error_bars[0,*] = kp_data.(level0_index).(level1_index) $
                        * ( 1.d0 - kp_data.(err0_index).(err1_index)*0.01 )
        error_bars[1,*] = kp_data.(level0_index).(level1_index) $
                        * ( 1.d0 + kp_data.(err0_index).(err1_index)*0.01 )
        ;
        ;  Now, flag the values that are upper lmits only
        ;
        upper_limit = where( kp_data.(err0_index).(err1_index) eq -1, count)
        if count gt 0 then error[*,upper_limit] = -1.d0
      end

    'STATIC': $
      begin
        if strmatch( temp_tag[1], '*o2plus_flow_vel*', /fold_case ) then begin
          error_bars[0,*] = kp_data.(level0_index).(level1_index) $
            - kp_data.(err0_index).(err1_index)
          error_bars[1,*] = kp_data.(level0_index).(level1_index) $
            + kp_data.(err0_index).(err1_index)
        endif else begin
          print,'Error parameter '+strjoin(temp_tag,'.')+' cannot be plotted.'
          print,"See Users' Guide and/or In-situ KP data SIS for details"
          print,'  on the meaning of this error parameter.'
        endelse
      end
  endcase
end