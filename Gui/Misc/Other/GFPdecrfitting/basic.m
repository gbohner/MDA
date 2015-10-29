f = @(p,x)p(1)*exp(-x/p(2)) + p(3);

[result, resnorm, residual] = lsqcurvefit(f, [-1 -10 1], AvgTime(900:1002), AvgInt.gfp.norm(900:1002));

a = [a; result];