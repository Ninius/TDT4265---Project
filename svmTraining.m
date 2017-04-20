%% Setup variables
numClasses = 43;
%Path to training images
folderpath = 'GTSRB\Final_Training\Images'; 
fullpath = fullfile(pwd, folderpath);
%Creates training data structure, label = (sub)foldername
imds = imageDatastore(fullpath,...
'IncludeSubfolders',true,'FileExtensions','.ppm','LabelSource','foldernames'); 
%Create training/test data.
[testSet, trainingSet] = splitEachLabel(imds, 0.3, 'randomize');
imds.ReadFcn = @(filename)readAndPreprocessImage2(filename); 
%Create training/test data.
[testSetCifar, trainingSetCifar] = splitEachLabel(imds, 0.3, 'randomize');
%% Training
img = imread(imds.Files{1});
img = imresize(img, [50 50]);
cellSize = [4 4];
[hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[1 1]);
[hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[4 4]);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);
%Feature size for selected HoG cell size
hogFeatureSize = length(hog_4x4);

numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');

%Feature extraction
for i = 1:numImages
    img = readimage(trainingSet, i);
    img = imresize(img, [50 50]);

    % Apply pre-processing steps
   

    trainingFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end

trainingLabels = trainingSet.Labels;
%Train SVM
classifier = fitcecoc(trainingFeatures, trainingLabels);

%% Testing
numImages = numel(testSet.Files);
testFeatures = zeros(numImages, hogFeatureSize, 'single');
tic;
for i = 1:numImages
    img = readimage(trainingSet, i);
    img = imresize(img, [50 50]);
  

    % Apply pre-processing steps


    testFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end
timer = toc;
fps = numel(testSet.Files)/timer;
testLabels = testSet.Labels;

predictedLabels = predict(classifier, testFeatures);

accuracy = sum(testLabels == predictedLabels)/numel(testLabels);

confMat = confusionmat(testLabels, predictedLabels);

helperDisplayConfusionMatrix(confMat)