import os
import sqlalchemy
from sqlalchemy import Column, Integer, String, Date, ForeignKey, ForeignKeyConstraint
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, backref

def get_engine():
    """
    Returns the vocabulary SQLAlchemy engine
    """

    global _engine
    try:
        return _engine
    except NameError:
        pass

    from medin import DEBUG

    uri = 'sqlite:///%s' % os.path.abspath(os.path.join(os.path.dirname(__file__), 'data', 'vocabularies.sqlite'))
    _engine = sqlalchemy.create_engine(uri, echo=DEBUG)
    _engine.execute('PRAGMA foreign_keys = ON') # we need referential integrity!
    return _engine

Base = declarative_base()

class Thesaurus(Base):
    __tablename__ = 'thesauri'

    id = Column(Integer, primary_key=True, autoincrement=False)
    name = Column(String)
    refdate = Column(Date)
    description = Column(String)

    discriminator = Column('type', String(30))
    __mapper_args__ = {'polymorphic_on': discriminator}

    terms = relationship('Term',
                         order_by='Term.term',
                         cascade="all, delete, delete-orphan",
                         single_parent=True)

    def __init__(self, id, name):
        self.id = id
        self.name = name

    def __repr__(self):
        return "<%s(%d, '%s')>" % (self.__class__.__name__, self.id, self.name)

class Term(Base):
    __tablename__ = 'terms'

    term = Column(String, primary_key=True)
    thesaurus_id = Column(Integer, ForeignKey('thesauri.id', ondelete='CASCADE'), primary_key=True)
    definition = Column(String)

    __mapper_args__ = {'polymorphic_on': thesaurus_id}

    def __init__(self, term, definition=None):
        self.term = term
        self.definition = definition

    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, self.term)

class ISOThesaurus(Thesaurus):
    __mapper_args__ = {'polymorphic_identity': 'iso-code'} # used to populate thesauri.type

# ISO Terms
class INSPIREDataType(Term):
    __mapper_args__ = {'polymorphic_identity': 1}

class MaintenanceFrequency(Term):
    __mapper_args__ = {'polymorphic_identity': 4}

class AccessRestriction(Term):
    __mapper_args__ = {'polymorphic_identity': 7}

class ContactRole(Term):
    __mapper_args__ = {'polymorphic_identity': 8}

class ResourceType(Term):
    __mapper_args__ = {'polymorphic_identity': 12}

class DateType(Term):
    __mapper_args__ = {'polymorphic_identity': 17}

def ISOTerm(thesaurus_id, *args, **kwargs):
    """
    Factory function for creating ISO Term instances
    """

    class_map = {1: INSPIREDataType,
                 4: MaintenanceFrequency,
                 7: AccessRestriction,
                 8: ContactRole,
                 12: ResourceType,
                 17: DateType}

    try:
        klass = class_map[thesaurus_id]
    except KeyError:
        raise ValueError('The thesaurus id is not an ISO thesaurus: %s' % str(thesaurus_id))

    return klass(*args, **kwargs)


class NERCThesaurus(Thesaurus):
    __tablename__ = 'nerc_thesauri'
    __mapper_args__ = {'polymorphic_identity': 'keyword'} # used to populate thesauri.type

    id = Column(Integer, ForeignKey('thesauri.id', ondelete='CASCADE'), primary_key=True, autoincrement=False)
    url = Column(String)

    def __init__(self, id, name, url):
        super(NERCThesaurus, self).__init__(id, name)
        self.url = url

class NERCTerm(Term):
    __tablename__ = 'nerc_terms'
    __table_args__ = (
        ForeignKeyConstraint(['thesaurus_id', 'term'], ['terms.thesaurus_id', 'terms.term'], ondelete='CASCADE'),
        {}
    )

    # Vocabulary entry key
    key = Column(String, primary_key=True)
    # Vocabulary entry abbreviated term
    abbrv = Column(String)

    # The foreign keys
    term = Column(String, nullable=False)
    thesaurus_id = Column(Integer, nullable=False)

    def __init__(self, key, term, abbrv, definition=None):
        super(NERCTerm, self).__init__(term, definition)
        self.key = key
        self.abbrv = abbrv

# Concrete NERC terms

class ISOCountry(NERCTerm):
    __mapper_args__ = {'polymorphic_identity': 2}

class TopicCategory(NERCTerm):
    __mapper_args__ = {'polymorphic_identity': 3}

class INSPIRETheme(NERCTerm):
    __mapper_args__ = {'polymorphic_identity': 6}

class SeaDataParameter(NERCTerm):
    __mapper_args__ = {'polymorphic_identity': 10}

class VerticalCoverage(NERCTerm):
    __mapper_args__ = {'polymorphic_identity': 11}

class IHBSeaArea(NERCTerm):
    __mapper_args__ = {'polymorphic_identity': 13}

class MEDINFormat(NERCTerm):
    __mapper_args__ = {'polymorphic_identity': 16}


