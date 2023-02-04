# dwt_compression
image compression using multi-level DWT
AND
image watermarking/dewatermarking using 1-L DWT with customizable coefficients

# Compression
__RUNME_dwt_compression.m__ uses `wavedec2` and `waverec2` to apply 2D multilevel DWT on matlab default images (`woman`, `sculpture`, `mask`, etc.)
calculates and show MSE & PSNR on top of compressed image figure

# Watermarking
watermarking is done on disco.jpg
__RUNME_dwt_watermarking.m__ creates a new image: __watermarked.png__

## No-DWT Compression
__RUNME_no_dwt_watermark_tiled.m__ uses bitplanes to insert the watermark
no DWT is used
tiles the watermark (if smaller than base image)
adds gauusian noise to watermarked image for even better watermark hiding
shows extracted watermark + inversed to see better (it's easier sometimes!)


# Dewatermarking
__RUNME_dwt_DEwatermarking.m__ uses the result from watermarking and extracts the watermark. only shows, does not save.
though can be saved from matlab gui

---
`.pdf` file includes all the explanations and some test cases, future works (don't hesitate to fork!) and references.
this is the final project for _FUM 01-1 A-DIP_ course.
