%% Poles Detection by Nasca Sergiu-Alin

% Extension of Piotr Dollar Toolxbox
% Piotr's Computer Vision Matlab Toolbox Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% set up opts for training detector (see acfTrain)
opts = acfTrain();
opts.modelDs = [150 15]; 
opts.modelDsPad = [180 45];

opts.nWeak = [64 256 1024 4096];
opts.pBoost.pTree.maxDepth = 5; 
opts.pBoost.discrete = 1;
opts.pBoost.pTree.fracFtrs = 1/16;

opts.stride = 4;

opts.pNms.overlap = 0.6;
opts.pNms.thr = 20;
opts.pNms.combine = 0.2;

opts.nNeg = 25000; 
opts.nAccNeg = 50000;
opts.pJitter = struct('flip', 1);
 
opts.pPyramid.pChns.pColor.enabled = 1;
opts.pPyramid.pChns.pColor.smooth = 1;
opts.pPyramid.pChns.pColor.colorSpace = 'gray';
opts.pPyramid.pChns.pGradHist.softBin = 1; 
opts.pPyramid.pChns.shrink = 2;

opts.pPyramid.pChns.pGradMag.normConst = 25;
opts.pPyramid.pChns.pGradMag.normRad = 0.01;

opts.pPyramid.pChns.pGradMagDisp.normConst = 9;
opts.pPyramid.pChns.pGradMagDisp.normRad = 0.013;

opts.useDispImage = 1;
opts.removeAnnotDepth = 1;
opts.depthThreshold = 50;
opts.pPyramid.pChns.pDisparity.enabled = 1;
opts.pPyramid.pChns.pDisparity.maxDepth = 113;
opts.pPyramid.pChns.pDisparity.periodicalFlagU16 = 8192;
opts.pPyramid.pChns.pDisparity.uniquenessFlagU16 = 4096;
opts.pPyramid.pChns.pDisparity.valueMaskU16 = 2047;

opts.pPyramid.pChns.pDisparity.floatFactor = 0.0625;

opts.pPyramid.pChns.pDisparity.baseline = 0.1200007;
opts.pPyramid.pChns.pDisparity.focalLength = 1378.359985;

if ismac
    opts.posGtDir = './Annotations';
    opts.posImgDir = './Positive Gray';
    opts.dispPgmDir = './Positive Disparity';

    opts.name='./Toolbox/Piotr_Dollar/toolbox-master/detector/models/PoleDetector';
elseif ispc
    opts.posGtDir = '.\Annotations';
    opts.posImgDir = '.\Positive Gray';
    opts.dispPgmDir = '.\Positive Disparity';

    opts.name='.\Toolbox\Piotr_Dollar\toolbox-master\detector\models\PoleDetector';
end

pLoad={'lbls', {'pole'}, 'ilbls', {''} };
opts.pLoad = [pLoad 'arRng', [-inf inf]];

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
pModify = struct('cascThr',-1,'cascCal', +0.0);
pModify.pNms = struct('thr', 35, 'overlap', 0.6);
detector = acfModify(detector, pModify);

%% test on sample image
writeImges = 0;
showImage = 1;

if ismac
%     imgNms = bbGt('getFiles', ...
%         {'./Visualization/LB-X_5326_20160801_11311320170223_151910/image_view', ...
%         './Visualization/LB-X_5326_20160801_11311320170223_151910/disparity', ...
%         });
    imgNms = bbGt('getFiles', ...
        {'./Positive Gray', ...
        './Positive Disparity', ...
        './Annotations'});
elseif ispc
%     imgNms = bbGt('getFiles', ...
%         {'.\Visualization\LB-X_5326_20160801_11311320170223_151910\image_view', ...
%         '.\Visualization\LB-X_5326_20160801_11311320170223_151910\disparity', ...
%         });
    imgNms = bbGt('getFiles', ...
        {'.\Positive Gray', ...
        '.\Positive Disparity', ...
        '.\Annotations'});
end

for ii = 1:size(imgNms, 2)
    Img = imread(imgNms{1, ii});

    if( detector.opts.useDispImage == 1 )
        ImgDisp = imread(imgNms{2, ii});
        Img = ImgAndDisp2Img(Img, ImgDisp, opts.pPyramid.pChns.pDisparity);
    end
    
    dt = acfDetect(Img, detector);
    
    if(size(imgNms, 1) == 3)
        [~,gt] = bbGt('bbLoad', imgNms{3, ii}, opts.pLoad);
        
        if( opts.removeAnnotDepth && opts.useDispImage == 1 )
            gt = bbGt('preProcessing', gt, Img, opts);
        end
        
        gtValid = gt(gt(:,5)==0,1:4);
        gtNValid = gt(gt(:,5)==1,1:4);
    end
    
    if(showImage == 1)
        figure(1); 
        im(Img(:, :, 1)); 

        bbApply( 'draw', dt);

        if(size(imgNms, 1) == 3)
            bbApply( 'draw', gtNValid, 'r');
            bbApply( 'draw', gtValid, 'b');
        end
    end
    
    if(writeImges == 1)
        outputImg = Img(:, :, 1);
        outputImg = bbApply( 'embed', outputImg, dt, 'col', [0, 255, 0], 'fh', 0);
        if(size(imgNms, 1) == 3)
            outputImg = bbApply( 'embed', outputImg, gtNValid, 'col', [255, 0, 0]);
            outputImg = bbApply( 'embed', outputImg, gtValid, 'col', [0, 0, 255]);
        end
        
        if ismac
            imwrite(outputImg, strcat('./OutputImages/image_', int2str(ii),'.png'));
        elseif ispc
            imwrite(outputImg, strcat('.\OutputImages\image_', int2str(ii),'.png'));
        end
    end

    if(showImage == 1)
        waitforbuttonpress();
    end
end
%% test detector and plot roc (see acfTest)
if ismac
    opts.name='./Toolbox/Piotr_Dollar/toolbox-master/detector/models/PoleDetector';
elseif ispc
    opts.name='.\Toolbox\Piotr_Dollar\toolbox-master\detector\models\PoleDetector';
end

pLoad={'lbls', {'pole'}, 'ilbls', {''} };
opts.pLoad = [pLoad 'arRng', [-inf inf]];

pModify=struct('cascThr', -1, 'cascCal', +0.0);
pModify.pNms = struct('thr', 30, 'overlap', 0.6);
if ismac
    [~,gt,dt]=acfTest('name',opts.name, ...
        'imgDir','./Positive Gray', ...
        'dispDir', './Positive Disparity', ...
        'gtDir','./Annotations', ...
        'pLoad',[pLoad, ...
        'arRng', [-inf inf]], ...
        'reapply', 1, ...
        'thr', .15, ...
        'pModify', pModify, ...
        'show', 2);
elseif ispc
    [~,gt,dt]=acfTest('name',opts.name, ...
        'imgDir', '.\Positive Gray', ...
        'dispDir', '.\Positive Disparity', ...
        'gtDir','.\Annotations', ...
        'pLoad', [pLoad, ...
        'arRng', [-inf inf]], ...
        'reapply', 1, ...
        'thr', .15, ...
        'pModify', pModify, ...
        'show', 2);
end
