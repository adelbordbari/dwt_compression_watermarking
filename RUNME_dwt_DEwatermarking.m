A = 'disco.jpg';
B = 'circle.png';
C = 'watermarked.png';

wv = 'haar';

host=imread(A);
[m n p]=size(host);
[host_LL,host_LH,host_HL,host_HH]=dwt2(host,wv);

water_mark=imread(B);
water_mark=imresize(water_mark,[m n]);
[water_mark_LL,water_mark_LH,water_mark_HL,water_mark_HH]=dwt2(water_mark,wv);

wm=imread(C);
[wm_LL,wm_LH,wm_HL,wm_HH]=dwt2(wm,wv);
extracted_watermark= (wm_LL-host_LL)/0.03;
ext=idwt2(extracted_watermark,water_mark_LH,water_mark_HL,water_mark_HH,wv);

figure
imshow(uint8(ext));
title('Extracted watermark');
