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
    a multiple element
    metadata.py accesses values through __str__
    """
    METADATAID = None
    ALTTITLE = None
    
    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, self.ALTTITLE)

    def __str__(self):
        return str(self.ALTTITLE)

class AccessUse(object):
    """
    Elements 20 & 21
    """
    ACCESSUSEID = None
    DESCRIPTION = None

    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, self.DESCRIPTION)
    def __str__(self):
        return str(self.DESCRIPTION)

class AccessConstraint(object):
    """
    Element 20
    """
    METADATAID = None
    ISOCODEID = None

class ResponsibleParty(object):
    RESPARTYID = None
    ROLEID = None # from resparty_res_table
    CONTACTTITLEID = None
    FIRSTNAME = None
    SURNAME = None
    ORGID = None
    POSITIONTITLE = None
    CONTACTID = None
    NOTES = None

class ResourceLocator(metadata.ResourceLocator):
    """
    Element 5
    a multiple element
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

class CoupledResource(metadata.CoupledResource):
    """
    Element 7
    """
    METADATAID = None

class ResourceLanguage(metadata.ResourceLanguage):
    """
    Element 8
    """
    def __init__(self, code, language):
        self.language = language
        self.code = code

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

class VerticalExtent(metadata.VerticalExtent):
    """
    Element 14
    """
    def __composite_values__(self):
        return [self.minv, self.maxv, self.refid]

    def __set_composite_values__(self, minv, maxv, refid):
        self.minv = minv
        self.maxv = maxv
        self.refid = refid

# class SpatialReferenceSystem(metadata.SpatialReferenceSystem):
#    """
#    Element 15
#    """

class TemporalReference(metadata.TemporalReference):
    """
    Element 16
    """
    def __composite_values__(self):
        return [self.extent_begin, self.extent_end,
                self.date_publication, self.date_revision, self.date_creation]
    def __set_composite_values__(self, extent_begin, extent_end,
                                 date_publication, date_revision,
                                 date_creation):
        self.extent_begin = extent_begin
        self.extent_end = extent_end
        self.date_publication = date_publication
        #self.date_publication_type = date_publication_type
        self.date_revision = date_revision
        #self.date_revision_type = date_revision_type
        self.date_creation = date_creation
        #self.date_creation_type = date_creation_end

