function mvn_kp_sc_traj_xyz, tracer, dims, x, y, z, $
        nn=nn, grid3=grid3, ti=ti
  
if (keyword_set(nn)) then begin
  ;
  ; Find nearest neighbor
  ;
  ix = value_locate(dims.x, x)
  iy = value_locate(dims.y, y)
  iz = value_locate(dims.z, z)
  model_interpol = tracer[ix,iy,iz]
  return, model_interpol
endif

if (keyword_set(grid3)) then begin
  
  data = x
  
  for i=0,n_elements(x)-1 do begin

        ;Reset all "out of bounds" errors
        x_out_of_bounds_error=0
        y_out_of_bounds_error=0
        z_out_of_bounds_error=0

        tempx = x[i]
        tempy = y[i]
        tempz = z[i]
        
        ;Find the closest values to tempx, tempy and tempz in the model,
        ;Box the point in a cube bounded by the points (xindex1,yindex1,zindex1) and (xindex2,yindex2,zindex2)
        xindex1 = value_locate(dims.x, tempx)
        if ((xindex1-1) lt 0) then begin
          xindex2 = xindex1+1
          x_out_of_bounds_error=1
        endif
        if ((xindex1+1) ge n_elements(dims.x)) then begin
          xindex2 = xindex1-1
          x_out_of_bounds_error=1
        endif
        if (x_out_of_bounds_error eq 0) then begin
          if (abs(dims.x[xindex1+1]-tempx) le abs(dims.x[xindex1-1]-tempx)) then begin
            xindex2=xindex1+1
          endif else begin
            xindex2=xindex1-1
          endelse
          if (dims.x[xindex2] lt dims.x[xindex1]) then begin
            temp=xindex2
            xindex2=xindex1
            xindex1=temp
          endif
        endif

        yindex1 = value_locate(dims.y, tempy)
        if ((yindex1-1) lt 0) then begin
          yindex2 = yindex1+1
          y_out_of_bounds_error=1
        endif
        if ((yindex1+1) ge n_elements(dims.y)) then begin
          yindex2 = yindex1-1
          y_out_of_bounds_error=1
        endif
        if (y_out_of_bounds_error eq 0) then begin
          if (abs(dims.y[yindex1+1]-tempy) le abs(dims.y[yindex1-1]-tempy)) then begin
            yindex2=yindex1+1
          endif else begin
            yindex2=yindex1-1
          endelse
          if (dims.y[yindex2] lt dims.y[yindex1]) then begin
            temp=yindex2
            yindex2=yindex1
            yindex1=temp
          endif
        endif

        zindex1 = value_locate(dims.z, tempz)
        if ((zindex1-1) lt 0) then begin
          zindex2 = zindex1+1
          z_out_of_bounds_error=1
        endif
        if ((zindex1+1) ge n_elements(dims.z)) then begin
          zindex2 = zindex1-1
          z_out_of_bounds_error=1
        endif
        if (z_out_of_bounds_error eq 0) then begin
          if (abs(dims.z[zindex1+1]-tempz) le abs(dims.z[zindex1-1]-tempz)) then begin
            zindex2=zindex1+1
          endif else begin
            zindex2=zindex1-1
          endelse
          if (dims.z[zindex2] lt dims.z[zindex1]) then begin
            temp=zindex2
            zindex2=zindex1
            zindex1=temp
          endif
        endif

        ;Transform the cube into a unit cube so we can determine the relative weights of each of the 8 points
        nx = (tempx-dims.x[xindex1])/(dims.x[xindex2]-dims.x[xindex1])
        ny = (tempy-dims.y[yindex1])/(dims.y[yindex2]-dims.y[yindex1])
        nz = (tempz-dims.z[zindex1])/(dims.z[zindex2]-dims.z[zindex1])

        ; Calculate the new interpolated number for each data point
          data[i] = tracer[xindex1, yindex1, zindex1]*(1-nx)*(1-ny)*(1-nz) $
            + tracer[xindex2, yindex1, zindex1]*(nx)*(1-ny)*(1-nz) $
            + tracer[xindex1, yindex2, zindex1]*(1-nx)*(ny)*(1-nz) $
            + tracer[xindex1, yindex1, zindex2]*(1-nx)*(1-ny)*(nz) $
            + tracer[xindex2, yindex1, zindex2]*(nx)*(1-ny)*(nz) $
            + tracer[xindex1, yindex2, zindex2]*(1-nx)*(ny)*(nz) $
            + tracer[xindex2, yindex2, zindex1]*(nx)*(ny)*(1-nz) $
            + tracer[xindex2, yindex2, zindex2]*(nx)*(ny)*(nz)


  endfor
  
  return, data
  
endif




end