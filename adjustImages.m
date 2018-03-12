function adjustImages(inputDirPath, extensionInput, outputDirPath, extensionOutput, funcImage)

if ismac
    name = char( strcat(inputDirPath, '/*', extensionInput));
elseif ispc
    name = char( strcat(inputDirPath, '\*', extensionInput));
end

imageFiles = dir(name);
nfiles = length(imageFiles);

for ii=1:nfiles
   currentFilename = imageFiles(ii).name;
   
   if ismac
        filePath = strcat(inputDirPath, '/', currentFilename);
   elseif ispc
        filePath = strcat(inputDirPath, '\', currentFilename);
   end
   
   currentImage = imread(filePath);
   img = funcImage(currentImage);
   
   if ismac
        name = strcat(outputDirPath, '/', extractBefore(currentFilename, length(currentFilename) - 4 ), '.', extensionOutput);
   elseif ispc
        name = strcat(outputDirPath, '\', extractBefore(currentFilename, length(currentFilename) - 3 ), '.', extensionOutput);
   end
   name = char(name);
   
   imwrite(img, name);
end
