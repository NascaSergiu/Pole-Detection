function adjustImages(inputDirPath, extensionInput, outputDirPath, extensionOutput, funcImage)

name = char( strcat(inputDirPath, '\*', extensionInput));
imageFiles = dir(name);
nfiles = length(imageFiles);

for ii=1:nfiles
   currentFilename = imageFiles(ii).name;
   filePath = strcat(inputDirPath, '\', currentFilename);
   currentImage = imread(filePath);
   
   img = funcImage(currentImage);
   
   name = strcat(outputDirPath, '\', extractBefore(currentFilename, length(currentFilename) - 3 ), '.', extensionOutput);
   name = char(name);
   
   imwrite(img, name);
end
