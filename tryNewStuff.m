%% for disparity
adjustImages('D:\CompareGabi\LB-X_5326_20160922_16122820170223_150152\image_view', 'bmp', ...
    'D:\CompareGabi\LB-X_5326_20160922_16122820170223_150152\image_view', 'bmp', @imadjust);

%% for dump images

name = 'D:\Poze Licenta\Dump Images';

directories = dir(name);

nfiles = length(directories);

for ii=3:nfiles
    adjustImages(strcat(directories(ii).folder, '\', directories(ii).name, '\frappe\image_view'), 'bmp', ...
        strcat(directories(ii).folder, '\', directories(ii).name, '\frappe\image_view'), 'png', @imadjust);
end