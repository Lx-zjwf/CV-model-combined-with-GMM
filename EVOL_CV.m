function phi = EVOL_CV(I, phi0, nu, lambda_1, lambda_2, timestep, epsilon)
phi=phi0;
phi=NeumannBoundCond(phi);
diracPhi=Delta(phi,epsilon);
Hphi=Heaviside(phi, epsilon);
kappa = CURVATURE(phi,'cc');
[C1,C2]=binaryfit(I,Hphi);
% updating the phi function
phi=phi+timestep*(diracPhi.*(nu-lambda_1*(I-C1).^2+lambda_2*(I-C2).^2));

function g = NeumannBoundCond(f)
% Make a function satisfy Neumann boundary condition
[nrow,ncol] = size(f);
g = f;
g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);