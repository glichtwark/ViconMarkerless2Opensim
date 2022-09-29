clear
%% select the folder with data in it
data_directory = uigetdir(cd, 'Select the folder with video files and XCP data in it');
cd(data_directory);

%%  load the csv files and calibration file
xcp_file = dir('*.xcp');

if length(xcp_file)>1
    disp('There are more than one XCP files in directory, please ensure only one')
    return;
end

cam = XCP_camera_params(xcp_file(1).name);

%% run mediapipe analysis via python wrapper across all avi files in directory
%pyversion('C:\ProgramData\Anaconda3\pythonw.exe'); % may need to run first if python version not loaded. 

mp_path = fileparts(which('media_pipe_3D_reconstruction.m'));
if count(py.sys.path,mp_path) == 0
    insert(py.sys.path,int32(0),mp_path)
end

% get names of all avi (video) files in the folder
avifiles = dir('*.avi');

% get names of all of the any existing csvfiles
csvfiles = dir('*.csv');
if ~isempty(csvfiles)
    run_mediapipe = input('CSV files already exist. Do you want to re-process (Y/N)  ','s');  
else 
    run_mediapipe = 'Y';
end

if strcmp(run_mediapipe,'Y')
    for F = 1:length(avifiles)
        disp(['Processing ' avifiles(F).name ' .....']);
        py.mediapipe_pose_estimation_markerless.mediapipe_video_analysis([avifiles(F).folder '\' avifiles(F).name]);
    end
end

% get names of all of the newly made csvfiles
csvfiles = dir('*.csv');

%% loop through csv files and open them and extract the landmark information and store to data structure
for F = 1:length(csvfiles)
    % load data fle
    data.data2d{F} = load_mediapipe_csv(csvfiles(F).name);
    % get frame_np time stamps for filtering and gap filling
    frame_no = table2array(data.data2d{F}(:,1));    
    time = table2array(data.data2d{F}(:,2));
    dt = nanmedian(diff(time));
    time = (1:frame_no(end))'*dt;    
    
    idx=ismember(1:numel(time),frame_no);
    
    for i = 3:4:size(data.data2d{1},2)
        MNAME = data.data2d{F}.Properties.VariableNames{i};
        MNAME = MNAME(1:end-2);        
        % get data from the table and interpolate any missing points from
        % the first to last frame
        XY = table2array(data.data2d{F}(:,i:i+1));
        % undistort points
        XY = undistortPoints(XY,cam.cam_dist{F});
        % interpolate across any missing frames
        X = (interp1(frame_no,XY(:,1),1:frame_no(end),'linear'))';
        Y = (interp1(frame_no,XY(:,2),1:frame_no(end),'linear'))';
        C = (interp1(frame_no,table2array(data.data2d{F}(:,i+3)),1:frame_no(end),'linear'))';        
        X(~idx) = 0;
        Y(~idx) = 0;
        C(~idx) = 0;
        % low pass filter
        X_filt = matfiltfilt_low(dt,6,2,X); % 6Hz low pass filter
        Y_filt = matfiltfilt_low(dt,6,2,Y); % 6Hz low pass filter
        %store to marker structure
        data.markers2D.(MNAME).XY(:,1,F) = X_filt;
        data.markers2D.(MNAME).XY(:,2,F) = Y_filt;
        data.markers2D.(MNAME).C(:,F) = C;
    end
end

% savve the frame no, time, frame_rate to data structure
data.frame(:,1) = frame_no(1):1:frame_no(end);
data.time = time;
data.frame_rate = 1/dt;
% get information about the number of frames and markers for doing
% triangulation
nframes = size(data.data2d{1},1);
markers = fieldnames(data.markers2D);

%% define the pose_stick connections
pose_stick = [1, 8; 1, 9; 12, 13; 12, 24; 24, 25; 13, 25; ...  torso and head
        12, 14; 14, 16; 16, 20; 16, 22; ...left arm
        13, 15; 15, 17; 17, 21; 17, 23; ... right arm
        24, 26; 26, 28; 28, 30; 30, 32; 28, 32; ... left leg
        25, 27; 27, 29; 29, 31; 31, 33; 29, 33]; %right leg
    
%% loop through each frame and triangulat all markers to get XYZ coordinates
figure;
% define a confidence threshold - only do triangulation on cameras that
% have a confidence value above this threshold
a = 1:8; % array numbering each camera
conf_thresh = 0.6; % threshold

% loop through all frames and do triangulation on all markers and then draw
% animation
for i = 1:nframes
    for j = 1:length(markers)
        s = 0.1;
        % find which cameras have confidence above threshold for current
        % frame and marker
        a_thresh = a(data.markers2D.(markers{j}).C(i,:)>conf_thresh);
        % if there aren't more than 2 cameras above threshold reduce it
        % temporarily and let the user know
        while length(a_thresh) < 2
            a_thresh = a(data.markers2D.(markers{j}).C(i,:)>(conf_thresh-s));
            s = s + 0.1;
            disp(['Reduced confidence threshold to ' num2str(conf_thresh-s) ' for ' markers{j} ' in frame number ' num2str(i)]);
        end
        % only write those above threshold to the pointTrack structure
        data.PT{i,j} = pointTrack(a_thresh,squeeze(data.markers2D.(markers{j}).XY(i,:,a_thresh))');
        % undertake triangulation on pointTracks (based on camera matrix)
        data.worldPoints{i,j} = vision.internal.triangulateMultiViewPoints(data.PT{i,j}, cam.cam_matrix);
    end
    % convert from mm to m
    data.XYZ(:,:,i) = (reshape([data.worldPoints{i,:}],3,length(markers)))'/1000; 
    % run animation
    if i == 1
        p = plot3(data.XYZ(:,1,i),data.XYZ(:,2,i),data.XYZ(:,3,i),'.b', 'MarkerSize',4);
        hold off        
    else
        p.XData = data.XYZ(:,1,i)';
        p.YData = data.XYZ(:,2,i)';
        p.ZData = data.XYZ(:,3,i)';
    end
    % draw lines (stick figure) between selected points
    for j = 1:length(pose_stick)
        if i == 1
            L(j) = line(data.XYZ(pose_stick(j,:),1,i)',data.XYZ(pose_stick(j,:),2,i)',data.XYZ(pose_stick(j,:),3,i)','Color','k','LineWidth',2);
        else
            L(j).XData = data.XYZ(pose_stick(j,:),1,i);
            L(j).YData = data.XYZ(pose_stick(j,:),2,i);
            L(j).ZData = data.XYZ(pose_stick(j,:),3,i);
        end
    end
    
    drawnow
    axis equal
    %axis([-800 0 -200 1200 0 1800]/1000) 
        
end

%% check the camera positions are in the write position relative to the person if there is a problem
% hold on;
% for c = 1:length(cam.Location)
%     plotCamera('Location',cam.Location{c}/1000,'Orientation',cam.Orientation{c},'Size',0.15);hold on;
% end
% hold off;


%% write the 3D data to a TRC filename for subsequent opensim modelling
TRC_Filename = [cd '\' xcp_file.name(1:end-4) '.trc'];
mediapipepose2trc(data, TRC_Filename);

%% process opensim model - start by scaling generic model
import org.opensim.modeling.*
mass = str2double(input('Enter mass in KG and press Enter:   ','s'));    
p_name = input('Enter participant code:   ','s');   

generic_model = 'C:\Users\uqglicht_local\OneDrive - The University of Queensland\Documents\Jarvis\Rajagopal2015_mediapipe_head.osim';
scale_settings_file = 'C:\Users\uqglicht_local\OneDrive - The University of Queensland\Documents\Jarvis\scale_settings_mediapipe.xml';
scaled_model = [cd '\ModelScaling\' p_name '_modelScaled' '.osim'];

disp('Scale Tool Processing....')

%load scale tool and associated tools
ScTool = ScaleTool(scale_settings_file);
ScTool.setName(p_name)
ScTool.setPathToSubject('');
GMM = ScTool.getGenericModelMaker;
MS = ScTool.getModelScaler;
MP = ScTool.getMarkerPlacer;

%add model to generic setup file
GMM.setModelFileName(generic_model);
GMM.setName(generic_model);

%add output files
MS.setOutputScaleFileName([cd '\ModelScaling\' p_name '_scaleSetApplied' '.xml']);
MS.setOutputModelFileName([cd '\ModelScaling\' p_name '_modelScaled' '.osim']);
MP.setOutputMotionFileName([cd '\ModelScaling\' p_name '_static' '.mot']);
MP.setOutputModelFileName([cd '\ModelScaling\' p_name '_modelScaled' '.osim']);
MP.setOutputMarkerFileName([cd '\ModelScaling\' p_name '_markersScaled' '.xml']);
ScaledModel = [cd '\ModelScaling\' p_name '_modelScaled' '.osim'];

% setup the specific file parameters
% note that the name and path of the file is in the data_structure for static file
MS.setMarkerFileName(TRC_Filename);
MP.setMarkerFileName(TRC_Filename);

markerData = MarkerData(TRC_Filename);
% Get initial and intial time
InitialTime = markerData.getStartFrameTime();
FinalTime = markerData.getLastFrameTime();

%add time range
time_range = ArrayDouble;
time_range.append(FinalTime-0.1);
time_range.append(FinalTime);
MS.setTimeRange(time_range);
MP.setTimeRange(time_range);

%add mass
ScTool.setSubjectMass(mass);

%create the ModelScaling directory above c3d directory if it doesn't exist
if isempty(dir([cd '\ModelScaling']))
    mkdir(cd,'ModelScaling');
end
%write new .xml file in setup folder
ScTool.print([cd '\ModelScaling\' p_name '_setupScale.xml']);
% run scaling tool;
ScTool.run();
disp('DONE.');
%%
disp('IK Tool Processing....');
data_path = cd;

ik_settings_file = 'C:\Users\uqglicht_local\OneDrive - The University of Queensland\Documents\Jarvis\IK_settings_mediapipe.xml';

ikTool = InverseKinematicsTool(ik_settings_file);

model = Model(scaled_model);

% Tell Tool to use the loaded model
ikTool.setModel(model);

%create the InverseKinematics directory above c3d directory if it
%doesn't exist
if isempty(dir([data_path '\InverseKinematics']))
    mkdir(data_path,'InverseKinematics');
end

% define the file names
marker_file = TRC_Filename;
[~,fname,~] = fileparts(TRC_Filename);
mot_file = [data_path '\InverseKinematics\' fname '.mot'];

setup_file = [data_path '\InverseKinematics\' fname '_iksetup.xml'];
% Get trc data to determine time range
markerData = MarkerData(TRC_Filename);
% Get initial and intial time
initial_time = markerData.getStartFrameTime();
final_time = markerData.getLastFrameTime();
% Setup the ikTool for this trial
ikTool.setMarkerDataFileName(marker_file);
ikTool.setStartTime(initial_time);
ikTool.setEndTime(final_time);
ikTool.setOutputMotionFileName(mot_file);
ikTool.setName(fname)
ikTool.setResultsDir([data_path '\InverseKinematics\']);

%write the XML setup file in same directory as MOT file
ikTool.print(setup_file);
disp(['Processing ' marker_file '....']);
% Run IK via API
ikTool.run();
disp(['DONE.']);



%% run body kinematics

body_settings_file = 'C:\Users\uqglicht_local\OneDrive - The University of Queensland\Documents\Jarvis\body_kinematics_settings_mediapipe.xml';
            
%create the InverseKinematics directory above c3d directory if it
%doesn't exist
if isempty(dir([data_path '\BodyKinematics']))
    mkdir(data_path,'BodyKinematics');
end

hd = ['time' '\t' 'vertical_acc' '\t' 'horizontal_acc' '\t' 'vertical_force' '\t' 'horizontal_force' '\n'];
fm = ['%6.6f\t%6.6f\t%6.6f\t%6.6f\t%6.6f\n'];

[~,fname,~] = fileparts(TRC_Filename);
mot_file = [data_path '\InverseKinematics\' fname '.mot'];
setup_file = [data_path '\BodyKinematics\' fname '_BKsetup.xml'];

tool = AnalyzeTool(body_settings_file);
tool.setModelFilename(scaled_model);
tool.setCoordinatesFileName(mot_file);
tool.setSolveForEquilibrium(false);
tool.setName(fname);
tool.setResultsDir([data_path '\BodyKinematics\' fname '\']);
motData = Storage(mot_file);
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();
tool.setStartTime(initial_time);
tool.setFinalTime(final_time);
AS = tool.getAnalysisSet();
BK = AS.get(0);
BK.setStartTime(initial_time);
BK.setEndTime(final_time);

tool.print(setup_file);

disp(['Processing ' mot_file '....']);
tool.run();
vel_data = load_sto_file([data_path '\BodyKinematics\' fname '\' fname '_BodyKinematics_vel_global.sto']);
time = vel_data.time(1:end-1);
acc_vert = smooth(diff(vel_data.center_of_mass_Y)./diff(vel_data.time),7);
acc_horz = smooth(diff(vel_data.center_of_mass_X)./diff(vel_data.time),7);
force_vert = (mass*acc_vert) + (mass*9.8);
force_horz = (mass*acc_horz);
out = [time acc_vert acc_horz force_vert force_horz];
fileout = [data_path '\BodyKinematics\' fname '_acc_force.txt'];

fid_1 = fopen(fileout,'w');
fprintf(fid_1, hd);
fprintf(fid_1,fm,out');
fclose(fid_1);
disp(['Wrote ' fileout]);
disp(['DONE.']);

disp('Successful');
output = 'Successful';