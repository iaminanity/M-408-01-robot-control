function [num, den] = link_feedback(nG, dG, nH, dH)
% Negative feedback: W = G / (1 + G*H)
num = conv(nG, dH);
a = conv(dG, dH);
b = conv(nG, nH);
% add two polynomials of different length (pad with zeros on the left)
n = max(numel(a), numel(b));
a = [zeros(1, n-numel(a)) a];
b = [zeros(1, n-numel(b)) b];
den = a + b;
end