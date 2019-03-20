% Edrick Ramos
% CPE 592 - Comp&Multimedia Network Security
% Professor Chandramouli
% Homework 1
% LSBstega.m


close all

% Message to be encrypted
message = 'Edrick Ramos';
temp = double(message);

message = uint8(message);
bMessage = dec2bin(message);
bLen = length(bMessage(:));

% Cover images folder
source = './original/';

% Stego images folder
dest = './stego/';

if(~exist(dest, 'dir'))
    mkdir(dest)
end

% Image type
fileType = '.jpg';


%% Embedding

% Image selected
imageName = 'sunflowerGray';
inputImage = strcat(source, imageName, fileType);

% Image read
orig = imread(inputImage);

figure(1)
imshow(uint8(orig))
title('Cover')

imageSize = size(orig);

% Determine whether image is gray or color
colorType = orig(1, 1, :);

    if length(colorType) == 3
        imageColor = orig(:, :, 1);
    else
        imageColor = orig;
    end

I = double(imageColor);

% Image height and width
[width, height] = size(I);

% Number of pixels
num = width * height;

% Embedding rate
embedRate = 0.5;

counts = [.50 .50];
len = embedRate * num;

% Hidden message
hiddenMessage = randsrc(len, 1, [0 1; counts]);
hiddenMessage(1:bLen) = transpose(reshape(bMessage, bLen, 1));

% LSB replaced
imagelsb = I(:);

% Secret key
secretKey = 4194967296;
rand('twister', secretKey);

% Position designated by the secret key
randLocation = randperm(num);
tempSeq = imagelsb(randLocation);
tempSeq(1:len) = 2 * fix(tempSeq(1:len)/2) + hiddenMessage;
imagelsb(randLocation) = tempSeq;
lsbImage = reshape(imagelsb, width, height);

% PSNR value
psnrLSB = PSNR(I, lsbImage);

% Stego image saved
outputImage = strcat(dest, 'stegoLSB', imageName, fileType);
    if length(colorType) == 3
        orig(:,:,1) = lsbImage;
        imwrite(uint8(orig), outputImage)
        show = orig;
    else
        imwrite(uint8(lsbImage), outputImage)
        show = lsbImage;
    end

figure(2)
imshow(uint8(show))
title('Stego')


%% Extracting

% Image read
oStego = imread(outputImage);

% Determine whether image is gray or color
colorType = oStego(1, 1, :);

    if length(colorType) == 3
        stegoColor = oStego(:, :, 1);
    else
        stegoColor = oStego;
    end

stegoColor = double(stegoColor);

% Secret key
secretKey = 4194967296;
rand('twister', secretKey);

% Position designated by the secret key
randLocation = randperm(num);
tempSeq = imagelsb(randLocation);
% Decoded message
decodedMessage = mod(tempSeq(1:bLen), 2);

diff = hiddenMessage(1:bLen)- decodedMessage;
decodeError = length(find(diff ~=0))/len;

