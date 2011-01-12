"""
Print out the database SQL schema

This script outputs the SQL table creation statements for a
combination of specific MEDIN schema and database dialect.
"""

# ensure we're using UTF-8
import sys
sys = reload(sys)
sys.setdefaultencoding('utf-8')

from sqlalchemy import create_engine
from sqlalchemy.schema import CreateTable
import medin.vocabulary
import medin.contact
import medin.schema
import imp

schema_module = imp.load_module('medin', *imp.find_module('medin', medin.schema.__path__))
e = create_engine('oracle://medin/mdip@localhost:1521/XE')
vocabs = medin.vocabulary.Session()
contacts = medin.contact.Session()
sess = schema_module.Session(e, vocabs, contacts)
schema = sess.getSchema()

for table in schema.sorted_tables:
    print str(CreateTable(table)).strip()+';'
