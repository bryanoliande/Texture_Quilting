function [result] = stitch(leftI,rightI,overlap);

% 
% stitch together two grayscale images with a specified overlap
%
% leftI : the left image of size (W1 x H)  
% rightI : the right image of size (W2 x H)
% overlap : the width of the overlapping region.
%
% result : an image of size H x (W1+W2-overlap)
%
if (size(leftI,1)~=size(rightI,1)); % make sure the images have compatible heights
  error('left and right image heights are not compatible');
end

[H, W1] = size(leftI);
[H, W2] = size(rightI);
result = zeros(H, (W1 + W2 - overlap) );

%You will want to first extract the overlapping strips from the two 
%input images 
left_strip = leftI(:, (W1-overlap+1:end) ); %overlap+1
right_strip = rightI(:, (1:overlap) );

%Removing the overlap region from the images
leftI_chopped = leftI(:, 1:(W1-overlap) );
rightI_chopped = rightI(:, (overlap+1:end) );

%and then compute a cost array given by the absolute value
%of their difference. 
difference = abs( (right_strip - left_strip) );

%you can then use your shortest_path function to 
%find the seam along which to stitch the images where they differ the 
%least in brightness.
cost_array = shortest_path(difference);

%Finally you need to generate the output image by 
%using pixels from the left image on the left side of the seam and from 
%the right image on the right side of the seam. You may find it easiest
%to code this by first turning the path into an alpha mask for each 
%image and then using the standard equation for compositing.

alpha = ones(H, overlap);

for i = 1:H
    for j = 1:overlap
        if( j > cost_array(i) )
            alpha(i, j) = 0;
        end
    end
end

strip = alpha.*left_strip + (1-alpha).*right_strip;
result = [leftI_chopped strip rightI_chopped];

