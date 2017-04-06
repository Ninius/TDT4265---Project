function GTData = readGTData(GTFile)
% Based 

fileNames = cell(900,1);
fID = fopen(GTFile, 'r');
bbox = cell(900,1);

data = fscanf(fID, '%05d.ppm;%d;%d;%d;%d;%d');
data = reshape(data, [6, numel(data) / 6])';

for i = 1:900
   if i-1 < 10
       prefix = 'FullIJCNN2013\0000';
   elseif i-1 < 100
       prefix = 'FullIJCNN2013\000';
   else
       prefix = 'FullIJCNN2013\00';
   end
   fileNames{i} =  char(prefix + string(i-1) + '.ppm'); 
end


for i = 1:size(data, 1)
    index = data(i, 1)+1;

    
    x = data(i, 2);
    y = data(i, 3);
    width = abs(data(i, 2)-data(i, 4));
    height = abs(data(i, 3) -data(i, 5));
    

    existingData = cell2mat(bbox(index, 1));
    newData = [existingData; [x y width height]];
    bbox{index, 1} = newData;
    
end

GTData = cell2table([fileNames bbox]);
GTData.Properties.VariableNames = {'fileNames' 'bbox'};
end
    
