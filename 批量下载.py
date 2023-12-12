# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 14:16:15 2023

@author: csk
"""
##   下载之前，在电脑C:/User/cxk/ 下面建立一个_netrc的文件，然后编辑，写入
# machine 
# login
# password
# 导入头文件
import re 
import requests
import os
print('sa')
URL = r'C:\Users\zhou\Desktop\GLDAS\2015/subset_GLDAS_NOAH025_3H_2.1_20231201_000838_.txt'

with open(URL, 'r') as file:
    urls = file.read()

#读取链接
url_t = urls.split('\n')
url_t = url_t[1:]
print(url_t[0])

#设置文件名
file_name = re.findall('LABEL=(.*).SUB.nc4', urls)
file_name[0]

def download(url, filename):
    print(f'start downloading {filename}')
    response = requests.get(url)
    try:     
        response.raise_for_status()
        f = open(filename,'wb')
        f.write(response.content)
        f.close()
        print('contents of URL written to '+filename)
        return ""
    except:
        print('error to connect '+ filename)
        return urls

for i in range(len(url_t)):
    output_path = r"C:\Users\zhou\Desktop\GLDAS\2015/" + file_name[i]
    download(url_t[i], output_path)