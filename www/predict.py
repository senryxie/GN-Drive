#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from os.path import dirname, abspath

HOME_PATH = dirname(abspath(__file__))
sys.path.insert(0, HOME_PATH)

from svm import svm_model
from libs.sqlstore import engine
from build_svm import url_re, seg

def predict(text, m):
    x = _build_x(text)
    label = m.predict(x)
    label = int(label)
    if label == 1:
        return  True
    return False

def _get_features():
    conn = engine.connect()
    rs = conn.execute('select word from features order by id')
    conn.close()
    return [r[0] for r in rs]

def _build_x(text):
    text = url_re.sub('', text)
    w_list = seg.cut(text.strip())
    w_list.reverse()
    w_list = [w.encode('utf-8') for w in w_list]
    features = []
    for w in words:
        if w in w_list:
            features.append(1)
        else:
            features.append(0)
    return features

words = _get_features()
snap_model = svm_model(HOME_PATH + '/snap.svm')

if __name__ == '__main__':
    print '特征数量', len(words)
    print 'predict "#韩国街拍#裤子的颜色很心水": ', predict('#韩国街拍#裤子的颜色很心水', snap_model)
    print 'predict "淘宝皇冠": ', predict('淘宝皇冠', snap_model)
