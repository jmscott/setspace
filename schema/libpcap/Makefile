include ../../local.mk
include ../../setspace.mk

all: pcap2json

pcap2json: pcap2json.c
	$(CC) $(CFLAGS) -I$(JMSCOTT_ROOT)/include -I$(PCAPINC) 		\
		pcap2json.c -L$(PCAPLIB) -lpcap -o pcap2json
