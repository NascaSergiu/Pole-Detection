%% for disparity
adjustImages('D:\Poze Licenta\Dump Images\AUDI-A4YH_20131118_091731\frappe\disparity', 'pgm', ...
    'D:\Poze Licenta\Dump Images\AUDI-A4YH_20131118_091731\frappe\disparity png', 'png', @pgmDisparityToPng, {'colormap', 'hsv'});

%% for dump images

name = 'D:\Poze Licenta\Dump Images';

directories = dir(name);

nfiles = length(directories);

for ii=3:nfiles
    adjustImages(strcat(directories(ii).folder, '\', directories(ii).name, '\frappe\image_view'), 'bmp', ...
        strcat(directories(ii).folder, '\', directories(ii).name, '\frappe\image_view'), 'png', @imadjust);
end