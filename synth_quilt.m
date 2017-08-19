function output = synth_quilt(tindex,tile_vec,tilesize,overlap)
%
% synthesize an output image given a set of tile indices
% where the tiles overlap, stitch the images together
% by finding an optimal seam between them
%
%  tindex : array containing the tile indices to use
%  tile_vec : array containing the tiles
%  tilesize : the size of the tiles  (should be sqrt of the size of the tile vectors)
%  overlap : overlap amount between tiles
%
%  output : the output image

if (tilesize ~= sqrt(size(tile_vec,1)))
  error('tilesize does not match the size of vectors in tile_vec');
end

% each tile contributes this much to the final output image width 
% except for the last tile in a row/column which isn't overlapped 
% by additional tiles
tilewidth = tilesize-overlap;  

% compute size of output image based on the size of the tile map
outputsize = size(tindex)*tilewidth+overlap;
output = zeros(outputsize(1),outputsize(2));
row_images = zeros( outputsize(1), outputsize(2) );

%First, for each row of tiles, construct a row image by repeatedly 
%stitching the next tile in the row on to the right side of your row 
%image. 
for i = 1:size(tindex, 1)
  for j = 1:(size(tindex, 2) - 1)
     ioffset = ((i-1) * tilesize);
     joffset = ((j) * tilewidth); 
     if(j == 1)   
        %grab the selected tile, do not take overlap into account
        left_tile_image = tile_vec(:, tindex(i, j) );
        %reshape it from a vector to a square
        left_tile_image = reshape(left_tile_image, tilesize, tilesize);
     else
        %take into account overlap
        left_tile_image = row_images( (1:tilesize) + ioffset, (1:joffset + overlap));

     end
     
     %grab the selected tile
     right_tile_image = tile_vec(:, tindex(i, j+1) );
     %reshape it from a vector to a square
     right_tile_image = reshape(right_tile_image, tilesize, tilesize);
     
     %stitch L and R to get image of size H x (W1+W2-overlap)
     stitched_tile_image = stitch(left_tile_image, right_tile_image, overlap);
     [rows cols] = size(stitched_tile_image);
     
     %Saving the row image
     row_images( (1:tilesize) + ioffset, (1:cols)) = stitched_tile_image;    

  end
end

%Once you have row images for all the rows, you can stitch them 
%together to get the final image. Since your stitch function only 
%works for vertical seams, you will want to transpose the rows, 
%stitch them together, and then transpose the result.
output = output';
column_images = row_images';

for i = 1:(size(tindex, 1) - 1)

 ioffset = ((i) * tilesize);

 %grab the selected tile
 if(i == 1) %do not have to take into account overlap
      left_tile_image = column_images(:, 1:ioffset);
 else
      %take away overlap from previous tile
      left_tile_image = output(:, 1:((ioffset) - ((i-1) * overlap)) );
 end
 
 right_tile_image = column_images(:, (ioffset):(tilesize * (i+1)) );
 
 %stitch L and R to get image of size H x (W1+W2-overlap)
 stitched_tile_image = stitch(left_tile_image, right_tile_image, overlap);
 [rows cols] = size(stitched_tile_image);

 %paste it down into the output image
 output(1:rows, 1:cols) = stitched_tile_image;
end

%transpose the result
output = output';