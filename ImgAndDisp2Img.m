
function imgOut = ImgAndDisp2Img(ImgGray, ImgDisp, opts)

ImgDisp = calculateDepthFromDisparity(ImgDisp, opts);
imgOut = combineGrayAndDisparity(ImgGray, ImgDisp, opts);

end

function imgOut = calculateDepthFromDisparity(IDisp, opts)
IDisp = double(IDisp);
for i = 1:size(IDisp, 1)
    for j = 1:size(IDisp, 2)
        if bitand(IDisp(i, j, 1), bitor(0, opts.uniquenessFlagU16)) ~= 0
            IDisp(i, j, 1) = 0;
        end
    end
end
    
IDisp = bitand(IDisp, opts.valueMaskU16);
IDisp = IDisp * opts.floatFactor;
imgOut = (opts.baseline * opts.focalLength) ./ IDisp;

end

function imgOut = combineGrayAndDisparity(I, IDisp, opts)
imgOut = I;
imgDepth = size(imgOut, 3);
imgOut(:,:,imgDepth + 1) = 255;

multiFactor = 255.0 / opts.maxDepth;

for x = 1:size(IDisp, 1)
    for y = 1:size(IDisp, 2)
        if IDisp(x, y) > opts.maxDepth || IDisp(x,y) == Inf
            imgOut(x * 2 - 1 + 24, y * 2 - 1 + 18, imgDepth + 1) = 255;
            imgOut(x * 2 - 1 + 24, y * 2 + 18, imgDepth + 1) = 255;
            imgOut(x * 2 + 24, y * 2 - 1 + 18, imgDepth + 1) = 255;
            imgOut(x * 2 + 24, y * 2 + 18, imgDepth + 1) = 255;
        else
            imgOut(x * 2 - 1 + 24, y * 2 - 1 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
            imgOut(x * 2 - 1 + 24, y * 2 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
            imgOut(x * 2 + 24, y * 2 - 1 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
            imgOut(x * 2 + 24, y * 2 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
        end
    end
end

end

