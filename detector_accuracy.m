 function ap = detector_accuracy(detector, testData)
%Inputs: detector [bboxes,scores] = detect(detector, img);
%testData: Ground truth table with filenames and bounding boxes

numImages = height(testData);
results(numImages) = struct('bbox',[],'scores',[]);
tic
for i=1:size(testData, 1)
    %Detect and store bboxes for all images
    img = imread(testData.fileNames{i});
    %Optional scaling for increased performance/reduced accuracy
    %img = imresize(img, 0.4);
    [bboxes,scores] = detect(detector, img);
    %Scale bboxes if optional scaling
    results(i).bbox = bboxes;
    results(i).scores = scores;
end
time = toc;
fps = numImages/time
detectorData = struct2table(results); 
%Evaluate detector
[ap,recall,precision] = evaluateDetectionPrecision(detectorData,testData(:, 2));
figure
plot(recall,precision)
xlabel('recall')
ylabel('precision')
grid on
title(sprintf('Average Precision = %.1f',ap))
end
