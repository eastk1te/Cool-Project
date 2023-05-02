install.packages("data.table")
install.packages("bit64")
install.packages("tidyverse")
install.packages("reshape2")
install.packages("caret")
install.packages("factoextra")
install.packages("tidyverse")
install.packages("knitr")
install.packages("kableExtra")
install.packages("cluster")
install.packages("DescTools")
install.packages("lawstat")
install.packages("dunn.test")
install.packages("haven")
install.packages("showtext")
install.packages("nortest")

library(data.table)
library(bit64)
library(tidyverse)
library(reshape2)
library(caret)
library(factoextra)
library(tidyverse)
library(knitr)
library(kableExtra)
library(cluster)
library(DescTools)
library(lawstat)
library(dunn.test)
library(haven)
library(showtext)
library(nortest)
memory.limit(100000)

#폰트지정
font_add_google('Nanum Gothic', family='NanumGothic')
showtext_auto()

#카드데이터 불러오기
setwd("C:/Users/Stat1317_02/Desktop/data/data/NATIVE")
card<-fread("NATIVE_RE.txt",header=T,encoding="UTF-8")

# 결측치 제거, 2019년 이후 데이터 추출
card<-card %>% filter(!v1=="")
card<-card %>% filter(!v2=="")
card<-card %>% filter(!is.na(cln_age_r))
card<-card %>% filter(ta_ym>=201901)

#v1+gb2+ta_ym별 usec의 합 데이터 프레임 만들기
card_usec<-aggregate(usec~v1+gb2+ta_ym,card,sum)

#long 데이터를 usec기준으로 wide하게 만들기
card_usec_1<-dcast(data=card_usec,ta_ym~v1+gb2,value.var="usec")

# 결측치를 0으로 대체
card_usec_1[is.na(card_usec_1)]<-0

#각 v1+gb2별 usec의 min-max표준화
scale_usec<-preProcess(card_usec_1[,-1],method="range")
scale_usec<-predict(scale_usec,card_usec_1)

#표준화 한 usec를 연도를 기준으로 wide 데이터를 long 데이터로 변환
card_usec_2<-melt(scale_usec,id="ta_ym")

#컬럼 명 지정, 코로나 이전, 이후로 나누기.
colnames(card_usec_2)<-c("연월","분류","사용건수")
card_usec_before<-card_usec_2 %>% filter(연월<202002)
card_usec_after<-card_usec_2 %>% filter(연월>=202002)

#v1+gb2+ta_ym 기준으로 usec와 vlm의 합 구하기
card_vlm<-aggregate(cbind(usec,vlm)~v1+gb2+ta_ym,card,sum)
#vlm변수를 V2(vlm)/V1(usec)으로 새롭게 지정 
card_vlm$mean_vlm<-card_vlm$V2/card_vlm$V1
#V1,V2변수 날리기.
card_vlm<-card_vlm[,c(-4,-5)]
#long 데이터를 mean_vlm기준으로 wide하게 만들기
card_vlm_1<-dcast(data=card_vlm,ta_ym~v1+gb2,value.var="mean_vlm")
#결측치 0으로 대체
card_vlm_1[is.na(card_vlm_1)]<-0
#각 v1+gb2별 mean_vlm의 min-max표준화
scale_vlm<-preProcess(card_vlm_1[,-1],method="range")
scale_vlm<-predict(scale_vlm,card_vlm_1)

#표준화 한 mean_vlm을 연도를 기준으로 long 데이터로 변환
card_vlm_2<-melt(scale_vlm,id="ta_ym")

#vlm 변수의 열 이름 지정
colnames(card_vlm_2)<-c("연월","분류","사용금액")
#코로나 전후로 나누기.
card_vlm_before<-card_vlm_2 %>% filter(연월<202002)
card_vlm_after<-card_vlm_2 %>% filter(연월>=202002)

#데이터를 분류를 기준으로 사용금액, 사용건수의 평균 구하기
card_before_vlm<-aggregate(사용금액~
                                 분류,data=card_vlm_before,mean)
card_after_vlm<-aggregate(사용금액~
                                분류,data=card_vlm_after,mean)

card_before_usec<-aggregate(사용건수~
                                  분류,data=card_usec_before,mean)
