clc; clear; close all;
import casadi.*

% parameters
vbar = 15;                      % max velocity
w0 = zeros(4,1);                % initial guess

% decision variables
% TODO

% objective
% TODO

% constraints
g = [];
lbg = [];
ubg = [];

% p1z >= 0
% TODO

% p2z >= 0
% TODO

% v1^2 <= vbar^2
% TODO

% v2^2 <= vbar^2
% TODO

nlp = struct('x', w, 'f', f', 'g', g);

% Create IPOPT solver object
solver = nlpsol('solver', 'ipopt', nlp);

% Solve the NLP
% TODO: fill in the correct parameters (replace "NaN")
res = solver('x0' , NaN,...           % solution guess
             'lbx', NaN,...           % lower bound on x
             'ubx', NaN,...           % upper bound on x
             'lbg', NaN,...           % lower bound on g
             'ubg', NaN);             % upper bound on g
 

% simulate optimal solution
wsol = full(res.x);
T = 0.5;
M = 100;
DT = T/M;
X0 = [0, 0, wsol(1), wsol(2), 10, 0, wsol(3), wsol(4)]';
X = X0;

% TODO: simulate with one step RK4 integrator



figure(1); clf; hold on;
plot(X(1,:), X(2,:))
plot(X(5,:), X(6,:))
