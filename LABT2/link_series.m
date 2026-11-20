function [num, den] = link_series(num1, den1, num2, den2)
% Series connection: W = W1 * W2  -> multiply polynomials
num = conv(num1, num2);
den = conv(den1, den2);
end