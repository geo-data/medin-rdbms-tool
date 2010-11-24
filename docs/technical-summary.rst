MEDIN RDBMS Tool: Technical Summary
===================================

Introduction
------------

The goal of the MEDIN Relational Database Management System (RDBMS) tool is to extract metadata from a Data Archive Centre (DAC) and output it as XML compliant with the MEDIN Metadata Standard. In order to achieve this the tool must meet a number of secondary requirements:

- Metadata Modelling: The tool must be able to access a number of pre-defined RDBMS schemas as each DAC maintains its metadata in different databases with different data structures. As a consequence, the tool must also be extensible enough to support the addition of new schemas and new DACs in the future.

- Metadata Enhancement: The tool must be able to automatically populate and expand metadata elements that are derived from common vocabularies. These vocabularies are not maintained by individual DACs but are instead managed centrally and only referenced by them. The tool matches these references with the relevant centrally managed thesauri and embeds further data as necessary.

- Metadata Validation: The tool must be able to validate the resulting XML output to ensure that the content obtained from the DAC RDBMS is MEDIN compliant.

- Metadata Output: The tool must be able to output data as MEDIN XML. It must be able to dump the entire contents of an DAC RDBMS as XML as well as being able to extract specific metadata entries.

The remainder of this document provides an overview of how these goals have been met from a technical perspective.

Implementation
--------------

The tool has currently been implemented as a Command Line Interface (CLI) application using the Python programming language. It is therefore run in a terminal window (command prompt) with options specified on the command line using various switches.

Basic usage would be:

medin-metadata [OPTIONS] [SCHEMA] [CONNSTRING]

where [OPTIONS] are one or more command line switches, [SCHEMA] is a name representing the schema to use and [CONNSTRING] is a string specifying the parameters required to connect to the RDBMS.

Options are as follows:

  -h, --help            Show the help message and exit
  -u, --update-vocab    Update the locally stored vocabularies from the
                        internet
  -d, --debug           Enable debugging output
  -i METADATA_ID, --metadata-id=METADATA_ID
                        Output a specific metadata ID
  -v, --validate        Enable validation of output XML.
  -o DIRECTORY, --output-dir=DIRECTORY
                        Output the XML to the specified DIRECTORY


Metadata Modelling
------------------

In order to enable the tool to connect to a variety of DAC RDBMS systems it implements a plugin architecture. A plugin is created for each unique DAC RDBMS schema, providing the tool with the information necessary to extract the metadata. The extracted metadata is then used to populate an independant internal data structure representing the MEDIN metadata standard. This data structure is the same across all plugins and as such provides a useful abstraction. The data structure can then be transformed to XML in a process that is independant of the DAC plugin which created it. An additional benefit is that it is relatively easy to update existing representations and create new ones in the future. This architecture is illustrated in Figure 1.

When using the tool in practice the user specifies both the schema plugin to use and the connection parameters for the RDBMS.

.. figure:: technical-summary.png
   :alt: Figure 1

   Figure 1: MEDIN Metadata from RDBMS to XML

Metadata Enhancement
--------------------

Common vocabularies are liable to change and be updated. It therefore makes sense for a DAC RDBMS to simply maintain references to well defined terms. The tool can then use the reference to extract the detail it needs to populate the metadata. The vocabularies themselves are maintained by various online services, notably http://vocab.ndg.nerc.ac.uk . The tool maintains a copy of the relevant vocabularies for off-line access. The --update-vocab option on the tool updates this local copy.

Metadata Validation
-------------------

Once the metadata has been assembled by the tool from the DAC RDBMS and the relevant vocabularies it can be output as MEDIN XML. Such XML, however, is not guaranteed to fully comply to the XML standard. The XML structure will be valid because that is controlled by the tool. The content, however, with the exception of the vocabulary terms, is under the control of the DAC and may not meet MEDIN requirements. A simple example might be that the metadata bounding box has a north value that is less than the south value. To catch these content errors, the tool provides the --validate option to validate the generated XML using the MEDIN schematron schema language. Documents which fail the validation cause the tool to output a list of errors requiring the attention of the DAC RDBMS administrator.

Metadata Output
---------------

By default the tool will iterate over the entire contents of the specified RDBMS, printing the results to the terminal screen as XML embedded as a multi-part MIME message. In addition to making it easy to see the XML produced, this also makes it capable of providing input to other processes (e.g. email). There is also an option to specify an output directory on the filesystem using the --output-dir switch. If this is done the metadata is saved as individual XML documents within this directory using the unique metadata identifier as the filename.

An option is also available to generate XML for individual metadata entries. This is done by specifying the unique metadata identifier on the command line. Again the default is to print the XML directly to the screen. If, however, an output directory is specified then the XML is created within that directory
