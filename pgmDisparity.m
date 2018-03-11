% read pgm files disparity and display this photo

G_PERIODICAL_FLAG_U16 = 8192;
G_UNIQUENESS_FLAG_U16 = 4096;
G_VALUE_MASK_U16 = 2047;

G_FLOAT_FACTOR = 0.0625;

G_DISP_MAX_DISPARITY = 113.0;

M_BASELINE = 0.1200007;
M_FOCAL_LENGTH = 1378.359985;

%% read pgm file
img = imread('D:\Poze Licenta\Dump Images\007M287_20140106_064503\frappe\disparity\disp_007M287_20140106_064503_42256.pgm');
img = double(img);

%% create depth image from pgm image
imgDisparity = bitxor(img, G_PERIODICAL_FLAG_U16);
imgDisparity = bitxor(imgDisparity, G_UNIQUENESS_FLAG_U16);
imgDisparity = bitand(imgDisparity, G_VALUE_MASK_U16);

imgDisparity = imgDisparity * G_FLOAT_FACTOR;

imgDepth = (M_BASELINE * M_FOCAL_LENGTH) ./ imgDisparity;
%imagesc(imgDepth ,[0 113]); colormap(parula);

%% create output image based on depth image(matrix)
imgOut = zeros( size(imgDepth, 1), size(imgDepth, 2), 3);



figure;
imshow(imgOut);