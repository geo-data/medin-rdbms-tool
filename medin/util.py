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

class Version(object):
    """Representation of program version information"""

    def __init__(self, major, minor, patch=0):
        self.major = major
        self.minor = minor
        self.patch = patch

    @classmethod
    def parse(cls, version_str):
        """Class method to parse a version string into a Version object"""
        import re

        m = re.search('(\d+)\.(\d+)(?:\.(\d+))?', version_str)
        if not m:
            raise ValueError('The version string could not be parsed')

        return cls(*[int(g) for g in m.groups() if g is not None])

    def __cmp__(self, other):
        """Compare one version with another"""
        
        res = cmp(self.major, other.major)
        if res != 0: return res
        res = cmp(self.minor, other.minor)
        if res != 0: return res
        return cmp(self.patch, other.patch)

    def __str__(self):
        return '%d.%d.%d' % (self.major, self.minor, self.patch)

    def __repr__(self):
        return "%s('%s')" % (self.__class__.__name__, self)

def get_version(config_cmd):
    """Try and retrieve a program version"""

    import subprocess

    try:
        p = subprocess.Popen([config_cmd, '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE);
    except OSError, e:
        raise EnvironmentError("There was an error retrieving version information using %s: %s" % (config_cmd, str(e)))
    out, err = p.communicate()
    if err and p.returncode != 0:
        raise EnvironmentError("There was an error retrieving version information using %s: %s" % (config_cmd, err))

    try:
        return Version.parse(out)
    except ValueError:
        raise EnvironmentError('The version of %s could not be determined' % config_cmd)

def check_environment(xml_only=False):
    """Check whether the system supports the program requirements"""
    import sys, os
    from warnings import warn
    
    # ensure we've got libxml2 and libxslt on the system
    try:
        import libxml2
    except ImportError:
        raise EnvironmentError('The libxml2 python module needs to be installed. See http://xmlsoft.org/python.html')

    try:
        import libxslt
    except ImportError:
        raise EnvironmentError('The libxslt python module needs to be installed. See http://xmlsoft.org/XSLT/python.html')

    if not xml_only:
        try:
            import suds
        except ImportError:
            raise EnvironmentError('The suds python module needs to be installed. See http://pypi.python.org/pypi/suds')

        try:
            import sqlalchemy
        except ImportError:
            raise EnvironmentError('The SQLAlchemy python module needs to be installed. See http://pypi.python.org/pypi/SQLAlchemy')

    # check we've got minimum python support
    if Version(*sys.version_info[:3]) < Version(2, 6, 0):
        raise EnvironmentError('Python 2.6 or greater is required')

    # check libxml on systems that have config scripts. On those that
    # don't (e.g. Windows) the installer should ensure the correct
    # version is present.
    if os.name == 'posix':
        # check we've got minimum libxml2 support
        try:
            version_cur = get_version('xml2-config')
        except EnvironmentError, e:
            warn(str(e), RuntimeWarning)
        else:
            version_min = Version(2, 6, 26)
            if version_cur < version_min:
                raise EnvironmentError('Your version of libxml2 is %s, it needs to be at least %s' % (version_cur, version_min))

        # check we've got minimum libxslt support
        try:
            version_cur = get_version('xslt-config')
        except EnvironmentError, e:
            warn(str(e), RuntimeWarning)
        else:
            version_min = Version(1, 1, 17)
            if version_cur < version_min:
                raise EnvironmentError('Your version of libxslt is %s, it needs to be at least %s' % (version_cur, version_min))

    if not xml_only:
        # check we've got minimum sqlalchemy support
        version_cur = Version.parse(sqlalchemy.__version__)
        version_min = Version(0, 6, 6)
        if version_cur < version_min:
            raise EnvironmentError('Your version of SQLAlchemy is %s, it needs to be at least %s' % (version_cur, version_min))

        # check we've got minimum suds support
        version_cur = Version.parse(suds.__version__)
        version_min = Version(0, 3, 9)
        if version_cur < version_min:
            raise EnvironmentError('Your version of suds is %s, it needs to be at least %s' % (version_cur, version_min))

def get_engine(name):
    """
    Returns a SQLAlchemy sqlite engine

    The 'name' parameter refers to a sqlite database managed by the
    medin module. This includes contacts.sqlite and
    vocabularies.sqlite
    """

    # try and retrieve the cache of engines. The cache is stored in
    # the get_engine object which should mean that it is global in
    # scope.
    try:
        engines = getattr(get_engine, 'engines')
    except AttributeError:
        engines = dict()
        setattr(get_engine, 'engines', engines)

    # try and return the cached engine
    try:
        return engines[name]
    except KeyError:
        pass

    from os.path import dirname, join, abspath
    from medin import DEBUG
    from sqlalchemy import create_engine

    dbname = abspath(join(dirname(__file__), 'data', name))
    uri = 'sqlite:///'+dbname
    engine = create_engine(uri, echo=DEBUG)
    engine.execute('PRAGMA foreign_keys = ON') # we need referential integrity!
    engines[name] = engine                     # cache the engine
    
    return engine
