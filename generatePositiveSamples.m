function samples = generatePositiveSamples(data)
fileNames = {};
bbox = {};
j = 1;
for i=1:size(data, 1)
    if size(data.bbox{i}) ~= [0 0]
        fileNames{j} = data.fileNames{i};
        bbox{j} = data.bbox{i};
        j = j +1;
    end
end
fileNames = fileNames';
bbox = bbox';
samples = cell2table([fileNames bbox]);
end
