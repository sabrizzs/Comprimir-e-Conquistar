function calculateError(originalImg, decompressedImg)
  originalImg = imread(originalImg);
  decompressedImg = imread(decompressedImg);
  origR = double(originalImg(:, :, 1)); origG = double(originalImg(:, :, 2)); origB = double(originalImg(:, :, 3));
  decR = double(decompressedImg(:, :, 1)); decG = double(decompressedImg(:, :, 2)); decB = double(decompressedImg(:, :, 3));

  errR = (norm(origR-decR))/(norm(origR));
  errG = (norm(origG-decG))/(norm(origG));
  errB = (norm(origB-decB))/(norm(origB));
  
  disp((errR + errG + errB)/3);
endfunction
