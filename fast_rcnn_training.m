%% Init
%Image-labels path
GTTable = 'FullIJCNN2013\gt.txt';
%Create Ground Truth table (GT)
data = readGTData(GTTable);
%Create complete image file paths
data.fileNames = fullfile(pwd, data.fileNames);
%Split into training, validation and test data
trainingData = data(1:750, :);
testData = data(751:end, :);


%Load pretrained network 1
load('rcnnStopSigns.mat', 'cifar10Net');
%Load pretrained network 2 (AlexNet)
load('alexnet_trained.mat');
%% Training
%Training options, reduce MiniBatchSize if GPU out of memory.
%Approx. values: 120 for cifar10Net, 10 for AlexNet on 8GB VRAM GPU
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 128, ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 100);
    
options2 = trainingOptions('sgdm', ...
    'MaxEpochs',20, ...
    'InitialLearnRate',0.0001, ...
    'MiniBatchSize', 128, ...
    'OutputFcn', @plotTrainingAccuracy);
    
        
%Train Fast-RCNN detector
frcnn = trainFastRCNNObjectDetector(trainingData, trainedAlexNet , options2);

% frcnn = trainFastRCNNObjectDetector(data, cifar10Net , options, ...
%     'NegativeOverlapRange', [0 0.1], ...
%     'PositiveOverlapRange', [0.7 1], ...
%     'SmallestImageDimension', 600);


numImages = height(testData);
results(numImages) = struct('bbox',[],'scores',[], 'labels', []);
tic;
for i=1:size(testData, 1)
    %Detect and store bboxes for all images
    img = imread(testData.fileNames{i});
    [bboxes,scores, labels] = detect(frcnn, img);
    results(i).bbox = bboxes;
    results(i).scores = scores;
    results(i).labels = labels;
end
classificationTime = toc;

detectorData = struct2table(results); 
%Evaluate detector
[ap,recall,precision] = evaluateDetectionPrecision(detectorData,testData(:, 2:end));
figure
% plot(recall,precision)
% xlabel('recall')
% ylabel('precision')
grid on
title(sprintf('Average Precision = %.1f',ap))

function plotTrainingAccuracy(info)

persistent plotObj

if info.State == "start"
    figure;
    plotObj = animatedline;
    xlabel("Iteration")
    ylabel("Training Accuracy")
elseif info.State == "iteration"
    addpoints(plotObj,info.Iteration,info.TrainingAccuracy)
    drawnow limitrate nocallbacks
end

end
    