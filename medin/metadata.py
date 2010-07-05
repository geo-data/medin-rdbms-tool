"""
Representation of MEDIN Metadata Specification

This is a DOM representing the MEDIN schema. It is populated by
mapping the object to a provider database schema. This mapping is done
using the appropriate provider plugin module in the medin.provider
package.
"""
import libxml2

class Metadata(object):
    """
    The top level object
    """

    # Element 1
    title = None

    # Element 2 - a list of alternative titles
    alt_titles = None

    # Element 6
    unique_id = None

    # Element 26 
    date = None

    # Element 27
    standard = 'MEDIN Discovery Metadata Standard'

    # Element 28
    version = 'Version 2.3'

    # Element 29
    language = 'English'

    def __init__(self):
        self.alt_titles = []

class UniqueId(object):
    """
    Element 6
    """
    id = None
    codespace = None
    
    def __init__(self, id, codespace=None):
        self.id = id
        self.codespace = codespace

    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, str(self))

    def __str__(self):
        if self.codespace:
            return self.codespace + self.id
        return self.id


class XMLBuilder(object):
    """
    Turn a Metadata object into XML
    """

    def __init__(self, metadata):
        from medin import __version__
        self.m = metadata

        # create the document
        self.doc = doc = libxml2.newDoc("1.0")
        comment = doc.newDocComment("Created by MEDIN Metadata Generator version %s" % str(__version__))
        doc.addChild(comment)

        # create the root element and namespaces
        self.root = root = doc.newChild(None, "MD_Metadata", None)
        gmd = root.newNs("http://www.isotc211.org/2005/gmd", "gmd")
        gco = root.newNs("http://www.isotc211.org/2005/gco", "gco")
        root.setNs(gmd)
        self.ns = {'gmd':gmd,
                   'gco':gco}

    def build(self):
        """
        Populate the XML document from the metadata DOM
        """

        self.root.addChild(self.identificationInfo())
        self.root.addChild(self.dateStamp())
        self.root.addChild(self.metadataStandardName())
        self.root.addChild(self.metadataStandardVersion())
        self.root.addChild(self.language())
        
        return self.doc

    def identificationInfo(self):
        identificationInfo = self.doc.newDocNode(self.ns['gmd'], 'identificationInfo', None)
        MD_DataIdentification = identificationInfo.newChild(None, 'MD_DataIdentification', None)
        citation = MD_DataIdentification.newChild(None, 'citation', None)
        CI_Citation = citation.newChild(None, 'CI_Citation', None)
        CI_Citation.addChild(self.title())
        for node in self.alternativeTitles():
            CI_Citation.addChild(node)

        return identificationInfo

    def title(self):
        """
        Element 1 to XML
        """
        title = self.doc.newDocNode(self.ns['gmd'], 'title', None)
        characterString = title.newChild(self.ns['gco'], 'CharacterString', self.m.title)
        return title

    def alternativeTitles(self):
        """
        Element 2 to XML
        """
        alt_titles = []
        for title in self.m.alt_titles:
            alternateTitle = self.doc.newDocNode(self.ns['gmd'], 'alternateTitle', None)
            characterString = alternateTitle.newChild(self.ns['gco'], 'CharacterString', str(title))
            alt_titles.append(alternateTitle)
        return alt_titles

    def dateStamp(self):
        """
        Element 26 to XML
        """
        import datetime
        
        dateStamp = self.doc.newDocNode(self.ns['gmd'], 'dateStamp', None)
        sdate = self.m.date.isoformat()
        if isinstance(self.m.date, datetime.datetime):
            ele_name = 'DateTime'
        else:
            ele_name = 'Date'
        date = dateStamp.newChild(self.ns['gco'], ele_name, sdate)
        return dateStamp

    def metadataStandardName(self):
        """
        Element 27 to XML
        """
        metadataStandardName = self.doc.newDocNode(self.ns['gmd'], 'metadataStandardName', None)
        characterString = metadataStandardName.newChild(self.ns['gco'], 'CharacterString', self.m.standard)
        return metadataStandardName

    def metadataStandardVersion(self):
        """
        Element 28 to XML
        """
        metadataStandardVersion = self.doc.newDocNode(self.ns['gmd'], 'metadataStandardVersion', None)
        characterString = metadataStandardVersion.newChild(self.ns['gco'], 'CharacterString', self.m.version)
        return metadataStandardVersion

    def language(self):
        """
        Element 29 to XML
        """
        language = self.doc.newDocNode(self.ns['gmd'], 'language', None)
        languageCode = language.newChild(None, 'LanguageCode', self.m.language)
        languageCode.setProp("codeList", "http://www.loc.gov/standards/iso639-2/php/code_list.php")
        languageCode.setProp("codeListValue", "eng")

        return language
