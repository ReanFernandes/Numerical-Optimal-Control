% Implementation of an interior point method 
clear variables
close all
clc

import casadi.*
% Problem definition
nv = 2;                 % number of decision variables
ne = 1;                 % number of equality constraints
ni = 1;                 % number of inequality constraints

x = MX.sym('x',nv);

x_test = [2,3];         % evaluate your function at this point and compare to given values

% YOUR CODE HERE:
% Objective
% F = Function(...);
f = (x(1)-4)^2 + (x(2)-4)^2;
F = Function('F',{x},{f});

F_test = 5;

% Equality contstraints
% G = Function(...);
g = sin(x(1))-x(2)^2;
G = Function('G',{x},{g});
G_test = -8.090702573174319;

% Inequality constraints
% H = Function(...);
h_test = 9.0;
h = x(1)^2+x(2)^2-4;
H = Function('H',{x},{h});



% Jacobian of f
% Jf = Function(...);
Jf = Function('Jf',{x},{jacobian(f,x)});
Jf_test = [-4,   -2];

% Jacobian of g
% Jg = Function(...);
Jg = Function('Jg',{x},{jacobian(g,x)});
Jg_test = [-0.4161,   -6.0000];

% Jacobian of h
% Jh = Function(...)
Jh = Function('Jh',{x},{jacobian(h,x)});
Jh_test = [4,   6];

% Hessian of f
% Hf = Function(...);
Hf = Function('Hf',{x},{hessian(f,x)});
Hf_test =   [   2, 0; ...
                0  2];
           
% Hessian of g
% Hg = Function(...);
Hg = Function('Hg',{x},{hessian(g,x)});
Hg_test =    [  -0.9093,  0        ; ...
                0,        -2.0000 ];
% Hessian of h
% Hh = Function(...);
Hh = Function('Hh',{x},{hessian(h,x)});
Hh_test =   [   2, 0; ...
                0  2];

% Interior point solver
max_it = 100;               % maximal number of iterations

% initial guesses for variables
xk = [-2;-4];                % decision variable
lk = 5*ones(ne,1);         % equality multipliers (lambda)
vk = 10*ones(ni,1);         % inequality multipliers (nu)
sk = 10*ones(ni,1);         % slack variables

% save iteration history in iter
iter = zeros(nv + ne + ni + ni,max_it);
iter(:,1) = [xk; lk; vk; sk];

% algorithm parameters
tau = 2;                    % initial value of tau
k_b = 1/3;                  % reduction factor for tau
th_1 = 1.0e-8;              % decrease tau if rhs of KKT smaller than this
th_2 = 1.0e-8;              % stop if tau smaller than this

% main loop
for i = 2:max_it
    % Build KKT system
    % first evaluate relevant functions at current iterate
    % constraints
    g_e     = G(xk);
    h_e     = H(xk);
    % Jacobians
    Jg_e    = Jg(xk);
    Jh_e    = Jh(xk);
    Jf_e    = Jf(xk);
    % Hessians
    Hf_e    = Hf(xk);
    Hg_e    = Hg(xk);
    Hh_e    = Hh(xk);
    % Hessian of Lagrangian
    Hl      = full(Hf_e) + full(Hg_e)*lk + full(Hh_e)*vk;
    

    % YOUR CODE HERE:
    % Buiild the KKT system
    M = full([        Hl     Jg_e'     Jh_e'    zeros(nv,ni);   
                      Jg_e    0         0           0;   
                      Jh_e    0         0           eye(ni);   
                      0  0      0         diag(sk)   diag(vk)]);  
    
    rhs = - full([    Jf_e' + Jg_e'*lk + Jh_e'*vk   ; 
                      g_e               ; 
                      h_e + sk             ; 
                      vk*sk-tau               ]);
    
    % Termination condition
    if norm(rhs) < th_1         % if smoothed system is solved for current tau
        if tau < th_2           % if tau is small enough
            disp('Solution found!')
            break;
        else
            % decrease tau and continue
            tau = tau*k_b;
        end
    end
     
    % YOUR CODE HERE:
    % Compute Newton step
    z_step = M\ rhs;
    
    % line-search
    max_ls = 100;
    x_step  = z_step(1:nv);
    l_step  = z_step(nv+1:nv+ne);
    v_step  = z_step(nv+ne+1:nv+ne+ni);
    s_step  = z_step(nv+ne+ni+1:end);
    alpha = 1;
    k_ls = 0.9;
    min_step = 1.0e-8;
    for j=1:max_ls
        
        % YOUR CODE HERE: 
        % Compute trial step
        v_t =vk + alpha*v_step;
        s_t =sk +alpha*s_step;
        if all(v_t >= 0) && all(s_t >= 0)
            break;
        end
        
        % YOUR CODE HERE:
        % Decrease alpha
        alpha = k_ls*alpha*.1;
        
        % Terminiation condition
        if norm(alpha*[ v_step;s_step]) < min_step
            error('Line search failed! Could not find dual feasible step.')
        end
    end
    
    % actual step
    xk  = xk + alpha*x_step;
    lk  = lk + alpha*l_step;
    vk  = vk + alpha*v_step;
    sk  = sk + alpha*s_step;
    % save for later processing
    iter(:,i) = [xk;lk;vk;sk];

    % every now and then reprint header
    if mod(i,20) == 1          
        fprintf([repmat('-',1,49),'\n']);
        fprintf('it \t tau \t\t ||rhs|| \t alpha\n');
        fprintf([repmat('-',1,49),'\n']);
    end
    % Print some info
    fprintf('%d \t %e \t %e \t %e\n',i, tau, norm(rhs), alpha)
end
iter = iter(:,1:i-1);
plot(iter')
grid on
xlabel('iterations')
ylabel('solution')

% Plot feasible set, and iterations
figure()
pl = ezplot('sin(x) - y^2');
set(pl,'Color','red');
hold all
pl= ezplot('x^2 + y^2 - 4');
set(pl,'Color','blue');
ezcontour('(x- 4)^2 + (y - 4)^2')
plot(iter(1,:),iter(2,:),'--','Color','black')
plot(iter(1,:),iter(2,:),'o','Color','black')
title('Iterations in the primal space')
grid on