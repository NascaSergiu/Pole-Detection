
function [imgOut, IDisp] = ImgAndDisp2Img(ImgGray, ImgDisp, opts)

IDisp = calculateDepthFromDisparity(ImgDisp, opts);
imgOut = combineGrayAndDisparity(ImgGray, IDisp, opts);

end

function imgOut = calculateDepthFromDisparity(IDisp, opts)

multiFactor = 255.0 / opts.maxDepth;
IDisp = double(IDisp);

for i = 1:size(IDisp, 1)
    for j = 1:size(IDisp, 2)
        if bitand(IDisp(i, j, 1), opts.uniquenessFlagU16) ~= 0
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
            imgOut(x, y) = 255;
        else
            imgOut(x, y) = multiFactor * imgOut(x, y);
        end
    end
end

imgOut = lensdistort(imgOut, 0.09);
imgOut = imgOut(:, 7:size(imgOut,2)-7);
imgOut = imresize(imgOut, [700 1230]);
imgOut = padarray(imgOut, [20 20], 255, 'pre');
imgOut = padarray(imgOut, [0 30], 255, 'post');

%imgOut = imcomplement(imfill(imcomplement(imgOut),'holes'));
imgOut = imfill(imgOut);

imgOut = uint8(255 * mat2gray(imgOut));
imgOut = imadjust(imgOut);

figure(20);
im(imgOut);

% imwrite(imgOut, '/Users/nascasergiualin/Documents/Output Movie Bosch/Pole Detection/img_Disp.png');

end

function imgOut = combineGrayAndDisparity(I, IDisp, opts)
imgOut = I;
imgDepth = size(imgOut, 3);
imgOut(:,:,imgDepth + 1) = IDisp;

% multiFactor = 255.0 / opts.maxDepth;
% 
% for x = 1:size(IDisp, 1)
%     for y = 1:size(IDisp, 2)
%         if IDisp(x, y) > opts.maxDepth || IDisp(x,y) == Inf
%             imgOut(x * 2 - 1 + 24, y * 2 - 1 + 18, imgDepth + 1) = 255;
%             imgOut(x * 2 - 1 + 24, y * 2 + 18, imgDepth + 1) = 255;
%             imgOut(x * 2 + 24, y * 2 - 1 + 18, imgDepth + 1) = 255;
%             imgOut(x * 2 + 24, y * 2 + 18, imgDepth + 1) = 255;
%         else
%             imgOut(x * 2 - 1 + 24, y * 2 - 1 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
%             imgOut(x * 2 - 1 + 24, y * 2 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
%             imgOut(x * 2 + 24, y * 2 - 1 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
%             imgOut(x * 2 + 24, y * 2 + 18, imgDepth + 1) = multiFactor * IDisp(x, y);
%         end
%     end
% end

end

