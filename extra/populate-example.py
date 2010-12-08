# ensure we're using UTF-8
import sys
sys = reload(sys)
sys.setdefaultencoding('utf-8')

import medin.provider.example
import medin.vocabulary
vocabs = medin.vocabulary.Session()
s = medin.provider.example.Session('test', vocabs)
sch = s.getSchema()

from sqlalchemy import create_engine
from os.path import join, dirname, abspath
dbname = abspath(join(dirname(medin.__file__),'data','example.sqlite'))
print "Populating %s" % dbname

e = create_engine('sqlite:///'+dbname)
sch.bind = e
sch.drop_all()
sch.create_all()

import cx_Oracle
c = cx_Oracle.connect('medin/mdip@localhost:1521/XE') # oracle connection
db = e.raw_connection()                 # sqlite connection

from itertools import repeat
src = c.cursor()
dst = db.cursor()
for table_name in sch.tables:
    print 'Copying %s' % table_name
    columns = sch.tables[table_name].columns.keys()
    colnames = ', '.join(columns)
    sql_src = 'SELECT %s FROM %s' % (colnames, table_name)
    #print sql_src
    src.execute(sql_src)
    
    sql_dst = 'INSERT INTO %s (%s) VALUES (%s)' % (table_name, colnames, ','.join(repeat('?', len(columns))))
    #print sql_dst
    dst.executemany(sql_dst, src)

db.commit()
dst.close()
src.close()
