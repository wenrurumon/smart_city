# -*- coding: utf-8 -*-
"""
Created on Tue Jul 10 09:45:07 2018

@author: wfsha
"""

import pandas as pd
import numpy as np

spotlist = pd.read_csv('C:/Users/wfsha/Desktop/list.csv',names=['id','spot','coordi'])
spotlist['co'] = np.array


for li in range(len(spotlist['id'])):
    spotlist['co'][li] = []
    for i in spotlist['coordi'][li].split(','):
        print(i.split())
        spotlist['co'][li].append(i.split())
        


def IsPtInPoly(aLon, aLat, pointList):

    iSum = 0
    iCount = len(pointList)

    if(iCount < 3):
        return False
    for i in range(iCount):
        pLon1 = float(pointList[i][0])
        pLat1 = float(pointList[i][1])
        if(i == iCount - 1):
            pLon2 = float(pointList[0][0])
            pLat2 = float(pointList[0][1])
        else:
            pLon2 = float(pointList[i + 1][0])
            pLat2 = float(pointList[i + 1][1])
        if ((aLat >= pLat1) and (aLat < pLat2)) or ((aLat>=pLat2) and (aLat < pLat1)):

            if (abs(pLat1 - pLat2) > 0):
                pLon = pLon1 - ((pLon1 - pLon2) * (pLat1 - aLat)) / (pLat1 - pLat2);

                if(pLon < aLon):
                    iSum += 1

    if(iSum % 2 != 0):
        return True
    else:
        return False
