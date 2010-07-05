__version__ = 0.1

# ensure we are using UTF-8. Catching this here will save headaches
# later!
import sys
if sys.getdefaultencoding() != 'utf-8':
    raise RuntimeError('Bad default Python encoding detected. MEDIN is expected to use UTF-8, found: %s' % sys.getdefaultencoding())

# Setting this to True after loading the module enables debugging
# output
DEBUG = False
def log(msg):
    """
    Log a debugging message to STDOUT
    """
    global DEBUG
    if DEBUG: print msg