card_after_usec<-aggregate(사용건수~
                                 분류,data=card_usec_after,mean)

#각각의 데이터 조인
card_total_vlm<-full_join(card_before_vlm,card_after_vlm,by="분류")
card_total_usec<-full_join(card_before_usec,card_after_usec,by="분류")

#v1과 v2가 같으면 0, 다르면 1 코딩
card$moving<-ifelse(card$v1==card$v2,0,1)
#v1+gb2+moving+ta_ym 기준으로 usec와 vlm의 합 구하기
card_moving<-aggregate(usec~v1+gb2+moving+ta_ym,card,sum)

#long 데이터를 usec기준으로 wide하게 만들기
card_moving<-dcast(data=card_moving,moving+ta_ym~v1+gb2,value.var="usec")
#결측치 제거
card_moving[is.na(card_moving)]<-0

#코로나 이후의 데이터 만을 사용하여 card_moving_after 데이터 프레임 생성
card_moving_after<-card_moving %>% filter(ta_ym>202001)

#각 v1+gb2별 usec의 min-max표준화
scale_moving_after<-preProcess(card_moving_after[,-1:-2],method="range")
scale_moving_after<-predict(scale_moving_after,card_moving_after)

#표준화 한 usec를 연도,이동여부를 기준으로 long 데이터로 변환
card_move_after<-melt(scale_moving_after,id=c("moving","ta_ym"))

#컬럼 명 지정, 이동여부로 나누기.
colnames(card_move_after)<-c("이동여부","연월","분류","사용건수")

card_area_after <- card_move_after %>% filter(이동여부=="0")
card_moving_after <- card_move_after %>% filter(이동여부=="1")

#데이터를 분류를 기준으로 사용건수의 평균 구하기
card_area_after<-aggregate(사용건수~분류,data=card_area_after,mean)
card_moving_after<-aggregate(사용건수~분류,data=card_moving_after,mean)

#각각의 데이터 조인
card_total_move_after<-full_join(card_area_after,card_moving_after,by="분류")
colnames(card_total_move_after)<-c("분류","동네사용건수","타지사용건수")

#코로나 이전의 데이터 만을 사용하여 card_moving_before 데이터 프레임 생성
card_moving_before<-card_moving %>% filter(ta_ym<202002)

#각 v1+gb2별 usec의 min-max표준화
scale_moving_before<-preProcess(card_moving_before[,-1:-2],method="range")
scale_moving_before<-predict(scale_moving_before,card_moving_before)

#표준화 한 usec를 연도,이동여부를 기준으로 long 데이터로 변환
card_move_before<-melt(scale_moving_before,id=c("moving","ta_ym"))

#컬럼 명 지정, 이동여부로 나누기.
colnames(card_move_before)<-c("이동여부","연월","분류","사용건수")
card_area_before <- card_move_before %>% filter(이동여부=="0")
card_moving_before <- card_move_before %>% filter(이동여부=="1")

#데이터를 분류를 기준으로 사용건수의 평균 구하기.
card_area_before<-aggregate(사용건수~분류,data=card_area_before,mean)
card_moving_before<-aggregate(사용건수~분류,data=card_moving_before,mean)

#각각의 데이터 조인
card_total_move_before<-full_join(card_area_before,card_moving_before,by="분류")
colnames(card_total_move_before)<-c("분류","동네사용건수","타지사용건수")

#각각의 데이터를 조인하여 최종 데이터 생성
card_total<-full_join(card_total_usec,card_total_vlm,by="분류")
card_total<-full_join(card_total,card_total_move_after,by="분류")
card_total<-full_join(card_total,card_total_move_before,by="분류")

#코로나 전. 후의 표준화된 사용건수와 사용금액 차이 컬럼생성
card_total$usec<-(card_total$사용건수.x)-(card_total$사용건수.y)
card_total$mean_vlm<-(card_total$사용금액.x)-(card_total$사용금액.y)
#코로나 전. 후의 동네 사용건수와 타지사용건수의 차이 컬럼생성
card_total$move_after<-(card_total$동네사용건수.x)-(card_total$타지사용건수.x)
card_total$move_before<-(card_total$동네사용건수.y)-(card_total$타지사용건수.y)
#필요없는 컬럼 제거
card_total<-card_total[-2:-9]

