function [miss,roc,gt,dt] = acfTest( varargin )
% Test aggregate channel features object detector given ground truth.
%
% USAGE
%  [miss,roc,gt,dt] = acfTest( pTest )
%
% INPUTS
%  pTest    - parameters (struct or name/value pairs)
%   .name     - ['REQ'] detector name
%   .imgDir   - ['REQ'] dir containing test images
%   .gtDir    - ['REQ'] dir containing test ground truth
%   .pLoad    - [] params for bbGt>bbLoad for test data (see bbGt>bbLoad)
%   .pModify  - [] params for acfModify for modifying detector
%   .thr      - [.5] threshold on overlap area for comparing two bbs
%   .mul      - [0] if true allow multiple matches to each gt
%   .reapply  - [0] if true re-apply detector even if bbs already computed
%   .ref      - [10.^(-2:.25:0)] reference points (see bbGt>compRoc)
%   .lims     - [3.1e-3 1e1 .05 1] plot axis limits
%   .show     - [0] optional figure number for display
%
% OUTPUTS
%  miss     - log-average miss rate computed at reference points
%  roc      - [nx3] n data points along roc of form [score fp tp]
%  gt       - [mx5] ground truth results [x y w h match] (see bbGt>evalRes)
%  dt       - [nx6] detect results [x y w h score match] (see bbGt>evalRes)
%
% EXAMPLE
%
% See also acfTrain, acfDetect, acfModify, acfDemoInria, bbGt
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

% get parameters
dfs={ 'name', 'REQ', ...
    'imgDir', 'REQ', ...
    'dispDir', 'REQ', ...
    'gtDir', 'REQ', ...
    'pLoad', [], ...
    'pModify', [], ...
    'thr', .5, ...
    'mul', 0, ...
    'reapply', 0, ...
    'ref', 10.^(-2:.25:0), ...
    'lims', [3.1e-3 1e1 .05 1], ...
    'show', 0};
[name,imgDir,dispDir,gtDir,pLoad,pModify,thr,mul,reapply,ref,lims,show] = ...
  getPrmDflt(varargin,dfs,1);

% run detector on directory of images
bbsNm=[name 'Dets.txt'];
detector = load([name 'Detector.mat']);
if(reapply && exist(bbsNm,'file')), delete(bbsNm); end
if(reapply || ~exist(bbsNm,'file'))
    detector = detector.detector;
    if(~isempty(pModify))
        detector=acfModify(detector,pModify); 
    end
    imgNms = bbGt('getFiles', {imgDir, dispDir});
    acfDetect( imgNms, detector, bbsNm );
else
    imgNms = bbGt('getFiles', {imgDir, dispDir});
    detector = detector.detector;
end

% run evaluation using bbGt
[gt, dt] = bbGt('loadAll', gtDir, bbsNm, pLoad);

opts = detector.opts;
if( opts.removeAnnotDepth )
    parfor i = 1:size(imgNms, 2)
        
        I = feval( opts.imreadf, imgNms{1, i}, opts.imreadp{:} ); %#ok<PFBNS>
        IDisp = feval( opts.imreadf, imgNms{2, i}, opts.imreadp{:} );

        I = ImgAndDisp2Img( I, IDisp, opts.pPyramid.pChns.pDisparity );

        gt{i} = bbGt( 'preProcessing', gt{i}, I, opts );
        bbs = gt{i};
        %bbs = bbs(bbs(:,5)==0,:);
        bbs(:, 6) = 0;
        gt{i} = bbs;
        
    end
end

[gt, dt] = bbGt('evalRes2', gt, dt, thr, mul);

[fp, tp, miss] = bbGt('compRoc2', gt, dt);

if( ~show )
    return;
end

figure(show + 1);
hold on;

title('Graph of TP, FP and miss of poles detection');
xlabel('Number of images');
ylabel('Number of poles');

plot(fp, 'r');
plot(tp, 'b');
plot(miss, 'g');
legend({'false positive', 'true positive', 'miss'}, 'Location', 'northwest');

%savefig([name 'Roc - '], show + 1, 'png');

hold off;




[fp, tp, score, miss] = bbGt('compRoc', gt, dt, 1, ref);
miss=exp(mean(log(max(1e-10,1-miss)))); 
roc=[score fp tp];

% optionally plot roc
if( ~show )
    return;
end
figure(show); 
plotRoc([fp tp],'logx',1,'logy',1,'xLbl','fppi',...
  'lims',lims,'color','g','smooth',1,'fpTarget',ref);
title(sprintf('log-average miss rate = %.2f%%',miss*100));
savefig([name 'Roc'],show,'png');

end
