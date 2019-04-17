function H = Heaviside(phi,epsilon)
H = 0.5*(1+ (2/pi)*atan(phi./epsilon));
end