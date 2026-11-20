%% Lab T2 - Part 1
clear; clc;

%% Step 2 - first-order link K/(Ts+1)
K = 2.0;
T = 0.1;
num1 = K;          % numerator
den1 = [T 1];      % denominator: T*s + 1
wc = 1/T;          % corner frequency

[mag_c, ph_c] = bode_point(num1, den1, wc);

fprintf('Step 2  first-order link  K/(Ts+1),  K=2, T=0.1 s\n');
fprintf('  DC magnitude     = %.4f dB\n', 20*log10(K));
fprintf('  corner wc = 1/T  = %.1f rad/s\n', wc);
fprintf('  |W| at corner    = %.4f dB\n', mag_c);
fprintf('  phase at corner  = %.4f deg\n', ph_c);
fprintf('  step y(t=T)      = %.4f\n', K*(1-exp(-1)));
%% Step 3 - integrator 1/s
num_i = 1;
den_i = [1 0];     % s + 0  ->  pole at s = 0

fprintf('\nStep 3  integrator 1/s -- phase is a CONSTANT -90 deg\n');
for w = [1 10 100]
    [m, p] = bode_point(num_i, den_i, w);
    fprintf('  w=%6.1f rad/s:  |W| = %8.4f dB,  phase = %.4f deg\n', w, m, p);
end
%% Step 4 - series: amplifier x motor
Kp = 5.0;
num_amp = Kp;      % amplifier = pure gain
den_amp = 1;

[num_f, den_f] = link_series(num_amp, den_amp, num1, den1);

fprintf('\nStep 4  forward path = amp x motor\n');
fprintf('  num = [%s],  den = [%s]\n', num2str(num_f), num2str(den_f));
fprintf('  forward DC gain  = %.4f\n', num_f(end)/den_f(end));
%% Step 5 - close unity feedback
nH = 1;  dH = 1;   % H(s) = 1

[num_cl, den_cl] = link_feedback(num_f, den_f, nH, dH);
pole = roots(den_cl);

fprintf('\nStep 5  closed loop  G/(1+GH),  H=1\n');
fprintf('  num = [%s],  den = [%s]\n', num2str(num_cl), num2str(den_cl));
fprintf('  closed-loop DC gain = %.4f\n', num_cl(end)/den_cl(end));
fprintf('  closed-loop pole    = %.4f\n', pole);
fprintf('  closed-loop corner  = %.4f rad/s  (vs open-loop 10)\n', abs(pole));