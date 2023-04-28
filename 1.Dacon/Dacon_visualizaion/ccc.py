import pandas as pd


category = pd.read_csv('C:\VisualStudioCode\잡코리아 직무 정리(1).csv', encoding='euc-kr')

a = pd.read_csv('C:\VisualStudioCode\job_df_대기업.csv', index_col=0)
a['기업형태'] = ['대기업'] * len(a)

b = pd.read_csv('C:\VisualStudioCode\job_df_공기업.csv', index_col=0)
b['기업형태'] = ['공기업'] * len(b)

c = pd.read_csv('C:\VisualStudioCode\job_df_중소기업.csv', index_col=0)
c['기업형태'] = ['중소기업'] * len(c)

df = pd.concat([a,b,c],axis=0)
df = df[['기업형태','회사','커리어','키워드']]
df = df.reset_index(drop=True)
df['id'] = df.index
# 제목에서 topic 분석을 실행하여 해당토픽에 많은 키워드?

df['커리어'] = list(map(lambda x : x.rstrip('@').split('@') ,df['커리어']))
df['키워드'] = list(map(lambda x : x.split(',') ,df['키워드']))
df['분류가능'] = [False] * len(df)
print('======================================================wordking===============================================================')

# 커리어 화살표 제거  # ↓ : 는 ↑
for i in range(len(df['커리어'])):
    for j in range(len(df['커리어'][i])):
        if '↑' in df['커리어'][i][j]:
            df['커리어'][i][j] = df['커리어'][i][j].replace('↑',' 이상') 

print('======================================================wordking===============================================================')
### 커리어 안에 있는 경력 분할
career = []
for i in range(len(df)):
    career_can = False
    for j in range(len(df['커리어'][i])):
        if '경력' or '신입' in df['커리어'][i][j]:
            career.append(df['커리어'][i][j])
            career_can = True
            break

    if not career_can:
        career.append('Null')
        
print('career : ',len(career))
df['career'] = career

print('======================================================wordking===============================================================')
### 커리아 안에 있는 학력 분할
edu_level = []
for i in range(len(df)):
    edu_can = False
    for j in range(len(df['커리어'][i])):
        if '학력' or '대졸' or '박사' or '석사' in df['커리어'][i][j]:
            edu_level.append(df['커리어'][i][j])
            edu_can = True
            break

    if not edu_can:
        edu_level.append('Null')

print('edu_level : ',len(edu_level))
df['edu_level'] = edu_level
df = df[['id','기업형태','회사','edu_level','career','커리어','키워드','분류가능']]
print(df)

import time
start_time = time.time()
t = pd.DataFrame(columns=['대분류','중분류','소분류'] + list(df.columns))
index = 0
for i in range(len(category)):
    if not i % 100:
        print('running index : ', i, ', running time : ',time.time() - start_time)
        
    for j in range(len(df)):
        if category['소분류'][i] in df['키워드'][j]:
            t.loc[index] = [category['대분류'][i],category['중분류'][i],category['소분류'][i]]  + list(df.iloc[j,:-1]) + [True]
            index += 1
            df['분류가능'][j] = True

for i in range(len(df)):
    if not df['분류가능'][i]:
        t.loc[index] = ['Null','Null','Null'] + list(df.iloc[i,:-1]) + [False]
        index += 1
t #t.drop_duplicates(subset=['소분류','id'])