# -*- coding: utf-8 -*-

from flask import g

class User(object):
    def __init__(self, id, udid, start, end, utime, ctime):
        self.id = id
        self.udid = udid
        self.start = start
        self.end = end
        self.utime = utime
        self.ctime = ctime

    @classmethod
    def new(cls, udid, start=0, end=0):
        if '-' in udid:
            udid = ''.join(udid.split('-'))
        sql = "insert into device (udid, start, end, create_time) values \
                ('%s', %s, %s, now())" % (udid, start, end)
        c = g.db.cursor()
        c.execute(sql)
        g.db.commit()

    @classmethod
    def get(cls, udid):
        if '-' in udid:
            udid = ''.join(udid.split('-'))
        sql = "select * from device where udid='%s'" % udid
        c = g.db.cursor()
        c.execute(sql)
        r = c.fetchone()
        if r:
            return cls(*r)

    def update(self, start, end):
        sql = "update device set start=%s, end=%s where id=%s" % (start, end, self.id)
        c = g.db.cursor()
        c.execute(sql)
        g.db.commit()

    @property
    def page(self):
        sql = "select count(*) from entry"
        c = g.db.cursor()
        c.execute(sql)
        r = c.fetchone()
        return self.start or self.end or int(r[0] / 5)