class NERCVocab(object):
    """
    Vocabularies sourced from the NERC service

    See http://vocab.ndg.nerc.ac.uk
    """

    def __init__(self, wsdl=None):
        import suds
        
        if wsdl is None:
            # from http://www.bodc.ac.uk/extlink/http%3A//vocab.ndg.nerc.ac.uk/1.1/VocabServerAPI_dl.wsdl
            wsdl = 'file://%s' % os.path.abspath(os.path.join(os.path.dirname(__file__), 'data', 'VocabServerAPI_dl.wsdl'))

        self.client = suds.client.Client(wsdl)

    def getTerms(self, url):
        """
        Returns the list of keywords from the specified service
        """

        # need some error handling here (see equivalent function in
        # medin portal)
        vlist = self.client.service.getList(url)[0]

        terms = []
        for entry in vlist:
            term = NERCTerm(entry.entryKey, entry.entryTerm, entry.entryTermAbbr, entry.entryTermDef)
            terms.append(term)

        return terms

class Session(object):

    def __init__(self):
        from sqlalchemy.orm import sessionmaker

        self.engine = get_engine()
        Session = sessionmaker(bind=self.engine)
        
        self.session = Session()

    def create(self):
        """
        Creates the required schema in the database

        This sets up the various thesauri.
        """
        from datetime import date
        from json import load
        import os.path

        # ensure the schema is valid
        Thesaurus.metadata.create_all(self.engine)

        # these dictionaries define the supported thesauri
        thesauri_path = os.path.join(os.path.dirname(__file__), 'data', 'thesauri.json')
        thesauri_data = load(open(thesauri_path, 'r'))

        terms_path = os.path.join(os.path.dirname(__file__), 'data', 'terms.json')
        terms_data = load(open(terms_path, 'r'))

        # delete existing data. We only need to delete the thesauri as
        # everything else cascades.
        self.session.expire_all()
        self.session.query(Thesaurus).delete(False)

        # add the NERC thesauri
        today = date.today()
        thesauri = []
        for id, name, url, description in thesauri_data['nerc']:
            thesaurus = NERCThesaurus(id, name, url)
            thesaurus.refdate = today
            thesaurus.description = description
            thesauri.append(thesaurus)

        # add the ISO thesauri
        for id, name, description in thesauri_data['iso']:
            thesaurus = ISOThesaurus(id, name)
            thesaurus.refdate = today
            thesaurus.description = description

            # add the ISO terms to the thesaurus
            terms = terms_data['iso'][str(id)]
            for word, definition in terms:
                term = ISOTerm(id, word, definition)
                thesaurus.terms.append(term)
            
            thesauri.append(thesaurus)

        # add it all in!
        self.session.add_all(thesauri)
        self.session.commit()

    def update(self, wsdl=None):
        """
        Update the vocabularies from the web
        """
        from medin import log

        # update the NERC vocabularies
        nerc_vocab = NERCVocab()
        for thesaurus in self.session.query(NERCThesaurus):
            log("Updating thesaurus %s..." % thesaurus.name)
            thesaurus.terms = nerc_vocab.getTerms(thesaurus.url)
            log("%s has %d entries" % (thesaurus.name, len(thesaurus.terms)))

        self.session.commit()

    def getThesaurus(self, id):
        """
        Return the thesaurus with the specific id
        """
        from sqlalchemy.orm.exc import NoResultFound

        try:
            return self.session.query(Thesaurus).filter(Thesaurus.id == id).one()
        except NoResultFound:
            return None

    def _getTerm(self, word, term_class):
        """
        Retrieve a term associated with a specific thesaurus
        """
        from sqlalchemy.orm.exc import NoResultFound

        try:
            return self.session.query(term_class).filter(term_class.term == word).one()
        except NoResultFound:
            return None

    def getINSPIREDataType(self, word):
        return self._getTerm(word, INSPIREDataType)

    def getMaintenanceFrequency(self, word):
        return self._getTerm(word, MaintenanceFrequency)

    def getAccessRestriction(self, word):
        return self._getTerm(word, AccessRestriction)

    def getContactRole(self, word):
        return self._getTerm(word, ContactRole)

    def getResourceType(self, word):
        return self._getTerm(word, ResourceType)

    def getDateType(self, word):
        return self._getTerm(word, DateType)

    def getISOCountry(self, word):
        return self._getTerm(word, ISOCountry)

    def getTopicCategory(self, word):
        return self._getTerm(word, TopicCategory)

    def getINSPIRETheme(self, word):
        return self._getTerm(word, INSPIRETheme)

    def getSeaDataParameter(self, word):
        return self._getTerm(word, SeaDataParameter)

    def getVerticalCoverage(self, word):
        return self._getTerm(word, VerticalCoverage)

    def getIHBSeaArea(self, word):
        return self._getTerm(word, IHBSeaArea)

    def getMEDINFormat(self, word):
        return self._getTerm(word, MEDINFormat)

if __name__ == '__main__':
    session = Session()
    session.create()
    session.update()
