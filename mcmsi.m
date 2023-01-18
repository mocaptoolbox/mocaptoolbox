function m = mcmsi(d1,d2,options)
% Multivariate Synchronization Index between two MoCap or Norm data structures.
%
% syntax
%
% m = mcmsi(d1,d2)
% m = mcmsi(d1,d2,'iterations',...)
%
% input parameters
%
% d1, d2: MoCap or Norm data structures
%
% iterations: Name-value argument used to specify number of iterations for calculating Imin (optional). Default: mcmsi(...,'iterations',1000)
%
% output
%
% m: multivariate synchronization index, returned as a scalar.
%
% examples
%
% m = mcmsi(d1,d2,'iterations',100)
%
% comments
%
% see also
%
% mccoupling, mcplsproj, mcgxwt
%
% references
%
% Carmeli, C. 2006. Assessing cooperative behaviour in dynamical networks with applications to brain data, PhD. thesis, Ecole Polytechnique Federale De Lausanne.

    arguments
        d1(1,1) {mustBeMocapNormSegm(d1)}
        d2(1,1) {mustBeMocapNormSegm(d2)}
        options.iterations = 1000
    end
    for k = 1:options.iterations
        rX1 = randn(size(d1.data));
        rX2 = randn(size(d2.data));
        rI(k) = Ifun(rX1,rX2);
    end
    Imin = min(rI);
    X1 = d1.data;
    X2 = d2.data;
    [I R] = Ifun(X1,X2);
    lognn=log(2*size(R,1));
    m=(lognn-I)/(lognn-Imin);
end

function [I R] = Ifun(X1,X2)
    C1=corr(X1);
    C2=corr(X2);
    C12=corr(X1,X2);

    T1=sqrt(inv(C1));
    T2=sqrt(inv(C2));

    Z=[X1 X2]*[[T1 zeros(size(T1,1))];[zeros(size(T1,1)) T2]];

    R=corr(Z);
    e=eig(R);

    % Deal with rounding errors
    e=real(e);
    e=max(e,0);

    en=e/sum(e);
    I=-sum(en.*log(en+eps));
end
