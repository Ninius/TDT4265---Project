doTrainingAndEval = true; 
if doTrainingAndEval
    % Run detector on each image in the test set and collect results.
    resultsStruct = struct([]);
    testData = data;
    for i = 1:100% height(testData)
        if mod(i, 10) == 0
            i
        end
        % Read the image.
        I = imread(testData.fileNames{i});

        % Run the detector.
        [bboxes, scores, labels] = detect(frcnn, I);

        % Collect the results.
        resultsStruct(i).Boxes = bboxes;
        resultsStruct(i).Scores = scores;
        resultsStruct(i).Labels = labels;
    end

    % Convert the results into a table.
    results = struct2table(resultsStruct);
else
    % Load results from disk.
    results = data.results;
end

% Extract expected bounding box locations from test data.
expectedResults = testData(1:100, 2:end);

% Evaluate the object detector using Average Precision metric.
[ap, recall, precision] = evaluateDetectionPrecision(results, expectedResults);