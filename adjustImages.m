function adjustImages(inputDirPath, extensionInput, outputDirPath, extensionOutput, funcImage)

name = char( strcat(inputDirPath, '/*', extensionInput));
imageFiles = dir(name);
nfiles = length(imageFiles);

for ii=1:nfiles
   currentFilename = imageFiles(ii).name;
   filePath = strcat(inputDirPath, '/', currentFilename);
   currentImage = imread(filePath);
   
   %img = currentImage;
   img = funcImage(currentImage);
   
   name = strcat(outputDirPath, '/', currentFilename(1: length(currentFilename) - 4 ), ' - edit.', extensionOutput);
   name = char(name);
   
   imwrite(img, name);
end
