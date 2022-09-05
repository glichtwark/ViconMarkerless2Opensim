function [Ax,Ay,Az] = InclDevAxis(alpha,beta)

% This function defines the unit vector representing the axis of rotation 
% for given inclination and deviation angles (given in degree)

% Given an inclination alpha (=tilt in sagittal plane) and a deviation beta 
% (=tilt in transversal plane) and assume X is anterior, Y is up, and Z is lateral. 

% Converting the angles in degrees to radians

alpha_rad = alpha*pi/180;
beta_rad= beta*pi/180;

% Calculating the x,y,z coordinate representation of the unit vector, which
% defines the axis of rotation;

Ax = cos(alpha_rad)*cos(beta_rad);
Ay = sin(alpha_rad);
Az = cos(alpha_rad)*sin(beta_rad);

% Outputs the axis
Axis = [Ax, Ay, Az];

end

