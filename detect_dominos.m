%LAB2init;
close all
%initalize_system;
%captureJpeg('workspace.jpg', colorVid, depthVid);
%stop([colorVid depthVid]);

%image = imread('SIFT_TEST/cluttered.jpeg');
[frame, depthIm, time, meta] = capture_frame(colorVid, depthVid);
%imwrite(frame, 'workspace.jpg');

%[boxPolygon, centroid] = find_fiducial(frame, depthIm);
%[domino, dominoBoxDimensions, dominoMatch, dominoPose] = edge_detection(frame, depthIm,...
%            model, referenceLibrary, compositeLibrary, dice, centroid);