# card_total 데이터 행이름 지정
rownames(card_total)<-card_total[,1]
#분류 컬럼을 지역과 소분류명으로 나눔.
a<-strsplit(as.character(card_total$분류),split ="_")
b<-NULL

for(i in 1:476){
  b[i]<-a[[i]][[1]]
}

c<-NULL

for(i in 1:476){
  c[i]<-a[[i]][[2]]
}
card_total<-card_total[,-1]
#지역과 여가 컬럼 생성
card_total$지역<-b
card_total$여가<-c

# 시계열 그림 시각화
card_<-aggregate(usec~ta_ym+gb2,card,mean)
ggplot(card_,aes(x=as.factor(ta_ym),y=usec,group=gb2,color=gb2))+
  theme_minimal(base_family = "NanumGothic")+geom_line(size=1)+
  theme(,element_blank(),axis.text.x=element_text(size=10,angle=45),axis.text.y=element_text(size=12),legend.title = element_blank())+
  xlab('연월')+ylab('사용건수')+guides(color = guide_legend(nrow =14))

ggplot(card_usec_2,aes(x=as.factor(연월),y=사용건수,group=분류,color=분류))+geom_line(size=0.1)+
  theme_minimal(base_family="NanumGothic")+geom_line(size=0.5)+theme(legend.position= "none")+
  theme(legend.position="none",element_blank(),axis.text.x=element_text(size=10,angle=45),axis.text.y=element_text(size=12))+
  xlab('연월')+ylab('사용건수')

# usec와 mean_vlm의 kmeans – clusturing, 시각화
set.seed(102)
km<-kmeans(card_total[,c(1,2)],4)
fviz_cluster(km,data=card_total[,c(1,2)],stand=F)+
  theme_minimal(base_family = "NanumGothic")

fviz_nbclust(card_total[,c(1,2)], kmeans, method = "silhouette")+
  theme_minimal(base_family = "NanumGothic")
card_total$cluster<-km$cluster

#각 군집의 특성 파악
card_mean_vlm_1<-card_total %>% filter(cluster==1)
table(card_mean_vlm_1$여가)
card_mean_vlm_2<-card_total %>% filter(cluster==2)
table(card_mean_vlm_2$여가)
card_mean_vlm_3<-card_total %>% filter(cluster==3)
table(card_mean_vlm_3$여가)
card_mean_vlm_4<-card_total %>% filter(cluster==4)
table(card_mean_vlm_4$여가)

#코로나 이후 moving과 usec의 kmeans-clustering
set.seed(102)
km<-kmeans(card_total[,c(1,3)],2)
fviz_cluster(km,data=card_total[,c(1,3)],stand=F)+
  theme_minimal(base_family = "NanumGothic")
card_total$cluster_after<-km$cluster
fviz_nbclust(card_total[,c(1,3)], kmeans, method = "silhouette")+
  theme_minimal(base_family = "NanumGothic")

#각 군집의 특성 파악, 시각화
card_move_after_1<-card_total %>% filter(cluster_after==1)
sort(table(card_move_after_1$지역))
table(card_move_after_1$여가)

card_move_after_2<-card_total %>% filter(cluster_after==2)
sort(table(card_move_after_2$지역))
table(card_move_after_2$여가)

card_move_after_1$취약지역<-ifelse(card_move_after_1$지역 == "세종","#63E2FA", "#F54847")
ggplot(card_move_after_1,aes(x=지역,fill=취약지역))+geom_bar()+
  theme_minimal(base_family = "NanumGothic")+
  theme(legend.position = "none")+ylim(0,20)

card_move_after_2$안전지역<-ifelse(card_move_after_2$지역=="강원"|card_move_after_2$지역=="제주"
                               ,"#63E2FA", "#F54847")
ggplot(card_move_after_2,aes(x=지역,fill=안전지역))+geom_bar()+
  theme_minimal(base_family = "NanumGothic")+
  theme(legend.position = "none")+ylim(0,25)

#코로나 이전 moving과 usec의 kmeans-clustering
set.seed(102)
km<-kmeans(card_total[,c(1,4)],2)
fviz_cluster(km,data=card_total[,c(1,4)],stand=F)+
  theme_minimal(base_family = "NanumGothic")
