# multiprocess 
# https://beomi.github.io/2017/07/05/HowToMakeWebCrawler-with-Multiprocess/
import pandas as pd
import time
import multiprocessing

from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.keys import Keys

chrome_options = webdriver.ChromeOptions()
prefs = {'profile.default_content_setting_values': {'cookies' : 2, 'images': 2, 'plugins' : 2, 'popups': 2,
                                                    'geolocation': 2, 'notifications' : 2, 'auto_select_certificate': 2,
                                                    'fullscreen' : 2, 'mouselock' : 2, 'mixed_script': 2, 'media_stream' : 2,
                                                    'media_stream_mic' : 2, 'media_stream_camera': 2, 'protocol_handlers' : 2,
                                                    'ppapi_broker' : 2, 'automatic_downloads': 2, 'midi_sysex' : 2, 'push_messaging' : 2,
                                                    'ssl_cert_decisions': 2, 'metro_switch_to_desktop' : 2, 'protected_media_identifier': 2,
                                                    'app_banner': 2, 'site_engagement' : 2, 'durable_storage' : 2}} 
                                                    
chrome_options.add_experimental_option('prefs', prefs)
chrome_options.add_argument('--headless')
chrome_options.add_argument('--no-sandbox')
chrome_options.add_argument('--disable-dev-shm-usage')


def scraping(url, page_num=30):
    job_df = pd.DataFrame(columns=['회사','커리어','키워드'])

    wd = webdriver.Chrome(
        'C:\Visual Studio Code\Dacon_visualizaion\chromedriver.exe', options=chrome_options)
    wd.get(url)

    #company_list = []
    #career_list = []
    #keyword_list = []
    wd.find_element_by_xpath('//*[@id="anchorGICnt_1"]/li[5]/button').send_keys(Keys.ENTER)
    # //*[@id="anchorGICnt_11"]/li[3]/button # li[2] 대기업, [3]중견, 중소, [4] 공기업공사, [5] 외국계
    wd.implicitly_wait(3)

    xpath_tr = '//*[@id="dev-gi-list"]/div/div[5]/table/tbody/tr['
    idx = 0
    for page_no in range(1, page_num + 1):
        try:
            print('page_no : ', page_no, ', running time : ',int(time.time() - start_time))

            df_list = pd.DataFrame(columns=['회사','커리어','키워드'])
            for i in range(1, 41):
                xpath = xpath_tr + str(i) + ']'
                
                company = wd.find_element_by_xpath(xpath + '/td[1]/a').text                
                carrer = '@'.join([p.text for p in wd.find_elements_by_xpath(xpath + '/td[2]/div/p[1]/span')])                
                keyword = wd.find_element_by_xpath(xpath + '/td[2]/div/p[2]').text
                
                df_list.loc[idx] = [company if company else '', carrer if carrer else '', keyword if keyword else '']
                idx += 1
                
            job_df = pd.concat([job_df, df_list])

            page_ul = wd.find_element_by_xpath('//*[@id="dvGIPaging"]/div/ul')

            if page_no % 10 == 0:
                if page_no > 10:
                    wd.find_element_by_xpath('//*[@id="dvGIPaging"]/div/p[2]/a').send_keys(Keys.ENTER)
                else:
                    wd.find_element_by_xpath('//*[@id="dvGIPaging"]/div/p/a').send_keys(Keys.ENTER)
            else:
                page_ul.find_element_by_link_text(str(page_no+1)).send_keys(Keys.ENTER)

            wd.implicitly_wait(3)

        except NoSuchElementException:
            break

    wd.quit()
    return job_df

url = 'https://www.jobkorea.co.kr/recruit/joblist?menucode=local&localorder=1'

start_time = time.time()
job_df = scraping(url, 100)  # 169
job_df.to_csv('job_df.csv')

'''
if __name__ == '__main__':
    pool = Pool(processes=4)  #multiprocessing.cpu_count())
    #job_df = scraping(url, 3000)  # 169
    job_df = pool.map(scraping, url)
    job_df.to_csv('job_df.csv')
'''