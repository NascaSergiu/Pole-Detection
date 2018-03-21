%% for disparity
adjustImages('C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Do Not Touch\Positive Disparity', 'pgm', ...
    'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Do Not Touch\Flip Positive Disparity', 'pgm', @fliplr);

%% for dump images

name = 'D:\Poze Licenta\Dump Images';

directories = dir(name);

nfiles = length(directories);

for ii=3:nfiles
    adjustImages(strcat(directories(ii).folder, '\', directories(ii).name, '\frappe\image_view'), 'bmp', ...
        strcat(directories(ii).folder, '\', directories(ii).name, '\frappe\image_view'), 'png', @imadjust);
end