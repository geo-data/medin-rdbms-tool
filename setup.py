from distutils.core import setup
import sys

def die(msg):
    sys.stderr.write(msg + "\n")
    sys.exit(1)

version = int(''.join([str(i) for i in sys.version_info[:2]]))
if version < 24:
    die('Python 2.4 or greater is required')

package_args = dict(
    name='medin-metadata',
    version='0.1',
    description='Tool to extract MEDIN XML metadata from a DAC RDBMS and optionally validate it',
    author='Homme Zwaagstra',
    author_email='hrz@geodata.soton.ac.uk',
    url='http://www.geodata.soton.ac.uk',
    requires=['libxml2', 'libxslt'],
    packages=['medin'],
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
                            'data/isotc211/xlink/*']})

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
