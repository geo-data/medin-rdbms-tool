import sys

# ensure we're using UTF-8
import sys
sys = reload(sys)
sys.setdefaultencoding('utf-8')

from distutils.core import setup
from medin.util import check_environment
from medin import __version__

def die(msg):
    sys.stderr.write(msg + "\n")
    sys.exit(1)

check_environment()

package_args = dict(
    name='medin-metadata',
    version=__version__,
    description='Tool to extract MEDIN XML metadata from a DAC RDBMS and optionally validate it',
    author='Homme Zwaagstra',
    author_email='hrz@geodata.soton.ac.uk',
    url='http://www.geodata.soton.ac.uk',
    requires=['libxml2', 'libxslt', 'suds', 'sqlalchemy'],
    packages=['medin', 'medin.schema'],
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
                            'data/vocabularies.sqlite']})

# decide whether to build an exe or install
try:
    import py2exe
    
    package_args['console'] = ['medin-metadata']
except ImportError:
    
    package_args.update(dict(
        scripts=['medin-metadata'],
        data_files=[('bin', ['medin-metadata'])]))

# run the setup
setup(**package_args)
