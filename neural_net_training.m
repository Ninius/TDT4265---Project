%% Setup variables
numClasses = 43;
folderpath = 'GTSRB\Final_Training\Images'; %Path to training images
fullpath = fullfile(pwd, folderpath);
load('rcnnStopSigns.mat', 'cifar10Net');         %Load pretrained net 1
cifar10Net = cifar10Net.Layers(1:end-3);         %Remove final classification layers
alexNet = alexnet               %Load pretrained alexnet
alexNet = alexNet.Layers(1:end-3);               %Remove final classification layers and input layer.

finalLayers = [fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20) softmaxLayer classificationLayer]; %New classification layers
alexNet = [alexNet; finalLayers'];  %Add final classificatrion layer
cifar10Net = [cifar10Net; finalLayers'];
imds = imageDatastore(fullpath,...
'IncludeSubfolders',true,'FileExtensions','.ppm','LabelSource','foldernames'); %Creates training data structure, label = (sub)foldername
[testSet, trainingSet] = splitEachLabel(imds, 0.3, 'randomize');        %Create training/validation data.
%% Training
imds.ReadFcn = @(filename)readAndPreprocessImage(filename); %Automatically resize image to correct input size when read (alexnet)
dim = [227 277]; %alexnet input size

optionsTransfer = trainingOptions('sgdm', ...
    'MaxEpochs',10, ...
    'InitialLearnRate',0.0001, ...
    'MiniBatchSize', 128); %Set training options. BatchSize 128 is typically used with alexnet, uses max ~5.6GB VRAM with GPU training
trainedAlexNet = trainNetwork(trainingSet,alexNet, optionsTransfer);   %Train net









%% Resize image functions
function Iout = readAndPreprocessImage(filename)
        dim = [227 227];
        I = imread(filename);
        % Resize the image as required for the CNN.
        Iout = imresize(I, dim);

end
    