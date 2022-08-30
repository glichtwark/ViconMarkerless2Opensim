function MP_Data = load_mediapipe_csv(filein)

% in no file given as input then use a ui to select file
if nargin < 1
    [filename, pathname, filterindex] = uigetfile('*.csv', 'Select CSV file of tracked data');
    if filterindex < 1
        return
    end
    filein = [pathname filename];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 134);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["FrameNumber", "Times", "NOSE_X", "NOSE_Y", "NOSE_Z", "NOSE_C", "LEFT_EYE_INNER_X", "LEFT_EYE_INNER_Y", "LEFT_EYE_INNER_Z", "LEFT_EYE_INNER_C", "LEFT_EYE_X", "LEFT_EYE_Y", "LEFT_EYE_Z", "LEFT_EYE_C", "LEFT_EYE_OUTER_X", "LEFT_EYE_OUTER_Y", "LEFT_EYE_OUTER_Z", "LEFT_EYE_OUTER_C", "RIGHT_EYE_INNER_X", "RIGHT_EYE_INNER_Y", "RIGHT_EYE_INNER_Z", "RIGHT_EYE_INNER_C", "RIGHT_EYE_X", "RIGHT_EYE_Y", "RIGHT_EYE_Z", "RIGHT_EYE_C", "RIGHT_EYE_OUTER_X", "RIGHT_EYE_OUTER_Y", "RIGHT_EYE_OUTER_Z", "RIGHT_EYE_OUTER_C", "LEFT_EAR_X", "LEFT_EAR_Y", "LEFT_EAR_Z", "LEFT_EAR_C", "RIGHT_EAR_X", "RIGHT_EAR_Y", "RIGHT_EAR_Z", "RIGHT_EAR_C", "MOUTH_LEFT_X", "MOUTH_LEFT_Y", "MOUTH_LEFT_Z", "MOUTH_LEFT_C", "MOUTH_RIGHT_X", "MOUTH_RIGHT_Y", "MOUTH_RIGHT_Z", "MOUTH_RIGHT_C", "LEFT_SHOULDER_X", "LEFT_SHOULDER_Y", "LEFT_SHOULDER_Z", "LEFT_SHOULDER_C", "RIGHT_SHOULDER_X", "RIGHT_SHOULDER_Y", "RIGHT_SHOULDER_Z", "RIGHT_SHOULDER_C", "LEFT_ELBOW_X", "LEFT_ELBOW_Y", "LEFT_ELBOW_Z", "LEFT_ELBOW_C", "RIGHT_ELBOW_X", "RIGHT_ELBOW_Y", "RIGHT_ELBOW_Z", "RIGHT_ELBOW_C", "LEFT_WRIST_X", "LEFT_WRIST_Y", "LEFT_WRIST_Z", "LEFT_WRIST_C", "RIGHT_WRIST_X", "RIGHT_WRIST_Y", "RIGHT_WRIST_Z", "RIGHT_WRIST_C", "LEFT_PINKY_X", "LEFT_PINKY_Y", "LEFT_PINKY_Z", "LEFT_PINKY_C", "RIGHT_PINKY_X", "RIGHT_PINKY_Y", "RIGHT_PINKY_Z", "RIGHT_PINKY_C", "LEFT_INDEX_X", "LEFT_INDEX_Y", "LEFT_INDEX_Z", "LEFT_INDEX_C", "RIGHT_INDEX_X", "RIGHT_INDEX_Y", "RIGHT_INDEX_Z", "RIGHT_INDEX_C", "LEFT_THUMB_X", "LEFT_THUMB_Y", "LEFT_THUMB_Z", "LEFT_THUMB_C", "RIGHT_THUMB_X", "RIGHT_THUMB_Y", "RIGHT_THUMB_Z", "RIGHT_THUMB_C", "LEFT_HIP_X", "LEFT_HIP_Y", "LEFT_HIP_Z", "LEFT_HIP_C", "RIGHT_HIP_X", "RIGHT_HIP_Y", "RIGHT_HIP_Z", "RIGHT_HIP_C", "LEFT_KNEE_X", "LEFT_KNEE_Y", "LEFT_KNEE_Z", "LEFT_KNEE_C", "RIGHT_KNEE_X", "RIGHT_KNEE_Y", "RIGHT_KNEE_Z", "RIGHT_KNEE_C", "LEFT_ANKLE_X", "LEFT_ANKLE_Y", "LEFT_ANKLE_Z", "LEFT_ANKLE_C", "RIGHT_ANKLE_X", "RIGHT_ANKLE_Y", "RIGHT_ANKLE_Z", "RIGHT_ANKLE_C", "LEFT_HEEL_X", "LEFT_HEEL_Y", "LEFT_HEEL_Z", "LEFT_HEEL_C", "RIGHT_HEEL_X", "RIGHT_HEEL_Y", "RIGHT_HEEL_Z", "RIGHT_HEEL_C", "LEFT_FOOT_INDEX_X", "LEFT_FOOT_INDEX_Y", "LEFT_FOOT_INDEX_Z", "LEFT_FOOT_INDEX_C", "RIGHT_FOOT_INDEX_X", "RIGHT_FOOT_INDEX_Y", "RIGHT_FOOT_INDEX_Z", "RIGHT_FOOT_INDEX_C"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
MP_Data = readtable(filein, opts);


%% Clear temporary variables
clear opts