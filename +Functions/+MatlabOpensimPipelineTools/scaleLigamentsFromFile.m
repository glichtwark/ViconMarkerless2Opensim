function newModel = scaleLigamentsFromFile(origModelFile,newModelFile,scaleSetFile)
% newModel = scaleLigamentsFromFile(origModelFile,newModelFile,scaleSetFile)
%
% Function to scale ligaments based on the scale set produced after running
% the scale tool
% 
% Input: origModelFile - path and filename of the original model file
%        newModelFile  - path and filename of the scaled model file
%        scaleSetFile  - path and filename of the applied scale set (XML)
%                        file
%
% Output: newModel     - new model as object (note that changes are printed
%                        to the new model file as well)
%
% Written by Glen Lichtwark, The University of Queensland (please
% acknowledge if used to produce work of academic publications)
%
% Last updated 26/09/2014
%

import org.opensim.modeling.*

% load original and sclaed model and initialise
origModel = Model(origModelFile);
origState = origModel.initSystem;
newModel = Model(newModelFile);
newState = newModel.initSystem;

% load the scale set from the applied scale set file
newScaleSet = getScaleSetFromFile(scaleSetFile);

% get the ligament objects from both original and scaled models (they will 
% be the same as ligaments aren't scaled) and store to a structure
origLigs = getOpensimLigaments(origModel);
newLigs = getOpensimLigaments(newModel);

% loop through each ligamen in and scale in the new model
for i = 1:length(newLigs.names)
    
    % go through each point that defines ligament (usually just two) and
    % get the body the point attaches to and the co-ordinates of the
    % location and then scale these in the new model based on the scale set 
    % for the required body
    for j = 1:origLigs.(newLigs.names{i}).ligament.getGeometryPath.getPathPointSet.getSize
        pointBody = char(origLigs.(newLigs.names{i}).ligament.getGeometryPath.getPathPointSet.get(j-1).getBodyName);
        pointLocation = origLigs.(newLigs.names{i}).ligament.getGeometryPath.getPathPointSet.get(j-1).getLocation;
        for k = 1:3
            newLigs.(newLigs.names{i}).ligament.getGeometryPath.getPathPointSet.get(j-1).setLocation(newState,(k-1),pointLocation.get(k-1)*newScaleSet.(pointBody).scales(k));
        end
    end
    % scale the resting length
    newLigs.(newLigs.names{i}).ligament.set_resting_length(origLigs.(newLigs.names{i}).ligament.get_resting_length*(newLigs.(newLigs.names{i}).ligament.getLength(newState)/origLigs.(newLigs.names{i}).ligament.getLength(origState)));
    % scale the maximum tension based on the difference in body weight
    % (assuming there is some sort of linear relationship)
    newLigs.(newLigs.names{i}).ligament.set_pcsa_force(origLigs.(newLigs.names{i}).ligament.get_pcsa_force*(newModel.getTotalMass(newState)/origModel.getTotalMass(origState)));
end

% print (ie. write) the new models as an XML files
newModel.print(newModelFile);

