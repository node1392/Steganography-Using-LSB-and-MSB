function psnrValue = PSNR(im1, im2)
  [p1, p2] = size(im1);
  top = p1 * p2;
  bottom  = sum(sum((im2 - im1).^2)) / top;
  psnrValue = 10*log10(255^2/bottom);