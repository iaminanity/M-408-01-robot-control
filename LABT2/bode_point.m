function [mag_db, ph_deg] = bode_point(num, den, w)
% Evaluate W(s) = num/den at s = j*w
s   = 1j*w;
val = polyval(num, s) ./ polyval(den, s);
mag_db = 20*log10(abs(val));
ph_deg = rad2deg(angle(val));
end