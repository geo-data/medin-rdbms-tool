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

from sqlalchemy.orm import sessionmaker
from medin.util import get_engine, Proxy
import medin.metadata
import skos
import rdflib
import logging

logger = logging.getLogger(__name__)

# we have to register a plugin to deal with the `text/xml` content
# type returned with RDF by the NERC vocabulary server
rdflib.plugin.register('text/xml', rdflib.plugin.Parser, 'rdflib.plugins.parsers.rdfxml', 'RDFXMLParser')

def _cacheable_property(method):
    """
    Make an object property cacheable
    """
    def getter(self):
        try:
            return self._attr_cache[method.__name__]
        except KeyError:
            return method(self)

    def setter(self, value):
        self._attr_cache[method.__name__] = value

    def deleter(self):
        try:
            del self._attr_cache[method.__name__]
        except KeyError:
            raise AttributeError(method.__name__)

    return property(getter, setter, deleter)

class Term(Proxy):
    """
    An object that proxies to `skos.Concept`, replicating the `Term`
    interface used prior to integrating skos.
    """
    _attr_cache = None

    def __init__(self, *args, **kwargs):
        self._attr_cache = {}
        super(Term, self).__init__(*args, **kwargs)
    
    @_cacheable_property
    def code(self):
        return self.notation.split('::')[-1]

    @_cacheable_property
    def term(self):
        return self.prefLabel

    @property
    def synonyms(self):
        return Terms(self.__subject__.synonyms)
    
    @property
    def broader(self):
        return Terms(self.__subject__.broader)

    @property
    def narrower(self):
        return Terms(self.__subject__.narrower)

    @property
    def related(self):
        return Terms(self.__subject__.related)

    def __str__(self):
        return self.term

    def __repr__(self):
        return 'Term(%s)' % repr(self.term)

class Terms(Proxy):
    """
    An object that proxies to `skos.Concepts`, returning `Term`
    instances instead of `skos.Concept`
    """
    def pop(self):
        return Term(self.__subject__.pop())
    
    def __getitem__(self, key):
        return Term(self.__subject__.__getitem__(key))

    def itervalues(self):
        for value in self.__subject__.itervalues():
            if not isinstance(value, Term):
                yield Term(value)
            else:
                yield value

class MetadataStandard(Term):

    def _setProperties(self):
        """
        Set the object properties from the term

        The term contains a json string with various attributes that
        are used to set properties on the instance.
        """
        from json import loads

        term = loads(self.definition)
        for key, value in term.items():
            setattr(self, '_'+key, value)

    @property
    def metadataStandardName(self):
        try:
            return self._metadataStandardName
        except AttributeError:
            pass

        self._setProperties()
        return self._metadataStandardName

    @property
    def metadataStandardVersion(self):
        try:
            return self._metadataStandardVersion
        except AttributeError:
            pass

        self._setProperties()
        return self._metadataStandardVersion

