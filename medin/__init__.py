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

__version__ = '0.16'

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
    from medin import DEBUG
    if DEBUG: print msg

class MedinWarning(Warning):
    """
    Base class for Medin related warnings
    """
    pass
