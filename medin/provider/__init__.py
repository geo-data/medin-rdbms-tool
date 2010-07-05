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
        raise NotImplementedError('This method must be overridden')
