function pdf()
  p = 500;
  A = ones(p, p, 3);
  k = 2.069e-3;
  fMin = 0; fMax = 1;

  for x=1 : p
    for y=1 : p
      A(x, y, 1) = floor(((sin(x * k) - fMin)/(fMax - fMin)) * 256);
      A(x, y, 2) = floor((((sin(y * k) + sin(x * k))/2 - fMin)/(fMax - fMin)) * 256);
      A(x, y, 3) = floor(((sin(x * k) - fMin)/(fMax - fMin)) * 256);
    endfor
  endfor

  imwrite(uint8(A), "pdf.png", 'Quality', 100);
endfunction
