#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys
from os.path import dirname, abspath
HOME_PATH = dirname(abspath(__file__))
sys.path.insert(0, HOME_PATH)

import re
from libs.smallseg.smallseg import SEG
from libs.sqlstore import store

seg = SEG()

digit_re = re.compile(r'.?\d+.?\d*.?', re.DOTALL)

ban_list = ['-', '的', '是', '@', '#', '/', '.', '_', '~', '+', 'T', '..', '##', '//', '~~', '...', 'weibo.com', '--', 't.cn', '街拍', '...-',
           '没', '欧', '下', '[囧', '囧]', '里', '[太', '找', '基', '社', '来的', '具', ']~', '～～', 'by', '次', 't', '吧~', '啊', '&',
           '中', '~[', '?', '】', '在', '【', '了', ']',
            '就', '原', '这', '详情请', '从', '加', '熊猫', '网友', '月号', '博也', '``', 'h4MS2M', '被', ';', '#t.cn', '*', '陈皮', '1747534564', '@kiki', '王晓', '发表', '亚马逊', 'http', 'Http', '兰州', 'else.', '】长', ]
url_re = re.compile(r'http://.*?')

def get_top_list(status=1):
    sql = "select text from sample where status=%s" % status
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
            if digit_re.match(w):
                continue
            dicts[w] = dicts.get(w,0) + 1

    for key, value in dicts.items():
        if len(key) and value > 1:
            top.append((key, value))

    top.sort(key=lambda x:x[1], reverse=True)
    return top

if __name__ == '__main__':
    import sys
    args = sys.argv
    print 'get_frequent.py trash'
    if len(args) == 2 and args[1] == 'trash':
        top = get_top_list(status=0)
    else:
        top = get_top_list()
    for k, v in top[1000:]:
        print k, v
    print len(top)
