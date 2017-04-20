%% Init
%Image-labels path
clearvars results
GTTable = 'FullIJCNN2013\gt.txt';
%Create Ground Truth table (GT)
data = readGTData(GTTable);
%Create complete image file paths
data.fileNames = fullfile(pwd, data.fileNames);
%Split into training, validation and test data
numImages = height(data);
%Create result struct
results(numImages) = struct('Boxes',[],'Scores',[], 'Labels', []);
%Sign categories
categories = {'speed_limit_20' 'speed_limit_30' 'speed_limit_50'...
    'speed_limit_60' 'speed_limit_70' 'speed_limit_80' 'restriction_ends_80' 'speed_limit_100'...
    'speed_limit_120' 'no_overtaking' 'no_overtaking_trucks' 'priority_at_next_intersection'...
    'priority_road' 'give_way' 'stop' 'no_traffic_both_ways' 'no_trucks' 'no_entry' 'danger'...
    'bend_left' 'bend_right' 'bend' 'uneven_road' 'slippery_road' 'road_narrows' 'construction'...
    'traffic_signal' 'pedestrian_crossing' 'school_crossing' 'cycles_crossing' 'snow' 'animals'...
    'restriction_ends' 'go_right' 'go_left' 'go_straight' 'go_right_or_straight' 'go_left_or_straight'...
    'keep_right' 'keep_left' 'roundabout' 'restriction_ends_overtaking' 'restriction_ends_overtaking_trucks'};

%% Detection and classification
tic;
for i=1:numImages
    %Read image
    img = imread(data.fileNames{i});
    %Detect and store bboxes
    [bboxes,scores] = detect(acfDetector, img);
    %Iterate over all bboxes
    if size(bboxes,1) > 0
        labels = zeros(1,size(bboxes,1));
        for j=1:size(bboxes,1)
            %Extract bbox, resize
            im = imcrop(img, bboxes(j,:) );
            im = imresize(im, [227, 227]);
            %Classify bbox
            [Ypred,score] = classify(trainedAlexNet,im);
            %Find max score index and label
            scores(j) = max(score);
            index = find(score==max(score)); 
            labels(j) = index;
        end
        results(i).Boxes = bboxes;
        results(i).Scores = scores;
        results(i).Labels = categorical(labels, 1:43, categories);
    end
end
timer = toc;
fps = numImages/timer;
results = struct2table(results);
[ap,recall,precision] = evaluateDetectionPrecision(results,data(:, 2:end), 0.3);