card_total$cluster_before<-km$cluster
fviz_nbclust(card_total[,c(1,4)], kmeans, method = "silhouette")+
  theme_minimal(base_family = "NanumGothic")

#각 군집의 특성 파악, 시각화
card_move_before_1<-card_total %>% filter(cluster_before==1)
sort(table(card_move_before_1$지역))
table(card_move_before_1$여가)

card_move_before_2<-card_total %>% filter(cluster_before==2)
sort(table(card_move_before_2$지역))
table(card_move_before_2$여가)

card_move_before_1$취약지역<-ifelse(card_move_before_1$지역 == "세종","#63E2FA", "#F54847")
ggplot(card_move_before_1,aes(x=지역,fill=취약지역))+geom_bar()+
  theme_minimal(base_family = "NanumGothic")+
  theme(legend.position = "none")+ylim(0,20)

card_move_before_2$안전지역<-ifelse(card_move_before_2$지역 == "서울"|card_move_before_2$지역 =="제주"
                                ,"#63E2FA", "#F54847")
ggplot(card_move_before_2,aes(x=지역,fill=안전지역))+geom_bar()+
  theme_minimal(base_family = "NanumGothic")+
  theme(legend.position = "none")+ylim(0,25)

#-----------------------------------------------------------------------------
#여가데이터 불러오기
culture<-read_sav("2020여가.sav")
culture<-data.frame(culture)

#사용할 컬럼만을 추출
culture<-culture[,c("ID","q2_1_n2","q2_1_n2_m2","q2_1_n2_m3","q2_1_n2_m4",
                    "q2_1_n2_m5","q2_3_1","q2_3_2","q2_3_3","q2_3_4",
                    "q2_3_5","q2_6_1","q2_6_2","q2_6_3","q2_6_4",
                    "q2_6_5","q26_1","q26_2","q26_3","q26_4","q26_5",
                    "q26_6","q26_7","q27_1","q27_2","q27_3","q27_4","q27_5",
                    "q27_6","q27_7","DM2","DM8","DM11","DM12")]

culture<-data.frame(culture)


culture1<-culture[,c("ID","DM11","q26_1","q26_2","q26_3","q26_4","q26_5",
                     "q26_6","q26_7","q27_1","q27_2","q27_3","q27_4","q27_5",
                     "q27_6","q27_7","DM2","DM8","DM12",
                     "q2_1_n2","q2_1_n2_m2","q2_1_n2_m3","q2_1_n2_m4",
                     "q2_1_n2_m5")]

culture2<-culture[,c("ID","DM11","q26_1","q26_2","q26_3","q26_4","q26_5",
                     "q26_6","q26_7","q27_1","q27_2","q27_3","q27_4","q27_5",
                     "q27_6","q27_7","DM2","DM8","DM12",
                     "q2_3_1","q2_3_2","q2_3_3","q2_3_4",
                     "q2_3_5")]

culture3<-culture[,c("ID","DM11","q26_1","q26_2","q26_3","q26_4","q26_5",
                     "q26_6","q26_7","q27_1","q27_2","q27_3","q27_4","q27_5",
                     "q27_6","q27_7","DM2","DM8","DM12",
                     "q2_6_1","q2_6_2","q2_6_3","q2_6_4",
                     "q2_6_5")]


# 1순위~5순위인 여가활동을 참여한 활동으로 데이터 구조 변경
culture_long1<-pivot_longer(data=culture1,cols=20:24,
                            names_to="선호도",values_to="여가")
culture_long1$선호도<-ifelse(culture_long1$선호도=="q2_1_n2",'1',
                          ifelse(culture_long1$선호도=="q2_1_n2_m2",'2',
                                 ifelse(culture_long1$선호도=="q2_1_n2_m3",'3',
                                        ifelse(culture_long1$선호도=="q2_1_n2_m4",'4','5'))))
culture_long1<-na.omit(culture_long1)

# 1순위~5순위인 여가활동 참여 빈도를 참여한 활동 참여빈도로 데이터 구조 변경
culture_long2<-pivot_longer(data=culture2,cols=20:24,
                            names_to="선호도",values_to="빈도")
culture_long2$선호도<-ifelse(culture_long2$선호도=="q2_3_1",'1',
                          ifelse(culture_long2$선호도=="q2_3_2",'2',
                                 ifelse(culture_long2$선호도=="q2_3_3",'3',
                                        ifelse(culture_long2$선호도=="q2_3_4",'4','5'))))
