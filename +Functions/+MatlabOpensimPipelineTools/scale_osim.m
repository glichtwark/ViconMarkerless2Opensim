function [ newModel ] = scale_osim ( setup_scale_file )
%SCALE_OSIM Function to scale an Opensim model based on the ScaleTool. 
%   [ newModel, newScaleSet ] = scale_osim ( setup_scale_file, origModel )
%   
%   Inputs - setup_scale_file = xml file containing default settings to use
%
%   Outputs - newModel = scaled model object
%           - newScaleSet = scale set used (useful for other scaling)
%
%  Written by Glen Lichtwark (University of Queesnland), but adapted from
%  the python script written by James Dunne (Stanford) and David Saxby
%  (Griffith University). Updated, 28/08/14

    import org.opensim.modeling.*

    % make a new scale tool from the setup file
    ST = ScaleTool(setup_scale_file);
    
    % load the model specified in the XML file
    ModelFile = ST.getGenericModelMaker.getModelFileName;
    origModel = Model(ModelFile);

    % initiate the model to get the initial states
    origState = origModel.initSystem;
    
    % set the output file name for the model from the 
    ST.getModelScaler().setOutputModelFileName(ST.getMarkerPlacer().getOutputModelFileName)
    
    % get the current scaleset to output and rename to same name as model
    ST.getModelScaler.getOutputScaleFileName
   
    % scale the model using scaleset
    ST.getModelScaler().processModel(origState,origModel);

    % open the new scaled model and change name to name from the scale tool
    newModel = Model(ST.getMarkerPlacer().getOutputModelFileName);
    newModel.setName(ST.getName);
    newState = newModel.initSystem;
    
    % move the markers using the getMarkerPlacement process and load the
    % new model so it can be output
    ST.getMarkerPlacer().processModel(newState,newModel)
    newModel = Model(ST.getMarkerPlacer().getOutputModelFileName);
    
end

% ligs.ATFL_r.ligament.getGeometryPath.getPathPointSet.get(0).getLocation

