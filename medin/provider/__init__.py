"""
Data Archive Centre (DAC) specific plugin modules are provided here
"""

class Session(object):
    """
    Abstract base class for interacting with a data provider
    """

    engine = None
    connstr = None
    vocabs = None
    sess = None

    def __init__(self, connstr, vocabs):
        self.connstr = connstr
        self.vocabs = vocabs
        engine = self.getEngine()
        self.setMapping()

        from sqlalchemy.orm import sessionmaker
        Sess = sessionmaker(bind=engine)
        self.sess = Sess()

    def getEngine(self):
        """
        A stub providing access to the engine
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