class SpatialResolution(metadata.SpatialResolution):
    """
    Element 18
    """
    # emulate array
    def __iter__(self):
        yield self

    def __composite_values__(self):
        return [self.distance, self.equivalent_scale]
    def __set_composite_values__(self, distance, equivalent_scale):
        self.distance = distance
        self.equivalent_scale = equivalent_scale


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
            Column('METADATAID', Numeric(10),
                   ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('COUPLRES', String(200), primary_key=True))
           
        ctrlvocab_res_table = Table(
            'CTRLVOCAB_RES', metadata,
            Column('METADATAID', Numeric(10),
                   ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('TERMID', String(10), primary_key=True))

        access_use_table = Table(
            'ACCESS_USE', metadata,
            Column('ACCESSUSEID', Numeric(10), primary_key=True),
            Column('DESCRIPTION', String(400)))

        o_r_resolve_table = Table(
            'O_R_RESOLVE', metadata,
            Column('METADATAID', Numeric(10),
                   ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('ACCESSUSEID', Numeric(10),
                   ForeignKey('ACCESS_USE.ACCESSUSEID'), primary_key=True))

        a_u_resolve_table = Table(
            'A_U_RESOLVE', metadata,
            Column('METADATAID', Numeric(10),
                   ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('ACCESSUSEID', Numeric(10),
                   ForeignKey('ACCESS_USE.ACCESSUSEID'), primary_key=True))

        a_c_resolve_table = Table(
            'A_C_RESOLVE', metadata,
            Column('METADATAID', Numeric(10),
                   ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('ISOCODEID', Numeric(10), primary_key=True))

        res_party_table = Table(
            'RES_PARTY', metadata,
            Column('RESPARTYID', Numeric(10),
                   ForeignKey('RESPARTY_RES.RESPARTYID'), primary_key=True),
            Column('CONTACTTITLEID', Numeric(10)),
            Column('FIRSTNAME', String(45)),
            Column('SURNAME', String(80)),
            Column('ORGID', Numeric(10)),
            Column('POSITIONTITLE', String(100)),
            Column('CONTACTID', Numeric(10)),
            Column('NOTES', String(400)))
            
        resparty_res_table = Table(
            'RESPARTY_RES', metadata,
            Column('RESPARTYID', Numeric(10),
                   ForeignKey('RES_PARTY.RESPARTYID'), primary_key=True),
            Column('METADATAID', Numeric(10),
                   ForeignKey('METADATA.METADATAID'), primary_key=True),
            Column('ROLEID', Numeric(10)))
                   
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
        mapper(metadata.Keyword, ctrlvocab_res_table, properties={
                'keyword': column_property(
                    select(["substr(%s,3)" % ctrlvocab_res_table.c.TERMID]).label('keyword')),
                'thesaurus': column_property(
                    select(["substr(%s,0,2)" % ctrlvocab_res_table.c.TERMID]).label('thesaurus'))
                })

        access_use_table = schema.tables['ACCESS_USE']
        mapper(AccessUse, access_use_table)

        a_u_resolve_table = schema.tables['A_U_RESOLVE']
        o_r_resolve_table = schema.tables['O_R_RESOLVE']
        a_c_resolve_table = schema.tables['A_C_RESOLVE']
        mapper(AccessConstraint, a_c_resolve_table)

        res_party_table = schema.tables['RES_PARTY']
        resparty_res_table = schema.tables['RESPARTY_RES']
        mapper(ResponsibleParty, res_party_table, properties={
            #'ROLEID': relationship(resparty_res_table.c.ROLEID, #thesaurus 8
            'CONTACTTITLEID': res_party_table.c.CONTACTTITLEID, #? (redundant)
            'FIRSTNAME': res_party_table.c.FIRSTNAME,
            'SURNAME': res_party_table.c.SURNAME,
            'ORGID': res_party_table.c.ORGID, #thesaurus ?
            'POSITIONTITLE': res_party_table.c.POSITIONTITLE,
            'CONTACTID': res_party_table.c.CONTACTID, #thesaurus ?
            'NOTES': res_party_table.c.NOTES
            })

        metadata_table = schema.tables['METADATA']
        mapper(BODCMetadata, metadata_table, properties={
            'date': metadata_table.c.MODDATE,
            'title': metadata_table.c.TITLE,
            'abstract': metadata_table.c.ABSTRACT,
            'resource_type': metadata_table.c.RESTYP_ID,
            'resource_locators': relationship(ResourceLocator), 
            # TODO: update resource_locators,
            # see Schema Changes, medin_schema_doc_2_3_3_11mar10.doc
            'unique_id': composite(
                    UniqueId, metadata_table.c.IDENTIFIER,
                    metadata_table.c.CODESPACE),
            'coupled_resources': relationship(CoupledResource),
            'keywords': relationship(metadata.Keyword),

            #'topic_category': relationship(metadata.Keyword, primaryjoin= # join on foreign key AND thesaurus_id in (9,3)


            'bounding_box': composite(
                    BoundingBox, metadata_table.c.WEST, metadata_table.c.SOUTH,
                    metadata_table.c.EAST, metadata_table.c.NORTH),
            'vertical_extent': composite(
                    VerticalExtent, metadata_table.c.VERTEXTMIN,
                    metadata_table.c.VERTEXTMAX,
                    metadata_table.c.VERTEXTREF_ID),
            'spatial_reference_system': metadata_table.c.SRSYS_ID,
            'temporal_reference': composite(
                    TemporalReference, metadata_table.c.TEMPEXBGN,
                    metadata_table.c.TEMPEXEND,
                    metadata_table.c.PUBDATE,
                    metadata_table.c.REVDATE,
                    metadata_table.c.CREATED),
            'lineage': metadata_table.c.LINEAGE,
            'spatial_resolution': composite(
                    SpatialResolution, metadata_table.c.SPARES,
                    select(["NULL"])),
            'alt_titles': relationship(
                    AlternativeTitle, order_by=AlternativeTitle.ALTTITLE),
            'limitations_public_access_vocab': relationship(
                    AccessConstraint, order_by=AccessConstraint.ISOCODEID),
            'limitations_public_access': relationship(
                    AccessUse, secondary=o_r_resolve_table),
            'conditions_applying_for_access_and_use': relationship(
                    AccessUse, secondary=o_r_resolve_table)#,
#            'responsible_parties': relationship(
#                    ResponsibleParty, secondary=resparty_res_table,
#                    primaryjoin="METADATA.METADATAID == RESPARTY_RES.METADATAID",
#                    secondaryjoin="RESPARTY_RES.RESPARTYID == RES_PARTY.RESPARTYID"
#                    )
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

