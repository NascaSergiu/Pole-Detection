%% Pre-processing input Image

img = imread('C:\temp\007M287_20131123_102822\frappe\image_view\007M28_frappe_img_export_0000.bmp');
img = rgbConvert(img, 'gray');
img = imadjust(img);

figure(1); 
im(img);
title('Normal Image');

%% Create LUV if img is RGB Image

if size(img, 3) == 3
    LUV = rgbConvert(img, 'luv');
    figure(2);
    subplot(2,2,1);
    im(LUV(:,:,1));
    title('Luminance Image');
    
    subplot(2,2,2);
    im(LUV(:,:,2));
    title('Saturation Image');
    
    subplot(2,2,3);
    im(LUV(:,:,3));
    title('Hue Image');
end

%% Read the image and print it

if size(img, 3) == 3
    imgGray = rgbConvert(img, 'gray');
    
    subplot(2,2,4);
    im(imgGray);
    title('Gray Image');
    
    I=imResample(single(imgGray),[360 640])/255;
else
    I=imResample(single(img),[360 640])/255;
end

%% Compute the gradient by x and y and gradient histogram and gradient magnitutde
figure(3);
[Gx, Gy] = gradient2(I);

subplot(2, 2, 1);
imshowpair(Gx, Gy, 'montage');
title('First derivative by x and y');

subplot(2, 2, 2);
[Gxx, Gxy] = gradient2(Gx);
imshowpair(Gxx, Gxy, 'montage');
title('Second derivative by x and y');

M = sqrt(Gx.^2 + Gy.^2);

subplot(2, 2, 3);
im(M);
title('Gradient Magnitude');

O = atan2(Gy, Gx);
subplot(2, 2, 4);
im(O);
title('Gradient Histogram');


%% Compute Hog
  
H=hog(I,10,6);
V=hogDraw(H,25); 

figure(4);
im(V);
title('6 Histogram Orientation Gradients')

%% binarize image

[counts, x] = imhist(I, 255);
T = otsuthresh(counts);
BW = imbinarize(I, 'adaptive');

figure(5);
im(BW);
title('Binarize Image');

%% test a demo caltech 

img = imread('C:\Users\NSE4CLJ\Downloads\test.jpg');

load('D:\Matlab\Toolbox\Piotr_Dollar\toolbox-master\detector\models\acfInriaDetector.mat','detector'); %load INRIA-trained detector

bbs = acfDetect(img,detector); %return bounding boxes [x y w h score]
imshow(img);
bbApply('draw',bbs);

%% convert gray Image to rgb

adjustImages('C:\Users\NSE4CLJ\Desktop\Poles\Feature Labels', 'png', 'C:\Users\NSE4CLJ\Desktop\Poles\Feature Labels', 'png', @imadjust);
