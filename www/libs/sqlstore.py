# -*- coding: utf-8 -*-
import MySQLdb

class Store:
    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(Store, cls).__new__(
                                cls, *args, **kwargs)
        return cls._instance

    def __init__(self):
        self.con = None
        self.c = None

    def close(self):
        self.con.close()

    def execute(self, sql):
        self.con = MySQLdb.connect('localhost', 'eye', 'sauron', 'exia')
        self.c = self.con.cursor()
        try:
            ret = self.c.execute(sql)
            self.con.commit()
            return ret
        except:
            import traceback; traceback.print_exc()
        self.close()

    def fetchall(self):
        return self.c.fetchall()

    def fetchone(self):
        return self.c.fetchone()

store = Store()
