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
MEDIN Output Module

This module contains a number of Output classes that write
medin.metadata.Metadata objects to various destinations in XML format
"""
from warnings import warn
from medin import MedinWarning

class ValidationWarning(MedinWarning):
    pass

class Filter(object):
    pass

class FilterMetadata(Filter):
    def __call__(self, metadata):
        from medin.metadata import XMLBuilder

        # transform the metadata to XML
        self.builder = XMLBuilder(metadata)
        doc = self.builder.build()

        if metadata.unique_id: unique_id = metadata.unique_id
        else: unique_id = None

        return doc, unique_id

class FilterXMLDoc(Filter):
    def __call__(self, metadata):
        from metadata import UniqueId

        xpath = metadata.xpathNewContext()
        xpath.xpathRegisterNs('gmd', 'http://www.isotc211.org/2005/gmd')
        xpath.xpathRegisterNs('gco', 'http://www.isotc211.org/2005/gco')
        try:
            node = xpath.xpathEval('//gmd:identificationInfo/gmd:MD_DataIdentification/*//gmd:identifier/gmd:RS_Identifier')[0]
        except IndexError:
            return metadata, None

        xpath.setContextNode(node)
        try:
            node = xpath.xpathEval('./gmd:code/gco:CharacterString')[0]
        except IndexError:
            return metadata, None
        code = node.content

        try:
            node = xpath.xpathEval('./gmd:codeSpace/gco:CharacterString')[0]
        except IndexError:
            codespace = None
        else:
            codespace = node.content

        unique_id = UniqueId(code, codespace)
        return metadata, unique_id

class Output(object):
    """
    Abstract base class for outputting metadata as XML
    """
    validator = None

    def __init__(self, validate=False):
        if validate:
            from medin.validate import Validator
            self.validator = Validator()

    def processMetadata(self, doc, unique_id):
        """
        Process an individual metadata instance

        Returns a tuple containing an XML string and a validation
        warning (or None, if no warning was generated).
        """
        from cStringIO import StringIO
        import libxml2
        from medin import log

        warning = None          # contains any validation warning

        if unique_id is None:
            unique_id = 'no identifier present'

        # try and validate the xml
        if self.validator:
            from medin.validate import ValidationError
            log('Validating document (%s)' % unique_id)

            try:
                self.validator(doc)
            except ValidationError, e:
                msg = 'This document (%s) is NOT valid MEDIN metadata: %s' % (unique_id, e.args[0])
                status = 'Validation status: '+msg
                warning = ValidationWarning(msg)
            else:
                status = 'Validation status: This document (%s) is valid MEDIN metadata' % unique_id
                log(status)
        else:
            status = 'Validation status: This document (%s) has NOT been validated as conforming to the MEDIN Metadata Standard' % unique_id
            log(status)
        # save the validation status in the document itself
        comment = doc.newDocComment(status)
        doc.getRootElement().addPrevSibling(comment)

        # output the document
        f = StringIO()
        buf = libxml2.createOutputBuffer(f, 'utf-8')
        doc.saveFormatFileTo(buf, 'utf-8', True)
        doc.freeDoc()                       # clean up

        return (f.getvalue().strip(), warning)

    def _createFlush(self, xml, doc, unique_id):
        """
        Return a function that outputs a metadata entry
        """
        raise NotImplementedError('This method must be overridden')
    
    def __call__(self, iter_metadata, filter_=None):
        if filter_ is None:
            filter_ = FilterMetadata()

        for metadata in iter_metadata:
            doc, unique_id = filter_(metadata)
            xml, warning = self.processMetadata(doc, unique_id)
            if not xml:
                continue
            yield self._createFlush(xml, doc, unique_id), warning

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        return False
    
class FileOutput(Output):
    """
    Output metadata as XML to a file handle
    """

    def __init__(self, file, *args, **kwargs):
        self.fh = file
        super(FileOutput, self).__init__(*args, **kwargs)

    def _createFlush(self, xml, doc, unique_id):
        def flush():
            self.fh.write(xml)
            self.fh.write("\n")
        return flush

class MIMEOutput(FileOutput):
    """
    Output metadata as XML wrapped in MIME format
    """

    def __init__(self, *args, **kwargs):
        from uuid import uuid4
        self.uid = uuid4().hex  # get an unique identifer

        super(MIMEOutput, self).__init__(*args, **kwargs)

    def __enter__(self):
        from medin import __version__
        # output the initial header
        self.fh.write("""MIME-Version: 1.0
Content-Type: multipart/mixed; charset=UTF-8; boundary="%s"

MEDIN XML Metadata created by MEDIN Metadata Generator version %s\n""" % (self.uid, str(__version__)))

    def __exit__(self, exc_type, exc_value, traceback):
        # output the final boundary
        self.fh.write("--%s--\n" % self.uid)
        return False

    def _createFlush(self, xml, doc, unique_id):
        def flush():
            if unique_id:
                filename = unique_id.id + '.xml'
            else:
                filename = self.uid + '.xml'
            self.fh.write("""--%s
Content-Type: text/xml; charset=UTF-8;
Content-Disposition: inline; filename="%s";

""" % (self.uid, filename))
            self.fh.write(xml)
            self.fh.write("\n")

        return flush

class DirOutput(Output):
    """
    Output metadata as XML files to a directory
    """

    def __init__(self, directory=None, *args, **kwargs):
        super(DirOutput, self).__init__(*args, **kwargs)

        from os.path import curdir, abspath
        if not directory:
            directory = curdir
        self.directory = abspath(directory)

    def _createFlush(self, xml, doc, unique_id):
        from os.path import join

        def flush():
            filename = unique_id.id + '.xml'
            path = join(self.directory, filename)
            try:
                with open(path, 'w') as fh:
                    fh.write(xml)
            except IOError, e:
                e.strerror = 'Could not write metadata to file: %s' % e.strerror
                raise e

        return flush
