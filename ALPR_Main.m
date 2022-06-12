clear;clc;
% load image
img= uigetfile("*.jpg");
carPlate = replace(img,'.jpg','');
img = imread("car_images\"+img);

% initialize the folders and paths
cropFolder = "car_plates";
resultFolder = "recognition_results/"+carPlate;
cropPath=cropFolder+"/"+carPlate+".jpg";
resultCharPath=resultFolder+"/"+carPlate+"_char.jpg";
resultFullPath=resultFolder+"/"+carPlate+"_full.jpg";
resultGcloudPath=resultFolder+"/"+carPlate+"_gcloud.jpg";

% folder creation
if ~exist(cropFolder, 'dir') % cropped plate
    mkdir(cropFolder)
end
if ~exist(resultFolder, 'dir') % recognition result
    mkdir(resultFolder)
end

r = height(img);
c = length(img);
hsv_img = rgb2hsv(img);
% HSV color space declaration for yellow, blue, black, and white
yellow_HSV = [0.09,0.2,0.355,1,0.3,1];
blue_HSV = [0.48, 0.743, 0.297, 1, 0.492, 1];
black_HSV = [0, 1, 0, 0.8, 0, 0.4];
white_HSV = [0, 1, 0, 1, 0.6, 1];

% HSV model declaration (character color + plate color)
hsv_pairs = [[black_HSV,yellow_HSV];[white_HSV,blue_HSV];[white_HSV,black_HSV];[white_HSV,black_HSV]];
pairs_name = ["black" "yellow";"white" "blue";"white" "black";"black" "white"]; %combination of word, plate
% declaration to check if recognition result is returned later on
result_char = false;

% loop through the HSV model
for pair = 1:height(hsv_pairs)
    % show current model & assign the hsv threshold for word and plate
    current = pairs_name(pair,:);
    disp("Current model: Word("+current(1)+")  Plate("+current(2)+")");
    word_color = hsv_pairs(pair,1:6);
    plate_color = hsv_pairs(pair,7:12);

    % yellow plate
    if(current(2)=="yellow")
        % function for segment plate using only one (yellow) hsv
        [no_candidate,finalBB] = single_hsv_plate_segmentation(img,r,c,hsv_img,plate_color,cropPath);
    % others
    else 
        % function for filter plate candidates using two hsv (word, plate)
        [word_seg,plate_seg] = double_hsv_segmentation(r,c,word_color,plate_color,hsv_img);
        % function for filter plate candidates using edge
        edgeImg = edge_segmentation(img);
        % combine three plate candidate images to filter the intersection
        final_seg = zeros(r,c);
        for i = 1:r
            for j = 1:c
                final_seg(i,j,:) = (word_seg(i,j) && plate_seg(i,j) && edgeImg(i,j));
            end
        end
%         figure,
%         subplot(3,2,[1 2]);imshow(img);title('Car image')
%         subplot(323);imshow(word_seg);title('Word HSV mask')
%         subplot(324);imshow(plate_seg);title('Plate HSV mask')
%         subplot(325);imshow(edgeImg);title('Edge mask')
%         subplot(326);imshow(final_seg);title('Intersection mask')
        % check if the combined mask image is completely black
        black_hist = sum(final_seg(:,:)==1);
        if(sum(black_hist)~=0)
            % function for identify the plate candidate using the combined mask image
            [no_candidate,finalBB] = combined_plate_segmentation(img,final_seg,cropPath);
        end
    end
    
    

    % check if there is a found plate candidate
    if (~no_candidate)
        % character-based recognition (using segmented characters)
        [Iocr_char,result_char,predicted_char] = char_recognition(img,finalBB,cropPath,current);
        % whole plate recognition (using the whole plate)
        [Iocr_full,predicted_full] = full_recognition(img,finalBB,cropPath,current);
    end

    % check if character based recognition has result
    if (result_char)
        % try to run google cloud vision python script and obtain the
        % character recognition result
        try
            pyrunfile("gcloud_vision.py "+carPlate);
            % read the temporary result txt file wrote by python script and
            % store the output as variable
            readtxt = importdata('gcloud_vision_result.txt');
            predicted_gcloud = cell2mat(readtxt(1));
            % draw roi on original image
            Iocr_gcloud = insertObjectAnnotation(img, 'rectangle', finalBB, predicted_gcloud, ...
                        'Color','blue','LineWidth',3,'FontSize',72,'TextColor','white');
            % save the original image with result annonation
            imwrite(Iocr_gcloud,resultGcloudPath,"jpg");
        catch
            disp("Sorry, Python Integration Failed!")
            disp("BASE_DIR variable in gcloud_vision.py incorrect!")
        end

        % save the original image with result annonation
        imwrite(Iocr_char,resultCharPath,"jpg");
        imwrite(Iocr_full,resultFullPath,"jpg");

        % try to plot the images with result annotation
        try
            figure,
            subplot(221);imshow(Iocr_full);title('Full Plate Recognition');
            subplot(222);imshow(Iocr_char);title('Character-Based Plate Recognition');
            subplot(2,2,[3 4]);imshow(Iocr_gcloud);title('Google Vision Plate Recognition');
            predicted_gcloud
        catch
            figure,
            subplot(121);imshow(Iocr_full);title('Full Plate Recognition');
            subplot(122);imshow(Iocr_char);title('Character-Based Plate Recognition');
        end
        predicted_char
        predicted_full
        break
    end
end