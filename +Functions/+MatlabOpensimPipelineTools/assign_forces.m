function data = assign_forces(data,assign_markers,assign_bodies, thresh, filter_freq)
% function data = assign_forces(data,assign_markers,assign_bodies, thresh)
%
% Function to assign any recorded forces to a specific body based on the
% position of a nominated marker attached to the body.
%
% INPUT -   data - structure containing fields from from previously loaded
%               C3D file using btk_loadc3d.m as well as a filename string
%           assign_markers - cell array of marker names to be used as
%               guides to match to a force vector COP (e.g. heel marker)
%           assign_bodies - cell array with the matching body name that any
%               matching forces can be assigned to
%           thresh - an array of length 2 e.g. [30 0.15] represnting the 
%               the 1) treshold force to use to determine a force event (default 30)
%               and 2) the mean distance from the marker to the COP
%               that is used to assess a positive assignment (in meters - 
%               defaults to 0.2m)
%           filter_freq - frequency to low-pass filter the GRF data
%               (default = 25, set to -1 for no filtering);
%
% OUTPUT -  data - structure containing the relevant data with assignments           
%
% Written by Glen Lichtwark (University of Queensland)
% Updated September 2014

if nargin<5
    filter_freq = 25; % default filter frequency
end

if nargin<4
    thresh(1) = 30; % default force threshold
    thresh(2) = 0.2; % default position threshold
end

% make sure the correct data is available
if ~isfield(data,'marker_data')
    error(['Ensure that the data structure contains a field called "marker_data" '...
    'that contains marker fields and coordinates - see btk_loadc3d']);
end

if ~isfield(data,'fp_data')
    error(['Ensure that the data structure contains a field called "fp_data" '...
    'that contains force plate data - see btk_loadc3d']);
end

% check that the is one assigned marker for each assigned body
if iscell(assign_markers) 
    if iscell(assign_bodies)
        if length(assign_markers) ~= length(assign_bodies)
            error('Cell arrays for assigned markers and bodies must be the same length')
        else N = length(assign_markers);
        end
    else error('Assigned marker list and assigned bodies must both be cell arrays of same length with paired matchings')
    end
else error('The body and marker assignment lists must be cell arrays');
end

% examine the force signals for each forcelpate and determine whether any
% of the markers are close to the COP to indicate that this force should be
% assigned to the bodies that the marker attaches to

% define the ratio of force sampling frequency to marker sampling frequency
F = data.fp_data.Info(1).frequency/data.marker_data.Info.frequency; %assume same sampling frequency on all plates!!!
dt = 1/data.fp_data.Info(1).frequency;

