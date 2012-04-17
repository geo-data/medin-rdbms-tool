# Created by Homme Zwaagstra
# 
# Copyright (c) 2011 GeoData Institute
# http://www.geodata.soton.ac.uk
# geodata@soton.ac.uk
# 
# Unless explicitly acquired and licensed from Licensor under another
# license, the contents of this file are subject to the Reciprocal
# Public License ("RPL") Version 1.5, or subsequent versions as
# allowed by the RPL, and You may not copy or use this file in either
# source code or executable form, except in compliance with the terms
# and conditions of the RPL.
# 
# All software distributed under the RPL is provided strictly on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR
# IMPLIED, AND LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES,
# INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT, OR
# NON-INFRINGEMENT. See the RPL for specific language governing rights
# and limitations under the RPL.
# 
# You can obtain a full copy of the RPL from
# http://opensource.org/licenses/rpl1.5.txt or geodata@soton.ac.uk

"""
MEDIN Metadata Schema

This provides the reference implementation for the MEDIN schema. This
schema is detailed at:

http://www.oceannet.org/marine_data_standards/medin_approved_standards/documents/medin_usermanaged_tables_user.doc

The schema can be used with any sqlalchemy supported database engine
as long as the underlying database schema conforms. An example of a
conforming schema is bundled in a sqlite database which can be found
at medin/data/example.sqlite

As with any schema, the primary purpose of this module is to create
a sqlalchemy mapping from the database schema to the medin.Metadata
class.
"""

from medin.schema import Session
import medin.metadata as metadata
from medin.vocabulary import Session as Vocabulary
from medin.contact import Session as Contacts
from sqlalchemy.orm import reconstructor
import datetime

# The metadata classes
class Metadata(metadata.Metadata):
    """
    A class that is used for the sqlalchemy mapping

    This augments the base Metadata class, encapsulating differences
    in the MEDIN schema behind the interface defined by the base
    class.
    """
    METADATAID = None
    RESTYP_ID = _RESTYP_ID = _resource_type = None
    SDSTYP_ID = _SDSTYP_ID = _service_type = None
    ACCESS_CONSTRAINTS = _ACCESS_CONSTRAINTS = _access_constraint_terms = None
    RESPARTY = _RESPARTY = _responsible_parties = None
    FREQMOD_ID = _FREQMOD_ID = _update_frequency = None
    terms = None
    
    def __init__(self):
        super(Metadata, self).__init__(self)
        self.vocabs = Vocabulary()
        self.contacts = Contacts()
        self.terms = []
    
    # Ensure the object is fully instantiated by sqlalchemy when
    # creating instances using the ORM
    @reconstructor
    def construct(self):
        # default values
        self.language = metadata.ResourceLanguage('English', 'eng')
        self.vocabs = Vocabulary()
        self.contacts = Contacts()

    @property
    def resource_type(self):
        if not self.RESTYP_ID:
            return None

        # check to see if we need to update the cached value
        if self._RESTYP_ID != self.RESTYP_ID:
            resource_type = self.vocabs.getResourceTypeFromCode(int(self.RESTYP_ID))
            if resource_type:
                self._resource_type = resource_type.term
            self._RESTYP_ID = self.RESTYP_ID

        return self._resource_type

    @property
    def service_type(self):
        if not self.SDSTYP_ID:
            return None

        # check to see if we need to update the cached value
        if self._SDSTYP_ID != self.SDSTYP_ID:
            service_type = self.vocabs.getINSPIREDataTypeFromCode(int(self.SDSTYP_ID))
            if service_type:
                self._service_type = service_type.term
            self._SDSTYP_ID = self.SDSTYP_ID

        return self._service_type
    
    def _getTerms(self, thesaurus_id):
        """
        Return terms for a specific thesaurus
        """

        for term in self.terms:
            if term.thesaurus_id == thesaurus_id:
                res = self.vocabs.getTermFromCode(term.thesaurus_id, term.code)
                if not res:
                    continue
                yield res

    @property
    def topic_categories(self):
        return list(self._getTerms(3))

    @property
    def keywords(self):
        categories = []
        for thesaurus_id in (10, 11, 18):
            categories.extend(self._getTerms(thesaurus_id))
        return categories
    
    @property
    def data_formats(self):
        return list(self._getTerms(16))

    @property
    def extents(self):
        extents = []
        for thesaurus_id in (2, 13, 14, 15):
            extents.extend(self._getTerms(thesaurus_id))
        return extents

    @property
    def additional_info(self):
        return "\n\n".join([str(c) for c in self.ADDITIONAL_INFO])

    @property
    def access_constraint_terms(self):
        if not self.ACCESS_CONSTRAINTS:
            return []

        # check to see if we need to update the cached value
        if self._ACCESS_CONSTRAINTS != self.ACCESS_CONSTRAINTS:
            access_constraint_terms = []
            for constraint in self.ACCESS_CONSTRAINTS:
                term = self.vocabs.getAccessRestrictionFromCode(int(constraint.ISOCODEID))
                if term: access_constraint_terms.append(term)

            self._access_constraint_terms = access_constraint_terms
            self._ACCESS_CONSTRAINTS = self.ACCESS_CONSTRAINTS

        return self._access_constraint_terms

    @property
    def responsible_parties(self):
        if not self.RESPARTY:
            return []

        # check to see if we need to update the cached value
        if self._RESPARTY != self.RESPARTY:
            responsible_parties = []
            for party in self.RESPARTY:
                # get the role
                term = self.vocabs.getContactRoleFromCode(int(party.ROLEID))
                party.role = term
                if not term:
                    continue

                # get the contact information
                contact = self.contacts.getOrganisation(int(party.CONTACTID))
                if party.CONTACTID != party.ORGID:
                    org = self.contacts.getOrganisation(int(party.ORGID))
                else:
                    org = contact
                if org: party.organisation = org.name
                if contact:
                    for attr in ('address', 'zipcode', 'city', 'state', 'country', 'website', 'phone', 'fax', 'email'):
                        setattr(party, attr, getattr(contact, attr))
                    
                responsible_parties.append(party)

            self._responsible_parties = responsible_parties
            self._RESPARTY = self.RESPARTY

        return self._responsible_parties
    
    @property
    def update_frequency(self):
        if not self.FREQMOD_ID:
            return None

        # check to see if we need to update the cached value
        if self._FREQMOD_ID != self.FREQMOD_ID:
            update_frequency = self.vocabs.getMaintenanceFrequencyFromCode(int(self.FREQMOD_ID))
            if update_frequency:
                self._update_frequency = update_frequency.term
            self._FREQMOD_ID = self.FREQMOD_ID

        return self._update_frequency

    @property
    def standard(self):
        try:
            return list(self._getTerms(19))[0].metadataStandardName
        except IndexError:
            return None

    @property
    def version(self):
        try:
            return list(self._getTerms(19))[0].metadataStandardVersion
        except IndexError:
            return None

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

