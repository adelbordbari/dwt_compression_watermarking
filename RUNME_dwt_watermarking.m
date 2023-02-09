clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%    WATERMARKING   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read cover-wm
% dwt 3-L both images
% res = k*cover + q*wm to merge
% inset result's LL3
% save and show result

% read images
cover = imread('circ.jpg');
wm = imread('disco.jpg');
fam = 'db3'; % wavelet family
lvl = 3; % wavelet depth
k = 1; % 0.2, 0.6, 1.0, 1.4, 1.8
q = 0.01; % 0.009, 0.01

% show images
%figure
%subplot(1,2,1);
%imshow(cover);
%title("Cover");
%subplot(1,2,2);
%imshow(wm);
%title("Watermark");

% convert to grayscale
%cover = rgb2gray(cover);
%wm = rgb2gray(wm);

% apply 2D wavelet decomposition on images
[c_cover, s_cover] = wavedec2(cover, lvl, fam);

% extract LL coeffs
ll_cover = appcoef2(c_cover, s_cover, fam, lvl);
% extract detail coeffs (LH, HL, HH)
[lh_cover, hl_cover, hh_cover] = detcoef2('all', c_cover, s_cover, lvl);

% get colormap range
rng = size(cover, 1); %576 for disco.jpg
% rescale coeff. matrices to original color range
ll_cover_scaled = wcodemat(ll_cover, rng, 'mat', lvl);
lh_cover_scaled = wcodemat(lh_cover, rng, 'mat', lvl);
hl_cover_scaled = wcodemat(hl_cover, rng, 'mat', lvl);
hh_cover_scaled = wcodemat(hh_cover, rng, 'mat', lvl);

% do everything the same for watermark image
[c_wm, s_wm] = wavedec2(wm, lvl, fam);
ll_wm = appcoef2(c_wm, s_wm, fam, lvl);
[lh_wm, hl_wm, hh_wm] = detcoef2('all', c_wm, s_wm, lvl);
wm_rng = size(wm, 1);
ll_wm_scaled = wcodemat(ll_wm, wm_rng, 'mat', 3);
lh_wm_scaled = wcodemat(lh_wm, wm_rng, 'mat', 3);
hl_wm_scaled = wcodemat(hl_wm, wm_rng, 'mat', 3);
hh_wm_scaled = wcodemat(hh_wm, wm_rng, 'mat', 3);

%figure
%colormap pink(255);
%subplot(2,4,1); imagesc(ll_wm_scaled); title('WM LL'); axis square;
%subplot(2,4,2); imagesc(lh_wm_scaled); title('WM LH'); axis square;
%subplot(2,4,3); imagesc(hl_wm_scaled); title('WM HL'); axis square;
%subplot(2,4,4); imagesc(hh_wm_scaled); title('WM HH'); axis square;
%subplot(2,4,5); imagesc(ll_cover_scaled); title('ORG LL'); axis square;
%subplot(2,4,6); imagesc(lh_cover_scaled); title('ORG LH'); axis square;
%subplot(2,4,7); imagesc(hl_cover_scaled); title('ORG HL'); axis square;
%subplot(2,4,8); imagesc(hh_cover_scaled); title('ORG HH'); axis square;

% merge LL bands of two images
k = double(k); q = double(q);
% resize wm to fit cover's dimensions
[x,y,z] = size(ll_cover);
ll_cover_size = [x, y];
[x,y,z] = size(ll_wm);
ll_wm_size = [x, y];
ll_wm_resized = imresize(ll_wm, ll_cover_size);

% apply k-q
ll_result = (k * ll_cover) + (q * ll_wm_resized);

% convert to 1D to reconstruct c_result
ll_result_1d = ll_result(:)';

% replace c_cover's first elements with ll_result
ll_result_1d_size = size(ll_result_1d);
c_result = c_cover; % initiate
for id=1:ll_result_1d_size(2) % replace LL values
    c_result(1,id) = ll_result_1d(1,id);
end

%[ll_result, lh_cover, hl_cover, hh_cover];
s_result = s_cover;
result = waverec2(c_result, s_result, fam);
wimage = uint8(result);

% calculate mse/psnr
%D = abs(wimage - cover) .^2;
mse  = immse(cover, wimage);
psnr = psnr(cover, wimage);

% show image and mse/psnr
figure
subplot(1,2,1);
imshow(cover); title("Original"); axis square;
subplot(1,2,2);
imshow(wimage); colormap(gray); axis square;
msg = strcat("MSE: ", num2str(mse), " | PSNR: ", num2str(psnr));
title({"Watermarked";msg});

% save image locally
imwrite(wimage, 'watermarked.png');

%=======================================================%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     DEWATERMARKING    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read res
% dwt 3-L res
% ext = [LL_3(res) - k*LL_3(cover)] / q
% other bands = 0
% compare ext and wm
% mse/psnr
% check results after gaussian/white noise

% clear variables
clearvars -except k q lvl fam ll_cover wm rng;

% read watermarked image
wimage = imread('watermarked.png');

% dwt 2D watermarked image
[c_wi, s_wi] = wavedec2(wimage, lvl, fam);

% extract watermarked image's LL_3 coeffs
ll_wi = appcoef2(c_wi, s_wi, fam, lvl);

% apply extraction formula
ll_ext = (ll_wi - (k * ll_cover)) / q;
% convert to 1D to use in c_ext
ll_ext_1d = ll_ext(:)';
ll_ext_1d_size = size(ll_ext_1d);

c_ext = c_wi;
s_ext = s_wi;

for id = 1:ll_ext_1d_size(2) % insert result's LL
    c_ext(id) = ll_ext_1d(id);
end

c_ext_size = size(c_ext);
for id = ll_ext_1d_size(2)+1:c_ext_size(2) % insert result's LL
    c_ext(id) = 0;
end

% idwt on the result array
ext = waverec2(c_ext, s_ext, fam);
ext = uint8(ext);

% since watermark was resized in previous step,
% we need to resize it again to calculate mse
[x,y,z] = size(ext);
ext_size = [x, y];
wm_resized = imresize(wm, ext_size);

% compare extracted and original wm
% calculate mse/psnr
mse  = immse(wm_resized, ext);
psnr = psnr(wm_resized, ext);

% show results
figure
subplot(1,2,1);
imshow(wm_resized); title("Original Watermark"); axis square;
subplot(1,2,2);
imshow(ext); colormap(gray); axis square;
msg = strcat("MSE: ", num2str(mse), " | PSNR: ", num2str(psnr));
title({"Extracted Watermark";msg});

% save image locally
imwrite(ext, 'extracted_watermark.png');

