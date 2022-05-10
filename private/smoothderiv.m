function y = smoothderiv(data,k,f,o)
% function y = smoothderiv(data,k,f,o)
% Compute a derivative of order o of signal data, using Savitzky-Golay FIR
% smoothing filter of polynomial order k and frame size f.

data = data(:)';
[b,g]=sgolay(k,f);
y = zeros(1,length(data)-f);
for n = (f+1)/2:length(data)-(f+1)/2,
    y(n)=factorial(o)*g(:,o+1)'*data(n - (f+1)/2 + 1: n + (f+1)/2 - 1)';
end