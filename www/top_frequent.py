#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import re
from libs.smallseg.smallseg import SEG
from libs.sqlstore import store

seg = SEG()
ban_list = ['-', '的', '是', '@', '#', '/', '.', '_', '~', '+', 'T', '..', '##', '//', '~~', '...', 'weibo.com', '--', 't.cn', '街拍']
url_re = re.compile(r'http://.*?')

def get_top_list():
    sql = "select text from sample where status=1"
    store.execute(sql)
    rs = store.fetchall()
    tweets = [r[0] for r in rs]
    store.close()

    dicts={}
    top = []

    for t in tweets:
        t = url_re.sub('', t)
        w_list = seg.cut(t.strip())
        w_list.reverse()
        for w in w_list:
            w = w.encode('utf-8')
            #print 'word:', w
            if w in ban_list:
                continue
            dicts[w] = dicts.get(w,0) + 1

    for key, value in dicts.items():
        if len(key) and value > 1:
            top.append((key, value))

    top.sort(key=lambda x:x[1], reverse=True)
    return top

if __name__ == '__main__':
    top = get_top_list()
    for k, v in top:
        print k, v
