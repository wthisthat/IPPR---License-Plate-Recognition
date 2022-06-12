import sys
from typing import final
plate_num = sys.argv[1]
import re
import io, json
import os
from google.cloud.vision_v1 import AnnotateImageResponse
from google.cloud import vision

########### TO DO BEFORE USE ###########
# pip install google-cloud-vision
# pip install google-cloud
# change BASE_DIR to the directory where this python script is
########################################

BASE_DIR = r"D:/cyk/y3s1/IPPR/IPPR_Assignment/"
img_path=BASE_DIR+'car_plates/'+plate_num+'.jpg'
json_path=BASE_DIR+'recognition_results/'+plate_num+'/'+plate_num+'.json'
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = BASE_DIR+"just-turbine-290715-5085f4fb2c9b.json"

#google cloud vision api call and get response
def detect_text(img_path):
    client = vision.ImageAnnotatorClient()
    with io.open(img_path, 'rb') as image_file:
        content = image_file.read()
    image = vision.Image(content=content)
    response = client.document_text_detection(image=image,image_context={"language_hints": ["en"]})
    return response

#get response and extract the predicted result, then remove spaces and symbols
response=detect_text(img_path)
response_json = AnnotateImageResponse.to_json(response)
result = response.full_text_annotation.text
result_list= (result.replace(' ','')).split('\n')
final_result = re.sub(r'[^\w]', '', result_list[0])

#write the filtered predicted result to a txt file
f = open("gcloud_vision_result.txt",'w')
f.write(final_result)
f.close()

#save the response as json
with open(json_path,'w') as outfile:
    json.dump(response_json,outfile)