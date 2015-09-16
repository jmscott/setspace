# Synopsis

The core **setspace** schema records common facts about blobs.

# Description

The **setspace** schema records common facts about blobs.  Typical facts
are byte count, byte existence, and the 32 byte prefix of the blob.

The fact tables stored in PostgreSQL are:

* *byte_count*: count of bytes in the blob;  i.e., the "size".
* *byte_bitmap*: a 256 bit vector **(bit(256))** enumerating existence of bytes
* *byte_prefix_32*: the first 32 bytes of the blob.

**SetSpace** always derives the core facts.

# Blame
* jmscott@setspace.com
* setspace@gmail.com
