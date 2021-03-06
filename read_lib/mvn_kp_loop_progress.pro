;+
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;
; :Params:
;    idx: in, required, integer
;       index for the loop to count
;    loopbot: in, required, integer
;       the minimum value of the progress count
;    looptop: in, required, integer
;       the maximum value of the progress count
;       
;
; :Keywords:
;     modval: in, optional type=integer
;       a way to jump ahead, not used here
;     message: in, optional, type=string
;       the header string to print at the beginning of the loop
;     cancel: in, optional, type=integer
;       a way out that isn't implemented as yet.
;-
pro MVN_KP_LOOP_PROGRESS,idx,loopbot,looptop,MODVAL=modval,MESSAGE=message,$
                    CANCEL=cancel

  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
                  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  cancel = 0
  
  !except = 0
  if n_elements(MODVAL) eq 0 then modval = 0
  !except = 1  

;  if modval mod idx ne 0 then return

  frac = float(idx+1-loopbot)/(looptop-loopbot+1)
  
  if keyword_set(MESSAGE) and idx eq loopbot then begin

     print
     print, message

  endif

  print,round(frac*100.), $
        strjoin(replicate('*',(round(frac*70) > 1))) ,$
        FORMAT="($,I3,'%',1x,'|',A-70,'|')"
  print
  
   if idx ge (looptop-modval) then print


end