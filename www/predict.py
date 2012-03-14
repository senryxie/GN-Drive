#!/usr/bin/env python
# -*- coding: utf-8 -*-

import random
from os.path import exists
from libs.sqlstore import store
from collections import namedtuple
from top_frequent import get_top_list, url_re, seg
from svm import (svm_problem, svm_parameter, svm_model, LINEAR)

top = get_top_list()
words = [w for w, v in top]

def get_training_data():
    Draft = namedtuple('Draft', 'id, sid, pic, snum, lnum, author, text, utime, ctime, status')

    store.execute('select * from draft order by rand()')
    rs = store.fetchall()

    tweets = map(Draft._make, rs)
    random.shuffle(tweets, random.random)

    fx = []
    fy = []
    fd = []

    for t in tweets:
        features = build_x(t.text)
        fx.append(features)
        status = 1
        if not t.status:
            status = -1
        fy.append(status)
        item = (t.pic, str(t.sid))
        fd.append(item)
    return fy, fx, fd

def build_x(text):
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

def predict(x):
    m = svm_model('snap.svm')
    label = m.predict(x)
    label = int(label)
    if label == 1:
        return  True
    return False

if __name__ == '__main__':
    fy, fx, fd = get_training_data()
    svm_file = 'snap.svm'
    if exists(svm_file):
        print '使用已有model'
        m = svm_model(svm_file)
    else:
        print '训练新的model'
        prob = svm_problem(fy, fx)
        param = svm_parameter(kernel_type = LINEAR, C = 80)

        ## training  the model
        m = svm_model(prob, param)
        m.save('snap.svm')
