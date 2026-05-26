function [r_lo, r_hi, dof_eff] = fisher_z_ci_AG(r, n_samples, autocorr_time_sec, dt_sec, alpha)
%FISHER_Z_CI_AG Fisher-z confidence interval with Bartlett-style effective DOF.
% n_samples: number of finite samples used in the correlation.
% autocorr_time_sec: characteristic decorrelation time of the smoother.
% dt_sec: sample period of x and y.
% alpha (default 0.05): two-sided confidence level.

if nargin < 5 || isempty(alpha), alpha = 0.05; end
if isnan(r) || n_samples < 5
    r_lo = NaN; r_hi = NaN; dof_eff = NaN;
    return
end

% effective independent samples ~ n / (autocorr_time / dt + 1)
ratio = max(1, autocorr_time_sec / dt_sec);
dof_eff = max(3, n_samples / ratio);

z = atanh(min(max(r, -0.999), 0.999));
se = 1 / sqrt(dof_eff - 3);

% normal critical value without Statistics Toolbox
zcrit = 1.959963984540054;
if alpha ~= 0.05
    if exist('norminv', 'file') == 2
        zcrit = norminv(1 - alpha/2);
    end
end

z_lo = z - zcrit*se;
z_hi = z + zcrit*se;
r_lo = tanh(z_lo);
r_hi = tanh(z_hi);
end
