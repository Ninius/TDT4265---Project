%% Setup variables
numClasses = 43;
%Path to training images
folderpath = 'GTSRB\Final_Training\Images'; 
fullpath = fullfile(pwd, folderpath);
%Load pretrained net #1, 
load('rcnnStopSigns.mat', 'cifar10Net');   %Structure: https://se.mathworks.com/help/vision/examples/object-detection-using-deep-learning.html      
%Remove final classification layers
cifar10Net = cifar10Net.Layers(1:end-3);   

%Load pretrained alexnet
alexNet = alexnet;    
%Remove final classification layers 
alexNet = alexNet.Layers(1:end-3);   

%New classification layers
finalLayers = [fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20) softmaxLayer classificationLayer]; 
%Add final classificatrion layers
alexNet = [alexNet; finalLayers'];  
cifar10Net = [cifar10Net; finalLayers'];

%Creates training data structure, label = (sub)foldername
imds = imageDatastore(fullpath,...
'IncludeSubfolders',true,'FileExtensions','.ppm','LabelSource','foldernames'); 
%Automatically resize image to correct input size when read (alexnet)
imds.ReadFcn = @(filename)readAndPreprocessImage(filename); 
%Create training/test data.
[testSetAlex, trainingSetAlex] = splitEachLabel(imds, 0.3, 'randomize');

imds.ReadFcn = @(filename)readAndPreprocessImage2(filename); 
%Create training/test data.
[testSetCifar, trainingSetCifar] = splitEachLabel(imds, 0.3, 'randomize');
%% Training
%Set training options. BatchSize 128 is typically used with alexnet, uses max ~5.6GB VRAM with GPU training
optionsTransfer = trainingOptions('sgdm', ...
    'MaxEpochs',10, ...
    'InitialLearnRate',0.0001, ...
    'MiniBatchSize', 128, ...
    'OutputFcn', @plotTrainingAccuracy);

% %Train alexnet
% tic;
% trainedAlexNet = trainNetwork(trainingSetAlex,alexNet, optionsTransfer);   %Train net
% trainingTimeAlex = toc;

%Train cifar10Net
% tic;
% trainedCifar10Net = trainNetwork(trainingSetCifar,cifar10Net, optionsTransfer);
% trainingTimeCifar = toc;

%% Testing
%Test alexnet
load('alexnet_trained.mat')
tic;
predictedLabels = classify(trainedAlexNet,testSetAlex);
classificationTimeAlex = toc
testLabels = testSetAlex.Labels;
%Calculate accuracy
accuracyAlex = sum(predictedLabels == testLabels)/numel(testLabels)
confMat = confusionmat(testLabels, predictedLabels);
%Test Cifar10Net
tic;
predictedLabels = classify(trainedCifar10Net,testSetCifar);
classificationTimeCifar = toc
%Calculate accuracy
accuracyCifar = sum(predictedLabels == testLabels)/numel(testLabels)






%% Resize image functions
%alexnet
function Iout = readAndPreprocessImage(filename)
        dim = [227 227];
        I = imread(filename);
        % Resize the image as required for the CNN.
        Iout = imresize(I, dim);

end
%Cifar10Net
function Iout = readAndPreprocessImage2(filename)
        dim = [32 32];
        I = imread(filename);
        % Resize the image as required for the CNN.
        Iout = imresize(I, dim);

end
%% Plot training accuracy
%Source: https://se.mathworks.com/help/nnet/ref/trainingoptions.html
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
    