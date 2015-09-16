# Synopsis

The core setspace schema records common facts about blobs.

# Description

The **setspace** schema records common facts about blobs.  Typical facts
are byte count, byte existence, and the 32 byte prefix of the blob.

All the fact tables are

* byte_count		The count of bytes in the blob;  i.e., the "size".
* byte_bitmap		A 256 bit vector **(bit(256))** enumerating existence of bytes
* byte_prefix_32	Bytes 0-31 of the blob, as a bytea

# Blame

	jmscott@setspace.com
	setspace@gmail.com
