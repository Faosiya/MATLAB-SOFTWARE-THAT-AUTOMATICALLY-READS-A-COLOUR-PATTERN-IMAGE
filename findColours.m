function colours = findColours(image)
    % Erode the image to remove noise
    image = imerode(image, ones(5));
    
    % Apply median filtering to suppress noise
    image = medfilt3(image, [11 11 1]);
    
    % Increase contrast of the image
    image = imadjust(image, stretchlim(image, 0.05));
    
    % Threshold the image to create a mask
    imageMask = rgb2gray(image) > 0.08;
    
    % Remove small positive specks
    imageMask = bwareaopen(imageMask, 100);
    
    % Remove small negative specks
    imageMask = ~bwareaopen(~imageMask, 100);
    
    % Remove outer white region
    imageMask = imclearborder(imageMask);
    
    % Erode to exclude edge effects
    imageMask = imerode(imageMask, ones(10));
    
    % Segment the image
    [L, N] = bwlabel(imageMask);
    
    % Calculate average color in each image mask region
    maskColors = zeros(N, 3);
    for p = 1:N
        imgmask = L == p;
        mask = image(imgmask(:,:,[1 1 1]));
        maskColors(p,:) = mean(reshape(mask,[],3), 1);
    end
    
    % Snap the centroids to a grid
    Stats = regionprops(imageMask, 'centroid');
    Centroids = vertcat(Stats.Centroid);
    centroidLimits = [min(Centroids, [], 1); max(Centroids, [], 1)];
    Centroids = round((Centroids - centroidLimits(1,:))./range(centroidLimits, 1) * 3 + 1);
    
    % Reorder color samples
    index = sub2ind([4 4], Centroids(:,2), Centroids(:,1));
    maskColors(index,:) = maskColors;
    
    % Specify color names and their references
    colorNames = {'white', 'red', 'green', 'blue', 'yellow'};
    colorReferences = [1 1 1; 1 0 0; 0 1 0; 0 0 1; 1 1 0];
    
    % Find color distances in RGB
    distance = maskColors - permute(colorReferences, [3 2 1]);
    distance = squeeze(sum(distance.^2, 2));
    
    % Find index of closest match for each patch
    [~, index] = min(distance, [], 2);
    
    % Look up color names and return a matrix of color names
    colours = reshape(colorNames(index), 4, 4);
end
