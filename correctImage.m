function correctedImage = correctImage(filename)
    % Load the original image
    orgImage = loadImage(filename);
    
    % Convert the image to grayscale
    grayImage = rgb2gray(orgImage);
    
    % Apply Gaussian blur for noise reduction
    blurredImage = imgaussfilt(grayImage, 2);  % Adjust the standard deviation as needed
    
    % Convert the grayscale image to black and white
    BWimage = ~imbinarize(blurredImage, 0.5);  % Invert binary image

    % Fill any holes in the image
    BandWfill = imfill(BWimage, 'holes');
    
    % Apply a median filter (if necessary)
    if ismatrix(BandWfill)  % Check if the image is 2D
        medianFilt = medfilt2(BandWfill);
    else
        error('Input image is not two-dimensional.');
    end
    
    % Find connected components in the image
    connectedComps = bwconncomp(medianFilt);
    
    % Get statistics of the image (area, centroid)
    stats = regionprops(medianFilt, 'Area', 'Centroid');
    
    % Identify circles based on area (smaller than the largest circle)
    Areas = [stats.Area];
    Circles = false(connectedComps.ImageSize);
    for p = 1:connectedComps.NumObjects 
        if stats(p).Area < max(Areas)
            Circles(connectedComps.PixelIdxList{p}) = true; 
        end
    end
    
    % Label the circles
    circlesLabeled = bwlabel(Circles, 8);
    
    % Get stats of the circles
    circlesProps = regionprops(circlesLabeled, 'Area', 'Centroid');
    circlesCentroids = [circlesProps.Centroid];
    
    % Set reference points for transformation
    varyingPoints = reshape(circlesCentroids, 2, []);
    MovingPointsT = transpose(varyingPoints);
    
    % Set fixed points as centroids of org_1.png
    staticPoints = flip(findCircles1(loadImage('org_1.png')));
    
    % Apply the transformation
    transformation = fitgeotrans(MovingPointsT, staticPoints, 'Projective');
    
    % Reference the size of org_1.png
    Reference = imref2d(size(loadImage('org_1.png')));
    
    % Determine pixel values for output image by mapping locations of the output to the input image
    correctedImage = imwarp(orgImage, transformation, 'OutputView', Reference);
    
    % If no circles are detected, correct the image using correctImage function
    if isempty(circlesCentroids)
        disp('Circle not detected');
        
        % Check if the file name contains "proj_" or "rot_"
        if contains(filename, 'proj_') || contains(filename, 'rot_')
            % Call correctImage function with the filename
            correctedImage = correctImage(filename);
            
            % Check if correctedImage is not empty
            if ~isempty(correctedImage)
                % Display the corrected image
                subplot(1, 3, 2);
                imshow(correctedImage);
                title(['Corrected Image: ', filename]);
            else
                disp('Corrected image is empty.');
            end
        end
    end
end
