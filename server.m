
% set opts paramters
if ismac
    name='./Toolbox/Piotr_Dollar/toolbox-master/detector/models/PoleDetector';
elseif ispc
    name='.\Toolbox\Piotr_Dollar\toolbox-master\detector\models\PoleDetector';
end

% load the detector
detector = load([name 'Detector.mat']);
detector = detector.detector;

% modify detector (see acfModify)
pModify = struct('cascThr',-1,'cascCal', +0.0);
pModify.pNms = struct('thr', 35, 'overlap', 0.6);
detector = acfModify(detector, pModify);

% create a server

% accept connection from anu machine on port 30000.
t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');

set(t, 'InputBufferSize', 10000000);

% open a connection. This will wait until a connection is received.
fopen(t);

grayImgWidth = 0;
grayImgHeight = 0;
dispImgWidth = 0;
dispImgHeight = 0;
grayImg = 0;
dispImg = 0;

while(true)
    if(t.BytesAvailable == 0)
        pause(0.1);
    else
        data = readFromSocket(t);
        str = char(transpose(data));
        if(~isempty(strfind(str, 'GrayImgWidth')))
            fwrite(t, 'OK');
            data = readFromSocket(t);
            data = char(transpose(data));
            grayImgWidth = str2double(data);
            fwrite(t, 'OK');
        elseif(~isempty(strfind(str, 'GrayImgHeight')))
            fwrite(t, 'OK');
            data = readFromSocket(t);
            data = char(transpose(data));
            grayImgHeight = str2double(data);
            fwrite(t, 'OK');
        elseif(~isempty(strfind(str, 'DisparityImgWidth')))
            fwrite(t, 'OK');
            data = readFromSocket(t);
            data = char(transpose(data));
            dispImgWidth = str2double(data);
            fwrite(t, 'OK');
        elseif(~isempty(strfind(str, 'DisparityImgHeight')))
            fwrite(t, 'OK');
            data = readFromSocket(t);
            data = char(transpose(data));
            dispImgHeight = str2double(data);
            fwrite(t, 'OK');
        elseif(~isempty(strfind(str, 'GrayImage')))
            fwrite(t, 'OK');
            data = readFromSocket(t, grayImgWidth * grayImgHeight);
            grayImg = reshape(data, [grayImgWidth, grayImgHeight]);
            grayImg = transpose(grayImg);
            fwrite(t, 'OK');
        elseif(~isempty(strfind(str, 'DisparityImage')))
            fwrite(t, 'OK');
            data = readFromSocket(t, dispImgWidth * dispImgHeight * 4);
            data = swapbytes(typecast(uint8(data),'uint32'));
            dispImg = reshape(data, [dispImgWidth, dispImgHeight]);
            dispImg = transpose(dispImg);
            
            img = ImgAndDisp2Img(grayImg, dispImg, detector.opts.pPyramid.pChns.pDisparity);
            dt = acfDetect(img, detector);
            fwrite(t, mat2str(dt));
        end
    end
end
