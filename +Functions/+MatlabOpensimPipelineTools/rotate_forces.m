function [Xout, Yout] = rotate_forces(X,Y,phi)

% Out = Rot2D(M,phi)
%
% This function performs a rotation on 2d point (X-Y). 
% where M is a n x 2 (X&Y) with n being each instant of the point
% and phi is the angle in rads to be rotated at each point
% see also RotXY for different layout

Yout = sin(phi(:,1)).*X + cos(phi(:,1)).*Y;
Xout = cos(phi(:,1)).*X - sin(phi(:,1)).*Y;
