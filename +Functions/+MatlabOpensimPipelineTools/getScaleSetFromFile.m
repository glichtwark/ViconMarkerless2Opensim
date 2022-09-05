function ScaleSetOut = getScaleSetFromFile(scaleSetFile)
% ScaleSet = getScaleSetFromFile(scaleSetFile)
%
% Function to create a structure providing the scale sets for each body
% based on a scaleset file

import org.opensim.modeling.*
 
% load scale set from file
SS = ScaleSet(scaleSetFile);

% go through each of the scales listed and assign to the body in a matlab
% structure
for i = 1:SS.getSize
    ScaleSetOut.(char(SS.getPropertyByIndex(0).getValueAsObject(i-1).getPropertyByName('segment'))).apply = char(SS.getPropertyByIndex(0).getValueAsObject(i-1).getPropertyByName('apply'));
    scales = char(SS.getPropertyByIndex(0).getValueAsObject(i-1).getPropertyByName('scales'));
    ScaleSetOut.(char(SS.getPropertyByIndex(0).getValueAsObject(i-1).getPropertyByName('segment'))).scales = str2num(scales(2:end-1));
end
