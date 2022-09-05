function [alpha,beta] = AxisInclDev(Ax,Ay,Az)

% Outputs the inclination and deviation values in degree based on a
% given unit vector

alpha = asin(Ay)/(pi/180);
beta = atan(Az/Ax)/(pi/180);

end



 