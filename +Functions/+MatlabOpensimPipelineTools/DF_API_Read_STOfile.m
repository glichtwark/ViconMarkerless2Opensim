function [DataStruct] = DF_API_Read_STOfile(filename)

% Function to read in the content of a .sto file and store each column of
% data in the structure DataStruct. The labels of the columns in the .sto
% file will become fields of the structure DataStruct.
%
% Inputs - filename - full path and file name of the .sto file
%
% Output - DataStruct - structure containing the data from columns in the
% .sto file stored as fields of the same name
%
% e.g. Data = DF_API_Read_STOfile('C:\Users\Documents\Data\Trial_01.sto')
%
% Author - Dominic Farris (North Carolina State University)Please
% acknowledge contribution in published academic works
% last updated - 31/10/2012

% import the classes from the .jar file for easy reference
import org.opensim.modeling.*

% Create a storage object from the .sto file
Data = Storage(filename);

% Get the column labels
Labels = Data.getColumnLabels;

% Loop through the columns extracting the data
for i = 0:Labels.getSize()-1;
    % Create an array double object to store column in
    DataColumn = ArrayDouble();
    
    % if it is the time column a different method is used to extract data
    if strcmp(Labels.getitem(i),'time')
        Data.getTimeColumn(DataColumn);
    else
        Data.getDataColumn(Labels.getitem(i),DataColumn);
    end
    
    % convert to matlab double array
    DataFields{i+1} = num2str(Labels.getitem(i).toCharArray())';
    
    % remove invalid '.' character from label if there
    if ~isempty(strfind(DataFields{i+1},'.'));
        DataFields{i+1} = strrep(DataFields{i+1},'.','_');
    end
    
    % write to structure
    DataStruct.(DataFields{i+1}) = str2num(DataColumn.toString())';
    
end

end