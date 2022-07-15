function solution = full_newton_step(previous_step,KKT,rhs,iteration_step)

solution = previous_step - KKT\rhs;


if iteration_step == 100
    fprintf("Maximum iterations reached")
    return
end


