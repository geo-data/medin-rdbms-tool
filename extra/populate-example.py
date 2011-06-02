# Inspired by http://www.tylerlesmann.com/2009/apr/27/copying-databases-across-platforms-sqlalchemy/
# ensure we're using UTF-8
import sys
sys = reload(sys)
sys.setdefaultencoding('utf-8')

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

def make_session(connection_string):
    engine = create_engine(connection_string, echo=False, convert_unicode=True)
    Session = sessionmaker(bind=engine)
    return Session(), engine

def quick_mapper(table):
    Base = declarative_base()
    class GenericMapper(Base):
        __table__ = table
    return GenericMapper

import medin.vocabulary
import medin.contact

from os.path import join, dirname, abspath

src_connstr = 'sqlite:///'+abspath(join(dirname(medin.__file__),'data','example.sqlite'))
#dst_connstr = 'oracle://medin:mdip@localhost:1521/XE'
#dst_connstr = 'mssql://medin:mdip@MEDIN'
dst_connstr = 'mysql://homme:mdip@localhost/medin'

print "Copying %s to %s" % (src_connstr, dst_connstr)

source, src_e = make_session(src_connstr)
destination, dst_e = make_session(dst_connstr)

import medin.schema
import imp
schema_module = imp.load_module('medin', *imp.find_module('medin', medin.schema.__path__))

vocabs = medin.vocabulary.Session()
contacts = medin.contact.Session()
s = schema_module.Session(src_e, vocabs, contacts)

sch_src = s.getSchema()
sch_src.bind = src_e

print "Creating destination database schema"
sch_dst = s.getSchema()
sch_dst.bind = dst_e
sch_dst.drop_all()
sch_dst.create_all()

for src_table in sch_src.sorted_tables:
    print "Copying table %s" % src_table.name

    NewRecord = quick_mapper(src_table)
    columns = src_table.columns.keys()

    for record in source.query(src_table).all():
        data = dict(
            [(str(column), getattr(record, column)) for column in columns]
            )
        destination.merge(NewRecord(**data))

print "Committing"
destination.commit()
