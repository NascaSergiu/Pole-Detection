function data = readFromSocket( socket, size, type )
%READFROMSOCKET Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    while(socket.BytesAvailable == 0)
        pause(0.1);
    end
    size = socket.BytesAvailable;
else
    while(socket.BytesAvailable ~= size)
        pause(0.1);
    end
end

if(nargin == 3)
    data = fread(socket, size, type);
else
    data = fread(socket, size);
end

end

