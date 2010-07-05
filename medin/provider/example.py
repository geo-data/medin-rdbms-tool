"""
Example Metadata Provider

This provides an example of how to add a metadata provider. It is
based on the BODC metadata schema, which it partly implements in a
sqlite database. This database can be found in data/example.sqlite

As with any provider, the primary purpose of this module is to create
a sqlalchemy mapping from the database schema to the medin.Metadata
class.
"""

from medin.provider import Session
import medin.metadata as metadata

# The BODC metadata classes
class BODCMetadata(metadata.Metadata):
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


class UniqueId(metadata.UniqueId):
    """
    Element 6

    This element is defined to allow it to be used as a SQLAlchemy
    composite column type
    (http://www.sqlalchemy.org/docs/mappers.html#composite-column-types).
    """
    def __composite_values__(self):
        return [self.id, self.codespace]
    
    def __set_composite_values__(self, id, codespace):
        self.id = id
        self.codespace = codespace

class BoundingBox(metadata.BoundingBox):
    """
    Element 12

    This element is defined to allow it to be used as a SQLAlchemy
    composite column type
    (http://www.sqlalchemy.org/docs/mappers.html#composite-column-types).
    """
    def __composite_values__(self):
        return [self.minx, self.miny, self.maxx, self.maxy]
    
    def __set_composite_values__(self, minx, miny, maxx, maxy):
        self.minx = minx
        self.miny = miny
        self.maxx = maxx
        self.maxy = maxy

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
        import medin
        import os.path

        super(Session, self).__init__(connstr)

        # we ignore the connection string
        dbname = os.path.abspath(os.path.join(os.path.dirname(medin.__file__), 'data', 'example.sqlite'))
        self.engine = create_engine('sqlite:///'+dbname, echo=medin.DEBUG)
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
        from sqlalchemy.orm import mapper, relationship, composite

        schema = self.getSchema()

        alt_title_table = schema.tables['ALT_TITLE']
        mapper(AlternativeTitle, alt_title_table)

        metadata_table = schema.tables['METADATA']
        mapper(BODCMetadata, metadata_table, properties={
            'date': metadata_table.c.MODDATE,
            'title': metadata_table.c.TITLE,
            'abstract': metadata_table.c.ABSTRACT,
            'unique_id': composite(UniqueId, metadata_table.c.IDENTIFIER, metadata_table.c.CODESPACE),
            'bounding_box': composite(BoundingBox, metadata_table.c.WEST, metadata_table.c.SOUTH, metadata_table.c.EAST, metadata_table.c.NORTH),
            'alt_titles': relationship(AlternativeTitle, order_by=AlternativeTitle.ALTTITLE)
        })

    def getMetadataById(self, code):
        # return a metadata instance
        from sqlalchemy.orm.exc import NoResultFound
        
        id = UniqueId(code, 'http://www.bodc.ac.uk/')
        try:
            return self.sess.query(BODCMetadata).filter(BODCMetadata.unique_id == id).one()
        except NoResultFound:
            return None

    def __iter__(self):
        # iterate over all metadata instances
        for metadata in self.sess.query(BODCMetadata):
            yield metadata
