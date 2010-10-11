"""
BODC Metadata Provider

Connects to Oracle archive, extracts according to the BODC schema.

connection string:
"medin/mdip@lorna:1521/XE" (cx_Oracle plain)
"medin:mdip@lorna:1521/XE" (sqlalchemy with cx_Oracle)

see example.py for details
"""

# from example.py...
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

class ResourceLocator(metadata.ResourceLocator):
    """
    Element 5
    """
    CITATIONID = None

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

class CoupledResource(object):
    """
    Element 7
    """
    METADATAID = None
    resource = None

class ResourceLanguage(object):
    """
    Element 8
    """
    language = None
    code = None
    def __init__(self, code, language):
        self.language = language
        self.code = code

class Keyword(object):
    """
    Element 10
    """
    keyword = None
    thesaurus = None
    

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

    def getEngine(self):
        # only new bit so far -- tries to connect to oracle (lorna)
        if self.engine:
            return self.engine

        # connect to oracle DB using self.connstr
        from sqlalchemy import create_engine
        import medin
        self.engine = create_engine('oracle://'+self.connstr, echo=medin.DEBUG)
        return self.engine

    def getSchema(self):
        """
        Return a sqlalchemy.MetaData object representing the database schema
        """
        from sqlalchemy import Table, Column, Numeric, String, Date, DateTime, MetaData, ForeignKey

        metadata = MetaData() # N.B. not a medin.metadata.Metadata object!!
        metadata_table = Table(
            'METADATA', metadata,
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
            Column('STD_ID', Numeric(10)))

        alt_title_table = Table(
            'ALT_TITLE', metadata,
            Column('METADATAID', Numeric(10), ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('ALTTITLE', String(350), primary_key=True))

        citation_table = Table(
            'CITATION', metadata,
            Column('CITATIONID', Numeric(10), ForeignKey('METADATA.RESLOC'), primary_key=True),
            Column('PUBYEAR', Date()),
            Column('PUBTYP', String(30)),
            Column('PUBTITLE', String(1000)),
            Column('VOLUME', Numeric(10)),
            Column('ISSUE', String(45)),
            Column('PAGES', String(10)),
            Column('AUTHORS', String(1000)),
            Column('EDITORS', String(255)),
            Column('PUBPLACE', String(200)),
            Column('ORGREP', String(255)),
            Column('ONLINERES', String(500)),
            Column('ONLINERESNAM', String(500)),
            Column('EDITION', String(25)),
            Column('EDITIONDATE', Date()),
            Column('PUBLISHER', String(255)),
            Column('PUBSUBTYP', String(30)),
            Column('CONTRACTCODE',String(100)),
            Column('URL_ACCESSED', Date()))

        coupled_res_table = Table(
            'COUPLED_RES', metadata,
            Column('METADATAID', Numeric(10), ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('COUPLRES', String(200), primary_key=True))
           
        ctrlvocab_res_table = Table(
            'CTRLVOCAB_RES', metadata,
            Column('METADATAID', Numeric(10), ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('TERMID', String(10), primary_key=True))
        return metadata

    def setMapping(self):
        """
        Map the Metadata classes to the provider database schema
        """
        from sqlalchemy.orm import mapper, relationship, composite, column_property
        from sqlalchemy.sql.expression import select, label

        schema = self.getSchema()

        alt_title_table = schema.tables['ALT_TITLE']
        mapper(AlternativeTitle, alt_title_table)
        
        citation_table = schema.tables['CITATION']
        mapper(ResourceLocator, citation_table, properties={
                'url': citation_table.c.ONLINERES,
                'name': citation_table.c.ONLINERESNAM
                })

        coupled_res_table = schema.tables['COUPLED_RES']
        mapper(CoupledResource, coupled_res_table, properties={
                'resource': coupled_res_table.c.COUPLRES
                })

        ctrlvocab_res_table = schema.tables['CTRLVOCAB_RES']
        mapper(Keyword, ctrlvocab_res_table, properties={
                'keyword': column_property(
                    select(["substr(%s,3)" % ctrlvocab_res_table.c.TERMID]).label('keyword')),
                'thesaurus': column_property(
                    select(["substr(%s,0,2)" % ctrlvocab_res_table.c.TERMID]).label('thesaurus'))
                })

        metadata_table = schema.tables['METADATA']
        mapper(BODCMetadata, metadata_table, properties={
            'date': metadata_table.c.MODDATE,
            'title': metadata_table.c.TITLE,
            'abstract': metadata_table.c.ABSTRACT,
            'resource_type': metadata_table.c.RESTYP_ID,
            'resource_locators': relationship(ResourceLocator), # TODO: update, see Schema Changes, medin_schema_doc_2_3_3_11mar10.doc
            'unique_id': composite(UniqueId, metadata_table.c.IDENTIFIER, metadata_table.c.CODESPACE),
            'coupled_resources': relationship(CoupledResource),
            'keywords': relationship(Keyword),
            'bounding_box': composite(BoundingBox, metadata_table.c.WEST, metadata_table.c.SOUTH, metadata_table.c.EAST, metadata_table.c.NORTH),
            'alt_titles': relationship(AlternativeTitle, order_by=AlternativeTitle.ALTTITLE)
        })

    def getMetadataById(self, code):
        # return a metadata instance
        from sqlalchemy.orm.exc import NoResultFound
        
        id = UniqueId(code, 'http://www.bodc.ac.uk/')
        try:
            metadata = self.sess.query(BODCMetadata).filter(BODCMetadata.unique_id == id).one()
            metadata.vocabs = self.vocabs
            # hard-coded values...
            metadata.resource_languages = [ResourceLanguage('eng', 'English')]
            return metadata
        except NoResultFound:
            return None

    def __iter__(self):
        # iterate over all metadata instances
        for metadata in self.sess.query(BODCMetadata):
            metadata.vocabs = self.vocabs
            # hard-coded values...
            metadata.resource_languages = [ResourceLanguage('eng', 'English')]
            yield metadata

