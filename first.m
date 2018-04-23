%% Poles Detection by Nasca Sergiu-Alin

% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% set up opts for training detector (see acfTrain)
opts = acfTrain();
opts.modelDs = [270 15]; 
opts.modelDsPad = [540 30];

opts.nWeak = [64 256 1024 4096];
opts.pBoost.pTree.maxDepth = 5; 
opts.pBoost.discrete = 1;
opts.pBoost.pTree.fracFtrs = 1/16;

opts.pNms.overlap = 0.3;
opts.pNms.thr = 20;
opts.pNms.combine = 0.1;

opts.nNeg = 25000; 
opts.nAccNeg = 50000;
 
opts.pPyramid.pChns.pColor.enabled = 1;
opts.pPyramid.pChns.pColor.smooth = 1;
opts.pPyramid.pChns.pColor.colorSpace = 'gray';
opts.pPyramid.pChns.pGradHist.softBin = 1; 
opts.pPyramid.pChns.shrink = 2;

opts.removeAnnotDepth = 1;
opts.depthThreshold = 65;
opts.pPyramid.pChns.pDisparity.enabled = 1;
opts.pPyramid.pChns.pDisparity.maxDepth = 113;
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

pLoad={'lbls', {'pole'}, ...
    'ilbls', {''}, ...
    'squarify', {0.058, 0.053}};
opts.pLoad = [pLoad 'arRng', [-inf inf]];

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
pModify=struct('cascThr',-1,'cascCal',-0.01);
pModify.pNms = struct('thr', 35, 'overlap', 0.6);
detector = acfModify(detector, pModify);

%% test on sample image
if ismac
    imgNms = bbGt('getFiles', ...
        {'/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Gray', ...
        '/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Disparity', ...
        '/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Annotations'});
elseif ispc
    imgNms = bbGt('getFiles', ...
        {'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Gray', ...
        'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Disparity', ...
        'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Annotations'});
end

for ii = 5:25
    ImgGray = imread(imgNms{1, ii});
    ImgDisp = imread(imgNms{2, ii});
    ImgComb = ImgAndDisp2Img(ImgGray, ImgDisp, opts.pPyramid.pChns.pDisparity);
    
    dt = acfDetect(ImgComb, detector);
    [~,gt] = bbGt('bbLoad', imgNms{3, ii}, opts.pLoad);
    
    if( opts.removeAnnotDepth )
        gt = bbGt('preProcessing', gt, ImgComb, opts);
    end
    
    gtValid = gt(gt(:,5)==0,1:4);
    gtNValid = gt(gt(:,5)==1,1:4);
    
    figure(2); 
    im(ImgGray); 
    
    bbApply( 'draw', dt);
    bbApply( 'draw', gtNValid, 'r');
    bbApply( 'draw', gtValid, 'b');
    
    pause(1.5);
end

%% check disparity image

ImgGray = imread('/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Gray/AUDI-A4YH_20131001_083932_2682 - flip.bmp');
ImgDisp = imread('/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Disparity/AUDI-A4YH_20131001_083932_2682 - flip.pgm');
ImgComb = ImgAndDisp2Img(ImgGray, ImgDisp, opts.pPyramid.pChns.pDisparity);
ImgDisp = ImgComb(:,:,2);
Img = imfuse(ImgGray, ImgDisp, 'blend');
figure(10);
imshow(Img);
figure(20);
imshow(ImgDisp);

%% test detector and plot roc (see acfTest)
pModify=struct('cascThr',-1,'cascCal',+.035);
pModify.pNms = struct('thr', 30, 'overlap', 0.6);
if ismac
    [~,~,gt,dt]=acfTest('name',opts.name, ...
        'imgDir','/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Gray', ...
        'dispDir', '/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Positive Disparity', ...
        'gtDir','/Users/nascasergiualin/Documents/GitHub/Pole-Detection/Annotations', ...
        'pLoad',[pLoad, ...
        'arRng', [-inf inf]], ...
        'reapply', 0, ...
        'thr', .15, ...
        'pModify', pModify, ...
        'show', 2);
elseif ispc
    [~,~,gt,dt]=acfTest('name',opts.name, ...
        'imgDir', 'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Gray', ...
        'dispDir', 'C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Positive Disparity', ...
        'gtDir','C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Annotations', ...
        'pLoad', [pLoad, ...
        'arRng', [-inf inf]], ...
        'reapply', 0, ...
        'thr', .15, ...
        'pModify', pModify, ...
        'show', 2);
end

