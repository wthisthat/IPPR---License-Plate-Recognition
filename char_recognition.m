function [Iocr_char,result_char,predicted_char] = char_recognition(img,finalBB,cropPath,current)
% character-based recognition (using segmented characters)
    croppedImage=imread(cropPath);
    croppedImage=im2gray(croppedImage);
    th = graythresh(croppedImage);
    car_plate=imbinarize(croppedImage,th);
    % figure,imshow(car_plate)
    
    % Segment Characters
    % define the ocr character set
    charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
 
    % select the top 10 blobs and bottom 4 blob in terms of area
    close_bin_plate = bwareafilt(car_plate,10,4);
%     figure, imshow(close_bin_plate);
    
    % invert the image if plate is white or yellow
    % ocr performs better for black characters
    if(current(2)=="white" || current(2)=="yellow")
        close_bin_plate = ~close_bin_plate;
    end
    
    % identif the blobs
    char_props = regionprops(close_bin_plate, 'BoundingBox');
    predicted_char="";
    
    % loop the blobs
    for n = 1 : length(char_props)
        flag=false;
        % limit 3 iterations to filter, crop and recognize the characters
        for m=1:3
            bounding_box = char_props(n).BoundingBox;
            w = bounding_box(3);
            h = bounding_box(4);
            % check if the character meets the aspect ratio condition
            if (w/h <1.2 && w*h>20)
                % crop the character and pad zeros
                crop = imcrop(close_bin_plate,bounding_box);
                crop = padarray(crop,[5 5],0,'both');
                % 'thin' morphology operation the padded char and resize
                if(flag)
                    crop = bwmorph(crop,'thin',1);
                end  
                crop = imresize(crop,[220,125]);
%                 figure,imshow(crop)
                
                % OCR
                % use default english and self-trained traineddata
                ocrResults = ocr(crop,'Language',{'tessdata\eng.traineddata', ...
                    'tessdata\charnum.traineddata'},CharacterSet=charset,TextLayout="Character");
                % check if the ocr result is empty
                if(ocrResults.Text=="")
                    flag=true;
                else
                    % extract ocr result and concatenate
                    predicted_char = strcat(predicted_char,ocrResults.Text);
                    break;
                end
                
            end
        end
    end
    
    % remove newline symbol and space
    predicted_char = replace(predicted_char,newline,'');
    predicted_char = replace(predicted_char,' ','');
    % check if the prediction is empty or length is not 5 to 10
    if(predicted_char=="" || ~(strlength(predicted_char)>4 && strlength(predicted_char)<10))
        Iocr_char = '';
        result_char=false;
    else
        result_char=true;
        % draw roi on orginal image
        Iocr_char = insertObjectAnnotation(img, 'rectangle', finalBB, predicted_char, ...
                    'Color','blue','LineWidth',3,'FontSize',72,'TextColor','white');
    end
end