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

%HoG features
img = imread(imds.Files{1});
img = imresize(img, [50 50]);
%HoG cell size for training/classification
cellSize = [4 4];
%Calculate HoG at different cell sizes
[hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[2 2]);
[hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[4 4]);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);
%Feature size for selected HoG cell size, replace "hog_AxA" if changing cell
%size
hogFeatureSize = length(hog_4x4);
numImages = numel(trainingSet.Files);
%Training feature storage
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');

% Show the original image
figure;
subplot(2,3,1:3); imshow(img);

% Visualize the HOG features
subplot(2,3,4);
plot(vis2x2);
title({'CellSize = [2 2]'; ['Length = ' num2str(length(hog_2x2))]});

subplot(2,3,5);
plot(vis4x4);
title({'CellSize = [4 4]'; ['Length = ' num2str(length(hog_4x4))]});

subplot(2,3,6);
plot(vis8x8);
title({'CellSize = [8 8]'; ['Length = ' num2str(length(hog_8x8))]});


%% Training

%Feature extraction
for i = 1:numImages
    img = readimage(trainingSet, i);
    %Apply pre-processing steps
    img = imresize(img, [50 50]);  
    img = imbinarize(rgb2gray(img));
    trainingFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end
%Extract training labels
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
    %Apply pre-processing steps
    img = imbinarize(rgb2gray(img));
    testFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end
%Classify test set
predictedLabels = predict(classifier, testFeatures);
timer = toc;
fps = numel(testSet.Files)/timer;
testLabels = testSet.Labels;
%Calculate accuracy
accuracy = sum(testLabels == predictedLabels)/numel(testLabels);
%Create confusion matrix
confMat = confusionmat(testLabels, predictedLabels);
