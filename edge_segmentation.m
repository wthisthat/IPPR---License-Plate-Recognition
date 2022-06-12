function edgeImg = edge_segmentation(img)
% function for filter plate candidates using edge
    % convert to gray
    grayImg = rgb2gray(img);
    % gaussian blur to remove noise
    gaussBlur = imgaussfilt(grayImg, 1.5);
    % edge
    edgeImg = edge(gaussBlur);
end