class ParentId(UniqueId):
    pass

class CoupledResource(object):
    """
    Element 7
    """
    METADATAID = None
    COUPLRES = None

    def __str__(self):
        return str(self.COUPLRES)

class Term(object):
    """
    Used to represent an entry in the CTRLVOCAB_RES table
    """
    METADATAID = None
    TERMID = None

    def __str__(self):
        return str(self.TERMID)

    @reconstructor
    def construct(self):
        self.thesaurus_id, self.code = int(self.TERMID[:2]), self.TERMID[2:]
        
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

    This element is defined to allow it to be used as a SQLAlchemy
    composite column type
    (http://www.sqlalchemy.org/docs/mappers.html#composite-column-types).
    """
    def __composite_values__(self):
        return [self.minimum, self.maximum, self.crs]
    
    def __set_composite_values__(self, minimum, maximum, crs):
        self.minimum = minimum
        self.maximum = maximum
        self.crs = crs

def parse_date(date):
    """
    Parse a date string into a datetime object
    """
    global _datep
    try:
        datep = _datep
    except NameError:
        from re import compile
        # create a pattern that matches any isoformat date or time
        datep = _datep = compile('^(?P<year>\d{4})(?:-(?P<month>\d{2})(?:-(?P<day>\d{2})(?:T(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})(?:\.(?P<microsecond>\d+))?)?)?)?$')

    try:
        groups = datep.match(date.strip()).groupdict()
    except AttributeError:
        return None

    if groups['hour'] is not None:
        # it is a datetime object
        if groups['microsecond']:
            groups['microsecond'] = int(groups['microsecond']) * 1000 # turn milliseconds into microseconds
        return datetime.datetime(*[int(groups[k]) for k in ('year', 'month', 'day', 'hour', 'minute', 'second') if groups[k]])
    elif groups['day']:
        # it is a date object
        return datetime.date(*[int(groups[k]) for k in ('year', 'month', 'day')])
    elif groups['month']:
        #  it is a YearMonth object
        return metadata.YearMonth(*[int(groups[k]) for k in ('year', 'month')])

    # it's a Year object
    return metadata.Year(int(groups['year']))    
    
class TemporalReference(metadata.TemporalReference):
    """
    Element 16

    This element is defined to allow it to be used as a SQLAlchemy
    composite column type
    (http://www.sqlalchemy.org/docs/mappers.html#composite-column-types).
    """
    
    def __composite_values__(self):
        return [str(self.begin), self.end, self.publication, self.revision, self.creation]
    
    def __set_composite_values__(self, begin, end, publication, revision, creation):
        self.begin = parse_date(begin)
        self.end = parse_date(end)
        self.publication = publication
        self.revision = revision
        self.creation = creation

class SpatialResolution(metadata.SpatialResolution):
    """
    Element 18
    """
    _distance = None

    @property
    def distance(self): return self._distance

    @distance.setter
    def distance(self, value):
        if value == 'inapplicable':
            value = metadata.Nil('inapplicable')
        self._distance = value

    # emulate array
    def __iter__(self):
        yield self

    def __composite_values__(self):
        return [self.distance, self.equivalent_scale]

    def __set_composite_values__(self, distance, equivalent_scale):
        self.distance = distance
        self.equivalent_scale = equivalent_scale

class AdditionalInformation(object):
    """
    Element 19

    This object aggregates various fields from the CITATION table and
    concatenates them when stringified.
    """

    CITATIONID = None
    PUBYEAR = None
    PUBTYP = None
    PUBTITLE = None
    VOLUME = None
    ISSUE = None
    PAGES = None
    AUTHORS = None
    EDITORS = None
    PUBPLACE = None
    ORGREP = None
    EDITION = None
    EDITIONDATE = None
    PUBLISHER = None
    PUBSUBTYP = None
    CONTRACTCODE = None

    def __str__(self):
        s = []
        if self.PUBYEAR:
            s.append('Publication year: %s' % str(self.PUBYEAR))
        if self.PUBTYP:
            s.append('Publication type: %s' % self.PUBTYP)
        if self.PUBTITLE:
            s.append('Publication title: %s' % self.PUBTITLE)
        if self.VOLUME:
            s.append('Publication volume: %s' % str(self.VOLUME))
        if self.ISSUE:
            s.append('Publication issue: %s' % self.ISSUE)
        if self.PAGES:
            s.append('Publication pages: %s' % self.PAGES)
        if self.AUTHORS:
            s.append('Publication authors: %s' % self.AUTHORS)
        if self.EDITORS:
            s.append('Publication editors: %s' % self.EDITORS)
        if self.PUBPLACE:
            s.append('Place of publication: %s' % self.PUBPLACE)
        if self.ORGREP:
            s.append('Organisation representative: %s' % self.ORGREP)
        if self.EDITION:
            s.append('Edition: %s' % self.EDITION)
        if self.EDITIONDATE:
            s.append('Edition date: %s' % str(self.EDITIONDATE))
        if self.PUBLISHER:
            s.append('Publisher: %s' % self.PUBLISHER)
        if self.PUBSUBTYP:
            s.append('Publisher sub type: %s' % self.PUBSUBTYP)
        if self.CONTRACTCODE:
            s.append('Contract code: %s' % self.CONTRACTCODE)

        return "\n".join(s)

class AccessConstraint(object):
    """
    Element 20 controlled vocabularies

    This links the metadata with the codes for Thesaurus 7
    """
    METADATAID = None
    ISOCODEID = None

class AccessUse(object):
    """
    Elements 20 & 21

    This contains a description of otherRestriction for Element 20 or
    the description for Element 21
    """
    ACCESSUSEID = None
    DESCRIPTION = None

    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, self.DESCRIPTION)

    def __str__(self):
        return str(self.DESCRIPTION)

class ResponsibleParty(metadata.ResponsibleParty):
    """
    Element 22
    """
    FIRSTNAME = None
    SURNAME = None
    ORGID = None
    CONTACTID = None

    @property
    def individual(self):
        name = ' '.join((name for name in (self.FIRSTNAME, self.SURNAME) if name))
        if name:
            return name
        return None

# The concrete provider Session class
class Session(Session):
    """
    A concrete implementation of the schema session class

    This provides an interface to obtaining metadata entries by ID as
    well as iterating over the entire metadata collection.
    """

    def getSchema(self):
        """
        Return a sqlalchemy.MetaData object representing the database schema
        """
        from sqlalchemy import Table, Column, Numeric, String, Date, DateTime, MetaData, ForeignKey, UniqueConstraint

        metadata = MetaData() # N.B. not a medin.metadata.Metadata object!!

        # Primary metadata record
        metadata_table = Table(
            'METADATA', metadata,
            Column('METADATAID', String(20), primary_key=True,
                   doc='Local primary key used as foreign key in other tables'),
            Column('TITLE', String(500),
                   doc='Used to populate MEDIN Element 1 (Resource Title)'),
            Column('ABSTRACT', String(4000),
                   doc='Used to populate MEDIN Element 3 (Resource Abstract)'),
            Column('RESTYP_ID', Numeric(10), nullable=False,
                   doc='Used to populate MEDIN Element 4 (Resource Type) using ISOCODEID in the Tool-managed table ISO_CODE which have a ThesaurusID = 12'),
            Column('IDENTIFIER', String(255),
                   doc='Used to populate MEDIN Element 6.1 (Unique Resource Identifier Code)'),
            Column('CODESPACE', String(255),
                   doc='Used to populate MEDIN Element 6.2 (Unique Resource Identifier Code Space)'),
            Column('SDSTYP_ID', Numeric(10),
                   doc='Used to populate MEDIN Element 10  (Spatial Data Service Type) after translation using ISOCODEID from Tool-managed table ISO_CODE which have a THESAURUSID = 1'),
            Column('WEST', Numeric(7,4),
                   doc='Used to populate MEDIN Element 12 (Geographic Bounding Box)'),
            Column('EAST', Numeric(7,4),
                   doc='Used to populate MEDIN element 12 (Geographic Bounding Box)'),
            Column('NORTH', Numeric(7,4),
                   doc='Used to populate MEDIN element 12 (Geographic Bounding Box)'),
            Column('SOUTH', Numeric(7,4),
                   doc='Used to populate MEDIN element 12 (Geographic Bounding Box)'),
            Column('VERTEXTMIN', Numeric(11),
                   doc='Used to populate MEDIN Element 14.1 (Vertical Extent Minimum Value)'),
            Column('VERTEXTMAX', Numeric(11),
                   doc='Used to populate MEDIN Element 14.2 (Vertical Extent Maximum Value)'),
            Column('VERTEXTREF_ID', String(500),
                   doc='Used to populate MEDIN Element 14.3 (Vertical Extent Coordinate Reference System)'),
            Column('SRSYS_ID', String(500),
                   doc='Used to populate MEDIN Element 15 (Spatial Reference System)'),
            Column('TEMPEXBGN', String(20),
                   doc='Used to populate MEDIN Element 16.1.1 (Temporal Extent Begin Date)'),
            Column('REVDATE', Date(),
                   doc='Used to populate MEDIN Element 16.3 (Date of Last Revision)'),
            Column('CREATED', Date(),
                   doc='Used to populate MEDIN Element 16.2 (Date of Publication)'),
            Column('PUBDATE', Date(),
                   doc='Used to populate MEDIN Element 16.4 (Date of Creation)'),
            Column('TEMPEXEND', String(20),
                   doc='Used to populate MEDIN Element 16.1.2 (Temporal Extent End Date)'),
            Column('LINEAGE', String(4000),
                   doc='Used to populate MEDIN Element 17 (Lineage)'),
            Column('SPARES', String(20),
                   doc='Used to populate MEDIN Element 18 (Spatial Resolution)'),
            Column('FREQMOD_ID', Numeric(10),
                   doc='Used to populate MEDIN Element 24 (Frequency of Update)'),
            Column('MODDATE', DateTime(),
                   doc='Used to populate MEDIN Element 26 (Metadata date)'),
            Column('MODBY', String(50),
                   doc="Name of person who last modified the metadata record"))

        # Implements many alternative titles for one primary metadata record
        alt_title_table = Table(
            'ALT_TITLE', metadata,
            Column('ALTTITLEID', Numeric(10), primary_key=True,
                   doc='Local primary key'),
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'),
                   doc='Foreign key linkage to Table METADATA'),
            Column('ALTTITLE', String(350),
                   doc='Used to populate MEDIN Element 2 (Alternative Resource Title)')),

        # Linker between primary metadata record and the people
        # repository (Responsible_Party)
        #
        # This table provides the linkage between the metadata record
        # and the people/organisations with which it is associated
        # through MEDIN Element 22 (Responsible Party). It should
        # include entries for the originator, custodian, metadata
        # point of contact and optionally the distributor for the
        # dataset.
        resparty_res_table = Table(
            'RESPARTY_RES', metadata,
            Column('RESPARTYID', Numeric(10), ForeignKey('RES_PARTY.RESPARTYID'), primary_key=True,
                   doc='Identifier of the person/organisation in the repository RES_PARTY table. Foreign key linkage to table RES_PARTY'),
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign key linking to METADATA table'),
            Column('ROLEID', Numeric(10),
                   doc='Populate using ISOCODEID in the Tool-managed table ISO_CODE where ThesaurusID = 8'))

        # People Repository
        #
        # This is a repository of people and organisation information.
        res_party_table = Table(
            'RES_PARTY', metadata,
            Column('RESPARTYID', Numeric(10), primary_key=True,
                   doc='Local primary key used as a Foreign key linking to RESPARTY_RS table'),
            Column('FIRSTNAME', String(45),
                   doc='Concatenated with SURNAME to provide MEDIN Element 22.4 (Metadata Point of Contact)'),
            Column('SURNAME', String(80),
                   doc='Concatenated with FIRSTNAME to provide MEDIN Element 22.4 (Metadata Point of Contact)'),
            Column('ORGID', Numeric(10),
                   doc='Foreign key linking to Tool-managed table ORGANISATION (based on EDMO)'),
            Column('POSITIONTITLE', String(100),
                   doc='Used to populate MEDIN Element 22.0.1 (Job Position)'),
            Column('CONTACTID', Numeric(10),
                   doc='Foreign key linking to Tool-managed table CONTACT'))

        # Linker between primary metadata record and access
        # constraints from ISO19115 controlled vocabulary
        #
        # Used to populate MEDIN Element 20 (Limitations on Public
        # Access) using code translations from THESAURUSID 7 in the
        # Tool managed table ISO_CODE.
        a_c_resolve_table = Table(
            'A_C_RESOLVE', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign key linking to METADATA table'),
            Column('ISOCODEID', Numeric(10), primary_key=True,
                   doc='Foreign key linking to Tool-managed table ISO_CODE where THESAURUSIS = 7'))

        # Repository of plaintext usage restrictions and access
        # constraint qualifiers
        #
        # Repository of plaintext strings used to populate MEDIN
        # Elements 20 and 21 (Limitations on Public Access and
        # Conditions Applying for Access and Use).
        access_use_table = Table(
            'ACCESS_USE', metadata,
            Column('ACCESSUSEID', Numeric(10), primary_key=True,
                   doc='Assign primary key'),
            Column('DESCRIPTION', String(400),
                   doc='Free text string describing terms for MEDIN Elements 20 and 21'))

        # Linker between primary metadata record and plaintext access
        # constraint qualifiers from Access_Use
        # 
        # Used to populate MEDIN Element 20 (Limitations on Public
        # Access) 'otherConstraints' Element.  Note that in the next
        # release of the MEDIN schema, this will be mandatory for all
        # ISO restriction codes, not just 'otherRestrictions'.
        o_r_resolve_table = Table(
            'O_R_RESOLVE', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign key from table METADATA'),
            Column('ACCESSUSEID', Numeric(10),
                   ForeignKey('ACCESS_USE.ACCESSUSEID'), primary_key=True,
                   doc='Foreign key from table ACCESS_USE'))

        # Linker between primary metadata record and plaintext usage
        # restrictions from Access_Use
        #
        # Used to populate MEDIN Element 21 (Conditions applying for
        # Access and Use) using the strings held in the table
        # ACCESS_USE linking via ACCESSUSEID.
        a_u_resolve_table = Table(
            'A_U_RESOLVE', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign key from table METADATA'),
            Column('ACCESSUSEID', Numeric(10),
                   ForeignKey('ACCESS_USE.ACCESSUSEID'), primary_key=True,
                   doc='Foreign key providing linkage to ACCESS_USE table to populate MEDIN Element 21 (Conditions applying for Access and Use)'))

        # Linker between primary metadata record and the controlled
        # vocabularies in tables Keyword, DataFormat and Extent
        ctrlvocab_res_table = Table(
            'CTRLVOCAB_RES', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign key linkage to Table METADATA'),
            Column('TERMID', String(10), primary_key=True,
                   doc="""Linkage to keywords in several vocabularies.

Links to THESAURUSID 10 are used to populate:

- MEDIN Element 9 (Topic Category) after translation into ISO Topic
  categories (using P021 to P051 map) and THESAURUSID 3 to convert
  codes to text.

- MEDIN Element 11 INSPIRE Keywords after translation (P021 to P220
  map) and THESAURUSID 6 to convert codes to text.

- MEDIN Element 11 MEDIN Keywords in their own right, translated from
  codes to text using THESAURUSID 10.

Links to THESAURUSIDs 2, 13, 14 or 15 are used to populate MEDIN
Element 13 (Extent), translated from codes to text using the
appropriate thesaurus.

Links to THESAURUSID 11 are used to populate MEDIN Element 11 'Other'
Keywords, translated from codes to text using THESAURUSID 11.

Links to THESAURUSID 16 are used to populate MEDIN Element 23 (Data
Format) translated from codes to text using the thesaurus."""))

        # List of URIs to any services linked to the metadata
        # document.
        coupled_res_table = Table(
            'COUPLED_RES', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign Key linkage to METADATA table'),
            Column('COUPLRES', String(200), primary_key=True,
                   doc='URI used to populate MEDIN Element 7 (Coupled Resource)'))

        # Presumably MEDIN Element 19 (Additional Information Source)
        # is built by concatenation.
        citation_table = Table(
            'CITATION', metadata,
            Column('CITATIONID', Numeric(10), primary_key=True,
                   doc='Local Primary Key'),
            Column('PUBYEAR', Date(),
                   doc='Date of publication'),
            Column('PUBTYP', String(30)),
            Column('PUBTITLE', String(1000)),
            Column('VOLUME', Numeric(10)),
            Column('ISSUE', String(45)),
            Column('PAGES', String(10)),
            Column('AUTHORS', String(1000)),
            Column('EDITORS', String(255)),
            Column('PUBPLACE', String(200)),
            Column('ORGREP', String(255)),
            Column('ONLINERES', String(500),
                   doc='URL used to populate MEDIN Element 5.1'),
            Column('ONLINERESNAM', String(500),
                   doc='Name of online resource used to populate MEDIN Element 5.2'),
            Column('ONLINERESFUNC', String(20),
                   doc='Description of online resource used to populate MEDIN Element 5.3'),
            Column('ONLINERESDESC', String(200),
                   doc='Description of online resource used to populate MEDIN Element 5'),
            Column('EDITION', String(25)),
            Column('EDITIONDATE', Date()),
            Column('PUBLISHER', String(255)),
            Column('PUBSUBTYP', String(30)),
            Column('CONTRACTCODE',String(100)),
            Column('URL_ACCESSED', Date()))

        # List of citations used as additional information
        a_is_resolve_table = Table(
            'A_IS_RESOLVE', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign Key linkage to METADATA table'),
            Column('CITATIONID', Numeric(10), ForeignKey('CITATION.CITATIONID'), primary_key=True,
                   doc='Foreign key linkage to CITATION table for population of MEDIN Element 19 (Additional Information Source)'))

        # List of citations to be used as resource locators
        resloc_res_table = Table(
            'RESLOC_RES', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign Key linkage to METADATA table'),
            Column('CITATIONID', Numeric(10), ForeignKey('CITATION.CITATIONID'), primary_key=True,
                   doc='Foreign key linkage to CITATION table for population of MEDIN Element 5 (Resource Locator)'))
            
        # List of citations to be used as resource locators
        parent_id_table = Table(
            'PARENT_ID', metadata,
            Column('METADATAID', String(20), ForeignKey('METADATA.METADATAID'), primary_key=True,
                   doc='Foreign Key linkage to METADATA table'),
            Column('PARENTID', String(20), ForeignKey('METADATA.METADATAID'),
                   doc='Foreign Key linkage to METADATA table for populating MEDIN Element 30 (Parent Identifier)'),
            UniqueConstraint('METADATAID', 'PARENTID'))

        return metadata

    def setMapping(self):
        """
        Map the Metadata classes to the provider database schema
        """
        from sqlalchemy.orm import mapper, relationship, composite, synonym
        from sqlalchemy.sql import select, join

        schema = self.getSchema()

        alt_title_table = schema.tables['ALT_TITLE']
        mapper(AlternativeTitle, alt_title_table)
        
        citation_table = schema.tables['CITATION']
        mapper(ResourceLocator, citation_table, properties={
                'url': citation_table.c.ONLINERES,
                'name': citation_table.c.ONLINERESNAM,
                'description': citation_table.c.ONLINERESDESC,
                'function': citation_table.c.ONLINERESFUNC
                })
        resloc_res_table = schema.tables['RESLOC_RES']

        a_is_resolve_table = schema.tables['A_IS_RESOLVE']
        mapper(AdditionalInformation, citation_table)

        coupled_res_table = schema.tables['COUPLED_RES']
        mapper(CoupledResource, coupled_res_table)

        ctrlvocab_res_table = schema.tables['CTRLVOCAB_RES']
        mapper(Term, ctrlvocab_res_table)

        a_c_resolve_table = schema.tables['A_C_RESOLVE']
        mapper(AccessConstraint, a_c_resolve_table)

        access_use_table = schema.tables['ACCESS_USE']
        o_r_resolve_table = schema.tables['O_R_RESOLVE']
        a_u_resolve_table = schema.tables['A_U_RESOLVE']
        mapper(AccessUse, access_use_table)

        res_party_table = schema.tables['RES_PARTY']
        resparty_res_table = schema.tables['RESPARTY_RES']
        res_party_join = join(res_party_table, resparty_res_table)
        mapper(ResponsibleParty, res_party_join, properties={
            'RESPARTYID': [res_party_table.c.RESPARTYID, resparty_res_table.c.RESPARTYID],
            'ROLEID': resparty_res_table.c.ROLEID,
            'FIRSTNAME': res_party_table.c.FIRSTNAME,
            'SURNAME': res_party_table.c.SURNAME,
            'ORGID': res_party_table.c.ORGID,
            'position': res_party_table.c.POSITIONTITLE,
            'CONTACTID': res_party_table.c.CONTACTID
            })

        parent_id_table = schema.tables['PARENT_ID']
        
        metadata_table = schema.tables['METADATA']
        mapper(ParentId, metadata_table, properties={
                'id': metadata_table.c.IDENTIFIER,
                'codespace': metadata_table.c.CODESPACE
                })
        mapper(Metadata, metadata_table, properties={
            'METADATAID': metadata_table.c.METADATAID,
            'title': metadata_table.c.TITLE,
            'alt_titles': relationship(AlternativeTitle, order_by=AlternativeTitle.ALTTITLE),
            'abstract': metadata_table.c.ABSTRACT,
            'RESTYP_ID': metadata_table.c.RESTYP_ID,
            'resource_locators': relationship(ResourceLocator, secondary=resloc_res_table),
            'unique_id': composite(
                    UniqueId,
                    metadata_table.c.IDENTIFIER,
                    metadata_table.c.CODESPACE),
            'parent_id': relationship(ParentId,
                                      secondary=parent_id_table,
                                      primaryjoin=(metadata_table.c.METADATAID == parent_id_table.c.METADATAID),
                                      secondaryjoin=(metadata_table.c.METADATAID == parent_id_table.c.PARENTID),
                                      uselist=False),
            'coupled_resources': relationship(CoupledResource),
            'terms': relationship(Term),
            'SDSTYP_ID': metadata_table.c.SDSTYP_ID,
            'bounding_box': composite(
                    BoundingBox,
                    metadata_table.c.WEST,
                    metadata_table.c.SOUTH,
                    metadata_table.c.EAST,
                    metadata_table.c.NORTH),
            'vertical_extent': composite(
                    VerticalExtent,
                    metadata_table.c.VERTEXTMIN,
                    metadata_table.c.VERTEXTMAX,
                    metadata_table.c.VERTEXTREF_ID),
            'srs': metadata_table.c.SRSYS_ID,
            'temporal_reference': composite(
                    TemporalReference,
                    metadata_table.c.TEMPEXBGN,
                    metadata_table.c.TEMPEXEND,
                    metadata_table.c.PUBDATE,
                    metadata_table.c.REVDATE,
                    metadata_table.c.CREATED),
            'lineage': metadata_table.c.LINEAGE,
            'spatial_resolutions': composite(
                    SpatialResolution,
                    metadata_table.c.SPARES,
                    select(["NULL"])),
            'ADDITIONAL_INFO': relationship(AdditionalInformation, secondary=a_is_resolve_table),
            'ACCESS_CONSTRAINTS': relationship(AccessConstraint, order_by=AccessConstraint.ISOCODEID),
            'other_access_constraints': relationship(AccessUse, secondary=o_r_resolve_table),
            'use_limitations': relationship(AccessUse, secondary=a_u_resolve_table),
            'RESPARTY': relationship(ResponsibleParty),
            'date': metadata_table.c.MODDATE
        })

    def getMetadataById(self, qualified_id):
        # return a metadata instance
        from sqlalchemy.orm.exc import NoResultFound
        
        id = UniqueId.FromQualifiedId(qualified_id)
        try:
            metadata = self.sess.query(Metadata).filter(Metadata.unique_id == id).one()
            metadata.vocabs = self.vocabs
            return metadata
        except NoResultFound:
            return None

    def __iter__(self):
        # iterate over all metadata instances
        for metadata in self.sess.query(Metadata).order_by(Metadata.METADATAID):
            metadata.vocabs = self.vocabs
            yield metadata

def set_argument_subparser(subparsers):
    import argparse
    description = """  Extract metadata from a data provider RDBMS implementing the MEDIN
  version 2.3.5 database schema.

basic usage:
  CONNSTRING should be in the following format:

  dialect://user:password@host/dbname

  where dialect is the name of the database system e.g

  oracle://me:mypass@myhost/mydb

  Details of supported dialects are available at:
  http://www.sqlalchemy.org/docs/core/engines.html#supported-dbapis

  The CONNSTRING `example` is a special argument that connects to a
  bundled sqlite database. This is a reference implementation of the
  medin schema based on the BODC EDMED oracle database. It can be
  called as follows:

  %(prog)s example
"""
    
    subparser = subparsers.add_parser(
        'medin-rdbms',
        description=description,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    def get_provider(args, vocabs, contacts):
        # create the database engine
        import medin
        from sqlalchemy import create_engine
        from sqlalchemy.exc import ArgumentError, OperationalError, DatabaseError
        engine = None
        connstr = args.connstr[0]
        if connstr == 'example':
            from os.path import join, abspath

            dbname = abspath(join(medin.__path__[0],'data','example.sqlite'))
            connstr = 'sqlite:///'+dbname

        try:
            engine = create_engine(connstr, echo=medin.DEBUG)
        except ArgumentError, e:
            raise argparse.ArgumentError('Bad CONNSTRING: %s' % str(e))
        except ImportError, e:
            raise argparse.ArgumentError('The database driver could not be found for the connection \'%s\': %s' % (connstr, e))

        # verify the schema plugin against the database schema
        provider = Session(engine, vocabs, contacts)

        try:
            errors = provider.verifySchema()
        except (OperationalError, DatabaseError), e:
            raise RuntimeError('Database error: %s' % e.args[0])

        if errors:
            msg = """The actual database schema does not match the required MEDIN schema:
    %s""" % "\n".join(errors)
            raise RuntimeError(msg)

        # retrieve the metadata
        if args.metadata_id:
            ids = set(args.metadata_id)

            def metadata_generator():
                for metadata_id in ids:
                    # get a specific metadata id
                    metadata = provider.getMetadataById(metadata_id)
                    if not metadata:
                        raise RuntimeError('A metadata entry with the following id does not exist: %s' % metadata_id)
                    yield metadata
        else:
            def metadata_generator():
                for metadata in provider:
                    yield metadata

        return metadata_generator

    subparser.add_argument("-i", '--metadata-id', action="append",
                           help="Output a specific resource ID. The ID must be the fully qualified unique resource identifier (Element 6 e.g. http://www.bodc.ac.uk/EDMED587). This option can be specified multiple times.")
    subparser.add_argument("connstr", nargs=1, metavar='CONNSTRING',
                           help="CONNSTRING is the connection parameter string for accessing the database")
    subparser.set_defaults(func=get_provider)
