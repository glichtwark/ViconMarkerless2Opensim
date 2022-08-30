function XCP2YAML(filein)
% function output = XCP2YAML(filein)
%
% function to convert information from XCP file to a YAML file that can be
% read by Jarvis and other softwares (or imported for use with OpenCV)
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

figure(1)
% loop through all cameras, find orxy cameras and output YAML calibration
% file for each one
for I = 1:length(S.Cameras.Camera)
    
    if strcmp(S.Cameras.Camera{I}.Attributes.DISPLAY_TYPE,'VideoInputDevice:Oryx ORX-10G-89S6C')
        %% load the parameters from structure
        % camera ID
        camera_id = S.Cameras.Camera{I}.Attributes.DEVICEID;
        
        % sensor size (or image size)
        SS = str2num(S.Cameras.Camera{I}.Attributes.SENSOR_SIZE);
        % principal point
        PP = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.PRINCIPAL_POINT);
        % intrinsics matrix
        IM = [str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.FOCAL_LENGTH) 0 0;0 str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.FOCAL_LENGTH) 0;PP(1) PP(2) 1];
        
        % load vicon radial2 pararameters
        VR = (S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.VICON_RADIAL2);
        % only use the numbers (not string)
        VR = str2num(VR(17:end));
        % create distortion coefficients array
        DC = [VR(3) VR(4) 0 0 0];
        
        %load orientation (quaternions) and convert to a rotation matrix
        q = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.ORIENTATION);
        qt = quaternion(q(4), q(1), q(2), q(3));
        % rotation matrix
        RM = rotmat(qt,'point');
        rotation = RM';        
        
        % translation matrix
        T = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.POSITION);
        translation = -T * RM';
        
        %% create structure for output to YAML file
        % intrinsics matrix
        output.intrinsicMatrix.rows = int32(3);
        output.intrinsicMatrix.cols = int32(3);
        output.intrinsicMatrix.dt = 'd';
        output.intrinsicMatrix.data = reshape(IM',1,9); % reshape to array
        
        % distortion coefficients
        output.distortionCoefficients.rows = int32(1);
        output.distortionCoefficients.cols = int32(5);
        output.distortionCoefficients.dt = 'd';
        output.distortionCoefficients.data = DC;
        
        % rotation matrix
        output.R.rows = int32(3);
        output.R.cols = int32(3);
        output.R.dt = 'd';
        output.R.data = reshape(rotation',1,9); % reshape to array
        
        % translation
        output.T.rows = int32(3);
        output.T.cols = int32(1);
        output.T.dt = 'd';
        output.T.data = translation;
        
        %% output the file
        % first get path for input file and put YAML files in same
        % directory
        [pathout, ~, ~] = fileparts(filein);
        % create output filename based on device ID
        fileout = [pathout '\' camera_id '.yaml'];
        
        % dump ouptut structure to yaml file
        yaml.dumpFile(fileout, output)
        %%
        plotCamera('Location',T,'Orientation',RM,'Size',200);hold on
    end
    
end

zlim([0 2500])