for i = 1:length(data.fp_data.GRF_data)
    
    % initilise the first lot of force arrays (this will grow as different
    % bodies contact each plate)
    for b = 1:length(assign_bodies)
        data.GRF.FP(i).(assign_bodies{b}).F = zeros(size(data.fp_data.GRF_data(i).F));
        data.GRF.FP(i).(assign_bodies{b}).M = zeros(size(data.fp_data.GRF_data(i).M));
        data.GRF.FP(i).(assign_bodies{b}).P = zeros(size(data.fp_data.GRF_data(i).P));
    end

    % filter the force and determine when the foot is in contact with the
    % gound - this is not the same filtering as is done on the final data
    % and is required to be able to determine the contact periods
    Fv = matfiltfilt(1/data.fp_data.Info(1).frequency,filter_freq,2,(interp1(data.fp_data.GRF_data(i).F(~isnan(data.fp_data.GRF_data(i).F(:,3)),3),1:length(data.fp_data.GRF_data(i).F(:,3)),'nearest','extrap'))');
    
    % if this is a cyclic movement, then it is best to make the baseline
    % zero as this improves capacity for detecting events
    if (max(Fv)-min(Fv))>400
        Fv = Fv-median(Fv(Fv<(min(Fv)+20)));
    end
    nt = find(Fv>thresh(1));
    
    if ~isempty(nt)
    % find out when the gaps between ground contact times are and use this
    % to define on and off times (there will always be an on as the first
    % point and off as the last point), a gap of greater than 25
    % miliseconds is considered a new event (change the 0.025 value below
    % to adjust this).
    dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.015);  
    on_i = [nt(1); nt(dnt+1)];
    off_i = [nt(dnt); nt(end)];
    
    if (off_i(1)-on_i(1)) < 7
    off_i(1) = [];
    on_i(1) = [];
    end
    
    if (off_i(end)-on_i(end)) < 7
    off_i(end) = [];
    on_i(end) = [];
    end
    
    ns = find((off_i - on_i) < data.fp_data.Info(1).frequency*0.1);
    if ~isempty(ns)
        if ns(end) == length(off_i)
            ns(end) = [];
        end
        off_i(ns) = [];
        on_i(ns+1) = [];
    end
    
    E = find((off_i-on_i)>1.2*median(off_i-on_i) | (off_i-on_i)<0.8*median(off_i-on_i));
    on_i(E) = [];
    off_i(E) = [];
    % loop through each event (from one value of on_i to its corresponding off_i) 
    % and determine which of the bodies is contacting to make this force
    for j = 1:length(on_i)
        
        % define the current period of interest
        a = on_i(j):off_i(j);
        aa = ceil((on_i(j))/F:(off_i(j))/F);

        for b = 1:length(assign_markers)
            % loop through each of the bodies that need assigning to forces
            % and determine the median distance between the markers defining
            % body and the COP  
            D(b) = nanmedian(dist_markers(data.fp_data.GRF_data(i).P(aa*F,:),...
                [data.marker_data.Markers.(assign_markers{b})(aa,1) ...
                data.marker_data.Markers.(assign_markers{b})(aa,2) ...
                zeros(size(data.marker_data.Markers.(assign_markers{b})(aa,1)))]));
        end
        % determine which of the markers are within the threshold distance defined
        aD = find(D<thresh(2));
        % if a markers is below the threshold, assign the force event to
        % that body for the current force plate
        if ~isempty(aD)
            if length(aD) < 2 
                if filter_freq > 0 % filter the data if a filter frequency is defined (defaults at low pass 25Hz)
                    data.GRF.FP(i).(assign_bodies{aD}).F(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).F(a,:));
                    data.GRF.FP(i).(assign_bodies{aD}).M(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).M(a,:));
                    data.GRF.FP(i).(assign_bodies{aD}).P(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).P(a,:));
                else % otherwise just assign the raw data
                    data.GRF.FP(i).(assign_bodies{aD}).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
                    data.GRF.FP(i).(assign_bodies{aD}).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
                    data.GRF.FP(i).(assign_bodies{aD}).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
                end
            else % if more than one marker falls within the threshold then 
                 % don't assign and inform the user 
                disp(['Force event ' num2str(j) ' on force plate ' num2str(i) ...
                    ' cannot be assigned to either body. Try adjusting the thresholds to improve detection.']);
            end
        else % if no marker falls within the threshold then don't assign and inform the user 
                 disp(['Force event ' num2str(j) ' on force plate ' num2str(i) ...
                    ' cannot be assigned to either body. Try adjusting the thresholds to improve detection.'...
                    'D = ' num2str(D) '.']);
        end
    end
    end
    
    % if there are no forces assigned to a body (i.e. it stays zero), then
    % remove this force assignment
    for b = 1:length(assign_bodies)
        if (sum(sum(data.GRF.FP(i).(assign_bodies{b}).F)) == 0)
            data.GRF.FP(i).(assign_bodies{b}) = rmfield(data.GRF.FP(i).(assign_bodies{b}),'F');
            data.GRF.FP(i).(assign_bodies{b}) = rmfield(data.GRF.FP(i).(assign_bodies{b}),'M');
            data.GRF.FP(i).(assign_bodies{b}) = rmfield(data.GRF.FP(i).(assign_bodies{b}),'P');
        end
    end
    
end



