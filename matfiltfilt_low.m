function [result] = matfiltfilt_low(dt, fcut, order, data)

% perform double nth order low pass butterworth filter on several columns of data

% the double filter should have 1/sqrt(2) transfer at fcut, so we
% need correction for filter order:
fcut = fcut/(sqrt(2)-1)^(0.5/order);

[b,a] = butter(order, 2*fcut*dt);

b = double(b);
a = double(a);

[n,m] = size(data);

for i=1:m
  result(:,i) = filtfilt(b,a,data(:,i));
end
