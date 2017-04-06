function samples = generateNegativeSamples(data)
samples = {}
j = 1;
for i=1:size(data, 1)
    if size(data.bbox{i}) == [0 0]
        samples{j} = data.fileNames{i};
        j = j +1;
    end
end
samples = samples';
end
