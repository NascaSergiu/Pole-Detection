% read pgm files disparity and display this photo
function I = pgmDisparityToPng(img, varargin)
    G_PERIODICAL_FLAG_U16 = 8192;
    G_UNIQUENESS_FLAG_U16 = 4096;
    G_VALUE_MASK_U16 = 2047;

    G_FLOAT_FACTOR = 0.0625;

    G_DISP_MAX_DISPARITY = 113.0;

    M_BASELINE = 0.1200007;
    M_FOCAL_LENGTH = 1378.359985;

    % read pgm file
    img = double(img);

    % create depth image from pgm image
    imgDisparity = bitxor(img, G_PERIODICAL_FLAG_U16);
    imgDisparity = bitxor(imgDisparity, G_UNIQUENESS_FLAG_U16);
    imgDisparity = bitand(imgDisparity, G_VALUE_MASK_U16);

    imgDisparity = imgDisparity * G_FLOAT_FACTOR;

    imgDepth = (M_BASELINE * M_FOCAL_LENGTH) ./ imgDisparity;
    %imagesc(imgDepth ,[0 113]); colormap(parula);

    % create output image based on depth image(matrix)
    imgOut = zeros( size(imgDepth, 1), size(imgDepth, 2), 3);

    current = hsv(113);
    for i = 1:length(varargin)
        pair = varargin{i};
        switch pair{1}
            case 'colormap'
                switch pair{2}
                    case 'gray'
                        current = colormap(flipud(gray(113)));
                    case 'parula'
                        current = parula(113);
                    case 'hsv'
                        current = hsv(113);
                    otherwise
                        current = jet(113);
                end
        end
    end


    for R=1:size(imgDepth, 1)
        for C=1:size(imgDepth, 2)
            if imgDepth(R, C) > 113
                imgOut(R, C, 1) = 0.0;
                imgOut(R, C, 2) = 0.0;
                imgOut(R, C, 3) = 0.0;
            else
                imgOut(R, C, 1) = current(round(imgDepth(R, C)), 1);
                imgOut(R, C, 2) = current(round(imgDepth(R, C)), 2);
                imgOut(R, C, 3) = current(round(imgDepth(R, C)), 3);
            end
        end
    end

    I = imgOut;
end