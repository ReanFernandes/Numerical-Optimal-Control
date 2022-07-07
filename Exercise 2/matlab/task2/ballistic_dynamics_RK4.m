function [ P_t ] = ballistic_dynamics_RK4( v_start )

    T = 0.5;
    M = 100;
    DT = T/M;

    X0 = [0, 0, v_start(1), v_start(2), 10, 0, v_start(3), v_start(4)];

    % RK4 integrator
    for j=1:M
        % insert your code here to do one RK4 step per iteration of j
    end

    P_t = [Xf(1), Xf(2), Xf(5), Xf(6)];

end

