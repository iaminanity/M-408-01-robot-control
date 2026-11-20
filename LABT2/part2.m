%% Lab T2 - Part 2
clear; clc;

%% (a) model & poles
wn   = 8.0;               % natural frequency
zeta = 0.25;              % damping ratio
num2 = wn^2;
den2 = [1, 2*zeta*wn, wn^2];
p  = sort(roots(den2));
wd = wn*sqrt(1 - zeta^2); % damped frequency

fprintf('(a) second-order link  wn=8, zeta=0.25\n');
fprintf('    num = [%g],  den = [%g %g %g]\n', num2, den2);
fprintf('    poles = %.4f %+.4fj ,  %.4f %+.4fj\n', ...
        real(p(1)), imag(p(1)), real(p(2)), imag(p(2)));
fprintf('    damped freq wd = %.4f rad/s\n', wd);

%% (b) step-response metrics
Mp = exp(-pi*zeta/sqrt(1-zeta^2))*100;  % overshoot, %
tp = pi/wd;                              % peak time
ts = 4/(zeta*wn);                        % 2% settling time

fprintf('\n(b) step-response metrics\n');
fprintf('    overshoot Mp = %.2f %%\n', Mp);
fprintf('    peak time tp = %.4f s\n', tp);
fprintf('    2%% settling  = %.4f s\n', ts);
%% (c) frequency response: resonant peak
wr    = wn*sqrt(1 - 2*zeta^2);
Mr_db = 20*log10(1/(2*zeta*sqrt(1-zeta^2)));
[m_wn, p_wn] = bode_point(num2, den2, wn);

fprintf('\n(c) frequency response\n');
fprintf('    resonant freq wr = %.4f rad/s\n', wr);
fprintf('    peak gain Mr     = %.4f dB\n', Mr_db);
fprintf('    at w=wn=8: |W| = %.4f dB,  phase = %.4f deg\n', m_wn, p_wn);
%% (d) pure delay: |W| = 1 (0 dB), phase = -w*tau
tau = 0.025;
fprintf('\n(d) pure delay  e^(-tau s),  tau = 25 ms   (|W| = 0 dB at every w)\n');
for w = [10 40 80]
    Wd = exp(-1j*w*tau);                         % e^(-s*tau) at s = j*w
    mag_d = abs(round(20*log10(abs(Wd)), 10));   % 0 dB
    fprintf('    w=%3d rad/s:  |W| = %g dB,  phase = %8.3f deg\n', ...
            w, mag_d, -rad2deg(w*tau));
end

%% (e) series: joint x delay at w = wn
ph_d_wn = -rad2deg(wn*tau);   % delay phase at w = 8
fprintf('\n(e) series joint x delay -- combined response at w = wn = 8 rad/s\n');
fprintf('    |combined| = %.4f dB  (delay adds 0 dB)\n', m_wn);
fprintf('    angle      = %.4f + %.4f = %.4f deg\n', p_wn, ph_d_wn, p_wn + ph_d_wn);
%% Reality-Check 1: resonant peak by dense frequency scan
ws   = logspace(-1, 2, 200001);                     % 0.1 ... 100 rad/s
Wjw  = polyval(num2, 1j*ws) ./ polyval(den2, 1j*ws); % W(jw) for all w at once
mags = 20*log10(abs(Wjw));                          % magnitude, dB
[Mr_scan, i] = max(mags);                           % biggest value and its index
wr_scan = ws(i);

ok1 = abs(wr_scan - wr) <= 5e-3*wr  &&  abs(Mr_scan - Mr_db) <= 2e-2;

fprintf('\nReality-Check 1: resonant peak by independent frequency scan\n');
fprintf('    scan  : wr = %.4f rad/s,  Mr = %.4f dB\n', wr_scan, Mr_scan);
fprintf('    theory: wr = %.4f rad/s,  Mr = %.4f dB\n', wr, Mr_db);
fprintf('    match? %d\n', ok1);
%% Reality-Check 2: RK4 step response
% state x = [y; y'],  y'' = -2*zeta*wn*y' - wn^2*y + wn^2*r
f  = @(x, r) [x(2); -2*zeta*wn*x(2) - wn^2*x(1) + wn^2*r];
dt = 1e-4;          % time step 0.1 ms
Tend = 6.0;         % simulate 6 seconds
r  = 1.0;           % unit step input
N  = round(Tend/dt);
x  = [0; 0];        % start at rest
ys = zeros(1, N+1);
tt = (0:N)*dt;

for k = 1:N+1
    ys(k) = x(1);
    k1 = f(x, r);
    k2 = f(x + 0.5*dt*k1, r);
    k3 = f(x + 0.5*dt*k2, r);
    k4 = f(x + dt*k3, r);
    x  = x + dt/6*(k1 + 2*k2 + 2*k3 + k4);
end

[ymax, imax] = max(ys);
tmax = tt(imax);

fprintf('\nReality-Check 2: RK4 time-domain step response\n');
fprintf('    sim overshoot = %.2f %%  (analytic %.2f %%)\n', (ymax-1)*100, Mp);
fprintf('    sim peak time = %.4f s  (analytic %.4f s)\n', tmax, tp);
fprintf('    sim final value = %.4f\n', ys(end));
%% Figures
% --- 1) Bode: joint, delay, joint x delay ---
w   = logspace(0, 2, 3000);
Wj  = polyval(num2, 1j*w) ./ polyval(den2, 1j*w);
Wdl = exp(-1j*w*tau);
Wc  = Wj .* Wdl;

figure('Color','w');
subplot(2,1,1);
semilogx(w, 20*log10(abs(Wj)), 'LineWidth', 1.6); hold on;
semilogx(w, 20*log10(abs(Wdl)), '--', 'LineWidth', 1.4);
plot(wr, Mr_db, 'rv', 'MarkerFaceColor', 'r');
plot(wn, m_wn, 'ko', 'MarkerFaceColor', 'k');
xline(wn, 'k:', '\omega_n = 8');
grid on; ylabel('|W|, dB'); ylim([-40 12]);
legend('joint', 'delay (0 dB)', 'peak at \omega_r', 'value at \omega_n', 'Location', 'southwest');
title('Magnitude: the peak is BELOW \omega_n');

subplot(2,1,2);
semilogx(w, rad2deg(unwrap(angle(Wj))), 'LineWidth', 1.6); hold on;
semilogx(w, rad2deg(-w*tau), '--', 'LineWidth', 1.4);
semilogx(w, rad2deg(unwrap(angle(Wc))), ':', 'LineWidth', 2);
plot(wn, -90, 'ko', 'MarkerFaceColor', 'k');
grid on; xlabel('\omega, rad/s'); ylabel('phase, deg');
legend('joint', 'delay', 'joint \times delay', 'Location', 'southwest');
title('Phase: -90° at \omega_n, delay adds extra lag');
saveas(gcf, 'part2_bode.png');

% --- 2) RK4 step response ---
figure('Color','w');
plot(tt, ys, 'LineWidth', 1.6); hold on;
yline(1, 'k:');
yline(1.02, 'g--'); yline(0.98, 'g--');
plot(tmax, ymax, 'ro', 'MarkerFaceColor', 'r');
text(tmax + 0.05, ymax, sprintf('M_p = %.2f%%,  t_p = %.4f s', (ymax-1)*100, tmax));
grid on; xlim([0 4]); xlabel('t, s'); ylabel('y(t)');
title('RK4 step response of 64/(s^2+4s+64)');
saveas(gcf, 'part2_step_rk4.png');