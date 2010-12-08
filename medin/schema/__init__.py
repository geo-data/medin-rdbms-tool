"""
Data Archive Centre (DAC) schema specific plugin modules
"""

class Session(object):
    """
    Abstract base class for interacting with a schema
    """
    vocabs = None
    sess = None

    def __init__(self, engine, vocabs):
        self.vocabs = vocabs

        self.setMapping()

        from sqlalchemy.orm import sessionmaker
        Sess = sessionmaker(bind=engine)
        self.sess = Sess()

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
