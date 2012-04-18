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

# ensure we're using UTF-8
import sys
sys = reload(sys)
sys.setdefaultencoding('utf-8')

import os
import glob

from distutils.core import setup
from medin.util import check_environment
from medin import __version__

def die(msg):
    sys.stderr.write(msg + "\n")
    sys.exit(1)

# from http://www.py2exe.org/index.cgi/data_files
def find_data_files(source,target,patterns):
    """Locates the specified data-files and returns the matches
    in a data_files compatible format.

    source is the root of the source data tree.
        Use '' or '.' for current directory.
    target is the root of the target data tree.
        Use '' or '.' for the distribution directory.
    patterns is a sequence of glob-patterns for the
        files you want to copy.
    """
    if glob.has_magic(source) or glob.has_magic(target):
        raise ValueError("Magic not allowed in src, target")
    ret = {}
    for pattern in patterns:
        pattern = os.path.join(source,pattern)
        for filename in glob.glob(pattern):
            if os.path.isfile(filename):
                targetpath = os.path.join(target,os.path.relpath(filename,source))
                path = os.path.dirname(targetpath)
                ret.setdefault(path,[]).append(filename)
    return sorted(ret.items())

check_environment()

package_args = dict(
    name='medin-metadata',
    version=__version__,
    description='Tool to extract MEDIN XML metadata from a DAC RDBMS and optionally validate it',
    author='Homme Zwaagstra',
    author_email='hrz@geodata.soton.ac.uk',
    url='http://www.geodata.soton.ac.uk',
    requires=['libxml2', 'libxslt', 'suds', 'sqlalchemy'],
    packages=['medin', 'medin.source'],
    package_data={'medin': ['data/isotc211/*.txt',
                            'data/isotc211/gco/*',
                            'data/isotc211/gfc/*',
                            'data/isotc211/gmd/*',
                            'data/isotc211/gmi/*',
                            'data/isotc211/gml/*',
                            'data/isotc211/gmx/*',
                            'data/isotc211/gsr/*',
                            'data/isotc211/gss/*',
                            'data/isotc211/gts/*',
                            'data/isotc211/resources/*.txt',
                            'data/isotc211/resources/Codelist/*',
                            'data/isotc211/resources/crs/*',
                            'data/isotc211/resources/example/*',
                            'data/isotc211/resources/uom/*',
                            'data/isotc211/srv/*',
                            'data/isotc211/xlink/*',
                            'data/example.sqlite',
                            'data/terms.json',
                            'data/thesauri.json',
                            'data/VocabServerAPI_dl.wsdl',
                            'data/ws_edmo.wsdl',
                            'data/MedinMetadataProfile_v1.7.xsl',
                            'data/ISOTS19139A1Constraints_v1.3.xsl',
                            'data/contacts.sqlite',
                            'data/vocabularies.sqlite']})

# decide whether to build an exe or install
try:
    import py2exe

    # convert package_data to data_files
    data_files = [('', ['README-Windows.txt'])]
    for directory, patterns in package_args['package_data'].items():
        data_files.extend(find_data_files(directory, directory, patterns))
    
    package_args.update({
            'console': ['medin-metadata'],
            'data_files': data_files,
            'options': {
                'py2exe': {
                    'packages': ['sqlalchemy.dialects.sqlite',
                                 'sqlalchemy.dialects.oracle',
                                 'cx_Oracle',
                                 'xml.etree.ElementTree',
                                 'medin.source.medin-rdbms'],
                    "dll_excludes": ["oci.dll"], # exclude oracle version specific dll (http://www.py2exe.org/index.cgi/ExcludingDlls)
                    "optimize": 2,
                    'skip_archive': True
                    }
                }
            })
except ImportError:
    
    package_args.update(dict(
        scripts=['medin-metadata', 'extra/validate-xml.py'],
        data_files=[('bin', ['medin-metadata'])]))

# run the setup
setup(**package_args)
