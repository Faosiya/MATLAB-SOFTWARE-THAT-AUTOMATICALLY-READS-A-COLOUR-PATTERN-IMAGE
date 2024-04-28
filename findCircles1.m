function [centers, radii] = findCircles1(image)
    % Detect and find the circles with their centers and radii.
    [centers, radii] = imfindcircles(image, [20 25], 'ObjectPolarity', 'dark', 'Sensitivity', 0.92, 'Method', 'twostage');

    % Draw the circles' boundaries on the image.
    viscircles(centers, radii);
    
    % Display the detected circle coordinates
    disp('Detected circle coordinates:');
    disp([centers, radii]);
end
