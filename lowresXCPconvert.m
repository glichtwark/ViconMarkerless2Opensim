function lowresXCPconvert(filein)
% function output = lowresXCPconvert(filein)
%
% function to adjust the data in the XCP file from high res to low res
%
% Input = filename of XCP file (if none then UI loads to select)
% Output = none
%
% Author: Glen Lichtwark, 14/08/22

% in no file given as input then use a ui to select file
if nargin < 1
    [filename, pathname, filterindex] = uigetfile('*.xcp', 'Pick Vicon XCP file');
    if filterindex < 1
        return
    end
    filein = [pathname filename];
end

% load the xcp file (xml structure)
S = xml2struct( filein );

% loop through all cameras, find orxy cameras and output YAML calibration
% file for each one
for I = 1:length(S.Cameras.Camera)
    
    if strcmp(S.Cameras.Camera{I}.Attributes.DISPLAY_TYPE,'VideoInputDevice:Oryx ORX-10G-89S6C')
        % camera ID
        camera_id = S.Cameras.Camera{I}.Attributes.DEVICEID;
        
        % sensor size (or image size)
        SS = str2num(S.Cameras.Camera{I}.Attributes.SENSOR_SIZE);
        % divide by 2 and return to string
        S.Cameras.Camera{I}.Attributes.SENSOR_SIZE = num2str(SS/2);
        
        % focal length
        FL = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.FOCAL_LENGTH);
        % divide by 2 and return to string
        S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.FOCAL_LENGTH = num2str(FL/2);
        
        % principal point
        PP = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.PRINCIPAL_POINT);
        S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.PRINCIPAL_POINT = num2str(PP/2);
        
        % load vicon radial2 pararameters
        VR = (S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.VICON_RADIAL2);
        VR_num = str2num(VR(17:end));
        VR_num(1:2) = VR_num(1:2)/2;
        S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.VICON_RADIAL2 = [VR(1:16) num2str(VR_num)];
    end
end

[pathout, filename, ~] = fileparts(filein);
% create output filename based on device ID
fileout = [pathout '\' filename '_adj.xcp'];

struct2xml( S, fileout )
