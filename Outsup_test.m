clc;        % Clear the command window.
clearvars;  % Clear workspace variables.
workspace;  % Make sure the workspace panel is showing
%%
% Specify the directory containing the images
imageDir = '/Users/tijaniramonii/Library/CloudStorage/OneDrive-UniversityofSussex/Report_classifycolor/Report/images';
% Get a list of all image files in the directory
imageFiles = dir(fullfile(imageDir, '*.png'));

% Loop through each image file
for i = 1:numel(imageFiles)
    try
        % Load the image
        imageFilename = imageFiles(i).name;
        imagePath = fullfile(imageDir, imageFilename);
        img = loadImage(imagePath);

        % Display the original image
        figure('Name', ['Original Image - ', imageFilename]);
        subplot(1, 3, 1);
        imshow(img);
        title(['Original Image: ', imageFilename]);

        % Find colors in squares using findColours function
        colours = findColours(img);
        
        % Print the image name along with the detected colors
        disp(['Identified colors in ', imageFilename, ':']);
        disp(colours);

        % Detect circles using findCircles function
        [centers, radii] = findCircles1(img);
        
        % Display the image with detected circles
        subplot(1, 3, 2);
        imshow(img);
        title(['Image with Detected Circles: ', imageFilename]);

        % Draw the detected circles on the image
        viscircles(centers, radii);
        
        % Correct the image if circles are not detected or if filename contains "proj_" or "rot_"
        correctedImage = correctImage(imagePath);
        
        % Display the corrected image
        subplot(1, 3, 3);
        imshow(correctedImage);
        title(['Corrected Image: ', imageFilename]);
        
        % Find colors in squares on the corrected image
        correctedColours = findColours(correctedImage);
        
        % Print the image name along with the detected colors on the corrected image
        disp(['Identified colors in corrected ', imageFilename, ':']);
        disp(correctedColours);
        
    catch exception
        % Print the error message and the name of the problematic image
        disp(['Error processing image ', imageFilename, ': ', exception.message]);
        % Move to the next image
        continue;
    end
end
