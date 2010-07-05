"""
BODC Metadata Provider

This module has a knowledge of the BODC metadata schema and provides a
sqlalchemy mapping from the schema to the metadata object.
"""

# - import the base provider class
# - set up an in-memory sqlite database in lieu of the oracle db
# - set up a sqlalchemy mapping to the db to populate the minimal Metadata object

from medin.provider import Session
from medin.metadata import Metadata

class Session(Session):

    def getMetadataById(self, id):
        # a stub function providing the interface

        metadata =  Metadata()

        # set a dummy date
        from datetime import date
        metadata.date = date.today()

        return metadata
