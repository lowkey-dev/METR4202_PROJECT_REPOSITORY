%% Top level function
%% Takes the two selected pixel points, and sends them to WorldCoords individually

function realDistance = getRealDistance(pixelCoords1, pixelCoords2, depthIm)

% Capture the image
% [colorIm, depthIm] = captureJpeg;
% 
% % may need to swap these around??
% imshow(colorIm);    
% [x, y] = ginput(2); %Take two point clicks as inputs
% % [x, y] = ginput(1);
% pixelCoords1(2) = round(x(1));
% pixelCoords1(1) = round(y(1));
% pixelCoords2(2) = round(x(2));
% pixelCoords2(1) = round(y(2));

%% not yet calibrated for real distance, only camera perception
coords1 = (getWorldCoords(pixelCoords1, depthIm));
coords2 = (getWorldCoords(pixelCoords2, depthIm));
realDistance = distance2(coords1, coords2);

end