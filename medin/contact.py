from sqlalchemy import Column, Integer, String, Index
from sqlalchemy.ext.declarative import declarative_base
from medin.util import get_engine

Base = declarative_base()

class Organisation(Base):
    __tablename__ = 'organisations'

    n_code = Column(Integer, primary_key=True, autoincrement=False, index=True)
    name = Column(String)
    address = Column(String)
    zipcode = Column(String)
    city = Column(String)
    state = Column(String)
    country = Column(String)
    email = Column(String)
    phone = Column(String)
    fax = Column(String)
    website = Column(String)

    def __init__(self, n_code, name):
        self.n_code = n_code
        self.name = name

    def __repr__(self):
        return "<%s(%d, '%s')>" % (self.__class__.__name__, self.n_code, self.name)

    def __hash__(self):
        return self.n_code

class Organisations(object):
    """
    Organisations sourced from the EDMO web service

    See http://www.seadatanet.org/metadata/edmo
    """

    def __init__(self, wsdl=None):
        from os.path import dirname, join, abspath
        import suds
        
        if wsdl is None:
            # from http://seadatanet.maris2.nl/ws/ws_edmo.asmx?wsdl
            wsdlname = join(dirname(__file__), 'data', 'ws_edmo.wsdl')
            wsdl = 'file://%s' % abspath(wsdlname)

        self.client = suds.client.Client(wsdl)

    def getOrganisations(self):
        """
        Returns the list of organisations
        """
        from xml.etree.cElementTree import XMLParser
        
        # need some error handling here (see equivalent function in
        # medin portal)
        xml = self.client.service.ws_edmo_get_list()
        parser = XMLParser()
        parser.feed(xml)
        tree = parser.close()

        organisations = []
        for element in tree:
            n_code = int(element.findtext('n_code'))
            name = element.findtext('name')
            organisation = Organisation(n_code, name)
            for attr in ('address',
                         'city',
                         'zipcode',
                         'state',
                         'email',
                         'phone',
                         'fax',
                         'website'):
                value = element.findtext(attr).strip()
                if value:
                    setattr(organisation, attr, value)
            organisation.country = element.findtext('c_country')
            organisations.append(organisation)

        return organisations
        
class Session(object):

    def __init__(self):
        from sqlalchemy.orm import sessionmaker

        self.engine = get_engine('contacts.sqlite')
        Session = sessionmaker(bind=self.engine)
        
        self.session = Session()

    def create(self):
        """
        Creates the required schema in the database

        This sets up the organisations.
        """
        from sqlalchemy import MetaData
        
        # drop all existing tables
        current = MetaData(self.engine)
        current.reflect()
        current.drop_all()
        del current

        # create the existing schema
        Organisation.metadata.create_all(self.engine)
       
        self.session.commit()

    def update(self, wsdl=None):
        """
        Update the organisations from the web
        """
        from medin import log

        # update the organisations
        log('Retrieving organisations from EDMO')
        source = Organisations()
        organisations = source.getOrganisations()

        log('Updating existing organisations')
        self.session.add_all(organisations)
        self.session.commit()

    def getOrganisation(self, n_code):
        """
        Return the organisation with the specific id
        """
        from sqlalchemy.orm.exc import NoResultFound

        try:
            return self.session.query(Organisation).filter(Organisation.n_code == n_code).one()
        except NoResultFound:
            return None

if __name__ == '__main__':
    session = Session()
    session.create()
    session.update()
