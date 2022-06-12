function [Iocr_full,predicted_full] = full_recognition(img,finalBB,cropPath,current)
% whole plate recognition (using the whole plate)
    %read saved plate image and binarize it
    croppedImage=imread(cropPath);
    croppedImage=im2gray(croppedImage);
    th = graythresh(croppedImage);
    car_plate=imbinarize(croppedImage,th);
    % figure,imshow(car_plate)
    
    % define the ocr character set
    charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    % invert the image if plate is white or yellow
    % ocr performs better for black characters
    if(current(2)=="white" || current(2)=="yellow")
        car_plate = ~car_plate;
    end
    
    % limit 3 iterations to filter and recognize the characters in the
    % plate
    for i = 1:3
        ocrResults=ocr(car_plate,'CharacterSet',charset);
        predicted_full=ocrResults.Text;
        predicted_full = replace(predicted_full,newline,'');
        predicted_full = replace(predicted_full,' ','');
        % check if the length of prediction is not 4 to 8
        if(strlength(predicted_full)<4||strlength(predicted_full)>8)
            % erode the image
            se = strel('square',3);
            car_plate = imerode(car_plate,se);
        end
    end
 
    %draw roi on image
    Iocr_full = insertObjectAnnotation(img, 'rectangle', finalBB, predicted_full, ...
                    'Color','blue','LineWidth',3,'FontSize',72,'TextColor','white');
   
end