culture_long2<-na.omit(culture_long2)

# 1순위~5순위인 여가활동 만족도를 참여한 활동 만족도로 데이터 구조 변경
culture_long3<-pivot_longer(data=culture3,cols=20:24,
                            names_to="선호도",values_to="만족도")
culture_long3$선호도<-ifelse(culture_long3$선호도=="q2_6_1",'1',
                          ifelse(culture_long3$선호도=="q2_6_2",'2',
                                 ifelse(culture_long3$선호도=="q2_6_3",'3',
                                        ifelse(culture_long3$선호도=="q2_6_4",'4','5'))))

culture_long3<-na.omit(culture_long3)

# 각각의 데이터 조인
culture_full<-full_join(culture_long1,culture_long2)
culture_full<-full_join(culture_full,culture_long3)
attach(culture_full)
culture_full<-culture_full[,c("ID","q26_1","q26_2","q26_3","q26_4","q26_5",
                              "q26_6","q26_7","q27_1","q27_2","q27_3","q27_4","q27_5",
                              "q27_6","q27_7","DM2","DM8","DM11","DM12","선호도","여가",
                              "빈도","만족도")]


# 여가활동을 신한카드의 usec,mean_vlm의 군집 결과로 cluster라는 파생변수 생성
table(culture_full$여가)
culture_full$cluster<-ifelse(여가==38|여가==39|여가==40|여가==41|여가==42|여가==43|여가==44|여가==45|여가==46|여가==47|여가==48,1,
                               ifelse(여가==1|여가==2|여가==9|여가==13|여가==16|여가==17|여가==18|여가==19|여가==20|여가==21|여가==22|여가==23|여가==25|여가==26|여가==27|여가==28|여가==32|여가==33|여가==34|여가==37|여가==53|여가==55|여가==60|여가==61|여가==62|여가==63|여가==64|여가==68|여가==69|여가==77|여가==80|여가==82|여가==85|여가==86|여가==87,2,
                                        ifelse(여가==3|여가==4|여가==5|여가==6|여가==7|여가==8|여가==10|여가==11|여가==12|여가==14|여가==15|여가==29|여가==30|여가==49|여가==50|여가==51|여가==54|여가==57|여가==58|여가==59|여가==65|여가==66|여가==67|여가==70|여가==72|여가==78,3,
                                                 ifelse(여가==24|여가==31|여가==35|여가==36|여가==52|여가==56|여가==71|여가==73|여가==74|여가==75|여가==76|여가==79|여가==81|여가==83|여가==84,4,"delete"))))

#위의 신한카드 군집이 아닌 활동 제거
culture_full<-culture_full %>% filter(!cluster=="delete")

# 만족도를 제외한 분산 분석에 필요한 변수들을 factor 형으로 바꾸어줌. 
# 만족도는 numeric형태
colnames(culture_full)
culture_full<-data.frame(culture_full)
culture_full[,16]<-as.factor(culture_full[,16])
culture_full[,17]<-as.factor(culture_full[,17])
culture_full[,18]<-as.factor(culture_full[,18])
culture_full[,19]<-as.factor(culture_full[,19])
culture_full[,22]<-as.factor(culture_full[,22])
culture_full[,23]<-as.numeric(culture_full[,23])

#1번 군집에 해당하는 행 추출, 분산분석에 필요한 변수 추출
culture_full_1<-culture_full %>% filter(cluster==1)
culture_full_1<-culture_full_1[,c(16,17,18,19,22,23)]

#혼합데이터를 사용하기 때문에 gower 거리를 통한 거리지정
#완전 연결법을 사용한 계층형 군집분석 실행
gower_distance_1<-daisy(culture_full_1,metric="gower")
agg_clust_c_1 <- hclust(gower_distance_1, method = "complete")
plot(agg_clust_c_1, main = "1군집의 계층형 군집분석 ",hang=-1)
rect.hclust(agg_clust_c_1, k=5,border=1:5)
cul1<-cutree(agg_clust_c_1,k=5)

#각각의 군집의 요약테이블 만들기
culture_full_1$cluster<-cul1
cluster_1 <- culture_full_1 %>% group_by(cluster) %>% do(the_summary = summary(.))
cluster_1$the_summary

