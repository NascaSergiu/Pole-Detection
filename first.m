%% another example

% Demo for aggregate channel features object detector on Caltech dataset.
%
% See also acfReadme.m
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% set up opts for training detector (see acfTrain)
opts=acfTrain();
opts.modelDs=[270 15]; 
opts.modelDsPad=[450 25];

opts.nWeak=[64 256 1024 4096];
opts.pBoost.pTree.maxDepth=5; 
opts.pBoost.discrete=0;
opts.pBoost.pTree.fracFtrs=1/16;

opts.pNms.overlap = 0.3;
opts.pNms.thr = 20;

opts.nNeg=25000; 
opts.nAccNeg=50000;
 
opts.pPyramid.pChns.pColor.enabled = 0;
opts.pPyramid.pChns.pColor.smooth = 1;
opts.pPyramid.pChns.pColor.colorSpace = 'gray';
opts.pPyramid.pChns.pGradHist.softBin=1; 
opts.pPyramid.pChns.shrink = 2;

opts.pPyramid.pChns.pCustom = struct('enabled', 1, 'name', 'Custom Channel', 'hFunc', @myKernel);

if ismac
    opts.posGtDir='C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Annotations';
    opts.posImgDir='C:\Users\NSE4CLJ\Desktop\Images';

    opts.name='C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Toolbox\Piotr_Dollar\toolbox-master\detector\models\PoleDetector';
elseif ispc
    opts.posGtDir='C:\Users\NSE4CLJ\Desktop\XML Poles - Modify\New';
    opts.posImgDir='C:\Users\NSE4CLJ\Desktop\Images';

    opts.name='C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Toolbox\Piotr_Dollar\toolbox-master\detector\models\PoleDetector';
end

%opts.pJitter=struct('flip',1);

pLoad={'lbls',{'pole'},'ilbls',{''}, 'squarify',{9.5,.41}};
opts.pLoad = [pLoad 'arRng', [-inf inf]];

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
pModify=struct('cascThr',-1,'cascCal',.015);
detector=acfModify(detector,pModify);

%% test on sample image
if ismac
    imgNms=bbGt('getFiles',{['C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Feature Labels' '']});
elseif ispc
    imgNms=bbGt('getFiles',{['C:\Users\NSE4CLJ\Documents\GitHub\Pole-Detection\Feature Labels' '']});
end

for ii=1:50
    I=imread(imgNms{ii}); tic, bbs=acfDetect(I,detector); toc
    figure(1); im(I); bbApply('draw',bbs); pause(.75);
end
%% test detector and plot roc (see acfTest)
% [~,~,gt,dt]=acfTest('name',opts.name,'imgDir','C:\Users\NSE4CLJ\Desktop\Poles\Feature Labels',...
%   'gtDir','C:\Users\NSE4CLJ\Desktop\Poles\Feature Labels Annotations','pLoad',...
%   [pLoad, 'wRng', [3 inf], 'hRng', [10, inf], 'arRng', [-inf inf]],...
%   'pModify',pModify, 'show',2);

