% code snippet for how to build a multiple shooting OCP in casadi
% adapted from direct_multiple_shooting.m from the casadi example pack
% for a complete example, but with lots of details you will not need, see
% https://github.com/casadi/casadi/releases/download/3.4.5/casadi-example_pack-v3.4.5.zip
clear all;clc;close all;

%% declare all functions and parameters you need to formulate the NLP
%% variable inits
import casadi.*
N = 50; %horizon
DT =0.1;% time step
N_rk4 = 10;% no os seteps in rk4 
nx = 2 ;%no of variables (theta, omega)
nu = 1; % no of control variables
x_bar = [pi;0];
dynamics = @(x,u)[x(2);(sin(x(1))+u)];  % ode of the systems
h = DT/N_rk4; % breaking down DT in N_k4 steps
x = MX.sym( 'x', nx,1 );
u = MX.sym('u',nu,1);
rho = 0.01;

%integrator from x_k, u_k to x_k+1
x_next = x;
for i = 1:N_rk4
    x_next = rk4step(x_next,u,dynamics,h);
end
F = Function('F',{x,u},{x_next});

%% formulate and solve the NLP
% Start with an empty NLP
w = {};             % decision variables
J = 0;              % cost
g = {};             % constraints

% elimination of initial state -> x0 is not a decision variable
xk = x_bar;

% build decision variables, objective, and constraint
for k = 0:N-1
    % New NLP variable for the control u_k
    uk = MX.sym(['u_', num2str(k)], nu);
   
    % collect in w
    w = {w{:}, uk};            

    % Integrate till the end of the current interval
    xnext = F(xk,uk); %something something xk uk
    
    % contribution of stage cost to total cost
    J = J + norm(xk).^2 + 2*norm(uk).^2- rho*(log(1-uk)+log(1+uk));

    % New NLP variable for state at end of interval
    xk = MX.sym(['x_', num2str(k+1)], nx);
    
    % collect in w
    w = {w{:}, xk};
    
    % Add dynamic constraint function,
    % constraining xk to integration result
    g = {g{:},  xk - xnext    };

end

% contribution of terminal cost
J = J + 10*norm(xk).^2;

%% structure of hessian of lagrangian
% NOT A NECESSARY PART TO BUILD NLP
% Lagrangian
L = J;          % start with contribution of objective function

% collect all variables of lagrangian in this (x_k, u_k, lambda_k) in the
% order defined on the sheet
z = {};
for k = 1:N
    % New variable for multiplier lambda_k of k-th dynamic constraint
    lam_k = MX.sym(['lam_', num2str(k)], nx);
    
    % contribution of constraint k to lagrangian
    L = L + g{k}'*lam_k;
        
    % collect variables in correct order
    z = {z{:}, w{2*k-1}};   % u_k-1
    z = {z{:}, lam_k};
    z = {z{:}, w{2*k}};   % x_k
end
z = vertcat(z{:});          % transform to column vector

%% % Hessian of Lagrangian and full newton step
Hess_L = Function('Hess_L', {z}, {hessian(L,z)});
Grad_L = Function('Grad_l',{z},{jacobian(L,z)'});

num_it = 100;
rhs_tol = 1e-6;
iter = 0.1*ones(size(z));
for i = 2:num_it
    rhs = full(Grad_L(iter(:,i-1)));
    KKT = full(Hess_L(iter(:,i-1)));
    if norm(rhs) < rhs_tol
        fprintf('converged after %d iterations\n', i)
        break
    end
    wk = iter(:,i-1);
    step =  - KKT \ rhs;
    % line search
    alpha = 1;
    beta = .5;
    while true
        candidate = wk + alpha * step;
        U = candidate(1:2*nx+nu:end);
        if all(U < 1) && all(U > -1)
            break
        end
        alpha = beta * alpha;
    end
    iter(:,i) = candidate;
end
if i == num_it
    display('maximum iterations reached')
end
figure(1)
spy(full(Hess_L(0.1)));
z_opt = full(iter(:,end));
 
U_opt = z_opt(1:2*nx+nu:end);
X_opt = [z_opt(4:2*nx+nu:end)';
         z_opt(5:2*nx+nu:end)'];
X_opt = [x_bar,X_opt];

figure(2);
title('Full Newton Step')
subplot(2,1,1);hold on;
plot(0:N,X_opt(1,:))
plot(0:N,X_opt(2,:))
title('State Trajectory- Full Newton step ')
legend('\phi','\omega')

subplot(2,1,2); hold on;
stairs(0:N-1,U_opt)
title('Control Trajectory-Full newton step')
legend('U')
animatePendulum(X_opt(1,:),0.05,'pendulum_simultaneous_control.gif')

%%
% Create an NLP solver
% vertcat({w}) will put all elements of w into a column vector
prob = struct('f', J, 'x', vertcat(w{:}), 'g', vertcat(g{:}));
solver = nlpsol('solver', 'ipopt', prob);

% either build lbg and ubg along with g, but as vector, like
% lbg = [];
% lbg = [lbg; ...];
% lbg = [lbg; ...];
% ...
% or just use g in standard form g(x) = 0 and use
lbg = 0; ubg = 0;

% similar for w0
% for complicated initial guess build along side w, otherwise just
% put it to some value here.
w0 = 0.1;

% Solve the NLP
sol = solver('x0', w0, 'lbg', lbg, 'ubg', ubg);

% obtain solution
w_opt = full(sol.x);
u_opt = w_opt(1:nx+nu:end);
x1_opt = w_opt(2:nx+nu:end);
x2_opt = w_opt(3:nx+nu:end);
X_opt = [x_bar,[x1_opt,x2_opt]'];
%%  visualize solution
figure(3);
title('Multiple shooting')
subplot(2,1,1);hold on;
plot(1:N,x1_opt)
plot(1:N,x2_opt)
title('State Trajectory-multiple shooting')
legend('\phi','\omega')

subplot(2,1,2); hold on;
stairs(0:N-1,u_opt)
title('Control Trajectory - multiple shooting')
legend('U')

% animatePendulum(X_opt(1,:),0.05,'pendulum_simultaneous_control.gif')
 