#정규성 검정
shapiro.test(culture_full_1$만족도)

# 만족도는 정규분포를 따르지 않기 때문에, 비모수적 검정, 사후검정 시행
kruskal.test(culture_full_1$만족도~culture_full_1$cluster)
dunn.test(culture_full_1$만족도,culture_full_1$cluster, method = 'bonferroni')
#--------------------------------------------------------------------
#2번 군집에 해당하는 행 추출, 분산분석에 필요한 변수 추출
culture_full_2<-culture_full %>% filter(cluster==2)
culture_full_2<-culture_full_2[,c(16,17,18,19,22,23)]

#혼합데이터를 사용하기 때문에 gower 거리를 통한 거리지정
#완전 연결법을 사용한 계층형 군집분석 실행
gower_distance_2<-daisy(culture_full_2,metric=c("gower"))
agg_clust_c_2 <- hclust(gower_distance_2, method = "complete")
plot(agg_clust_c_2, main ="2군집의 계층형 군집분석 ",hang=-1)
rect.hclust(agg_clust_c_2, k=4,border=2:5)
clu2<-cutree(agg_clust_c_2,k=4)

#각각의 군집의 요약테이블 만들기
culture_full_2$cluster<-clu2
cluster_2 <- culture_full_2 %>% group_by(cluster) %>% do(the_summary = summary(.))

cluster_2$the_summary

#정규성 검정
ad.test(culture_full_2$만족도)

# 만족도는 정규분포를 따르지 않기 때문에, 비모수적 검정, 사후검정 시행
kruskal.test(culture_full_2$만족도~culture_full_2$cluster)
dunn.test(culture_full_2$만족도,culture_full_2$cluster, method = 'bonferroni')
#--------------------------------------------------------------------

#3번 군집에 해당하는 행 추출, 분산분석에 필요한 변수 추출
culture_full_3<-culture_full %>% filter(cluster==3)
culture_full_3<-culture_full_3[,c(16,17,18,19,22,23)]

#혼합데이터를 사용하기 때문에 gower 거리를 통한 거리지정
#완전 연결법을 사용한 계층형 군집분석 실행
gower_distance_3<-daisy(culture_full_3,metric=c("gower"))
agg_clust_c_3 <- hclust(gower_distance_3, method = "complete")
plot(agg_clust_c_3, main = "3군집의 계층형 군집분석",hang=-1)
rect.hclust(agg_clust_c_3, k=3,border=2:4)
clu3<-cutree(agg_clust_c_3,k=3)

#각각의 군집의 요약테이블 만들기
culture_full_3$cluster<-clu3
cluster_3 <- culture_full_3 %>% group_by(cluster) %>% do(the_summary = summary(.))

cluster_3$the_summary

#정규성 검정
ad.test(culture_full_3$만족도)

# 만족도는 정규분포를 따르지 않기 때문에, 비모수적 검정, 사후검정 시행
kruskal.test(culture_full_3$만족도~culture_full_3$cluster)
dunn.test(culture_full_3$만족도,culture_full_3$cluster, method = 'bonferroni')
#--------------------------------------------------------------------

#4번 군집에 해당하는 행 추출, 분산분석에 필요한 변수 추출
culture_full_4<-culture_full %>% filter(cluster==4)
culture_full_4<-culture_full_4[,c(16,17,18,19,22,23)]


#혼합데이터를 사용하기 때문에 gower 거리를 통한 거리지정
#완전 연결법을 사용한 계층형 군집분석 실행
gower_distance_4<-daisy(culture_full_4,metric=c("gower"))
agg_clust_c_4 <- hclust(gower_distance_4, method = "complete")
plot(agg_clust_c_4, main = "4군집의 계층형 군집분석",hang=-1)
rect.hclust(agg_clust_c_4, k=4,border=2:5)
clu4<-cutree(agg_clust_c_4,k=4)

#각각의 군집의 요약테이블 만들기
culture_full_4$cluster<-clu4
cluster_4 <- culture_full_4 %>%
  group_by(cluster) %>%
  do(the_summary = summary(.))

cluster_4$the_summary

#정규성 검정
ad.test(culture_full_4$만족도)
# 만족도는 정규분포를 따르지 않기 때문에, 비모수적 검정, 사후검정 시행

