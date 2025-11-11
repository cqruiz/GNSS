"""

Please place this script into the folder "./GNSS dataset/"
You can use this code to read the processed data.

The contributors:
Xiaoyan Wang (xiaoyan_wang2020@163.com)
Jingjing Yang (yangjingjing@ynu.edu.cn)
Ming Huang (huangming@ynu.edu.cn)

12/28 2023
"""

import json


def read_processed_data(day, hour, item):
    """
    This function is used to read the processed data file.
    You need to provide the day and hour so that the code
    can successfully find the path to the specified file.

    :param day: describes the date, which corresponds to
                the next level of the processed data folder, with options
                ranging from September 12th to 30th and December 21st.
    :param hour: describes the hour, ranging from 0 to 23
    :param item: There are three modes to choose: 'observation','pvtSolution', 'satelliteInfomation'
    :return:
    """

    fileName = 'processed data/%s/%s%s.json' % (day,item,hour)
    print('**'*50)
    print('You are reading file: ', fileName)
    with open(fileName, "r", encoding="utf-8") as f:
        content0 = json.load(f)
    for key,value in content0.items():
        print(key,': ', value)


if __name__ == '__main__':
    items = ['observation','pvtSolution', 'satelliteInfomation']
    days = [12]
    hours= [14]
    for day in days:
        for item in items:
            for hour in hours:
                read_processed_data(day, hour, item)
