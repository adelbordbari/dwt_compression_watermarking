clc;
close all;
imtool close all;
clear;
workspace;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%       WATERMARKING       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in the image what will have another image hidden into it.
A = imread('disco.jpg');
%x = mat2gray(double(A));

% Display the original gray scale image.
subplot(2,2,1);
imshow(rgb2gray(A));
title('Grayscale Base Image');

B = imread('circle.png');
% Display the original gray scale image.
subplot(2,2,2);
imshow(rgb2gray(B));
title('Grayscale Watermark');

thr = 150;
bBin = rgb2gray(B) < thr;
subplot(2,2,3);
imshow(bBin);
title('Binary Watermark thr=150');

[pixelCount, grayLevels] = imhist(B);
subplot(2,2,4);
bar(pixelCount, 'BarWidth', 2);
title('Watermark Histogram');
grid on;

bitp = 7; % bit plane to insert watermark

[visRow, visCol, visClrChan] = size(A);
[hidRow, hidCol, hidClrChan] = size(B);

% Tile the hiddenImage, if it's smaller, so that it will cover the original image.
if hidRow < visRow || hidCol < visCol
  wm = zeros(size(A), 'uint8');
  for column = 1:visCol
    for row = 1:visRow
      wm(row, column) = bBin(mod(row,hidRow)+1, mod(column,hidCol)+1);
    end
  end
  % Crop it to the same size as the original image.
  wm = wm(1:visRow, 1:visCol);
else
  % Watermark is the same size as the original image.
  wm = bBin;
end

wmResult = A; % Initiate
for column = 1 : visCol
  for row = 1 : visRow
    wmResult(row, column) = bitset(A(row, column), bitp, wm(row, column));
  end
end
% Display the image
figure
subplot(2, 2, 1);
imshow(wm, []);
title("Resized Watermark");
subplot(2, 2, 2);
imshow(wmResult, []);
title("Watermarked Image w/o Noise");

noisyWmResult = imnoise(wmResult,'gaussian', 0, 0.0005);
% Display the image.
subplot(2, 2, 3);
imshow(noisyWmResult, []);
title("Watermarked Image with Gaussian Noise");

imwrite(wmResult, "wmResult.jpg");
imwrite(noisyWmResult, "noisyWmResult.jpg");



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%      DEWATERMARKING      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recWM = zeros(size(wmResult));  % init recovered wm
recNoisyWm = zeros(size(noisyWmResult));    % init recovered noisy wm

for column = 1:visCol
  for row = 1:visRow
    recWm(row, column) = bitget(wmResult(row, column), bitp);
    recNoisyWm(row, column) = bitget(noisyWmResult(row, column), bitp);
  end
end

% Scale the recovered watermark to 0=255
recWm = uint8(255 * recWm);
recNoisyWm = uint8(255 * recNoisyWm);

% Display the images.
figure
subplot(1, 2, 1);
imshow(recWm, []);
title("Recovered Watermark");

subplot(1, 2, 2);
imshow(recNoisyWm, []);
title("Recovered Noisy Watermark");