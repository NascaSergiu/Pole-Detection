
function imgOut = ImgAndDisp2Img(ImgGray, ImgDisp, opts)

ImgDisp = calculateDepthFromDisparity(ImgDisp, opts);
imgOut = combineGrayAndDisparity(ImgGray, ImgDisp, opts);

end

function imgOut = calculateDepthFromDisparity(IDisp, opts)
IDisp = double(IDisp);


opts.PeriodicalFlagU16 = 8192;
opts.UniquenessFlagU16 = 4096;
opts.ValueMaskU16 = 2047;

opts.FloatFactor = 0.0625;

opts.Baseline = 0.1200007;
opts.FocalLength = 1378.359985;


IDisp = bitxor(IDisp, opts.PeriodicalFlagU16);
IDisp = bitxor(IDisp, opts.UniquenessFlagU16);
IDisp = bitand(IDisp, opts.ValueMaskU16);

IDisp = IDisp * opts.FloatFactor;

imgOut = (opts.Baseline * opts.FocalLength) ./ IDisp;

end

function imgOut = combineGrayAndDisparity(I, IDisp, opts)
imgOut = I;
imgOut(:,:,4) = 255;

opts.MaxDepth = 113;

for x = 1:size(IDisp, 1)
    for y = 1:size(IDisp, 2)
        %         if IDisp(x, y) > opts.MaxDepth
        %             imgOut(x, y, 4) = 255;
        %         else
        %             imgOut(x, y, 4) = 2 * IDisp(x, y);
        %         end
        
        if IDisp(x, y) > opts.MaxDepth || IDisp(x,y) == Inf
            imgOut(x * 2 - 1 + 24, y * 2 - 1 + 18, 4) = 255;
            imgOut(x * 2 - 1 + 24, y * 2 + 18, 4) = 255;
            imgOut(x * 2 + 24, y * 2 - 1 + 18, 4) = 255;
            imgOut(x * 2 + 24, y * 2 + 18, 4) = 255;
        else
            imgOut(x * 2 - 1 + 24, y * 2 - 1 + 18, 4) = 2 * IDisp(x, y);
            imgOut(x * 2 - 1 + 24, y * 2 + 18, 4) = 2 * IDisp(x, y);
            imgOut(x * 2 + 24, y * 2 - 1 + 18, 4) = 2 * IDisp(x, y);
            imgOut(x * 2 + 24, y * 2 + 18, 4) = 2 * IDisp(x, y);
        end
    end
end

end

