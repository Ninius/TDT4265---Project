function GTData = readGTData(GTFile)
% Based 

fileNames = cell(900,1);
fID = fopen(GTFile, 'r');
bbox = cell(900,43);

data = fscanf(fID, '%05d.ppm;%d;%d;%d;%d;%d');
data = reshape(data, [6, numel(data) / 6])';

for i = 1:900
   if i-1 < 10
       prefix = 'FullIJCNN2013\0000';
   elseif i-1 < 100
       prefix = 'FullIJCNN2013\000';
   else
       prefix = 'FullIJCNN2013\00';
   end
   fileNames{i} =  char(prefix + string(i-1) + '.ppm'); 
end


for i = 1:size(data, 1)
    index = data(i, 1)+1;
    category = data(i, 6) + 1;
    
    x = data(i, 2);
    y = data(i, 3);
    width = abs(data(i, 2)-data(i, 4));
    height = abs(data(i, 3) -data(i, 5));
    
    index = data(i, 1)+1; 
    existingData = cell2mat(bbox(index, category));
    newData = [existingData; [x y width height]];
    bbox{index, category} = newData;
    
end

GTData = cell2table([fileNames bbox]);
GTData.Properties.VariableNames = {'fileNames' 'speed_limit_20' 'speed_limit_30' 'speed_limit_50'...
    'speed_limit_60' 'speed_limit_70' 'speed_limit_80' 'restriction_ends_80' 'speed_limit_100'...
    'speed_limit_120' 'no_overtaking' 'no_overtaking_trucks' 'priority_at_next_intersection'...
    'priority_road' 'give_way' 'stop' 'no_traffic_both_ways' 'no_trucks' 'no_entry' 'danger'...
    'bend_left' 'bend_right' 'bend' 'uneven_road' 'slippery_road' 'road_narrows' 'construction'...
    'traffic_signal' 'pedestrian_crossing' 'school_crossing' 'cycles_crossing' 'snow' 'animals'...
    'restriction_ends' 'go_right' 'go_left' 'go_straight' 'go_right_or_straight' 'go_left_or_straight'...
    'keep_right' 'keep_left' 'roundabout' 'restriction_ends_overtaking' 'restriction_ends_overtaking_trucks'};
end
    
