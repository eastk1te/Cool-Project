> ## Project
Formula 1 승자예측 프로젝트

> ## Description
F1 레이스에서 어떤 드라이버가 우승할지 예측하는 이진분류 ML 모델을 개발하는 프로젝트입니다.

> ## Tech Stack
프로젝트에서 사용한 기술과 라이브러리를 나열합니다.
- Python
- Pandas
- Numpy
- Scikit-learn

> ## Data
사용된 데이터에 대한 설명과 데이터를 얻을 수 있는 방법을 제공합니다.

- 데이터셋 이름: F1 race dataset
- 데이터셋 출처: https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020
- 데이터셋 설명: Formula 1의 races, drivers, constructors, qualifying, circuits, lap times, pit stops, championships 내용을 포함한 1950년도 부터 2020년도까지의 데이터입니다.
- 데이터셋 형식: .zip 압축 파일 형태로 제공됩니다.
- 데이터셋 크기: 14개의 csv파일로 총 20.14MB

> ## Modeling
사용한 모델과 알고리즘에 대한 설명과 모델 학습 및 평가 과정을 설명합니다.

- 모델 이름: MLPClassifier (Multi Layer Perceptron Classifier)
- 모델 설명: (80, 40, 10)의 은닉층을 가진 단순 다층퍼셉트론 모델
- 학습 방법: Adam optimizer를 사용하여 학습합니다.
- 평가 방법: 분리한 test 데이터셋으로 정확도를 측정합니다.

> ## Result
모델 결과와 결과에 대한 분석을 제공합니다.

- 모델 성능: test 데이터셋에서 97%의 정확도를 달성했습니다.
- 결과 분석: 데이터를 1등과 1등이 아닌 이진 분류로 진행하였기에 metrics이 잘못되었음.

> ## Improvement
프로젝트 진행 과정에서 1위를 예측하는 이진 분류 과정에서 1등인 사람과 1등이 아닌 사람들의 데이터 크기 차이를 고려하지 못했습니다. 이러한 문제를 해결하기 위해 upsampling과 downsampling을 시도하였지만, 이러한 방법으로 1등만을 예측하는 것은 어려웠습니다. 또한, 데이터 크기간의 부조화와 acc로 계산하는 등 metrics에 대한 이해가 부족하여 프로젝트 목표 수립부터 잘못되었음을 인지하게 되었습니다.

이를 통해 불균형한 데이터 셋 처리 등 데이터 전처리의 중요성을 인지하고, metrics에 대한 정확한 이해를 할 필요가 있습니다. 추후에 이러한 점들을 고려하여 프로젝트를 이어나가 볼 예정입니다.
