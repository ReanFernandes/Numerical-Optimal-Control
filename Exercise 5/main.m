import casadi.*
%%
N = 500;
x0 = 0.5;
h = 0.1;
x = MX.sym('x',1);
u = MX.sym('u',1);
U = MX.sym('U',N);

f = Function('f',{x,u},{x + h*((1-x)*x+u)});

Phi_expr = x0; % first value of Phi vector (Phi(x0))
for i = 1:N
    Phi_expr = [Phi_expr;f(Phi_expr(i),U(i))];
end
Phi_expr = Phi_expr(2:end);

Phi = Function('Phi',{U},{Phi_expr});
J = Function('J',{U},{jacobian(Phi_expr,U)});

%%tests
utest = rand(N,1);
Jref = full(J(utest));
m = 1;

fprintf('Mismatch between hand-coded forward AD and CasADi (column %d):\n',m)
disp(max(max(Jref(:,m) - forw_AD(utest, m, x0, h))))

m = N;
fprintf('Mismatch between hand-coded backward AD and CasADi (row %d):\n',m)
disp(max(max(Jref(m,:) - back_AD(utest, m, x0, h))))

fprintf('Mismatch between hand-coded forward AD and CasADi (full jacobian)\n')
disp(max(max(Jref(N-m+1:end,:) - J_FAD(utest, m, x0, h))))

fprintf('Mismatch between hand-coded backward AD and CasADi (full jacobian)\n')
disp(max(max(Jref(N-m+1:end,:) - J_BAD(utest, m, x0, h))))


%% timing

t_fw = zeros(N,1);
t_bw = zeros(N,1);

for i = 1:N
    tic
    J_FAD(utest, i, x0, h);
    t_fw(i) = toc;
    
    tic
    J_BAD(utest, i, x0, h);
    t_bw(i) = toc;
end

figure(1); clf; hold on;
plot(t_fw);
plot(t_bw);
legend('FAD', 'BAD')
xlabel('rows computed')
ylabel('t in s')
