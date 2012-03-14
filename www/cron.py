#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from os.path import dirname, abspath
HOME_PATH = dirname(abspath(__file__))
sys.path.insert(0, HOME_PATH)

import urllib2
from libs.weibo1 import APIClient
from libs.sqlstore import store
from predict import predict, build_x
from libs.core_image import open_pic

APP_KEY = '459673502'
APP_SECRET = '87ff70bf34f6b026217a4025a97b0ed0'

access_token = 'f6f03cbc8dd90cbe7d1d2346646360d5'
token_secret = 'adeb5b5770326a639d58fd3b5609d0ce'

client = APIClient(app_key=APP_KEY, app_secret=APP_SECRET)
client.oauth_token = access_token
client.oauth_token_secret = token_secret

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
        tweets = client.trends__statuses(trend_name='街拍', page=page)
        if page > 1:
            break

    #svm predict
    selected = set()
    for t in all:
        x = build_x(t[3])
        if predict(x):
            pic = t[1]
            passed = True

            try:
                r = urllib2.urlopen(pic)
                im = open_pic(r.read())
                width, height = im.size
                if height / width > 1.7777 or width / height > 1.7777:
                    passed = False
            except :
                import traceback; traceback.print_exc()
            if passed:
                selected.add(t)
                print pic

    print '选中:', len(selected)

    #save to draft
    for line in selected:
        try:
            store.execute('insert into draft (sid, pic, author, text, create_time) \
              values(%s,"%s",%s,"%s", now())' % line)
        except:
            print '已经插入'

if __name__ == '__main__':
    download_snap_timeline()
