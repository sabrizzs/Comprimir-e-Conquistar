function colorido()
  p = 500;
  A = ones(p, p, 3);

  for x=1 : p
    for y=1 : p
      A(x, y, 1) = floor( (256/x+y) );
      A(x, y, 2) = floor( (256/y*x) );
      A(x, y, 3) = floor( (256/x+y) );
    endfor
  endfor

  imwrite(uint8(A), "colorido.png", 'Quality', 100);
endfunction
