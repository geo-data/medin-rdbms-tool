# Created by Homme Zwaagstra
# 
# Copyright (c) 2011 GeoData Institute
# http://www.geodata.soton.ac.uk
# geodata@soton.ac.uk
# 
# Unless explicitly acquired and licensed from Licensor under another
# license, the contents of this file are subject to the Reciprocal
# Public License ("RPL") Version 1.5, or subsequent versions as
# allowed by the RPL, and You may not copy or use this file in either
# source code or executable form, except in compliance with the terms
# and conditions of the RPL.
# 
# All software distributed under the RPL is provided strictly on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR
# IMPLIED, AND LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES,
# INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT, OR
# NON-INFRINGEMENT. See the RPL for specific language governing rights
# and limitations under the RPL.
# 
# You can obtain a full copy of the RPL from
# http://opensource.org/licenses/rpl1.5.txt or geodata@soton.ac.uk

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
import medin.source
import imp

schema_module = imp.load_module('medin', *imp.find_module('medin', medin.source.__path__))
e = create_engine('oracle://medin/mdip@localhost:1521/XE')
vocabs = medin.vocabulary.Session()
contacts = medin.contact.Session()
sess = schema_module.Session(e, vocabs, contacts)
schema = sess.getSchema()

for table in schema.sorted_tables:
    print str(CreateTable(table)).strip()+';'
