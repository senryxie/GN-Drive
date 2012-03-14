# -*- coding: utf-8 -*-
import MySQLdb

class Store:
    def __init__(self):
        self.con = MySQLdb.connect('localhost', 'eye', 'sauron', 'exia')
        self.c = self.con.cursor()

    def close(self):
        self.con.close()

    def execute(self, sql):
        try:
            ret = self.c.execute(sql)
            self.con.commit()
            return ret
        except:
            import traceback; traceback.print_exc()

    def fetchall(self):
        return self.c.fetchall()

    def fetchone(self):
        return self.c.fetchone()

store = Store()
