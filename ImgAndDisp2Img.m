
function [imgOut, IDisp] = ImgAndDisp2Img(ImgGray, ImgDisp, opts)

IDisp = calculateDepthFromDisparity(ImgDisp, opts);
imgOut = combineGrayAndDisparity(ImgGray, IDisp);

end

function imgOut = calculateDepthFromDisparity(IDisp, opts)

multiFactor = 255.0 / opts.maxDepth;
IDisp = double(IDisp);

for i = 1:size(IDisp, 1)
    for j = 1:size(IDisp, 2)
        if bitand(IDisp(i, j, 1), bitor(opts.periodicalFlagU16, opts.uniquenessFlagU16)) ~= 0
            IDisp(i, j, 1) = 0;
        end
    end
end
    
IDisp = bitand(IDisp, opts.valueMaskU16);
IDisp = IDisp * opts.floatFactor;
imgOut = (opts.baseline * opts.focalLength) ./ IDisp;

for x = 1:size(imgOut, 1)
    for y = 1:size(imgOut, 2)
        if imgOut(x, y) > opts.maxDepth || imgOut(x,y) == Inf
            imgOut(x, y) = 0;
        else
            imgOut(x, y) = 255 - multiFactor * imgOut(x, y);
        end
    end
end

% figure(21);
% im(imgOut);

imgOut = medfilt2(imgOut, [7 7]);

% imgOut = imcomplement(imfill(imcomplement(imgOut),'holes'));
% imgOut = imfill(imgOut);

imgOut = uint8(255 * mat2gray(imgOut));
imgOut = imadjust(imgOut);

imgOut = lensdistort(imgOut, 0.09);
imgOut = imgOut(:, 7:size(imgOut,2)-7);
imgOut = imresize(imgOut, [700 1230]);
imgOut = padarray(imgOut, [20 20], 255, 'pre');
imgOut = padarray(imgOut, [0 30], 255, 'post');

% figure(20);
% im(imgOut);

end

function imgOut = combineGrayAndDisparity(I, IDisp)
imgOut = I;
imgDepth = size(imgOut, 3);
imgOut(:,:,imgDepth + 1) = IDisp;
end

