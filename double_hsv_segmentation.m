function [word_seg,plate_seg] = double_hsv_segmentation(r,c,word_color,plate_color,hsv_img)
% function for filter plate candidates using 
% two hsv (word, plate)
h_image = hsv_img(:,:,1);
s_image = hsv_img(:,:,2);
v_image = hsv_img(:,:,3);

% mask the word and plate candidate image using hsv thresholding
word_seg = zeros(r,c);
plate_seg = zeros(r,c);
for i = 1:r
    for j = 1:c
        h = h_image(i,j);
        s = s_image(i,j);
        v = v_image(i,j);
        word_seg(i,j,:)=((h>=word_color(1,1) && h<=word_color(1,2)) && ...
                (s>=word_color(1,3) && s<=word_color(1,4)) && (v>=word_color(1,5) && v<=word_color(1,6)));
        plate_seg(i,j,:)=((h>=plate_color(1,1) && h<=plate_color(1,2)) && ...
                (s>=plate_color(1,3) && s<=plate_color(1,4)) && (v>=plate_color(1,5) && v<=plate_color(1,6)));
    end
end
% figure, imshow(word_seg), title('Word Color Extracting');
% figure, imshow(plate_seg), title('Plate Color Extracting');

% Morphological Operations
% close 5
se = strel("disk",5);
word_seg = imclose(word_seg, se);
plate_seg = imclose(plate_seg, se);
% figure,
% subplot(221),imshow(word_seg), title('word_seg');
% subplot(222),imshow(plate_seg), title('plate_seg');
%sgtitle('Close 1');

% open 1 
se = strel("disk",1);
word_seg = imopen(word_seg, se);
plate_seg = imopen(plate_seg, se);
% figure,
% subplot(221),imshow(word_seg), title('word_seg');
% subplot(222),imshow(plate_seg), title('plate_seg');
%sgtitle('Open 1');

% dilation 5 to find candidate region
se = strel("disk",5);
word_seg = imdilate(word_seg, se);
plate_seg = imdilate(plate_seg, se);
% figure, imshow(word_seg), title('white_dialation');
% figure, imshow(plate_seg), title('blue_dialation');
%sgtitle('Dilate 5');

end