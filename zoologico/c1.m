function c1()
  p = 500;
  A = ones(p, p, 3);

  for x=1 : p
    for y=1 : p
      A(x, y, 1) = floor( (256*x)/280 );
      A(x, y, 2) = floor( (256*y)/280 );
      A(x, y, 3) = floor( (256*x)/280 );
    endfor
  endfor

  imwrite(uint8(A), "c1.png", 'Quality', 100);
endfunction
