# -*- coding: utf-8 -*-

from flask import g, request, render_template, jsonify
from application import app

@app.route('/')
def index():
    length = 21
    start  = request.args.get('start', 0)
    start = 0 if int(start) < 0 else int(start)

    next = start + length
    pre = start - length if start - length > 0 else 0

    sql = "select * from entry  order by create_time desc \
            limit %s, %s" % (start, length)
    c = g.db.cursor()
    c.execute(sql)
    msgs = list(c.fetchall())
    return render_template('index.html', **locals())

@app.route('/version/')
def get_version():
    ret = { 'version': 1 }
    ret['action'] = 'version'
    return jsonify(ret)
