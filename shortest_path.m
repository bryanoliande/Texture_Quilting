function [path] = shortest_path(costs)

%
% given a 2D array of costs, compute the minimum cost vertical path
% from top to bottom which, at each step, either goes straight or
% one pixel to the left or right.
%
% costs:  a HxW array of costs
%
% path: a Hx1 vector containing the indices (values in 1...W) for 
%       each step along the path

[row_size, col_size] = size(costs);

%M_i,j = cumulative minimum energy at position (i,j)
%need to create 2 new columns at beginning and end for loop conditions to
%work. Because we call min() below the 2 columns of the maximum integer
%value do not affect our output
M = padarray(costs, [0 1], intmax, 'both');

backtrack = zeros(row_size, col_size);

%Scan every row in the image i=2 to i=M-1 updating with local best choice
%M_i,j =  e_i,j + min(M_i-1,j-1, M_i-1,j, M_i-1,j+1) 
for  i = 2:row_size
    for j = 2:col_size+1
        %                   diagonal        above          diagonal
        [e, argmin] = min([M(i - 1, j - 1), M(i - 1, j), M(i - 1, j + 1)]);
        M(i, j) = e + M(i, j);
        backtrack(i, j - 1) = (j + argmin - 3); %-3 b/c of padding
    end
end

%From piazza:
%"In the end, the minimum value of the last row in E will indicate 
%the end of the minimal vertical path though the surface and one can 
%trace back and find the path of the best cut."

[~, min_index] = min( M(row_size, :) );
min_index = min_index - 1; %for padding

% create the Hx1 column vector output
path = zeros(row_size, 1);

% do backtracking
for i = row_size:-1:1
    path(i) = min_index;
    min_index = backtrack(i, min_index);
end
