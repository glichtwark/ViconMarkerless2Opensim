clear
osim_file = 'FQ_Lowerlimb.osim';

Pref.Str2Num = 'never';
Pref.ReadSpec = true;
Pref.ReadAttr = true;

[V, RootName] = xml_read(osim_file,Pref);

% first setup the default values
load muscle_model_structures

V.Model.defaults.Millard2012EquilibriumMuscle = Millard;

% now loop through all schutte muscles and take the required variables and make a new
% strucuture as a millard muscle (remembering tha most stuff can be set to
% default values, so only need basic parameters)
for i = 1:length(V.Model.ForceSet.objects.Thelen2003Muscle)
        V.Model.ForceSet.objects.Millard2012EquilibriumMuscle(i) = Millard;
end

% now loop through these muscles and change muscle specific parameters,
% like fibre length or isometric force, to those from the Thelen models.
 for i = 1:length(V.Model.ForceSet.objects.Thelen2003Muscle)
        V.Model.ForceSet.objects.Millard2012EquilibriumMuscle(i).ATTRIBUTE.name = ...
            V.Model.ForceSet.objects.Thelen2003Muscle(i).ATTRIBUTE.name;
        V.Model.ForceSet.objects.Millard2012EquilibriumMuscle(i).GeometryPath = ...
            V.Model.ForceSet.objects.Thelen2003Muscle(i).GeometryPath;
        V.Model.ForceSet.objects.Millard2012EquilibriumMuscle(i).max_isometric_force = ...
            V.Model.ForceSet.objects.Thelen2003Muscle(i).max_isometric_force;
        V.Model.ForceSet.objects.Millard2012EquilibriumMuscle(i).optimal_fiber_length = ...
            V.Model.ForceSet.objects.Thelen2003Muscle(i).optimal_fiber_length;
        V.Model.ForceSet.objects.Millard2012EquilibriumMuscle(i).tendon_slack_length = ...
            V.Model.ForceSet.objects.Thelen2003Muscle(i).tendon_slack_length;
        V.Model.ForceSet.objects.Millard2012EquilibriumMuscle(i).pennation_angle_at_optimal = ...
            V.Model.ForceSet.objects.Thelen2003Muscle(i).pennation_angle_at_optimal;
        
end

% delete the Thelen muscles
V.Model.ForceSet.objects.Thelen2003Muscle = [];
V.Model.ForceSet.objects = rmfield(V.Model.ForceSet.objects,'Thelen2003Muscle');

% write to a new xml (osim) file
osim_fileout = 'FQ_Lowerlimb_millard.osim';

xmlscript = xml_formatany(V, RootName);

clear Pref
Pref.StructItem = false;

xml_write(osim_fileout, V, RootName,Pref);
