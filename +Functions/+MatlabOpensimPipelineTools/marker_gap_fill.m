function [ Markers ] = marker_gap_fill( Markers )
%MARKER_GAP_FILL function to fill in any gaps using spline gap fill
%   Input = Markers: Structure containing the marker data
%
% Author: Glen Lichtwark (6/11/15)

marker_list = fieldnames(Markers);

for i = 1:length(marker_list)
    a = find(Markers.(marker_list{i})(:,1)==0);
    b = find(Markers.(marker_list{i})(:,1)~=0);
    if ~isempty(a)
        if a(1) == 1
            c = find(diff(a)>1);
            a(1:c(1)) = [];
        end
        if a(end) == length(Markers.(marker_list{i})(:,1))
            c = find(diff(a)>1);
            if isempty(c)
                a(1:end) = [];
            else
                a(c(end)+1:end) = [];
            end
        end
        Markers.(marker_list{i})(a,:) = interp1(b,Markers.(marker_list{i})(b,:),a,'pchip');
    end
end

end

