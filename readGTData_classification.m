function GTData = readGTData_classification(basepath)
% Based 

sBasePath = 'X:\TSR-dataset\GTSRB\Training\'; 
fileNames = {};
class = {};
for nNumFolder = 0:42
    sFolder = num2str(nNumFolder, '%05d');
    
    sPath = [basepath, '\', sFolder, '\'];

    if isdir(sPath)
        [ImgFiles, Rois, Classes] = readSignData([sPath, '\GT-', num2str(nNumFolder, '%05d'), '.csv']);
        GTData = [GTData; [ImgFiles, Classes]];
    end
        
GTData.Properties.VariableNames = {'fileNames' 'speed_limit_20' 'speed_limit_30' 'speed_limit_50'...
    'speed_limit_60' 'speed_limit_70' 'speed_limit_80' 'restriction_ends_80' 'speed_limit_100'...
    'speed_limit_120' 'no_overtaking' 'no_overtaking_trucks' 'priority_at_next_intersection'...
    'priority_road' 'give_way' 'stop' 'no_traffic_both_ways' 'no_trucks' 'no_entry' 'danger'...
    'bend_left' 'bend_right' 'bend' 'uneven_road' 'slippery_road' 'road_narrows' 'construction'...
    'traffic_signal' 'pedestrian_crossing' 'school_crossing' 'cycles_crossing' 'snow' 'animals'...
    'restriction_ends' 'go_right' 'go_left' 'go_straight' 'go_right_or_straight' 'go_left_or_straight'...
    'keep_right' 'keep_left' 'roundabout' 'restriction_ends_overtaking' 'restriction_ends_overtaking_trucks'};
end

function [rImgFiles, rRois, rClasses] = readSignData(aFile)
% Reads the traffic sign data.
%
% aFile         Text file that contains the data for the traffic signs
%
% rImgFiles     Cell-Array (1 x n) of Strings containing the names of the image
%               files to operate on
% rRois         (n x 4)-Array containing upper left column, upper left row,
%               lower left column, lower left row of the region of interest
%               of the traffic sign image. The image itself can have a
%               small border so this data will give you the exact bounding
%               box of the sign in the image
% rClasses      (n x 1)-Array providing the classes for each traffic sign

    fID = fopen(aFile, 'r');
    
    fgetl(fID); % discard line with column headers
    
    f = textscan(fID, '%s %*d %*d %d %d %d %d %d', 'Delimiter', ';');
    
    rImgFiles = f{1}; 
    rRois = [f{2}, f{3}, f{4}, f{5}];
    rClasses = f{6};
    
    fclose(fID);
