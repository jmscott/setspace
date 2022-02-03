include ../../local.mk
include ../../setspace.mk

ifndef PCAPLIB
.ABORT
endif

ifndef PCAPINC
.ABORT
endif

all: loop2json

loop2json: loop2json.c
	$(CC) $(CFLAGS) -I$(JMSCOTT_ROOT)/include -I$(PCAPINC) 		\
		loop2json.c -L$(PCAPLIB) -lpcap -o loop2json
clean:
	rm -f loop2json
