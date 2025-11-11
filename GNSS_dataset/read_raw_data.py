"""

Please place this script into the folder "./GNSS dataset/"
You can use this code to read the raw data.

The contributors:
Xiaoyan Wang (xiaoyan_wang2020@163.com)
Jingjing Yang (yangjingjing@ynu.edu.cn)
Ming Huang (huangming@ynu.edu.cn)

12/28 2023
"""

import json, os, time


def get_data_path(your_path):
    datPaths = []
    for root, dirs, files in os.walk(your_path, topdown=True):
        for name in files:
            if (name != ".DS_Store"):
                iPath = os.path.join(root, name)
                datPaths.append(iPath)
    return datPaths


def read_raw_data(day, hour, item):
    '''
    :param day: date
    :param hour:  hour
    :param item: choose the item file from ['RXM-RAWX','NAV-PVT','NAV-DOP','NAV-SAT','NAV-POSECEF','NAV-SPAN']
    :return: None
    '''
    fileName = '../GNSS_Dataset/Raw_data/%s/%s/RXM-RAWX'%(day, hour)
    #fileName = 'G:/GNSSJson09_2/%s/%s/%s'%(day, hour,item)
    json_names = os.listdir(fileName)

    # Read single file
    with open(os.path.join(fileName, json_names[0]), "r", encoding="utf-8") as f:
        content0 = json.load(f)
    for key,value in content0.items():
        print(key,': ', value)

    # Read one hour files
    for json_name in json_names:
        print('**'*50)
        print('You are reading file: ', os.path.join(fileName, json_name))
        with open(os.path.join(fileName, json_name), "r", encoding="utf-8") as f:
            content = json.load(f)
        for key,value in content.items():
            print(key,': ', value)
        time.sleep(5)


if __name__ == '__main__':
    # Read single file
    
    json_name = "Raw_data/12/0/RXM-RAWX/2023-09-12 00-00-01.json"
    with open(json_name, "r", encoding="utf-8") as f:
        content = json.load(f)
    for key,value in content.items():
        print(key,': ', value)


    # Read all files
    items = ['RXM-RAWX','NAV-PVT','NAV-DOP','NAV-SAT','NAV-POSECEF','NAV-SPAN']
    # days = [12,13,14,15,16]
    for item in items:
        for day in range(12,31):
            for hour in range(24):
                read_raw_data(day, hour, item)
