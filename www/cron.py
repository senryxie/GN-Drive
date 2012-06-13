#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import urllib2
from urllib2 import HTTPError
from os.path import dirname, abspath
HOME_PATH = dirname(abspath(__file__))
sys.path.insert(0, HOME_PATH)

from collections import namedtuple

from libs.sqlstore import engine
from libs.weibo1 import APIClient
from libs.core_image import open_pic
from predict import predict

APP_KEY = '459673502'
APP_SECRET = '87ff70bf34f6b026217a4025a97b0ed0'

access_token = 'f6f03cbc8dd90cbe7d1d2346646360d5'
token_secret = 'adeb5b5770326a639d58fd3b5609d0ce'

client = APIClient(app_key=APP_KEY, app_secret=APP_SECRET)
client.oauth_token = access_token
client.oauth_token_secret = token_secret

baned_list = ['皇冠', '聚美秀', '跑车街拍', '汽车街拍', '网友原创街拍', '手机摄影', '头条博客', '精品App推荐', '京东商城', '微电影', '爆笑街拍', 'Camera360', '时尚潮店', '店铺', '彩妆', '包邮', '外贸', '积分', '汽車', '￥', '这里逛', '笑喷', '豪车', '$', '比基尼', '淘到', '运费', '大家快来看']
Draft = namedtuple('Draft', 'id, sid, pic, snum, lnum, author, text, utime, ctime, status')

def download_snap_timeline():
    page = 1
    all=[]

    tweets = client.trends__statuses(trend_name='街拍', page=page)
    while tweets:
        for i in tweets:
            id = i['id']
            pic = i.get('bmiddle_pic')
            author = i['user']['id']
            text = i['text'].encode('utf-8')
            retweet = i.get('retweeted_status')
            if retweet:
                id = retweet['id']
                text = retweet['text'].encode('utf-8')
                author = retweet['user']['id']
            if pic:
                text = text.replace("'", '"')
                pic = pic.encode('utf-8')
                feature = (id, pic, author, text)
                all.append(feature)
        page += 1
        tweets = []
        try:
            tweets = client.trends__statuses(trend_name='街拍', page=page)
        except HTTPError as e:
            if str(e.code) in ('400', '403', '401'):
                '''bad request or forbidden'''
                print '微博接口%s错误', e.code
            else:
                raise

        if page > 5:
            break

    #
    #
    #

    #mysql engine
    conn = engine.connect()

    #svm predict
    dup = 0
    selected = set()
    for t in all:
        is_ban = False
        for ban in baned_list:
            if ban in t[3]:
                is_ban = True
                break

        #是否ban掉
        if is_ban:
            continue

        rs = conn.execute('select * from draft where sid=%s' % t[0])
        rs = map(Draft._make, rs)
        if len(rs):
            dup += 1
            continue

        text = t[3]
        if predict(text):
            id, pic, author, text = t
            passed = True

            try:
                r = urllib2.urlopen(pic.replace('bmiddle', 'thumbnail'))
                im = open_pic(r.read())
                width, height = im.size
                if height / width > 1.7777 or width / height > 1.7777:
                    passed = False
            except :
                pass
                #print '抓取、分析图片异常'
                #import traceback; traceback.print_exc()
            if passed:
                selected.add(t)

    #save to draft
    count = 0
    for line in selected:
        id, pic, author, text = line
        try:
            conn.execute('insert into draft (sid, pic, author, text, create_time) \
              values(%s,"%s",%s,"%s", now())' % line)
            print '入库:', id, pic, author, text
            count += 1
        except:
            pass
            #print '重复入库:', id, pic, author, text
    conn.close()
    return len(all), len(selected), dup

if __name__ == '__main__':
    #singleton job
    import fcntl, sys
    pid_file = '/var/tmp/snap-cron.pid'
    fp = open(pid_file, 'w')
    try:
        fcntl.lockf(fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except IOError:
        # another instance is running
        sys.exit(0)

    import redis
    import datetime

    now = datetime.datetime.now()
    db = redis.StrictRedis()
    snow = datetime.datetime.strftime(now, "%Y-%m-%d %H:%M:%S")
    print 'start:', snow
    db.set('lastrun', snow)
    total, count, dup = download_snap_timeline()
    now = datetime.datetime.now()
    snow = datetime.datetime.strftime(now, "%Y-%m-%d %H:%M:%S")
    print 'end:', snow
    print 'from: %s, get: %s, duplicate: %s' % (total, count, dup)
