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

import os
import libxml2
import libxslt

class SchemaError(Exception):
    def __init__(self, msg, errors):
        self.msg = msg
        self.errors = errors

    def __str__(self):
        s = self.msg + ':'
        for error in self.errors:
            s += "\n * %s" % error
        return s

class ValidationError(Exception):
    pass

class ErrorHandler:

    def __init__(self):
        self.errors = []

    def handler(self, msg, data):
        self.errors.append(msg.strip())

    def clear(self):
        self.errors = []

class Validator(object):
    """
    Validate an xml document as MEDIN compliant

    This object validates a libxml2 document against the ISO TC 211
    W3C schema, the ISO TS 19139 A1 constraints and the Medin Metadata
    Profile constraints, in that order.

    The object is a python callable and should be passed a libxml2
    document as an argument. If the validation fails a ValidationError
    is raised, otherwise the document has been deemed valid.
    """
    
    def __init__(self):
        # set up the W3C schema parser
        self.error_handler = ErrorHandler()
        filepath = os.path.join(os.path.dirname(__file__), 'data', 'isotc211', 'gmx', 'gmx.xsd')
        ctxt_parser = libxml2.schemaNewParserCtxt(filepath)
        self.isotc211_schema = ctxt_parser.schemaParse()

        # set up the ISO TS 19139 A1 constraints schematron
        filepath = os.path.join(os.path.dirname(__file__), 'data', 'ISOTS19139A1Constraints_v1.3.xsl')
        doc = libxml2.parseFile(filepath)
        self.isots19139_xslt = libxslt.parseStylesheetDoc(doc)

        # set up the MEDIN Metadata Profile schematron
        filepath = os.path.join(os.path.dirname(__file__), 'data', 'MedinMetadataProfile_v1.7.xsl')
        doc = libxml2.parseFile(filepath)
        self.medin_xslt = libxslt.parseStylesheetDoc(doc)

    def validateISOTC211W3C(self, doc):
        """
        Validate a document against the ISO TC 211 W3C Schema
        """
        
        ctxt_valid = self.isotc211_schema.schemaNewValidCtxt()
        ctxt_valid.setValidityErrorHandler(self.error_handler.handler,
                                           self.error_handler.handler,
                                           None)

        ret = doc.schemaValidateDoc(ctxt_valid)

        del ctxt_valid
        
        if ret != libxml2.XML_ERR_OK:
            msg = 'Schema validation failed'
            if ret == libxml2.XML_SCHEMAV_CVC_ELT_1:
                errors = ['The root element of a metadata document is expected to be MD_Metadata, not %s' % doc.getRootElement().name]
            elif self.error_handler.errors:
                errors = self.error_handler.errors
            else:
                errors = ['Unknown error']

            raise SchemaError(msg, errors)

    def validateISOTS19139A1(self, doc):
        """
        Validate a document against the ISO TS 19139 A1 constraints
        """
        self._validateSchematron(doc, self.isots19139_xslt)

    def validateMedinMetadataProfile(self, doc):
        """
        Validate a document against the MEDIN Metadata Profile
        """
        self._validateSchematron(doc, self.medin_xslt)
        
    def _validateSchematron(self, doc, xslt):
        result = xslt.applyStylesheet(doc, None)

        xpath_ctxt = result.xpathNewContext()
        xpath_ctxt.xpathRegisterNs('svrl', 'http://purl.oclc.org/dsdl/svrl')

        errors = [e.getContent().strip() for e in xpath_ctxt.xpathEval('//svrl:failed-assert/svrl:text/text()')]
        if errors:
            raise SchemaError('The schematron validation failed', errors)

        del xpath_ctxt
        result.freeDoc()

    def __call__(self, doc):
        try:
            try:
                self.validateISOTC211W3C(doc)
            except SchemaError, e:
                e.msg = "The document failed to validate against the ISO TC 211 W3C Schema"
                raise ValidationError(str(e))

            try:
                self.validateISOTS19139A1(doc)
            except SchemaError, e:
                e.msg = "The document failed to validate against the ISO TS 19139 A1 constraints"
                raise ValidationError(str(e))

            try:
                self.validateMedinMetadataProfile(doc)
            except SchemaError, e:
                e.msg = "The document failed to validate against the Medin Metadata Profile"
                raise ValidationError(str(e))
        finally:
            # ensure the error cache is cleared
            self.error_handler.clear()
            
    def __del__(self):
        del self.isotc211_schema
        libxml2.schemaCleanupTypes()
        self.isots19139_xslt.freeStylesheet()
        self.medin_xslt.freeStylesheet()
