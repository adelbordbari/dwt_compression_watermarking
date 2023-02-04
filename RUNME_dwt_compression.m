load woman; %sculpture woman mask
n = 5;
w = 'db3';

[cr,bpp] = wcompress('c',X,'mask.wtc','lvl_mmc','wname',w,'level',n);

% 'c' compress, 'u' uncompress
% gbl_mmc_f , gbl_mmc_h: for global
% wcompress('c', x, cname, compmthd, level, it)
% it: image type transform

% compmthd:
%'ezw'  Embedded Zerotree Wavelet
%'spiht'    Set Partitioning In Hierarchical Trees
%'stw'	Spatial-orientation Tree Wavelet
%'wdr'	Wavelet Difference Reduction
%'aswdr'	Adaptively Scanned Wavelet Difference Reduction
%'spiht_3d'	Set Partitioning In Hierarchical Trees 3D for truecolor images
%'lvl_mmc'	Subband thresholding of coefficients and Huffman encoding
%'gbl_mmc_f'	Global thresholding of coefficients and fixed encoding
%'gbl_mmc_h'	Global thresholding of coefficients and Huffman encoding

% wname:
%Haar                     		haar    
%Daubechies               		db      
%more: https://www.mathworks.com/help/wavelet/ref/waveletfamilies.html 

Xc = wcompress('u','mask.wtc');
delete('mask.wtc')

X = double(X);
D = abs(X-Xc).^2;
mse  = sum(D(:))/numel(X);
psnr = 10*log10(255*255/mse);

figure
image(Xc);
title(strcat(num2str(cr),'|',num2str(mse),'|',num2str(psnr)));
colormap(map);

figure
image(X);
title("Org");
colormap(map);