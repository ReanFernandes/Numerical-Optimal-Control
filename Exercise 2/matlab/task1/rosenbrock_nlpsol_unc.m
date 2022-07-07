%
%     This file is part of CasADi.
%
%     CasADi -- A symbolic framework for dynamic optimization.
%     Copyright (C) 2010-2014 Joel Andersson, Joris Gillis, Moritz Diehl,
%                             K.U. Leuven. All rights reserved.
%     Copyright (C) 2011-2014 Greg Horn
%
%     CasADi is free software; you can redistribute it and/or
%     modify it under the terms of the GNU Lesser General Public
%     License as published by the Free Software Foundation; either
%     version 3 of the License, or (at your option) any later version.
%
%     CasADi is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with CasADi; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
%
%
% Load CasADi
clear variables
close all
import casadi.*
 
% Create NLP: Solve the Rosenbrock problem (unconstrained):
%     minimize    (x-1)^2 + 100*(y - x^2)^2
%

x = SX.sym('x');
y = SX.sym('y');
v = [x;y];
f = unc_rosenbrock_fun(x,y);
g = [];
nlp = struct('x', v, 'f', f', 'g', g);

% Create IPOPT solver object
solver = nlpsol('solver', 'ipopt', nlp);

% % Solve the NLP
res = solver('x0' , [2.5 3.0],...      % solution guess
             'lbx', -inf,...           % lower bound on x
             'ubx',  inf);             % upper bound on g
              
 
% Print the solution
f_opt = full(res.f)          
x_opt = full(res.x)         
lam_x_opt = full(res.lam_x)  
lam_g_opt = full(res.lam_g)  

% Plot result
figure()
n_points = 50;
range = 2;

x_v = linspace(x_opt(1) - 2*range,  x_opt(1) + range,n_points);
y_v = linspace(x_opt(2) - 2*range,  x_opt(2) + 2*range,n_points);

[X, Y] = meshgrid(x_v, y_v);

surf(X, Y, unc_rosenbrock_fun(X,Y) )
xlabel('x')
ylabel('y')
zlabel('z')