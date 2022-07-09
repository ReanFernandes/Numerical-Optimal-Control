function [ xdot ] = ballistic_dynamics( x ) 

    % ode parameters
    w = 2;          % wind speed
    d = .1;         % drag coefficient
    g = 9.81;       % gravity

    % Insert your code defining the ode here
    x = x(:);

%     x = [ x(1) = py;
%           x(2) = pz;
%           x(3) = vy;
%           x(3) = vz]
    xdot = [x(3);
            x(4);
            -(x(3)-w)*norm((x(3:4)-[w;0]))*d;
            -x(3)*norm((x(3:4)-[w;0]))*d-g];
    

end

