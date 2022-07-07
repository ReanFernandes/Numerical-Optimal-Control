function W = newton_type(w0, F, M, numit,flag)
    % implementation of a Newton type algorithm for finding the root of
    % function F(w), i.e., finding w such that F(w) = 0
    
    % Inputs:   w0:     initial guess (column vector)
    %           F:      function handle of F
    %           M:      function handle of a approximation of the Jacobian of F
    %           numit:  number of iterations performed
    
    % Returns:
    %           W:      iteration history of w
    

    % TODO
    % implement your Newton type algorithm
    W = w0;
    if flag == 1 %using hessian approx j*j
        for k =1:numit
            w = W(:,k);
            W(:,k+1) = w- (M(w)*M(w)')\F(w);
        end
    
    else        %using exact hessian
        for k =1:numit
            w = W(:,k);
            W(:,k+1) = w- (M(w))\F(w);
        end
    end