include ../schema.mk
include ../../local.mk

all: merge-stdin-xml_doc

clean:
	rm -f merge-stdin-xml_doc

merge-stdin-xml_doc: merge-stdin-xml_doc.pgc
	ecpg merge-stdin-xml_doc.pgc
	$(CC) -I$(PGINC) merge-stdin-xml_doc.c -o merge-stdin-xml_doc \
						-L$(PGLIB) -lecpg
	rm merge-stdin-xml_doc.c
