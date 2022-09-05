function [ data ] = btk_filtint( data , filt_cutoff , max_gap )
%BTK_FILTINT Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    max_gap = 0.5;
end

max_gap_frames = max_gap*data.marker_data.Info.frequency;

if isfield(data.marker_data,'Markers')
    
    %find the names of the markers
    fnames = fieldnames(data.marker_data.Markers);
    
    %loop through each marker name and interpolate and filter
    for i = 1:length(fnames)
        % load the marker data for current marker name
        D = data.marker_data.Markers.(fnames{i});
        % find rows with missing data (i.e. equal to zero)
        m = find(D(:,1) ~= 0);
        if length(m) < length(D)
            if m(1) > 1
                D(1,:) = mean(D(m,:));
                D(2,:) = mean(D(m,:));
            end
            % interpolate across these gaps
            Di = interp1(m,D(m,:),(1:length(D(:,1)))','spline');
            
            a = find(diff(m)>max_gap_frames);
            if ~isempty(a)
                disp(['WARNING - THERE ARE ' num2str(length(a)) ' GAPS THAT ARE GREATER THAN YOUR MAX FOR THE ' fnames{i} ' MARKER']);
            end
        else Di = data.marker_data.Markers.(fnames{i});
        end
        % filter the marker data
        Di = matfiltfilt(1/data.marker_data.Info.frequency,double(filt_cutoff),2,Di);
        
        % write the interpolated and filtered data back to marker data
           % structure
           data.marker_data.Markers.(fnames{i}) = Di;
           
       end
       
   end

end

