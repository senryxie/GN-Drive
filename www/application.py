# -*- coding: utf-8 -*-
import MySQLdb
from flask import Flask, g, request, render_template, jsonify

app = Flask(__name__)
from flup.server.fcgi import WSGIServer

from collections import namedtuple
import api_1

Draft = namedtuple('Draft', 'id, sid, pic, snum, lnum, author, text, utime, ctime, status')

@app.before_request
def before_request():
    g.db = MySQLdb.connect('localhost', 'eye', 'sauron',
            'exia', port=3306)

@app.teardown_request
def teardown_request(exception):
    if hasattr(g, 'db'):
        g.db.close()

@app.route('/')
def index():
    length = 21
    start  = request.args.get('start', 0)
    start = 0 if int(start) < 0 else int(start)

    next = start + length
    pre = start - length if start - length > 0 else 0

    sql = "select * from entry order by id desc \
            limit %s, %s" % (start, length)
    c = g.db.cursor()
    c.execute(sql)
    msgs = map(Draft._make, c.fetchall())
    return render_template('index.html', **locals())

@app.route('/draft')
def draft():
    length = 21
    start  = request.args.get('start', 0)
    start = 0 if int(start) < 0 else int(start)

    next = start + length
    pre = start - length if start - length > 0 else 0

    sql = "select * from draft order by id desc \
            limit %s, %s" % (start, length)
    c = g.db.cursor()
    c.execute(sql)
    msgs = map(Draft._make, c.fetchall())
    return render_template('draft.html', **locals())

@app.route('/sample')
def sample():
    length = 21
    start  = request.args.get('start', 0)
    start = 0 if int(start) < 0 else int(start)

    next = start + length
    pre = start - length if start - length > 0 else 0

    sql = "select * from sample order by id desc \
            limit %s, %s" % (start, length)
    c = g.db.cursor()
    c.execute(sql)
    msgs = map(Draft._make, c.fetchall())
    return render_template('sample.html', **locals())

@app.route('/version/')
def get_version():
    ret = { 'version': 1 }
    ret['action'] = 'version'
    return jsonify(ret)

@app.route('/classification/<int:sid>/')
def classification(sid):
    c = g.db.cursor()
    sql = "select * from draft where sid=%s" % sid
    c.execute(sql)
    r = c.fetchone()
    draft = Draft(*r)
    status = 1 - draft.status
    sql = 'update draft set status=%s where sid=%s' % (status, sid)

    ret = {}
    c.execute(sql)
    g.db.commit()
    if status:
        try:
            c.execute('insert into entry (sid, pic, author, text, create_time, status) \
              values(%s,"%s",%s,"%s", now(), 1)' % \
              (draft.sid, draft.pic, draft.author, draft.text))
            g.db.commit()
        except:
            print '重复插入'
    else:
        try:
            c.execute('delete from entry where id=%s' % draft.id)
            g.db.commit()
        except:
            print '删除失败'
    ret['status'] = status
    return jsonify(ret)

@app.route('/remove_entry/<int:sid>/')
def remove_entry(sid):
    c = g.db.cursor()
    sql = "select * from entry where sid=%s" % sid
    c.execute(sql)
    r = c.fetchone()
    draft = Draft(*r)
    status = 1 - draft.status
    sql = 'update draft set status=%s where sid=%s' % (status, sid)

    ret = {}
    c.execute(sql)
    g.db.commit()
    try:
        c.execute('delete from entry where id=%s' % draft.id)
        g.db.commit()
    except:
        print '删除失败'
    ret['status'] = status
    return jsonify(ret)

if __name__ == "__main__":
    import sys
    args = sys.argv
    if len(args) == 2 and args[1] == 'test':
        print 'test mode'
        app.debug = True
        app.run(host='0.0.0.0')
    else:
        WSGIServer(app,bindAddress='/var/www/gn-drive.sock').run()
