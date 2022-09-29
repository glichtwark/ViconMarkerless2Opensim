function [cam] = XCP_camera_params(filein,plotcam)
% function output = XCP2YAML(filein)
%
% function to convert information from XCP file to a YAML file that can be
% read by Jarvis and other softwares (or imported for use with OpenCV)
%
% Input = filename of XCP file (if none then UI loads to select)
% Output = cam = structure containing the camera matrix and pose etc
%
% Author: Glen Lichtwark, 14/08/22

if nargin < 2
    plotcam = 0;
end

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

%figure(1)

c = 1;

% loop through all cameras, find orxy cameras and output YAML calibration
% file for each one

for I = 1:length(S.Cameras.Camera)
    
    if strcmp(S.Cameras.Camera{I}.Attributes.DISPLAY_TYPE,'VideoInputDevice:Oryx ORX-10G-89S6C')
        %% load the parameters from structure
        % camera ID
        camera_id = S.Cameras.Camera{I}.Attributes.DEVICEID;
        
        % sensor size (or image size)
        IS = str2num(S.Cameras.Camera{I}.Attributes.SENSOR_SIZE);
        % principal point
        PP = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.PRINCIPAL_POINT);
        % focal length
        FL = str2double(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.FOCAL_LENGTH);
             
        % load vicon radial2 pararameters
        VR = (S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.VICON_RADIAL2);
        % only use the numbers (not string)
        VR = str2num(VR(17:end));
        % create distortion coefficients array
        RD = [VR(3) VR(4)];
        
        %load orientation (quaternions) and convert to a rotation matrix
        q = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.ORIENTATION);
        % CHANGE THE 4TH (REAL) VALUE TO THE FIRST TO FOLLOW MATLAB
        % CONVENTION
        qt = quaternion(q(4), q(1), q(2), q(3));
        % convert quaternion to rotation matrix (point frame of reference)
        RM(:,:,c) = rotmat(qt,'point');
        
        % translation matrix
        T(:,c) = str2num(S.Cameras.Camera{I}.KeyFrames.KeyFrame.Attributes.POSITION);
        
        %plottransformaxis(RM(:,:),T,300); hold on;
        %% store in camera parameters
        % store up the camera pose matrix (4x4) (camera relative to world)
        cam.cam_pose{c} = rigid3d ([[RM(:,:,c) [0; 0; 0]];[T(:,c)' 1]]);
        
        %cam.cam_params{c} = cameraParameters('IntrinsicMatrix',IM,'RadialDistortion',RD);         
        % define intrinsics matrix
        % intrinsic_matrix = [FocalLength(1)  , 0 , 0; ...
        %                     Skew,   FocalLength(2) , 0; ...
        %                    PrincipalPoint(1), PrincipalPoint(2), 1]; 
        % note that focalLength(2) is generally the same as FL1
        cam.cam_intrinsics{c} = cameraIntrinsics(FL,PP,IS);
        cam.cam_dist{c} = cameraParameters('RadialDistortion',RD);
        
        % define extrinsics matrix 
        % Transformation from world coordinates to camera coordinates. The transformation allows you to transform points from the world coordinate system to the camera coordinate system. tform is computed as:
        % tform.Rotation = cameraPose.Rotation'
        % tform.Translation = -cameraPose.Translation * cameraPose.Rotation'
        [cam.rotationMatrix(:,:,c),cam.translationVector(:,c)] = cameraPoseToExtrinsics(RM(:,:,c),T(:,c));
        
        % determine the camera projection matrix (4 x 3)
        %The function computes camMatrix as follows:
        %     camMatrix = [rotationMatrix; translationVector] × K.
        %     K: the intrinsic matrix
        cam.cam_matrix{c} = cameraMatrix(cam.cam_intrinsics{c},cam.rotationMatrix(:,:,c),cam.translationVector(:,c));
        
        cam.cam_id{c} = uint32(c);
        
        cam.Location{c} = T(:,c);
        cam.Orientation{c} = RM(:,:,c);
        
        if plotcam == 1
            plotCamera('Location',T(:,c),'Orientation',RM(:,:,c),'Size',200);hold on;zlim([0 2500])
        end
        % increase counter by one
        c = c+1; 
    end
    
end

%cam.pose_table = table([cam.cam_id{:}]',[cam.cam_pose{:}]','VariableNames',{'ViewId', 'AbsolutePose'});
