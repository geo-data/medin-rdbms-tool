MEDIN METADATA RDBMS XML GENERATION TOOL
========================================

This package provides a tool to extract MEDIN XML metadata from a
Relational Database Management System (RDBMS) and optionally validate
it.

This package provides the tool in a stand-alone binary form for
Windows systems. The tool is also available in source form for
installation on systems that have Python installed. The source package
is available at:
http://www.geodata.soton.ac.uk/MEDIN_rdbms/metadata-tool.tar.gz

PREREQUISITES
-------------

The tool currently supports connecting to Oracle databases. However,
either the Oracle server or Client software must be installed for the
tool to be able to connect to an oracle database. The easiest solution
is to install the Oracle Instant Client. This is available from:
http://www.oracle.com/technetwork/database/features/instant-client/index-097480.html

Note that you have to add the location of the instant-client directory
to your PATH environment variable for the tool to be able to use the
instant client.

Support for other databases can be added by the developer as
required. A list of databases that can potentially be supported is at:
http://www.sqlalchemy.org/docs/core/engines.html#supported-dbapis

DOWNLOAD
--------

The tool can be downloaded from
http://www.geodata.soton.ac.uk/MEDIN_rdbms/metadata-tool.zip

INSTALLATION
------------

Simply unzip the package download file place the medin-metadata
directory with all its contents in a convenient location.

TESTING AND BASIC USAGE
-----------------------

The tool is command line based. You therefore interact with it through
the DOS command prompt. This can be opened by typing 'cmd' in the
'Run...' box accessible from the Windows Start menu. You then need to
change to the tool directory by along the lines of:

cd C:\medin-metadata-tool

where C:\medin-metadata-tool is your tool directory. Once there you
can use the tool by issuing it with commands e.g.

medin-metadata --help

Use of the tool should be reasonably straight forward if you're
familiar with the --help option!

It comes bundled with a copy of the EDMED database as a sqlite file
which has been used as a reference implementation for the medin schema
defined at
http://www.oceannet.org/marine_data_standards/medin_approved_standards/documents/medin_usermanaged_tables_user.doc

You can access this sample database as follows:

medin-metadata medin example

Assuming you have a database schema identical to the BODC EDMED one
and are using an Oracle database called 'EDMED' on the machine
'myhost' with the username 'me' and the password 'secret' you should
be able to connect to it as follows:

./medin-metadata medin oracle://me:secret@myhost/EDMED

CONTACT
-------

Specific queries on regarding the tool can be directed to Homme
Zwaagstra (hrz@geodata.soton.ac.uk). More general queries can be
directed to <geodata@soton.ac.uk>.
