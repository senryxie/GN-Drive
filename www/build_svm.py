#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import sys
import random
from collections import namedtuple
from os.path import dirname, abspath
HOME_PATH = dirname(abspath(__file__))
sys.path.insert(0, HOME_PATH)

import redis
import simplejson
from svm import (svm_problem, svm_parameter, svm_model, LINEAR)
from libs.sqlstore import engine
from libs.smallseg.smallseg import SEG

seg = SEG()

url_re = re.compile(r'http://.*?')
digit_re = re.compile(r'.?\d+.?\d*.?', re.DOTALL)

ban_list = ['-', '的', '是', '@', '#', '/', '.', '_', '~', '+', 'T', '..', '##', '//', '~~', '...', 'weibo.com', '--', 't.cn', '街拍', '...-',
           '没', '欧', '下', '[囧', '囧]', '里', '[太', '找', '基', '社', '来的', '具', ']~', '～～', 'by', '次', 't', '吧~', '啊', '&',
           '中', '~[', '?', '】', '在', '【', '了', ']',
            '就', '原', '这', '详情请', '从', '加', '熊猫', '网友', '月号', '博也', '``', 'h4MS2M', '被', ';', '#t.cn', '*', '陈皮', '1747534564', '@kiki', '王晓', '发表', '亚马逊', 'http', 'Http', '兰州', 'else.', '】长', ]


def get_top_list(tweets=[]):
    dicts={}
    top = []

    for t in tweets:
        t = url_re.sub('', t)
        w_list = seg.cut(t.strip())
        w_list.reverse()
        for w in w_list:
            w = w.encode('utf-8')
            if w in ban_list:
                continue
            if digit_re.match(w):
                continue
            dicts[w] = dicts.get(w,0) + 1

    for key, value in dicts.items():
        if len(key) and value > 2:
            top.append((key, value))

    top.sort(key=lambda x:x[1], reverse=True)
    return top[:1500]


def get_training_data():
    print '获取样本...'
    Draft = namedtuple('Draft', 'id, sid, pic, snum, lnum, author, text, utime, ctime, status')
    conn = engine.connect()

    rs = conn.execute('select * from sample where status=0 order by rand()')
    trash_tweets = map(Draft._make, rs)

    rs = conn.execute('select * from entry order by rand()')
    snap_tweets = map(Draft._make, rs)


    tweets = trash_tweets + snap_tweets
    print '随机打乱样本顺序...'
    random.shuffle(tweets, random.random)

    print '获取特征表...'
    top = get_top_list(tweets=(t.text for t in tweets))
    words = [w for w, v in top]

    print '特征表存入redis...'
    db = redis.StrictRedis()
    db.set('features', simplejson.dumps(words))

    print '特征表写入本地文件...'
    with open('feature_words.txt', 'w') as f:
        f.writelines((w + '\n' for w in words))
        f.close()

    def build_x(text):
        text = url_re.sub('', text)
        w_list = seg.cut(text.strip())
        w_list.reverse()
        w_list = [w.encode('utf-8') for w in w_list]
        fs = []
        for w in words:
            if w in w_list:
                fs.append(1)
            else:
                fs.append(0)
        return fs

    fx = []
    fy = []
    fd = []

    print '构建fx, fy, fd'
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

if __name__ == '__main__':
    from optparse import OptionParser
    u = 'app for snap'
    parser = OptionParser(usage=u)
    parser.add_option('-t', '--test', action='store_true')
    options, args = parser.parse_args()

    sample_file = 'sample.dat'

    if options.test:
        f = open(sample_file, 'r')
        j = f.read()
        fy, fx, fd = simplejson.loads(j)
        f.close()
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

        print '生成预测后snap html...'
        with open('snap.html', 'w') as f:
            f.write(html_snap)
            f.close()

        print '生成预测后trash html...'
        with open('trash.html', 'w') as f:
            f.write(html_trash)
            f.close()
    else:
        fy, fx, fd = get_training_data()
        print '保存样本数据'
        data = [fy, fx, fd]
        with open(sample_file, 'w') as f:
            f.write(simplejson.dumps(data))
            f.close()
