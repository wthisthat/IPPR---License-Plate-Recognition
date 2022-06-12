function [no_candidate,finalBB] = single_hsv_plate_segmentation(img,r,c,hsv_img,plate_color,cropPath)
% function for segment plate using only 
% one (yellow) hsv
h_image = hsv_img(:,:,1);
s_image = hsv_img(:,:,2);
v_image = hsv_img(:,:,3);

% mask the plate candidate image using hsv thresholding
plate_seg = zeros(r,c);
for i = 1:r
    for j = 1:c
        h = h_image(i,j);
        s = s_image(i,j);
        v = v_image(i,j);
        plate_seg(i,j,:)=((h>=plate_color(1,1) && h<=plate_color(1,2)) && ...
                (s>=plate_color(1,3) && s<=plate_color(1,4)) && (v>=plate_color(1,5) && v<=plate_color(1,6)));
    end
end

% to logical (binary)
plate_seg = imbinarize(plate_seg);
% figure,imshow(plate_seg);title('masked')

% outer 15%
x_15f = round(c*0.15); %left
y_15f = round(r*0.15); %top
x_85f = c-round(c*0.15); %right
y_85f = r-round(r*0.15); %bottom

% find all blob and loop for filtering
props = regionprops(plate_seg, 'BoundingBox');
finalBB='';
flag = false;

% check if whole image black
black_hist = sum(plate_seg(:,:)==1);
if(sum(black_hist)~=0)
    for n = 1 : length(props)
        bounding_box = props(n).BoundingBox;
        x = bounding_box(1);
        y = bounding_box(2);
        w = bounding_box(3);
        h = bounding_box(4);
        % check blob if match the condition, crop if matched
        if (~(x<x_15f || x+w>x_85f || y<y_15f || y+h>y_85f) && ... %outer region 10%
                (w/h >= 2 && w/h <= 5.5 && w*h >=2500))   %aspect ratio and area
            finalBB = bounding_box;
            cropped = imcrop(img,finalBB);
            flag = true;
        end
    end
end

% check if candidate exists
if(flag)
    % save the cropped car plate image
    no_candidate = false;
    imwrite(cropped,cropPath,"jpg");
%     figure,
%     subplot(121);imshow(plate_seg);title('HSV masked')
%     subplot(122);imshow(cropped);title('Cropped License Plate')
else
    no_candidate = true;
end
end