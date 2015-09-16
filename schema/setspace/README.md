# Synopsis

The core **setspace** schema records common facts about immutable blobs.

# Description

The **setspace** schema records common facts about immutable blobs.
Typical facts are byte count, byte existence, and the 32 byte prefix of the
blob.

These facts are eventually pushed to a relation database, like PostgreSQL.
Each fact is expected to map to a particular table in the relational database.
The full set of fact tables stored in PostgreSQL are as follows:

* *byte_count*: count of bytes in the blob;  i.e., the "size".
* *byte_bitmap*: a 256 bit vector **(bit(256))** enumerating existence of bytes
* *byte_prefix_32*: the first 32 bytes of the blob.
* *new_line_count*: count of newlines bytes in the blob
* *is_utf8wf*: is the blob a well formed UTF-8 sequence of bytes

#See
	The PostgreSQL schema

		[http://github.com/jmscott/setspace/blob/master/schema/setspace/schema.sql]

# Blame
* jmscott@setspace.com
* setspace@gmail.com
