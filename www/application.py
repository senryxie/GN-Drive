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
    return render_template('index.html', **locals())

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
    return render_template('index.html', **locals())

@app.route('/version/')
def get_version():
    ret = { 'version': 1 }
    ret['action'] = 'version'
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
