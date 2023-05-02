""""
python dicom library
pydicom
https://pydicom.github.io/pydicom/stable/tutorials/installation.html
free dicom view
microdicom
https://www.microdicom.com/
python에서 dicom파일을 여는 pydicom 라이브러리와 무료 dicom view입니다.
사용법 등은 공식 문서를 참고해주시면 좋을 거 같습니다. 
그리고 간단히opencv와 pydicom을 사용해서 시각화 하는 코드도 첨부했습니다.
그냥 간단히 만든 코드라 참고만 해주세요. 
그리고 dicom을 확인해보니 이미지의 depth도 8bit로 일반적인 grayscale 영상과 동일한 거 같습니다. 
"""


import numpy as np
import cv2
import pydicom as dicom
import argparse
import warnings
from os import environ

warnings.filterwarnings(action='ignore')

def suppress_qt_warnings():
    environ["QT_DEVICE_PIXEL_RATIO"] = "0"
    environ["QT_AUTO_SCREEN_SCALE_FACTOR"] = "1"
    environ["QT_SCREEN_SCALE_FACTORS"] = "1"
    environ["QT_SCALE_FACTOR"] = "1"

def main(args) :

    prev = None 
    data = dicom.dcmread(args.dcm_path).pixel_array
    fps = args.fps 
    delay = int(1000/fps)
    cnt = data.shape[0]
    idx = 0

    while True:
        cv2.imshow('dicom',data[idx])

        idx +=1

        if idx>cnt-1: 
            idx=cnt-1

        if cv2.waitKey(delay)==27: #ESC
            break

    cv2.destroyAllWindows()

if __name__ =='__main__':
    suppress_qt_warnings()
    
    parser = argparse.ArgumentParser()
    parser.add_argument("--dcm_path", type=str, default='1/1(1).dcm')
    parser.add_argument("--fps", type=int, default=15)
    args = parser.parse_args()

    main(args)
