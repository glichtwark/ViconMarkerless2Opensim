function mediapipepose2trc(data, TRC_Filename)
% function [TRC_Filenames] = mediapipepose2trc(data, TRC_Filename)
% This function will take the output from media_pipe_3D_reconstruction and
% write a TRC file for use with opensim
% Input - data: structure containing XYZ data, along with time, frames and
%               marker names
%         TRC_Filename: name for TRC file to be output
%
% Written by Glen Lichtwark, 19/08/2022

% flip the Y and Z axis for opensim
data.XYZ = data.XYZ(:,[1 3 2],:);
data.XYZ(:,1,:) = -data.XYZ(:,1,:);
% reshape array to be flat
marker_data = reshape(permute(data.XYZ,[3,2,1]),size(data.XYZ,3),size(data.XYZ,2)*size(data.XYZ,1));

time_data = [data.frame data.time];

markers = fieldnames(data.markers2D);

freq = data.frame_rate;

% determine number of markers
n_markers = size(markers);
% determine number of time points
n_rows = size(marker_data,1);

%%
% now we need to make the headers for the column headings for the TRC file
% which are made up of the marker names and the XYZ for each marker

% first initialise the header with a column for the Frame # and the Time
% also initialise the format for the columns of data to be written to file
dataheader1 = 'Frame#\tTime\t';
dataheader2 = '\t\t';
format_text = '%i\t%2.4f\t';
% initialise the matrix that contains the data as a frame number and time row
data_out = [time_data marker_data]';

% now loop through each maker name and make marker name with 3 tabs for the
% first line and the X Y Z columns with the marker numnber on the second
% line all separated by tab delimeters
% each of the data columns (3 per marker) will be in floating format with a
% tab delimiter - also add to the data matrix
for i = 1:length(markers)
    dataheader1 = [dataheader1 markers{i} '\t\t\t'];
    dataheader2 = [dataheader2 'X' num2str(i) '\t' 'Y' num2str(i) '\t'...
        'Z' num2str(i) '\t'];
    format_text = [format_text '%f\t%f\t%f\t'];
end
dataheader1 = [dataheader1 '\n'];
dataheader2 = [dataheader2 '\n'];
format_text = [format_text '\n'];

disp('Writing trc file...')

%Output marker data to an OpenSim TRC file

%open the file
fid_1 = fopen(TRC_Filename,'w');

% first write the header data
fprintf(fid_1,'PathFileType\t4\t(X/Y/Z)\t %s\n',TRC_Filename);
fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
fprintf(fid_1,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', freq, freq, n_rows, length(markers), 'm', freq, 1, n_rows);
fprintf(fid_1, dataheader1);
fprintf(fid_1, dataheader2);

% then write the output marker data
fprintf(fid_1, format_text,data_out);

% close the file
fclose(fid_1);

disp('Done.')


