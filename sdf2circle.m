 function f = sdf2circle(nrow,ncol, ic,jc,r)
[X,Y] = meshgrid(1:ncol, 1:nrow);
f = sqrt((X-jc).^2+(Y-ic).^2)-r;