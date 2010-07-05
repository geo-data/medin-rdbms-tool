"""
BODC Metadata Provider

This module has a knowledge of the BODC metadata schema and provides a
sqlalchemy mapping from the schema to the metadata object.
"""

# - set up an in-memory sqlite database in lieu of the oracle db
# - set up a sqlalchemy mapping to the db to populate the minimal Metadata object

from medin.provider import Session
from medin.metadata import Metadata

# The BODC metadata classes
class BODCMetadata(Metadata):
    """
    A class that is used for the sqlalchemy mapping

    This is used instead of the base Metadata class to avoid mapping
    clashes if more than one provider were to be used.
    """

class AlternativeTitle(object):
    """
    This represents an alternative title (Element 2)
    """
    METADATAID = None
    ALTTITLE = None
    
    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, self.ALTTITLE)

    def __str__(self):
        return str(self.ALTTITLE)

# The concrete provider Session class
class Session(Session):
    """
    A concrete implementation of the Provider class

    This provides an interface to obtaining metadata entries by ID as
    well as iterating over the entire metadata collection.
    """

    def __init__(self, connstr):
        from sqlalchemy import create_engine
        from sqlalchemy.orm import sessionmaker
        from medin import DEBUG

        super(Session, self).__init__(connstr)

        self.engine = create_engine('sqlite:///'+connstr, echo=DEBUG)
        self.setMapping()
        Sess = sessionmaker(bind=self.engine)
        self.sess = Sess()

    def getSchema(self):
        """
        Return a sqlalchemy.MetaData object representing the database schema
        """
        from sqlalchemy import Table, Column, Numeric, String, Date, DateTime, MetaData, ForeignKey

        metadata = MetaData() # N.B. not a medin.metadata.Metadata object!!
        metadata_table = Table('METADATA', metadata,
                               Column('METADATAID', Numeric(10), primary_key=True),
                               Column('TITLE', String(500)),
                               Column('ABSTRACT', String(4000)),
                               Column('RESTYP_ID', Numeric(10), nullable=False),
                               Column('RESLOC', String(200)),
                               Column('IDENTIFIER', String(255)),
                               Column('CODESPACE', String(255), default='http://www.bodc.ac.uk'),
                               Column('SDSTYP_ID', Numeric(10)),
                               Column('WEST', Numeric(7,4)),
                               Column('EAST', Numeric(7,4)),
                               Column('NORTH', Numeric(7,4)),
                               Column('SOUTH', Numeric(7,4)),
                               Column('VERTEXTMIN', Numeric(11)),
                               Column('VERTEXTMAX', Numeric(11)),
                               Column('VERTEXTREF_ID', String(500)),
                               Column('SRSYS_ID', String(500)),
                               Column('TEMPEXBGN', String(20)),
                               Column('REVDATE', Date()),
                               Column('CREATED', Date()),
                               Column('PUBDATE', Date()),
                               Column('TEMPEXEND', String(20)),
                               Column('LINEAGE', String(4000)),
                               Column('SPARES', String(20)),
                               Column('FREQMOD_ID', Numeric(10)),
                               Column('MODDATE', DateTime()),
                               Column('MODBY', String(50)),
                               Column('STD_ID', Numeric(10))
                               )
        alt_title_table = Table('ALT_TITLE', metadata,
                                Column('METADATAID', Numeric(10), ForeignKey('METADATA.METADATAID'), primary_key=True),
                                Column('ALTTITLE', String(350), primary_key=True)
                                )
        return metadata

    def setMapping(self):
        """
        Map the Metadata classes to the provider database schema
        """
        from sqlalchemy.orm import mapper, relationship
        from medin.metadata import UniqueId

        schema = self.getSchema()

        alt_title_table = schema.tables['ALT_TITLE']
        mapper(AlternativeTitle, alt_title_table)

        metadata_table = schema.tables['METADATA']
        mapper(BODCMetadata, metadata_table, properties={
            'date': metadata_table.c.MODDATE,
            'title': metadata_table.c.TITLE,
            'alt_titles': relationship(AlternativeTitle, order_by=AlternativeTitle.ALTTITLE)
        })

    def getMetadataById(self, id):
        # return a dummy metadata instance
        metadata = BODCMetadata()

        # set a dummy date
        from datetime import date
        metadata.date = date.today()

        return metadata

    def __iter__(self):
        # iterate over dummy metadata instances
        from datetime import datetime
        for metadata in self.sess.query(BODCMetadata):
            yield metadata