class _Session(object):

    # Relate Term classes to thesauri
    _term_classes = {
        19: MetadataStandard
        }
    
    def __init__(self):
        self._vocabs = self._getVocabs()
        self.engine = get_engine('vocabularies.sqlite')
        Session = sessionmaker(bind=self.engine)

        self.session = Session()
        
    def _getVocabs(self):
        """
        Return a dictionary with the available vocabularies

        The format is:

        { thesaurus_id: reference }

        where `thesaurus_id` is the thesaurus id number and reference is an array in the format:

        [ URI, id_string ]

        `URI` references the actual SKOS data source whereas
        `id_string` is the static symbol used to referer to the
        dictionary.
        """
        from os.path import join, dirname

        # the online vocabs
        vocabs = {
            2: [                # ISO Countries
                'http://vocab.nerc.ac.uk/collection/C32/current/accepted',
                'http://vocab.nerc.ac.uk/collection/C32/current'],
            3: [                # ISO Topic Categories
                'http://vocab.nerc.ac.uk/collection/P05/current/accepted',
                'http://vocab.nerc.ac.uk/collection/P05/current'],
            6: [                # INSPIRE themes
                'http://vocab.nerc.ac.uk/collection/P22/current/accepted',
                'http://vocab.nerc.ac.uk/collection/P22/current'],
            10: [               # SeaDataNet PDV
                'http://vocab.nerc.ac.uk/collection/P02/current/accepted',
                'http://vocab.nerc.ac.uk/collection/P02/current'],
            11: [               # Vertical Coverages
                'http://vocab.nerc.ac.uk/collection/L13/current/accepted',
                'http://vocab.nerc.ac.uk/collection/L13/current'],
            13: [               # SeaDataNet sea areas
                'http://vocab.nerc.ac.uk/collection/C16/current/accepted',
                'http://vocab.nerc.ac.uk/collection/C16/current'],
            16: [               # MEDIN formats
                'http://vocab.nerc.ac.uk/collection/M01/current/accepted',
                'http://vocab.nerc.ac.uk/collection/M01/current'],
            18: [               # NDG Data Providers
                'http://vocab.nerc.ac.uk/collection/N01/current/accepted',
                'http://vocab.nerc.ac.uk/collection/N01/current'],
            19: [               # NERC DDS input standards
                'http://vocab.nerc.ac.uk/collection/N05/current/accepted',
                'http://vocab.nerc.ac.uk/collection/N05/current']
            }

        # the local vocabs
        local_thesauri = (
            1,                  # INSPIRE spatial data type
            4,                  # ISO maintainence frequency codelist
            7,                  # ISO Restriction codelist
            8,                  # ISO Role codelist
            12,                 # ISO scope codelist
            17)                 # ISO date type codelist
        vocab_dir = join(dirname(__file__), 'data', 'vocabularies')
        for tid in local_thesauri:
            filename = '%d.xml' % tid
            vocabs[tid] = [join(vocab_dir, filename), filename]

        return vocabs

    def getGraph(self):
        from urllib2 import HTTPError

        # Parse the vocabularies into a RDF graph
        graph = rdflib.Graph()
        for uri in (v[0] for v in self._vocabs.values()):
            logger.info('parsing vocabulary %s', uri)
            try:
                graph.parse(uri)
            except (HTTPError, IOError), e:
                logger.warn('cannot load %s: %s', uri, str(e))

        return graph

    def update(self):
        """
        Creates and populates the required schema in the database

        This sets up the various thesauri and their terms.
        """

        from os.path import basename
        def normalise_uri(uri):
            """
            Ensure a vocabulary URI is consistent
            """
            if uri.startswith('file://'):
                # strip off unnecessary dirname info so we have a consistent
                # reference
                return basename(uri)
            return uri.rstrip(u'/')

        graph = self.getGraph()
        loader = skos.RDFLoader(graph, normalise_uri=normalise_uri)

        # re-create the schema and load the vocabularies
        with self.session.begin(subtransactions=True):
            conn = self.session.connection()
            skos.Base.metadata.drop_all(conn)
            skos.Base.metadata.create_all(conn)

            self.session.add_all(loader.values())
        self.session.commit()

    def _thesaurusIdToRef(self, id):
        """
        Convert a thesaurus ID number to its SKOS Collection reference
        """

        return self._vocabs[id][1]

    def getThesaurus(self, id):
        """
        Return the thesaurus with the specific id
        """

        from sqlalchemy.orm.exc import NoResultFound

        uri = self._thesaurusIdToRef(id)
        try:
            return self.session.query(skos.Collection).filter(skos.Collection.uri == uri).one()
        except NoResultFound:
            return None

    def getTermFromCode(self, thesaurus_id, code):
        """
        Retrieve a term from a specific thesaurus using it's code
        """
        return self._getTermFromCode(code, thesaurus_id)

    def _getTermClass(self, thesaurus_id):
        """
        Retrieve the class representing a specific term
        """

        try:
            return self._term_classes[thesaurus_id]
        except KeyError:
            return Term        
    
    def _getTerm(self, word, thesaurus_id):
        """
        Retrieve a term associated with a specific thesaurus
        """
        from sqlalchemy.orm.exc import NoResultFound

        uri = self._thesaurusIdToRef(thesaurus_id)
        class_ = self._getTermClass(thesaurus_id)
        try:
            concept = self.session.query(skos.Concept)\
                .join(skos.Concept.collections)\
                .filter(skos.Collection.uri == uri)\
                .filter(skos.Concept.prefLabel.ilike(word)).one()
            return class_(concept)
        except NoResultFound:
            return None

    def _getTermFromCode(self, code, thesaurus_id):
        """
        This uses the skos notation code for lookup
        used in eg. METADATA.RESTYP_ID
        """
        from sqlalchemy.orm.exc import NoResultFound

        uri = self._thesaurusIdToRef(thesaurus_id)
        class_ = self._getTermClass(thesaurus_id)
        try:
            concept = self.session.query(skos.Concept)\
                .join(skos.Concept.collections)\
                .filter(skos.Collection.uri == uri)\
                .filter(skos.Concept.notation.ilike('%%::%s' % code)).one()
            return class_(concept)
        except NoResultFound:
            return None

    def getINSPIREDataType(self, word):
        return self._getTerm(word, 1)

    def getMaintenanceFrequency(self, word):
        return self._getTerm(word, 4)

    def getAccessRestriction(self, word):
        return self._getTerm(word, 7)

    def getContactRole(self, word):
        return self._getTerm(word, 8)

    def getResourceType(self, word):
        return self._getTerm(word, 12)

    def getDateType(self, word):
        return self._getTerm(word, 17)

    def getISOCountry(self, word):
        return self._getTerm(word, 2)

    def getTopicCategory(self, word):
        return self._getTerm(word, 3)

    def getINSPIRETheme(self, word):
        return self._getTerm(word, 6)

    def getSeaDataParameter(self, word):
        return self._getTerm(word, 10)

    def getVerticalCoverage(self, word):
        return self._getTerm(word, 11)

    def getIHBSeaArea(self, word):
        return self._getTerm(word, 13)

    def getMEDINFormat(self, word):
        return self._getTerm(word, 16)

    def getTopicCategoryFromCode(self, code):
        return self._getTermFromCode(code, 3)

    def getINSPIREDataTypeFromCode(self, code):
        return self._getTermFromCode(code, 1)

    def getMaintenanceFrequencyFromCode(self, code):
        return self._getTermFromCode(code, 4)

    def getAccessRestrictionFromCode(self, code):
        return self._getTermFromCode(code, 7)

    def getContactRoleFromCode(self, code):
        return self._getTermFromCode(code, 8)

    def getResourceTypeFromCode(self, code):
        return self._getTermFromCode(code, 12)

    def getDateTypeFromCode(self, code):
        return self._getTermFromCode(code, 17)

    def getSeaDataParameterFromCode(self, code):
        return self._getTermFromCode(code, 10)

# Create a singleton vocabulary session
_vocab_session = None
def Session():
    global _vocab_session
    if not _vocab_session:
        _vocab_session = _Session()
    return _vocab_session

if __name__ == '__main__':
    session = Session()
    session.update()
