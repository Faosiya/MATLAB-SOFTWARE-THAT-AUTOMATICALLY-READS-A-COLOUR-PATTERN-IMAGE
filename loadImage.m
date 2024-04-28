
% Loads an image from the file specified by filename, and returns it as type double.
function image = loadImage(filename)

% Read in the image using imread
img = imread(filename);

% Convert the image to double precision
image = im2double(img);

end
