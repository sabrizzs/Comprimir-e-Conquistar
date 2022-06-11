function decompress(compressedImg, method, k, h)
  #coloca linhas na imagem
  compressedImg = imread(compressedImg);
  [n, colunas, rgb] = size(compressedImg);
  p = n+(n-1)*k;
  img = zeros(p, p, 3);
  img = img - 1; #arruma os 0 pra n ter conflito
  for x = 1: n;
     for y = 1: n;
       img((x-1)*(k+1)+1, (y-1)*(k+1)+1, :) = compressedImg(x,y,:);
     endfor
  endfor

  #bilinear
  if(method == "bilinear")
    H = [1,0,0,0; 1,0,h,0; 1,h,0,0; 1,h,h,h^2];
    for x = 1: k+1 : p-1;     #passa por todos os pontos
      for y = 1: k+1 : p-1;
        F = zeros(4,1,3);     #inicializa matriz de f
        F(1,:) = img(x,y,:); F(2,:) = img(x,y+k+1,:); F(3,:) = img(x+k+1,y,:); F(4,:) = img(x+k+1,y+k+1,:);
        A = H\F;
        for j = x : x+k+1;    #passa pelos pontos vazios
          for i = y : y+k+1;
            if(img(j,i) == -1);
              img(j,i,1) = A(1) + A(2)*(j-x) + A(3)*(i-y) + A(4)*(j-x)*(i-y);
              img(j,i,2) = A(5) + A(6)*(j-x) + A(7)*(i-y) + A(8)*(j-x)*(i-y);
              img(j,i,3) = A(9) + A(10)*(j-x) + A(11)*(i-y) + A(12)*(j-x)*(i-y);
            endif
          endfor
        endfor
      endfor
    endfor

  #bicubica
  else
    H = [1,0,0,0;1,h,h^2,h^3,;0,1,0,0;0,1,2*h,3*h^2];
    HT = transpose(H);          #matriz transposta de H
    HT = inv(HT);               #inverte matriz HT
    H = inv(H);                 #inverte matriz H
    #H = H*HT;                  #multiplicação da H com HT para o sistema

    for x = 1: k+1 : p-1;     #passa por todos os pontos
      for y = 1: k+1 : p-1;
        F = zeros(4,4,3);     #inicializa matriz de f

        #precisamos calcular as derivadas abaixo:

        #derivada primeira dx - > dx(x,y) = (f(x+1,y) - f(x-1,y))/2h
        #dx(x,y)
        dx1 = dx(img, x, y, h, k, p);
        #dx(x,y+1)
        dx2 = dx(img, x, y+k+1, h, k, p);
        #dx(x+1,y)
        dx3 = dx(img, x+k+1, y, h, k, p);
        #dx(x+1,y+1)
        dx4 = dx(img, x+k+1, y+k+1, h, k, p);

        #derivada primeira dy -> dy(x,y) = (f(x,y+1) - f(x,y-1))/2h
        #dy(x,y)
        dy1 = dy(img, x, y, h, k, p);
        #dy(x,y+1)
        dy2 = dy(img, x, y+k+1, h, k, p);
        #dy(x+1,y)
        dy3 = dy(img, x+k+1, y, h, k, p);
        #dy(x+1,y+1)
        dy4 = dy(img, x+k+1, y+k+1, h, k, p);

        #derivada mista dxdy - > dxdy(x,y) = (dx(x+1,y) - dx(x-1,y))/2h
        #dxdy(x,y)
        dxdy1 = dxdy(img, x, y, h, k, p);
        #dxdy(x,y+1)
        dxdy2 = dxdy(img, x, y+k+1, h, k, p);
        #dxdy(x+1,y)
        dxdy3 = dxdy(img, x+k+1, y, h, k, p);
        #dxdy(x+1,y+1)
        dxdy4 = dxdy(img, x+k+1, y+k+1, h, k, p);


        #adiciona os f's em F
        F(1,1,:) = img(x,y,:); F(1,2,:) = img(x,y+k+1,:); F(2,1,:) = img(x+k+1,y,:); F(2,2,:) = img(x+k+1,y+k+1,:);
        #adiciona os dy's em F
        F(1,3,:) = dy1; F(1,4,:) = dy2; F(2,3,:) = dy3; F(2,4,:) = dy4;
        #adiciona os dx's em F
        F(3,1,:) = dx1; F(3,2,:) = dx2; F(4,1,:) = dx3; F(4,2,:) = dx4;
        #adiciona os dxdy's em F
        F(3,3,:) = dxdy1; F(3,4,:) = dxdy2; F(4,3,:) = dxdy3; F(4,4,:) = dxdy4;

        #sistema:

        #resolvendo o sitema
        A1 = H * F(:,:,1) * HT;
        A2 = H * F(:,:,2) * HT;
        A3 = H * F(:,:,3) * HT;

        #interpolação dos pontos do quadrado
        for j = x : x+k+1;      #passa pelos pontos vazios
          for i = y : y+k+1;
            if(img(j,i) == -1); #interpola pontos sem cor

              #polinomio
              img(j,i,1) = [1,(j-x),(j-x)^2,(j-x)^3]*A1*[1; i-y; (i-y)^2; (i-y)^3];
              img(j,i,2) = [1,(j-x),(j-x)^2,(j-x)^3]*A2*[1; i-y; (i-y)^2; (i-y)^3];
              img(j,i,3) = [1,(j-x),(j-x)^2,(j-x)^3]*A3*[1; i-y; (i-y)^2; (i-y)^3];
            endif
          endfor
        endfor
      endfor
    endfor

  endif
  imwrite (uint8(img), "decompressed.png", "Compression", "none");
endfunction

#derivada primeira
function result = dx(img, x, y, h, k, p)
  if(x == 1)
    result = (img(x+k+1, y, :) - img(x, y, :))/h;
  elseif(x == p)
    result = (img(x, y, :) - img(x-k-1, y, :))/h;
  else
    result = (img(x+k+1, y, :) - img(x-k-1, y, :))/2*h;
  endif
endfunction

function result = dy(img, x, y, h, k, p)
  if(y == 1)
    result = (img(x, y+k+1, :) - img(x, y, :))/h;
  elseif(y == p)
    result = (img(x, y, :) - img(x, y-k-1, :))/h;
  else
    result = (img(x, y+k+1, :) - img(x, y-k-1, :))/2*h;
  endif
endfunction

#derivada mista
function result = dxdy(img, x, y, h, k, p)
  if(x == 1)
    result = ( dy(img, x, y, h, k, p) - dy(img, x+k+1, y, h, k, p) )/h;
  elseif(x == p)
    result = ( dy(img, x-k-1, y, h, k, p) - dy(img, x, y, h, k, p) )/h;
  else
    result = ( dy(img, x-k-1, y, h, k, p) - dy(img, x+k+1, y, h, k, p) )/2*h;
  endif
endfunction


