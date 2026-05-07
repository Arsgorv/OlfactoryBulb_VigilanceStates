function y = safe_log(x)
% Log-transform positive signals while avoiding invalid log values.

y = x;
y(y <= 0) = NaN;
y = log(y);
end
