clear all;clc;close all;

import casadi.*


%% variable inits
import casadi.*
N = 50; %horizon
DT =0.1;% time step
N_rk4 = 10;% no os seteps in rk4 
nv = 2 ;%no of variables (theta, omega)
nu = 1; % no of control variables
x_bar = [pi;0];

%% integrator
import casadi.*
dynamics = @(x,u) [x(2); sin(x(1)) + u]; %ode dynamics of system
h = DT/N_rk4 % breaking down DT in N_k4 steps
x = MX.sym( 'x', nv,1 );
u = MX.sym('u',nu,1);

x_next = x;
%rk4 integrator
for i = 1:N_rk4
    x_next = rk4step(x_next,u,dynamics,h);
end

F = Function('F',{x,u},{x_next});

%% NLP
import casadi.*
U = MX.sym('U',N);
U0 = .1*ones(N,1);

X = F(x_bar,U(1)); %first state
for i = 1:N-1
    X = [X,F(X(:, i),U(i+1))];
end

%% cost function
cas();
L = sum(sum(X(:,1:end-1).^2)) + 2*sum(U.^2); %stage cost
L = L + 10*sum(X(:,end).^2);

Lhess = Function('Lhess',{U},{hessian(L,U)});
figure(1)
spy(full(Lhess(U0)));
lbx = [];
ubx = [];
for i = 0:N-1
    lbx = [lbx;-1];
    ubx = [ubx; 1];
end

nlp = struct('x', U, 'f',L);
solver = nlpsol('solver','ipopt', nlp);
sol  = solver('x0',U0,'lbx',lbx,'ubx',ubx,'lbg',0,'ubg',0);

u_opt = sol.x;
FX = Function('FX',{U},{X});
x_opt = [x_bar,full(FX(u_opt))];
figure(2); clf;
subplot(2,1,1);hold on;
plot(0:N,x_opt(1,:))
plot(0:N,x_opt(2,:))
title('State Trajectory')
legend('\phi','\omega')

subplot(2,1,2);hold on;
stairs(0:N-1,[full(u_opt)])
title('Control Trajectory')
legend('U')

animatePendulum(x_opt(1,:), 0.05, 'pendulum.gif')










