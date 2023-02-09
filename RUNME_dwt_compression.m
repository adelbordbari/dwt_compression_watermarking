clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%    COMPRESSION    %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read base image
% dwt 3/5-L on base images
% quantize coeffs (local/global)
% count zero value-ed coeffs
% calculate mse/psnr
% save and show result

% set to 1,2,3 for different images
in = 2;

fam = 'db3'; % wavelet family
lvl = 5; % wavelet depth

% set to 1 to apply global thr
thr_type = 1;

% global threshold value
gthr = 100;

% read images
if in == 1
    x = 'rail.jpg';
elseif in == 2
    x = 'disco.jpg';
else
    x = 'circ.jpg';
end

% read image
base = imread(x);

% apply dwt on base image
dc = wavedec3(base, lvl, fam);

% extract coeffs
lll_base = abs(dc.dec{1});
hll_base = abs(dc.dec{2});
lhl_base = abs(dc.dec{3});
hhl_base = abs(dc.dec{4});
llh_base = abs(dc.dec{5});
hlh_base = abs(dc.dec{6});
lhh_base = abs(dc.dec{7});
hhh_base = abs(dc.dec{8});

% find 2D standard deviation for all coeff. matrices
lll_std = stdfilt(lll_base);
hll_std = stdfilt(hll_base);
lhl_std = stdfilt(lhl_base);
hhl_std = stdfilt(hhl_base);
llh_std = stdfilt(llh_base);
hlh_std = stdfilt(hlh_base);
lhh_std = stdfilt(lhh_base);
hhh_std = stdfilt(hhh_base);

% count number of elements
lll_n = numel(lll_base);
hll_n = numel(hll_base);
lhl_n = numel(lhl_base);
hhl_n = numel(hhl_base);
llh_n = numel(llh_base);
hlh_n = numel(hlh_base);
lhh_n = numel(lhh_base);
hhh_n = numel(hhh_base);

% find local threshold
lll_t = lll_std * (sqrt(2 * log2(lll_n)));
hll_t = hll_std * (sqrt(2 * log2(hll_n)));
lhl_t = lhl_std * (sqrt(2 * log2(lhl_n)));
hhl_t = hhl_std * (sqrt(2 * log2(hhl_n)));
llh_t = llh_std * (sqrt(2 * log2(llh_n)));
hlh_t = hlh_std * (sqrt(2 * log2(hlh_n)));
lhh_t = lhh_std * (sqrt(2 * log2(lhh_n)));
hhh_t = hhh_std * (sqrt(2 * log2(hhh_n)));

% if global
if thr_type == 1
    lll_t = gthr;
    hll_t = gthr;
    lhl_t = gthr;
    hhl_t = gthr;
    llh_t = gthr;
    hlh_t = gthr;
    lhh_t = gthr;
    hhh_t = gthr;
end

% find each matrix's size
lll_size = size(lll_base);
hll_size = size(hll_base);
lhl_size = size(lhl_base);
hhl_size = size(hhl_base);
llh_size = size(llh_base);
hlh_size = size(hlh_base);
lhh_size = size(lhh_base);
hhh_size = size(hhh_base);

% count zero values in new band matrices
lll_zeros = sum(lll_base==0,'all');
hll_zeros = sum(hll_base==0,'all');
lhl_zeros = sum(lhl_base==0,'all');
hhl_zeros = sum(hhl_base==0,'all');
llh_zeros = sum(llh_base==0,'all');
hlh_zeros = sum(hlh_base==0,'all');
lhh_zeros = sum(lhh_base==0,'all');
hhh_zeros = sum(hhh_base==0,'all');

% local threshold for 2D decomposition can be
% found WITHOUT the formula, using Birge-Massart strategy
% using wdcbm2
% but we're reading colors too so, irrelevent.

% apply thresholding on bands
% if new value < thr => 0
% otherwise, keep the previous value
lll_new = lll_base .* double(lll_base > lll_t);
hll_new = hll_base .* double(hll_base > lll_t);
lhl_new = lhl_base .* double(lhl_base > lll_t);
hhl_new = hhl_base .* double(hhl_base > lll_t);
llh_new = llh_base .* double(llh_base > lll_t);
hlh_new = hlh_base .* double(hlh_base > lll_t);
lhh_new = lhh_base .* double(lhh_base > lll_t);
hhh_new = hhh_base .* double(hhh_base > lll_t);

% count number of zeros for new matrices
lll_new_zeros = sum(lll_new==0,'all');
hll_new_zeros = sum(hll_new==0,'all');
lhl_new_zeros = sum(lhl_new==0,'all');
hhl_new_zeros = sum(hhl_new==0,'all');
llh_new_zeros = sum(llh_new==0,'all');
hlh_new_zeros = sum(hlh_new==0,'all');
lhh_new_zeros = sum(lhh_new==0,'all');
hhh_new_zeros = sum(hhh_new==0,'all');

