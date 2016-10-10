function [domino, dominoBoxDimensions, dominoMatch, dominoPose] = ...
                edge_detection(currentImage, depthIm, model, referenceLibrary, compositeLibrary, dice, feducialCentroid)
%close all
%%function takes in a 1980x1020 image
%%
%%%unpack data from reference image library%%%
referenceImages = referenceLibrary{1};
%referencePoints = referenceLibrary{2};
referenceFeatures = referenceLibrary{3};

compositeImages = compositeLibrary{1};
compositeFeatures = compositeLibrary{3};
dominoString = {'0-0', '0-1', '0-2', '0-3', '0-4', '0-5', '0-6', '1-1', '1-2',...
    '1-3', '1-4', '1-5', '1-6', '2-2', '2-3', '2-4', '2-5', '2-6', '3-3', '3-4',...
    '3-5', '3-6', '4-4', '4-5', '4-6', '5-5', '5-6', '6-6'};

poseString = {'flat', 'upright', 'sideways'};


%%

%scale image down to improve processing time
resize = 0.5;
% load
%currentImage = imread('test.jpg');
%currentImage = imread('Tracking sequence 1/sequence_1.jpg');
fprintf('Detect edges from image...');

J = imresize(currentImage, resize);
K = imsharpen(J, 'Radius',3, 'Amount', 2);

F = edgesDetect(K, model); 
BW = imbinarize(F, graythresh(F));



%figure(1); im(F);
%figure(2); im(K);
%figure(3); im(BW);

%% Adds bounding box to all of the objects (rectangles) found
%%by the edge detection toolbox
%%
%{
[B,L,N,A] = bwboundaries(BW);
figure; imshow(currentImage); hold on;
for k=1:length(B),
    if(~sum(A(k,:)))
      boundary = B{k};
     plot(boundary(:,2)/resize,boundary(:,1)/resize,'r','LineWidth',2);hold on;
    end
end
%}
%%
%%Plot bouding boxes found via bwboudnaries
fprintf('Done\n');
fprintf('Filter bad candidates...');

blobMeasurements = regionprops(logical(BW), 'BoundingBox', 'MajorAxisLength', 'MinorAxisLength', 'Area');
numberOfBlobs = size(blobMeasurements, 1);

%%crop domino candidates out of original image
%%some preprocessing by filtering boxes that are too small/large
rects = [];
index = 1;
for k = 1 : numberOfBlobs % Loop through all blobs.
    rects = blobMeasurements(k).BoundingBox; % Get list ofpixels in current blob.
    x1 = rects(1)/resize;
    y1 = rects(2)/resize;
    x2 = x1 + rects(3)/resize;
    y2 = y1 + rects(4)/resize;
    width = rects(3)/resize;
    height = rects(4)/resize;
    axis_aspect_ratio = blobMeasurements(k).MinorAxisLength / blobMeasurements(k).MajorAxisLength;
    if  (axis_aspect_ratio > 0.25)  && (width* height) > 100 &&...
       (width * height) < (size(currentImage, 1) * size(currentImage, 2) * 0.1);
        x = [x1, x2, x2, x1, x1];
        y = [y1, y1, y2, y2, y1];
        dominoCanidate_box_dimensions{index} = [x1, y2, width, height];
        croppedImage = imcrop(currentImage, [x1, y1, width, height]);
        dominoCandidate{index} = croppedImage;
        dominoCandidateBox_x{index} = x;
        dominoCandidateBox_y{index} = y;
        index = index + 1;
        %plot(x, y, 'LineWidth', 2);
    end
end
%hold off

%%
%%SURF matching of candidates cropped out of original image
figure(20); imshow(currentImage);
hold on;
count = 1;
for i = 1 : size(dominoCandidate, 2)
    isDomino = 0;
    isDice = 0;
%%loop through domino candidates
    candidateGray = rgb2gray(dominoCandidate{i});
%%extract canidate features
    candidatePoints = detectSURFFeatures(candidateGray);
    [candidateFeatures, candidatePoints] = extractFeatures(...
                    candidateGray, candidatePoints);
    
%{
    if size(candidatePoints, 1) > 0
        figure; imshow(candidateGray);
        hold on;
        plot(selectStrongest(candidatePoints, 100));
        hold off;
    end
%}
    dominoCandidatePairs = [];
    index = 0; %%index of matched image in referenceImage array
    for j = 1 : size(compositeImages, 2)
%%compare candidates to reference image library  
       [dominoCandidatePairsSearch, status] = matchFeatures(...
                    compositeFeatures{j}, candidateFeatures);
       %%if a better match found update matches features array
       if size(dominoCandidatePairs) < size(dominoCandidatePairsSearch)
          dominoCandidatePairs = dominoCandidatePairsSearch;
          index = j;
          isDomino = 1;
       end
       %%check if match successful
       
    end
    
    
   [dominoCandidatePairsSearch, status] = matchFeatures(dice{2}, candidateFeatures);
   if size(dominoCandidatePairs) < size(dominoCandidatePairsSearch)
       isDomino = 0;
       isDice = 1;
       dominoCandidatePairs = dominoCandidatePairsSearch;
   end
%{
    if size(dominoCandidatePairs, 2) > 0
        matchedBoxPoints = referencePoints{index}(dominoCandidatePairs(:, 1), :);
        matchedScenePoints = candidatePoints(dominoCandidatePairs(:, 2), :);
        figure;
        showMatchedFeatures(referenceImages{index}, dominoCandidate{i}, matchedBoxPoints, ...
        matchedScenePoints, 'montage');
        title('Putatively Matched Points (Including Outliers)');
    end
%}
    
    if size(dominoCandidatePairs, 2) > 1 && isDomino
        plot(dominoCandidateBox_x{i}, dominoCandidateBox_y{i}, 'LineWidth', 2, 'Color', 'g');
        strmax = ['Domino = ', dominoString{index}];
        text(dominoCanidate_box_dimensions{i}(1), dominoCanidate_box_dimensions{i}(2),strmax,'HorizontalAlignment','left', ...
            'FontSize', 8);
        drawnow;
        domino{count} = dominoCandidate{i};
        dominoBoxDimensions{count} = dominoCanidate_box_dimensions{i};
        %dominoMatch{count} = compositeImages{index};
        [match, pose] = identify_domino(candidateFeatures, ...
                                            index, referenceImages, referenceFeatures);
        dominoMatch{count} = match;
        dominoPose{count} = pose;
        fprintf('Domino %g detected at x: %g y: %g\n', count, dominoBoxDimensions{count}(1)...
            + dominoBoxDimensions{count}(3)/2, dominoBoxDimensions{count}(2) - dominoBoxDimensions{count}(4)/2);
        fprintf('Domino is %s; pose is %s\n', dominoString{index}, poseString{pose});
        distance = getRealDistance([round(feducialCentroid(2)), round(feducialCentroid(1))], ...
                    [round(dominoBoxDimensions{count}(2)), round(dominoBoxDimensions{count}(1))], depthIm);
        fprintf('Distance to domino %s from origin: %g\n', dominoString{index}, distance);
        count = count + 1;
    end
    
    if isDice
        plot(dominoCandidateBox_x{i}, dominoCandidateBox_y{i}, 'LineWidth', 2, 'Color', 'r');
    end
end
fprintf('Done\n');


end
