%% Init
%Image-labels path
GTTable = 'FullIJCNN2013\gt.txt';
%Create Ground Truth table (GT)
data = readBoundingBoxes(GTTable);
%Create complete image file paths
data.fileNames = fullfile(pwd, data.fileNames);
%Split into training, validation and test data
trainingData = data(1:600, :);
validationData = data(751:end, :);
testData = data(601:750, :);

acfDetector = trainACFObjectDetector(data, 'NumStages', 10);
ap = detector_accuracy(acfDetector, validationData);
