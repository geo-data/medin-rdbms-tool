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
        from sqlalchemy import MetaData
        
        errors = []
        my_schema = self.getSchema()
        db_schema = MetaData(self.sess.bind)
        db_schema.reflect()

        # iterate over each schema table
        for my_table in my_schema.tables.values():
            # ensure the table exists in the database
            try:
                db_table = db_schema.tables[my_table.name]
            except KeyError:
                errors.append('The table does not exist in the database: '+my_table.name)
                continue

            # ensure each column exists
            for my_column in my_table.columns:
                try:
                    db_column = db_table.columns[my_column.name]
                except KeyError:
                    errors.append('The column does not exist in the table "%s": %s' % (db_table.name, my_column.name))
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
