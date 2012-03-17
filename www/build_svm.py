#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from os.path import dirname, abspath
HOME_PATH = dirname(abspath(__file__))
sys.path.insert(0, HOME_PATH)

import random
from os.path import exists
from sqlalchemy import create_engine
from collections import namedtuple
from top_frequent import get_top_list, url_re, seg
from svm import (svm_problem, svm_parameter, svm_model, LINEAR)

top = get_top_list()
words = [w for w, v in top]

def get_training_data():
    Draft = namedtuple('Draft', 'id, sid, pic, snum, lnum, author, text, utime, ctime, status')
    engine = create_engine('mysql://eye:sauron@localhost/exia')
    conn = engine.connect()

    rs = conn.execute('select * from sample where status=0 order by rand()')
    trash_tweets = map(Draft._make, rs)

    rs = conn.execute('select * from entry order by rand()')
    snap_tweets = map(Draft._make, rs)

    conn.close()

    tweets = trash_tweets + snap_tweets
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

if __name__ == '__main__':
    fy, fx, fd = get_training_data()
    print '训练新的model'
    prob = svm_problem(fy, fx)
    param = svm_parameter(kernel_type = LINEAR, C = 80)

    ## training  the model
    m = svm_model(prob, param)
    m.save('snap.svm')

    img = '<img src="%s"></img>'
    super_count = 0
    error_count = 0
    html_snap = ''
    html_trash = ''
    for i, x in enumerate(fx):
        label = m.predict(x)
        if label == 1:
            html_snap += img % fd[i][0]
        else:
            html_trash += img % fd[i][0]
        if label == fy[i]:
            super_count += 1
        else:
            error_count += 1
    print m, super_count, error_count

    with open('snap.html', 'w') as f:
        f.write(html_snap)
        f.close()

    with open('trash.html', 'w') as f:
        f.write(html_trash)
        f.close()

    with open('feature_words.txt', 'w') as f:
        f.writelines((w + '\n' for w in words))
        f.close()
