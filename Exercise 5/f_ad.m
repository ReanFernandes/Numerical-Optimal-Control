function Jp = f_ad(u,m,x0,h)

N = length(u);
udot = zeros(N,1); %set initial u vector
xdot = zeros(N,1);
xk = x0;
xdot(1) = h*udot(1); %(df/du at point u0 * udot(0);

for i = 2:N
    xk = xk+ h((1-xk)*xk +u(i-1));
    dfdu = h;
    dfdx = 1 +h*(1-2*xk);
    xdot(i) = dfdu*udot(i-1)+dfdx*xdot(i-1);
end
Jp = xdot