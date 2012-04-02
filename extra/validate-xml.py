#!/usr/bin/env python2

# Created by Homme Zwaagstra
# 
# Copyright (c) 2012 GeoData Institute
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

__version__ = '0.0.1'

# ensure we're using UTF-8
import sys
sys = reload(sys)
sys.setdefaultencoding('utf-8')

DEBUG = False                           # controls debugging output

# replace the default warning display function with our own
import warnings
from warnings import showwarning as defaultwarning
def showwarning(message, category, *args, **kwargs):
    """
    Replacement for default warnings.showwarning

    This function only shows warnings when in debugging mode unless
    they are medin warnings in which case they are always output.
    """
    from medin import MedinWarning
    global DEBUG
    if DEBUG:
        defaultwarning(message, category, *args, **kwargs)
    elif issubclass(category, MedinWarning):
        sys.stderr.write("WARNING: %s\n" % message)
warnings.showwarning = showwarning

def die(msg):
    """End the program with a message to standard error"""

    sys.stderr.write("%s\n" % msg)
    try:
        log(msg)
    except NameError:
        pass                    # for when the medin module can't be imported

    sys.exit(1)

def main():
    """
    The main program
    """

    from optparse import OptionParser

    # try and load the medin modules
    try:
        import medin
        from medin import log
        from medin.util import check_environment
        from medin.output import MIMEOutput, FileOutput, DirOutput, ValidationWarning, FilterXMLDoc
    except ImportError:
        die('The medin module could not be found. Please ensure it is in your python module search path.')
    
    # parse out the command options
    usage = """usage: %prog [OPTION]... [INPUT]...

  Check MEDIN XML files to see whether they conform to the MEDIN
  metadata schema. 

Basic Usage:
  INPUT is the XML input to examine. It can be an individual file, a
  directory or a URL, and may be specified more than once. If INPUT is
  not specified, or is `-`, then the XML is read from standard
  input. When a directory is specified, xml files to be validated are
  expected to have a `.xml` extension.

  Validation is a three step process:

  1. Validate against the ISO TC 211 W3C schema.
  2. Validate against the ISO TS 19139 A1 Constraints (version 1.3)
  3. Validate against the Medin Metadata Profile (version 1.7)

  Any XML document passing these tests complies with the Medin
  Metadata requirements."""

    parser = OptionParser(usage=usage, version="%%prog %s" % str(__version__))

    # add the command line options
    parser.add_option("-d", '--debug', action="store_true",
                      help="Enable debugging output")
    parser.add_option("-n", '--no-mime', action="store_true",
                      help="Do not encapsulate the XML output in MIME format. This is only useful when --destination is not specified.")
    parser.add_option("-r", '--recurse', action="store_true",
                      help="If INPUT is a directory, recurse into subdirectories as well")
    parser.add_option("-o", '--destination', metavar='DIRECTORY',
                      help="Output the XML to the specified DIRECTORY. Existing files are over-written.")
    parser.add_option("-v", '--validation', default='strict', metavar='LEVEL',
                      choices=['warn', 'strict'],
                      help="""Control validation of output XML. LEVEL can be either 'warn' (output warning messages for failed validations) or 'strict' (default - output a warning message for a failed validation and exit the program)""")

    (options, args) = parser.parse_args()

    inputs = set(args)
    if not inputs:
        inputs = ['-']          # default to STDIN
    
    # turn on debugging
    global DEBUG
    if options.debug:
        DEBUG = medin.DEBUG = True

    try:
        check_environment(True) # only check the XML support
    except EnvironmentError, e:
        die(str(e))

    # function to retrieve the metadata
    from sys import stdin
    import os.path
    from os import listdir
    import libxml2

    def metadata_generator():
        for input_ in inputs:
            if input_ == '-':
                log('Reading standard input')
                yield libxml2.readFd(stdin.fileno(), 'stdin', 'utf-8', 0)
            elif os.path.isfile(input_) or os.path.islink(input_):
                log('Reading file %s' % input_)
                yield libxml2.parseFile(input_)
            elif os.path.isdir(input_):
                log('Reading directory %s' % input_)
                for metadata in iter_directory(input_, options.recurse):
                    yield metadata
            else:
                # it must be a URL
                log('Reading URL %s' % input_)
                yield libxml2.parseFile(input_)

    def iter_directory(directory, recurse=False):
        for entry in listdir(directory):
            filename = os.path.join(directory, entry)
            if recurse and os.path.isdir(filename):
                for doc in iter_directory(filename):
                    yield doc
            root, ext = os.path.splitext(entry)
            if ext == '.xml':
                log('Reading file %s' % filename)
                yield libxml2.parseFile(filename)
                
    # determine the output format
    if options.destination:
        output = DirOutput(options.destination, True)
    elif options.no_mime:
        output = FileOutput(sys.stdout, True)
    else:
        output = MIMEOutput(sys.stdout, True)

    # output the metadata entries with appropriate validation messages
    with output:
        for flush, warning in output(metadata_generator(), FilterXMLDoc()):
            try:
                flush()              # output this metadata record
            except IOError, e:
                if e.filename:
                    msg = '%s: %s' % (e.strerror, e.filename)
                else:
                    msg = e.strerror
                die(msg)

            # deal with validation warnings
            if warning and validate:
                if options.validation == 'strict':
                    die('Validation Error: %s' % str(warning))
                warnings.warn(str(warning), warning.__class__)

if __name__ == '__main__':
    try:
        main()
    except IOError, e:
        if e.errno == 32:
            pass                # it's a broken pipe
        else:
            raise
    except KeyboardInterrupt:
        die("\nProgram interrupted! Exiting...")
    except Exception, e:
        if DEBUG:
            raise
        else:
            die('FATAL ERROR: %s' % e)
