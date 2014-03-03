pro MVN_KP_3D_OPTIMIZE, in, out, optimize

  out=in

  index=0
  for i=0,n_elements(in)-1, optimize do begin
    out[index] = in[i]
    index++
  endfor

  out = out[0:index-1]

end