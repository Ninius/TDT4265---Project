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
%Generate negative samples (no signs)
negativeTrainingData = generateNegativeSamples(data);
%Generate positive samples (only signs)
positiveTrainingData = generatePositiveSamples(trainingData);
%Train detector
%trainCascadeObjectDetector('cascadeDetector.xml',trainingData,negativeTrainingData);
%Load detector
detector = vision.CascadeObjectDetector('cascadeDetector.xml');

%Test accuracy

numImages = height(testData);
results = cell(numImages, 1);
for i=1:size(testData, 1)
    %Detect and store bboxes for all images
    img = imread(testData.fileNames{i});
    [bboxes] = step(detector, img);
    results{i} = bboxes;
end

detectorData = cell2table(results); 
%Evaluate detector
[ap,recall,precision] = evaluateDetectionPrecision(detectorData,testData(:, 2));
figure
plot(recall,precision)
grid on
title(sprintf('Average Precision = %.1f',ap))

