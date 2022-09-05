function out = load_trc_file(filename)

% function data = load_trc_file(filename,delimiters)
%
% This function loads a TRC file and stores each X, Y, Z column in a field
% named after the marker the data is associated with (taken from header)
%
% Input: filename - the TRC filename
%
% Output: Stucture containing the data
%
% Author: Glen Lichtwark 
% Last Modified: 13/10/2015

if nargin < 1
    [fname, pname] = uigetfile('*.*', 'File to load - ');
    file = [pname fname];
else file = filename;    
end

[file_data,s_data]= readtext(file, '\t', '', '', 'empty2NaN');

% search the numerical data (in s_data.numberMask) to find when the block
% of data starts
a = find(abs(diff(sum(s_data.numberMask,2)))>0);
[m,n] = size(file_data);
% create an array with all of the data
num_dat = [file_data{a(end)+1:end,1:sum(s_data.numberMask(a(end)+1,:),2)}];
% reshape to put back into columns and rows
data = reshape(num_dat,m-a(end),sum(s_data.numberMask(a(end)+1,:),2));

% look at the labels (row 4) and go through and assign data to the label

% first find which cells have labels
c = find(s_data.stringMask(4,:)>0);

% now loop through all labels, create a new field name with the new label 
% name and assign the data from that column to the column of the next label 
for i = 1:length(c)
    fname = file_data{4,c(i)};
    if ~isempty(strfind(fname,'#'))
        fname(strfind(fname,'#')) = [];
    end
    if i<length(c)
        out.(fname) = data(:,c(i):c(i+1)-1);
    else out.(fname) = data(:,c(i):size(data,2));
    end
end
