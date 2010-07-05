"""
Data Archive Centre (DAC) specific plugin modules are provided here
"""

class Session(object):
    """
    Abstract base class for interacting with a data provider
    """

    def __init__(self, connstr):
        self.connstr = connstr

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