% count how many coeff. were thresholded
lll_zeros_diff = abs(lll_zeros - lll_new_zeros);
hll_zeros_diff = abs(hll_zeros - hll_new_zeros);
lhl_zeros_diff = abs(lhl_zeros - lhl_new_zeros);
hhl_zeros_diff = abs(hhl_zeros - hhl_new_zeros);
llh_zeros_diff = abs(llh_zeros - llh_new_zeros);
hlh_zeros_diff = abs(hlh_zeros - hlh_new_zeros);
lhh_zeros_diff = abs(lhh_zeros - lhh_new_zeros);
hhh_zeros_diff = abs(hhh_zeros - hhh_new_zeros);

% show coeff. matrices vs. thresholded version
figure
colormap(gray);
subplot(2,8,1); image(lll_base(:,:,1)); title('LLL');axis square;
subplot(2,8,2); image(hll_base(:,:,1)); title('HLL');axis square;
subplot(2,8,3); image(lhl_base(:,:,1)); title('LHL');axis square;
subplot(2,8,4); image(hhl_base(:,:,1)); title('HHL');axis square;
subplot(2,8,5); image(llh_base(:,:,1)); title('LLH');axis square;
subplot(2,8,6); image(hlh_base(:,:,1)); title('HLH');axis square;
subplot(2,8,7); image(lhh_base(:,:,1)); title('LHH');axis square;
subplot(2,8,8); image(hhh_base(:,:,1)); title('HHH');axis square;
subplot(2,8,9); image(lll_new(:,:,1));
title({'LLL thr';lll_zeros_diff});axis square;
subplot(2,8,10); image(hll_new(:,:,1));
title({'HLL thr';hll_zeros_diff});axis square;
subplot(2,8,11); image(lhl_new(:,:,1));
title({'LHL thr';lhl_zeros_diff});axis square;
subplot(2,8,12); image(hhl_new(:,:,1));
title({'HHL thr';hhl_zeros_diff});axis square;
subplot(2,8,13); image(llh_new(:,:,1));
title({'LLH thr';llh_zeros_diff});axis square;
subplot(2,8,14); image(hlh_new(:,:,1));
title({'HLH thr';hlh_zeros_diff});axis square;
subplot(2,8,15); image(lhh_new(:,:,1));
title({'LHH thr';lhh_zeros_diff});axis square;
subplot(2,8,16); image(hhh_new(:,:,1));
title({'HHH thr';hhh_zeros_diff});axis square;

% set new band matrices
dc.dec{1} = lll_new;
dc.dec{2} = hll_new;
dc.dec{3} = lhl_new;
dc.dec{4} = hhl_new;
dc.dec{5} = llh_new;
dc.dec{6} = hlh_new;
dc.dec{7} = lhh_new;
dc.dec{8} = hhh_new;

% idwt to reconstruct compressed image
cmp = waverec3(dc);
cmp = uint8(cmp);

% calculate mse/psnr
D = abs(cmp - base) .^2;
mse  = sum(D(:))/numel(base);
psnr = 10*log10(255*255/mse);

% calculate ratio based on number of zero-ed values
all_zeros = lll_zeros_diff + hll_zeros_diff + ...
    lhl_zeros_diff + hhl_zeros_diff + ...
    llh_zeros_diff + hlh_zeros_diff + ...
    lhh_zeros_diff + hhh_zeros_diff;
all_elements = numel(base);
cr = 100 * (all_zeros / all_elements);

% show images and metrics
figure
subplot(1,2,1);
imshow(base); axis square;
title("Original");
subplot(1,2,2);
imshow(cmp); axis square;
msg = strcat("MSE: ", num2str(mse), " | PSNR: ", num2str(psnr));
title({strcat("Ratio: %", num2str(cr));msg});

% save image locally
imwrite(cmp, 'compressed.jpg');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Easier, copy-pasted script: %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%load woman;
%fam='haar';lvl=3;
%[cr,bpp] = wcompress('c',X,'mask.wtc','lvl_mmc','wname',fam,'level',lvl);
%Xc = wcompress('u','mask.wtc');
%delete('mask.wtc');
%colormap(pink(255))
%subplot(1,2,1); image(X);  title('Original image')
%axis square
%subplot(1,2,2); image(Xc); title('Compressed image')
%axis square
%D = abs(X-Xc).^2;
%mse  = sum(D(:))/numel(X);
%psnr = 10*log10(255*255/mse);
%mse
%psnr
