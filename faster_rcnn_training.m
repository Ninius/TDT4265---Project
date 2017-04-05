%% Init
%Image-labels path
GTTable = 'FullIJCNN2013\gt.txt';
%Create Ground Truth table (GT)
data = readGTData(GTTable);
%Create complete image file paths
data.fileNames = fullfile(pwd, data.fileNames);
trainingData = data(1:600,:);
testData = data(601:end, :);

%Load pretrained network 1
load('rcnnStopSigns.mat', 'cifar10Net');
%Load pretrained network 2 (AlexNet)
load('alexnet_10epoch_128batch.mat');
%% Training
%Training options, reduce MiniBatchSize if GPU out of memory.
%Approx. values: 120 for cifar10Net, 10 for AlexNet on 8GB VRAM GPU
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 128, ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 100);
    
options_alex = trainingOptions('sgdm', ...
        'MiniBatchSize', 32, ...
        'InitialLearnRate', 0.0001, ...
        'MaxEpochs', 500, ...
        'Verbose', true);
    
        
%Train Fast-RCNN detector
fasterrcnn = trainFasterRCNNObjectDetector(trainingData, trainedAlexNet , options_alex, ...
    'NegativeOverlapRange', [0 0.1], ...
    'PositiveOverlapRange', [0.7 1], ...
    'NumStrongestRegions', Inf);

