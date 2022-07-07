

f = @(x,y) (1 - x).^2 + 100 * (y - x.^2).^2 ;
w0 = [1; 1.1];
numit = 1000;

figure(1); clf; hold on;
x = linspace(.8, 1.2, 100);
[X,Y] = meshgrid(x);
contour(X,Y, f(X,Y), 100, 'DisplayName', 'f(w)');

scatter(w0(1), w0(2), 'c*', 'DisplayName', 'w_0')
axis([min(x), max(x), min(x), max(x)])
xlabel('x')
ylabel('y')
legend()


%% (b): impelment gradient and hessian
gradient = @(x)([2*(1-x(1))+100*2*(x(2)-x(1).^2)*(-2*x(1)); ...
                  200*(x(2)-x(1).^2)  ]);

hess = @(x)([(-2-400*(x(1)*(-2*x(1))+(x(2)-x(1).^2))), -400*x(1); ...
                  -400*x(1),   200  ]);




%% (c): test with two different Hessian approximations
% TODO: fill in the correct parameters (replace "NaN")
%% i) gradient desc, rho = 100
W_gd100 = newton_type(w0, gradient, @(w) 100 * eye(2), numit, 1);
plot(W_gd100(1,:), W_gd100(2,:), 'rx-', 'DisplayName', 'GD, \rho=100' )


%% gradien desc, rho = 500
W_gd500 = newton_type(w0, gradient, @(w) 500* eye(2), numit, 1);
plot( W_gd500(1,:), W_gd500(2,:), 'bo-', 'DisplayName', 'GD, \rho=500' )

%% gradien desc, rho = 550
W_gd500 = newton_type(w0, gradient, @(w) 550* eye(2), numit,1);
plot( W_gd500(1,:), W_gd500(2,:), 'ms-', 'DisplayName', 'GD, \rho=550' )


%% exact hessian

W_eh = newton_type(w0, gradient, @(w) hess(w), numit, 0);
plot( W_eh(1,:), W_eh(2,:), 'k^-', 'DisplayName', 'exact Hessian' )


%% plot of convergence speed
figure(2); clf; hold on;
xopt = [1;1];                               % true minimizer
plot(0:numit, log10(max(abs(W_gd500 - xopt))))
plot(0:numit, log10(max(abs(W_eh - xopt))))
legend('GD, \rho=500', 'exact hessian')
xlabel('iteration k')
ylabel('log ||w_k - w^* ||_\infty')

% (d): now use Casadi
import casadi.*
% TODO: calculate gradient, hessian via Casadi
w = MX.sym('w',2);
f_expr = f(w(1),w(2));
f_cas = Function('f_cas', {w}, {f_expr});
grad_cas =  Function('grad_cas', {w}, {gradient(w)});
grad_cas = returntypes('full',grad_cas);
hess_cas =  Function('hess_cas', {w}, {hessian(w)});
hess_cas = returntypes('full',hess_cas);

% exact hessian
% TODO: fill in the correct parameters (replace "NaN")
W_cas = newton_type(w0, grad_cas, hess_cas, numit,0);

figure(1)
plot(W_cas(1,:), W_cas(2,:), 'gv-','DisplayName', 'exact Hessian, casadi');