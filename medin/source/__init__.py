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
Data Archive Centre (DAC) schema specific plugin modules
"""

class Session(object):
    """
    Abstract base class for interacting with a schema
    """
    vocabs = None
    contacts = None
    sess = None

    def __init__(self, engine, vocabs, contacts):
        self.vocabs = vocabs
        self.contacts = contacts

        self.setMapping()

        from sqlalchemy.orm import sessionmaker
        Sess = sessionmaker(bind=engine)
        self.sess = Sess()

    def verifySchema(self):
        """
        Check the database schema matches expectations

        Reflect the database schema and check it against the plugin
        schema.
        """
        from sqlalchemy import MetaData, Table
        from sqlalchemy.engine.reflection import Inspector
        
        errors = []
        my_schema = self.getSchema()
        db_schema = MetaData()
        insp = Inspector.from_engine(self.sess.bind)

        # create a case insensitive map between table names in the user database
        table_map = dict([(name.lower(), name) for name in insp.get_table_names()])
        
        # iterate over each schema table
        for my_table in my_schema.tables.values():
            # ensure the table exists in the database
            try:
                table_name = table_map[my_table.name.lower()]
            except KeyError:
                errors.append('The table does not exist in the database: '+my_table.name)
                continue

            # create a case insensitive map between column names for the user table
            column_map = dict([(column['name'].lower(), column) for column in insp.get_columns(table_name)])

            # ensure each required column exists in the user table
            for my_column in my_table.columns:
                try:
                    db_column = column_map[my_column.name.lower()]
                except KeyError:
                    errors.append('The column does not exist in the table "%s": %s' % (table_name, my_column.name))
                    continue

        return errors

    def getSchema(self):
        """
        Return a sqlalchemy.MetaData object representing the database schema
        """
        raise NotImplementedError('This method must be overridden')

    def setMapping(self):
        """
        Map the Metadata classes to the provider database schema
        """
        raise NotImplementedError('This method must be overridden')

    def getMetadataById(self, id):
        """
        A stub providing access to individual metadata objects
        """
        raise NotImplementedError('This method must be overridden')

    def __iter__(self):
        """
        A stub providing the provider iterator interface

        This method should return an iterator of all provider metadata
        objects.
        """
        raise NotImplementedError('This method must be overridden')
