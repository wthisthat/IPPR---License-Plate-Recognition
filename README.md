# IPPR---License-Plate-Recognition
In this group project, the building of license plate recognition system is done using image processing techniques available in MATLAB. The dataset consists of 20 car images, 7 from lecturer, 13 from internet. It involves car plate with 4 different colors which are yellow, blue, black, and white.

## Solution

Plate detection: HSV(Hue,Saturation,Value) and HSV-Edge.

Plate recognition: Tesseract OCR with single character, Tesseract OCR with entire plate, Google Vision entire plate

Example recognition result image (respectively):
![image](https://user-images.githubusercontent.com/65324580/177566347-fa78fefc-2bae-462d-a320-bd6e6c9dae5a.png)

## Experimental Results

|No.	| Plate	| Detection	| Recognition (Tesseract OCR Character-based)| Recognition (Tesseract OCR Entire plate)|Recognition (Google Vision Entire plate)|
|--- | --- | --- | --- |--- |--- |
|1	|AHA236| Yes| AHA236|	IAHA336I|	AHA236|
|2	|MCC86| Yes| MCCX6	| MIC86	| MCC86|
|3	|MCG7722	|Yes	|MCG7722	|MCGZ7722	|MCG7722|
|4	|PEN15	|Yes	|PEN15	|PEN15	|PEN15|
|5	|WVS7250	|Yes	|WVS7250	|7LI	|WVS7250|
|6	|HS1000	|Yes	|HS1000	|HSHQ	|HS1000|
|7	|HWC5310	|Yes	|HWC5310	|HVIC5310	|HWC5310|
|8	|HWD3092	|Yes	|HWD3092	|HWD3092	|HWD3092
|9	|KA555ZG	|Yes	|KA555ZG	|-	|KA555ZG|
|10	|MAK2860	|Yes	|MAK260	|MAK2860	|MAK2860|
|11	|AE02RYA	|Yes	|AEI2RYA	|TAED2RYA	|AEO2RYA|
|12	|FIJKU	|Yes	|FLIZU	|FUKUI	|FIJKU|
|13	|P004MAD	|Yes	|POU4MND	|-	|P0O4MAD|
|14	|SMU45G	|Yes	|SMU45GX	|WU45G	|SMU45G|
|15	|W400M	|Yes	|H4IIM	|H4UDM5	|W4OOM|
|16	|W065910	|Yes	|NII65910	|HU6591U	|W065910|
|17	|W083706	|Yes	|NUIX3706	|-	|W083706|
|18	|W083909	|Yes	|HI0X3909	|VHJ83909	|W083909|
|19	|W092200	|Yes	|WI09220U	|HU922OU	|W092200|
|20	|W104505	|Yes	|HI1I4505	|VMEMSOS	|W104505|
. | Total	|20/20	|8/20	|3/20	|17/20|
. | Accuracy Rate	|100%	|40%	|15%	|85%|

Note: Black (No. 1-5), White (No. 6-10), Yellow (No. 11-15), Blue (No. 16-20)

Credit:
Team members: See Rui, Moo Chi Yuen
