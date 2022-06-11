function compress(originalImg, k)
  originalImg = imread(originalImg);
  [p, colunas, rgb] = size(originalImg) # tamanho da imagem
  n = floor((p+k)/(1+k)) # tamanho nxn (arredonda o n)
  img = zeros(n, n, 3);
  for x = 1: n;
     for y = 1: n;
       img(x, y, :) = originalImg((x-1)*(k+1)+1, (y-1)*(k+1)+1, :);
     endfor
  endfor
  imwrite (uint8(img), "compressed.png", "Compression", "none"); # cria imagem comprimida
endfunction
   
