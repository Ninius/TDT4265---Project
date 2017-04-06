function MATspace = createMATfileForMultiClass(classVector)
%createMATfileForClass()

% Traffic Sign Recognition Benchmark
% Creates a list of elements used to train a object detector/classifier

%sBasePath = '/Users/bjorneev/Documents/MATLAB/Datasets/GTSRB/Final_Training/Images'; 
sBasePath = ['/Users/bjorneev/Documents/MATLAB/Datasets/GTSRB/Final_Training/Images'];

j = 0;
matfile = struct;

for nNumFolder = classVector
    sFolder = num2str(nNumFolder, '%05d');
    sPath = [sBasePath, '/', sFolder, '/'];
    prefix = ['/Datasets/GTSRB/Final_Training/Images/',sFolder,'/'];
    if isdir(sPath)
        j = numel(matfile(1,:));
        [ImgFiles, Rois, Classes] = readSignData([sPath, 'GT-', num2str(nNumFolder, '%05d'), '.csv']);
         %ImgFiles = fullfile(pwd, ImgFiles);
        ImgFiles = fullfile(pwd, prefix, ImgFiles);
        for i = 1:numel(ImgFiles)

            matfile(i+j).imageFilename = ImgFiles{i};
            matfile(i+j).objectBoundingBoxes = [Rois(i, 1), Rois(i, 2), Rois(i, 3), Rois(i, 4)];
        end
    end
    %disp(nNumFolder)
    
end


MATspace = matfile;




