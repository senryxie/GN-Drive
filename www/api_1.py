# -*- coding: utf-8 -*-

from flask import g, request, jsonify
from application import app
from user import User

PAGE_LIMIT = 5

@app.route('/v/1/user/<udid>/start_page/')
def user_start_page(udid):
    user = User.get(udid)
    if not user:
        User.new(udid)
        user = User.get(udid)

    ret = {}
    ret['action'] = 'get_start_page'
    ret['page'] = user.page
    return jsonify(ret)

@app.route('/v/1/snaps/<int:page>/')
def get_snaps(page):
    start = page * PAGE_LIMIT
    sql = "select * from entry order by id asc limit %s, %s" % (start, PAGE_LIMIT)
    c = g.db.cursor()
    c.execute(sql)
    data = c.fetchall()
    ret = {}
    pics = []
    for row in data:
        pic = {}
        pic['id'] = row[0]
        pic['url'] = row[2]
        pic['text'] = '触摸时尚'
        pics.append(pic)

    ret['more'] = False
    if len(pics) == PAGE_LIMIT: #本页取到limit张图片，则认为仍然有下一页
        ret['more'] = True

    ret['action'] = 'get_multi'
    ret['pics'] = pics
    return jsonify(ret)

@app.route('/v/1/snap/<snap_id>/')
def get_snap(snap_id):
    sql = "select * from entry where id=%s" % snap_id
    c = g.db.cursor()
    c.execute(sql)
    data = c.fetchone()

    pic = {}
    pic['id'] = data[0]
    pic['url'] = data[2]
    pic['text'] = '街拍控图册'

    ret = pic
    ret['action'] = 'single'
    return jsonify(ret)

@app.route('/v/1/user/<udid>/feedback/')
def post_feedback(udid):
    user = User.get(udid)
    if not user:
        User.new(udid)
        user = User.get(udid)

    feedback = request.args.get('feedback', '')
    ret = {}
    ret['udid'] = user.udid
    ret['feedback'] = feedback or '未反馈'
    ret['action'] = 'feedback'

    ret['r'] = 1
    if feedback:
        ret['r'] = 0
    return jsonify(ret)
