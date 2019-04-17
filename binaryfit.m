function [C1,C2]= binaryfit(Img,H_phi) 
a= H_phi.*Img;
numer_1=sum(a(:)); 
denom_1=sum(H_phi(:));
C1 = numer_1/denom_1;

b=(1-H_phi).*Img;
numer_2=sum(b(:));
c=1-H_phi;
denom_2=sum(c(:));
C2 = numer_2/denom_2;