kruskal.test(culture_full_4$만족도~culture_full_4$cluster)
dunn.test(culture_full_4$만족도,culture_full_4$cluster, method = 'bonferroni')


#------------------------------------------------------------------------------
# 1번군집에 대한 ipa 분석 시행
ipa1<-culture_full %>% filter(DM2==6&(DM8==1|DM8==2|DM8==3)&cluster==1)
ipa1_impo<-c(mean(ipa1$q26_1),mean(ipa1$q26_2),mean(ipa1$q26_3),mean(ipa1$q26_4),mean(ipa1$q26_5),mean(ipa1$q26_6),mean(ipa1$q26_7))
ipa1_sati<-c(mean(ipa1$q27_1),mean(ipa1$q27_2),mean(ipa1$q27_3),mean(ipa1$q27_4),mean(ipa1$q27_5),mean(ipa1$q27_6),mean(ipa1$q27_7))
g1<- data.frame("ipa1_impo"= ipa1_impo, 
                "ipa1_sati"= ipa1_sati, 
                "group"=1:7)
ggplot(data=g1,aes(x=ipa1_sati,y=ipa1_impo))+geom_point(color=2:8,size=2)+
  geom_text(aes(label=group),size=4,vjust=-1)+
  xlim(4.3,4.9)+ylim(5.1,6.2)+geom_hline(yintercept = mean(ipa1_impo),color=5)+
  geom_vline(xintercept=mean(ipa1_sati),color=5)+theme_minimal(base_family = "NanumGothic")+
  xlab("만족도")+ylab("중요도")


# 2번군집에 대한 ipa 분석 시행
ipa2<-culture_full %>% filter((DM2==6|DM2==7)&cluster==2&빈도==3&DM8==1)
ipa2_impo<-c(mean(ipa2$q26_1),mean(ipa2$q26_2),mean(ipa2$q26_3),mean(ipa2$q26_4),mean(ipa2$q26_5),mean(ipa2$q26_6),mean(ipa2$q26_7))
ipa2_sati<-c(mean(ipa2$q27_1),mean(ipa2$q27_2),mean(ipa2$q27_3),mean(ipa2$q27_4),mean(ipa2$q27_5),mean(ipa2$q27_6),mean(ipa2$q27_7))
g2<- data.frame("ipa2_impo"= ipa2_impo, 
                "ipa2_sati"= ipa2_sati, 
                "group"=1:7)
ggplot(data=g2,aes(x=ipa2_sati,y=ipa2_impo))+geom_point(color=2:8,size=2)+
  geom_text(aes(label=group),size=4,vjust=-1)+
  xlim(4.1,4.7)+ylim(4.7,6)+geom_hline(yintercept = mean(ipa2_impo),color=5)+
  geom_vline(xintercept=mean(ipa2_sati),color=5)+theme_minimal(base_family = "NanumGothic")+
  xlab("만족도")+ylab("중요도")

# 4번군집에 대한 ipa 분석 시행
ipa4<-culture_full %>% filter(DM2==7&cluster==4&DM8==1)
ipa4_impo<-c(mean(ipa4$q26_1),mean(ipa4$q26_2),mean(ipa4$q26_3),mean(ipa4$q26_4),mean(ipa4$q26_5),mean(ipa4$q26_6),mean(ipa4$q26_7))
ipa4_sati<-c(mean(ipa4$q27_1),mean(ipa4$q27_2),mean(ipa4$q27_3),mean(ipa4$q27_4),mean(ipa4$q27_5),mean(ipa4$q27_6),mean(ipa4$q27_7))
g4<- data.frame("ipa4_impo"= ipa4_impo, 
                "ipa4_sati"= ipa4_sati, 
                "group"=1:7)
ggplot(data=g4,aes(x=ipa4_sati,y=ipa4_impo))+geom_point(color=2:8,size=2)+
  geom_text(aes(label=group),size=4,vjust=-1)+
  xlim(4.2,4.6)+ylim(4.9,5.75)+geom_hline(yintercept = mean(ipa4_impo),color=5)+
  geom_vline(xintercept=mean(ipa4_sati),color=5)+theme_minimal(base_family = "NanumGothic")+
  xlab("만족도")+ylab("중요도")


