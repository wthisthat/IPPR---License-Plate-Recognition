function [no_candidate,finalBB] = combined_plate_segmentation(img,final_seg,cropPath)
% function for identify the plate candidate 
% using the combined mask image

plate = final_seg;
% figure, imshow(plate), title('plate');

% close 6
se = strel("disk",6);
plate = imclose(plate, se);
% figure, imshow(plate), title('plate close 6');

% dilation & erosion edge image to remove noises
% open 2
se = strel("disk",2);
plate = imopen(plate, se);
% figure, imshow(plate), title('plate open 2');

% remove noise based on area
p = 600;
plate = bwareaopen(plate,p);
% figure, imshow(plate), title('plate area open');

% close 12
se = strel("disk",12);
plate = imclose(plate, se);
% figure, imshow(plate), title('plate_close 12');

% give extra padding for plate
extra_padding = 5;
padding = [-extra_padding, -extra_padding, 2*extra_padding, 2*extra_padding];

% select the top 6 blob in terms of size
blob=bwareafilt(logical(plate), 6);
%figure,imshow(blob),title('blob')

% check if the plate candidate image is completely black
black_hist_blob = sum(blob(:,:)==1);
if(sum(black_hist_blob)~=0)
    % get bounding boxes and ordering by Area from big to small
    propsAreaBB = regionprops('table',blob,'Area','BoundingBox');
    propsAreaBB = sortrows(propsAreaBB, "Area",'descend');
    props = propsAreaBB{:,:}; % convert it to matrix
    propsArea = props(:,1);
    
    % take the a contour as a candidate, in case no candidate pass the
    % condition selection
    sizeOfProps = size(props,1);
    firstBB = props(sizeOfProps,2:5); % take the last one
    candidate_count = 0;
    pre_density = propsArea(sizeOfProps)/(firstBB(3)*firstBB(4));  % white pixel / bounding box area
    
    % padding for crop
    finalBB = firstBB + padding;
    croppedImage = imcrop(img, finalBB);  %filtering

    no_candidate = false;
    % loop through the blobs to filter out the plate candidate
    for k = sizeOfProps : -1 : 1
        thisBB = props(k,2:5);
        w=thisBB(3);
        h=thisBB(4);
        this_density = propsArea(k)/(w*h); % white pixel divided by bounding box area
        if(w/h>2.2 && w/h < 5.2 && w*h > 2000)
            candidate_count = candidate_count + 1;
            
            % tend to select high quality
            if (candidate_count > 1 && this_density > pre_density)
                thisBB = thisBB + padding;
                finalBB=thisBB;
                croppedImage = imcrop(img, finalBB);  %filtering
                pre_density = this_density;
            elseif(candidate_count == 1) % directly use the first candidate
                thisBB = thisBB + padding;
                finalBB=thisBB;
                croppedImage = imcrop(img, finalBB);  %filtering
                pre_density = this_density;
            end
        end
    end
%     figure,
%     subplot(121);imshow(blob);title('Filtered Plate Candidates')
%     subplot(122);imshow(croppedImage);title('Cropped License Plate')
    % save the cropped car plate image
    imwrite(croppedImage,cropPath,'jpg');
    
else
    no_candidate = true;
    finalBB = '';
end
