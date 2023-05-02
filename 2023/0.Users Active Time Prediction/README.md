> ## Project

User Active Time Prediction

> ## Description
프로젝트의 목적과 목표를 설명합니다.

> ## Tech Stack
프로젝트에서 사용한 기술과 라이브러리를 나열합니다.
- Python
- PyTorch
- TensorFlow
- Scikit-learn

> ## Data
사용된 데이터에 대한 설명과 데이터를 얻을 수 있는 방법을 제공합니다.

- 데이터셋 이름: MNIST handwritten digit dataset
- 데이터셋 출처: http://yann.lecun.com/exdb/mnist/
- 데이터셋 설명: 28x28 크기의 흑백 손글씨 숫자 이미지 70,000개로 이루어진 데이터셋입니다.
- 데이터셋 형식: .gz 압축 파일 형태로 제공됩니다.
- 데이터셋 크기: train 데이터셋 60,000개, test 데이터셋 10,000개

> ## Modeling
사용한 모델과 알고리즘에 대한 설명과 모델 학습 및 평가 과정을 설명합니다.

- 모델 이름: CNN (Convolutional Neural Network)
- 모델 설명: 2개의 convolution layer와 2개의 fully connected layer로 이루어진 간단한 CNN 모델입니다.
- 학습 방법: Adam optimizer와 Cross Entropy loss를 사용하여 10 epoch 동안 학습합니다.
- 평가 방법: test 데이터셋으로 정확도를 측정합니다.

> ## Result
모델 결과와 결과에 대한 분석을 제공합니다.

- 모델 성능: test 데이터셋에서 98.5%의 정확도를 달성했습니다.
- 결과 분석: 손글씨 숫자 인식 문제에서 간단한 CNN 모델이 잘 동작함을 보여줍니다.

> ## Improvement
해당 프로젝트의 문제점 및 앞으로의 보완점에 대해서 서술합니다.

> ## How to use
프로젝트를 실행하는 방법과 코드 실행 방법을 설명합니다.

1. 데이터 다운로드: http://yann.lecun.com/exdb/mnist/에서 MNIST 데이터셋을 다운로드하고 압축을 해제합니다.
2. 코드 실행: Python 3.6 이상과 PyTorch, TensorFlow, Scikit-learn 라이브러리가 설치되어 있어야 합니다. 아래와 같이 코드를 실행합니다.


> ## Copyright and License
코드와 데이터에 대한 저작권 정보와 라이선스를 설명합니다.

- 코드 라이선스: MIT License
- 데이터 라이선스: MNIST 데이터셋은 Public Domain License를 따릅니다.

> ## References
프로젝트와 관련된 논문, 문서 및