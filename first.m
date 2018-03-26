%% another example

% Demo for aggregate channel features object detector on Caltech dataset.
%
% See also acfReadme.m
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% set up opts for training detector (see acfTrain)
opts = acfTrain();
opts.modelDs = [270 15]; 
opts.modelDsPad = [540 30];

opts.nWeak = [64 256 1024 4096];
opts.pBoost.pTree.maxDepth = 5; 
opts.pBoost.discrete = 0;
opts.pBoost.pTree.fracFtrs = 1/16;

opts.pNms.overlap = 0.3;
opts.pNms.thr = 20;

opts.nNeg = 25000; 
opts.nAccNeg = 50000;
 
opts.pPyramid.pChns.pColor.enabled = 0;
opts.pPyramid.pChns.pColor.smooth = 1;
opts.pPyramid.pChns.pColor.colorSpace = 'gray';
opts.pPyramid.pChns.pGradHist.softBin = 1; 
opts.pPyramid.pChns.shrink = 2;

opts.pPyramid.pChns.pDisparity.enabled = 1;
opts.pPyramid.pChns.pDisparity.maxDepth = 40;
opts.pPyramid.pChns.pDisparity.periodicalFlagU16 = 8192;
opts.pPyramid.pChns.pDisparity.uniquenessFlagU16 = 4096;
opts.pPyramid.pChns.pDisparity.valueMaskU16 = 2047;

opts.pPyramid.pChns.pDisparity.floatFactor = 0.0625;

opts.pPyramid.pChns.pDisparity.baseline = 0.1200007;
opts.pPyramid.pChns.pDisparity.focalLength = 1378.359985;

if ismac
    opts.posGtDir = '/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Annotations';
    opts.posImgDir = '/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Gray';
    opts.dispPgmDir = '/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Disparity';

    opts.name='/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Toolbox/Piotr_Dollar/toolbox-master/detector/models/PoleDetector';
elseif ispc
    opts.posGtDir = 'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Annotations';
    opts.posImgDir = 'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Gray';
    opts.dispPgmDir = 'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Disparity';

    opts.name='C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Toolbox\Piotr_Dollar\toolbox-master\detector\models\PoleDetector';
end

pLoad={'lbls',{'pole'},'ilbls',{''}, 'squarify',{9.5,.41}};
opts.pLoad = [pLoad 'arRng', [-inf inf]];

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
pModify=struct('cascThr',-1,'cascCal',.015);
detector=acfModify(detector,pModify);

%% modify detector threshold
pModify.pNms = struct('thr', 30, 'overlap', 0.15);
detector = acfModify(detector, pModify);

%% test on sample image
if ismac
    imgNms = bbGt('getFiles', ...
        {'/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Gray', ...
        '/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Disparity'});
elseif ispc
    imgNms = bbGt('getFiles', ...
        {'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Gray', ...
        'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Disparity'});
end

for ii = 141:141
    ImgGray = imread(imgNms{1, ii});
    ImgDisp = imread(imgNms{2, ii});
    ImgComb = ImgAndDisp2Img(ImgGray, ImgDisp, opts.pPyramid.pChns.pDisparity);
    bbs = acfDetect(ImgComb, detector);
    figure(2); 
    im(ImgGray); 
    bbApply('draw', bbs);
    pause(1.0);
end

%% check disparity image

I = imread('C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Disparity\AUDI-A4YH_20131001_083932_0182 - flip.pgm');
I = pgmDisparityToPng(I);
imshow(I);
%% test detector and plot roc (see acfTest)
% [~,~,gt,dt]=acfTest('name',opts.name,'imgDir','C:\Users\NSE4CLJ\Desktop\Poles\Feature Labels',...
%   'gtDir','C:\Users\NSE4CLJ\Desktop\Poles\Feature Labels Annotations','pLoad',...
%   [pLoad, 'wRng', [3 inf], 'hRng', [10, inf], 'arRng', [-inf inf]],...
%   'pModify',pModify, 'show',2);

