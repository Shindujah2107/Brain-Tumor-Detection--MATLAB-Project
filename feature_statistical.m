function [F]=feature_statistical(im)
global area  numWhitePixels perimeter1  tumor x y    labeledImage centroid numberOfPixels2 perimeter numberOfPixels1
numWhitePixels = sum(tumor(:))
labeledImage = bwlabel(tumor);
measurements = regionprops(tumor,  ...
    'area', 'Centroid', 'Perimeter');
area = measurements.Area
centroid = measurements.Centroid
perimeter = measurements.Perimeter

numberOfPixels1 = sum(tumor(:));

numberOfPixels2 = bwarea(tumor);
area=sqrt(numberOfPixels2);
area=area*0.26458333;
% Get coordinates of the boundary of the tumor region.
structBoundaries = bwboundaries(tumor);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.
perimeter1=perimeter*0.26458333;

F=[numberOfPixels1 numberOfPixels2 area perimeter perimeter1 centroid(1) centroid(2)];

   
   
   