/*
 *  Synopsis:
 *	Transform output of pcal_loop() function to json.
 *  Usage:
 *	loop2json <file-path> >loop.json
 *  Note:
 *	Need to swap bytes on int values returned by pcap_*() header routines.
 *
 *	Code is NOT ready for UTF8.
 *
 *	Be sure to add link layer:
 *
 *		PKTAP (Apple DLT_PKTAP)
 *
 *	The "-i any" generates that link layer on mac.
 */
#include <string.h>
#include <stdio.h>

#include <pcap.h>
#include <netinet/in.h>
#include <netinet/if_ether.h>

#include "jmscott/die.c"
#include "jmscott/hexdump.c"
#include "jmscott/posio.c"
#include "jmscott/time.c"
#include "jmscott/json.c"

#define MAX_TCP_PACKET	65535

char *jmscott_progname = "loop2json";
struct jmscott_json *json;

static long long pkt_count = 0;
static long long ETHERTYPE_IP_count = 0;
static long long unknown_pkt_type_count = 0;
static long long IPPROTO_TCP_count = 0;
static long long ETHERTYPE_ARP_count = 0;
static long long ETHERTYPE_REVARP_count = 0;

struct loop_invoke
{
	pcap_t			*pcp;
	struct jmscott_json	*jp;
};

static void
die(char *msg)
{
	jmscott_die(1, msg);
}

static void
die2(char *msg1, char *msg2)
{
	jmscott_die2(1, msg1, msg2);
}

#ifdef NO_COMPILE
static short
swap_short(pcap_t *pcp, int i)
{
	if (pcap_is_swapped(pcp))
	     return ((u_short)(((((u_int)(i))&0xff)<<8) | \
                ((((u_int)(i))&0xff00)>>8)));
	return (unsigned short)i;
}
#endif

static void
ETHERTYPE_IP_cb(
    u_char *args,
    const struct pcap_pkthdr *header,
    const u_char *packet
) {
	(void)args;

	ETHERTYPE_IP_count++;

	/*
	 *  The total packet length, including all headers
	 *  and the data payload is stored in
	 *  header->len and header->caplen. Caplen is
       	 *  the amount actually available, and len is the
       	 *  total packet length even if it is larger
       	 *  than what we currently have captured. If the snapshot
       	 *  length set with pcap_open_live() is too small, you may
       	 *  not have the whole packet.
	 */
	fprintf(stderr, "Total packet available: %d bytes\n", header->caplen);
	fprintf(stderr, "Expected packet size: %d bytes\n", header->len);

	/* Pointers to start point of various headers */
	const u_char *ip_header;
	const u_char *tcp_header;
	const u_char *payload;

	/* Header lengths in bytes */
	int ethernet_header_length = 14; /* Doesn't change */
	int ip_header_length;
	int tcp_header_length;
	int payload_length;

	/* Find start of IP header */
	ip_header = packet + ethernet_header_length;

	/*  The second-half of the first byte in ip_header
         *  contains the IP header length (IHL).
	 */
	ip_header_length = ((*ip_header) & 0x0F);

	/*
	 *  The IHL is number of 32-bit segments. Multiply
	 *  by four to get a byte count for pointer arithmetic
	 */
	ip_header_length = ip_header_length * 4;
	fprintf(stderr, "IP header length (IHL) in bytes: %d\n", ip_header_length);

	/*
	 *  Now that we know where the IP header is, we can 
         *  inspect the IP header for a protocol number to 
         *  make sure it is TCP before going any further. 
         *  Protocol is always the 10th byte of the IP header
	 */
	u_char protocol = *(ip_header + 9);
	if (protocol != IPPROTO_TCP) {
		fprintf(stderr, "Not a TCP packet. Skipping...\n\n");
		return;
	}
	IPPROTO_TCP_count++;

	/*
	 *  Add the ethernet and ip header length to the start of the packet
         *  to find the beginning of the TCP header
	 */
	tcp_header = packet + ethernet_header_length + ip_header_length;

	/*
	 *  TCP header length is stored in the first half 
         *  of the 12th byte in the TCP header. Because we only want
         *  the value of the top half of the byte, we have to shift it
         *  down to the bottom half otherwise it is using the most 
         *  significant bits instead of the least significant bits
	 */
	tcp_header_length = ((*(tcp_header + 12)) & 0xF0) >> 4;

	/*
	 *  The TCP header length stored in those 4 bits represents
         *  how many 32-bit words there are in the header, just like
         *  the IP header length. We multiply by four again to get a
         *  byte count.
	 */
	tcp_header_length = tcp_header_length * 4;
	fprintf(stderr, "TCP header length in bytes: %d\n", tcp_header_length);

	/* Add up all the header sizes to find the payload offset */
	int total_headers_size = ethernet_header_length + ip_header_length
	                         + tcp_header_length;
	fprintf(stderr, "Size of all headers combined: %d bytes\n", total_headers_size);
	payload_length = header->caplen -
        	(ethernet_header_length + ip_header_length + tcp_header_length);

	fprintf(stderr, "Payload size: %d bytes\n", payload_length);
	payload = packet + total_headers_size;

	/* Print payload in ASCII */
	if (payload_length > 0) {
		char hex[1024 * 64];

		jmscott_hexdump(
			(unsigned char *)payload,
			payload_length,
			'>',
			hex,
			sizeof hex - 1
		);
		fprintf(stderr, "Hex:\n%s\n", hex);
	}
}

		
/*
 *  Convert an arbitrary packet in pcap stream to json object.
 */
static
void pkt2json(
    u_char *args,
    const struct pcap_pkthdr *header,
    const u_char *packet
) {
	struct loop_invoke *lip = (struct loop_invoke *)args;

	char *err;
	char *template = "{						\n\
	#  loop packet offset						\n\
	k:i,								\n\
									\n\
	#  ts->ts_sec							\n\
	k:i,								\n\
									\n\
	#  caplen: length of portion present				\n\
	k:i,								\n\
									\n\
	#  len: length of this pkt (off wire)				\n\
	k:i								\n\
	#  struct pcap_pkthdr {						\n\
        #	struct timeval ts;      // time stamp			\n\
        #	bpf_u_int32 caplen;     // length of portion present	\n\
        #	bpf_u_int32 len;        // length of this pkt (off wire)\n\
	#  };								\n\
},";

	/*
	 *  Write out the generic pcap packet structure, regardless of
	 *  link type.
	 */
	err = jmscott_json_write(lip->jp, template,
		"loop_offset", pkt_count,
		"ts_tv_sec", header->ts.tv_sec,
		"ts_tv_usec", header->ts.tv_usec,
		"caplen", header->caplen,
		"len", header->len
	);
	if (err)
		die2("pkt2json(): jmscott_json_write() failed", err);
	pkt_count++;
	
	//  do we have an ethernet packet?
	struct ether_header *eth_header;
	eth_header = (struct ether_header *)packet;
	switch (ntohs(eth_header->ether_type)) {
	case ETHERTYPE_IP:
		ETHERTYPE_IP_cb(args, header, packet);
		break;
	case ETHERTYPE_ARP:
		ETHERTYPE_ARP_count++;
		break;
	case ETHERTYPE_REVARP:
		ETHERTYPE_REVARP_count++;
		break;
	default:
		unknown_pkt_type_count++;
	}
}

static void
json_open(struct loop_invoke *lip, char *now)
{
	char *err;
	struct jmscott_json *jp = jmscott_json_new();
	if (!jp)
		die("malloc(struct jmscott_json) failed");
	lip->jp = jp;
	pcap_t *pcp = lip->pcp;

	char *template = "{						\n\
	#  now timestamp						\n\
	k:s,								\n\
									\n\
	#  is_swapped:  is the endianess opposite of machine order?	\n\
	k:b,								\n\
									\n\
	#  put_payload: do we put the payloads				\n\
	k:b,								\n\
									\n\
	#  pcap major version						\n\
	k:i,								\n\
									\n\
	#  pcap minor version						\n\
	k:i,								\n\
									\n\
	#  snapshot length						\n\
	k:i,								\n\
									\n\
	#  version of libpcap						\n\
	k:s,								\n\
									\n\
	#  datalink							\n\
	k:i,								\n\
									\n\
	#  datalink name						\n\
	#								\n\
	#  Note:							\n\
	#	not checking for unknown datalink name			\n\
	k:s,								\n\
									\n\
	#  datalink description						\n\
	k:s,								\n\
									\n\
	#  start of array of packets						\n\
	k:[								\n\
";
	err = jmscott_json_write(lip->jp, template,
		"now", now,
		"is_swapped", pcap_is_swapped(pcp),
		"put_payload", 1,
		"major_version", pcap_major_version(pcp),
		"minor_version", pcap_minor_version(pcp),
		"snapshot", pcap_snapshot(pcp),
		"lib_version", pcap_lib_version(),
		"datalink", pcap_datalink(pcp),
		"datalink_name",
			pcap_datalink_val_to_name(pcap_datalink(pcp)),
		"datalink_description",
			pcap_datalink_val_to_description(pcap_datalink(pcp)),
		"packets"
	);
	if (err)
		die2("json_open(): jmscott_json_write() ailed", err);
}

static void
json_close(struct loop_invoke *lp)
{
	char *err;
	char *template = "						\n\
	{}],								\n\
									\n\
	#  pkt_count							\n\
	k:i,								\n\
									\n\
	#  known_pkt_type_count						\n\
	k:i,								\n\
									\n\
	#  ETHERTYPE_IP_count						\n\
	k:i,								\n\
									\n\
	#  IPPROTO_TCP_count						\n\
	k:i,								\n\
									\n\
	#  ETHERTYPE_ARP_count						\n\
	k:i,								\n\
									\n\
	#  ETHERTYPE_REVARP_count					\n\
	k:i								\n\
}";
	err = jmscott_json_write(lp->jp, template,
		"pkt_count", pkt_count,
		"unknown_pkt_type_count", unknown_pkt_type_count,
		"ETHERTYPE_IP_count", ETHERTYPE_IP_count,
		"IPPROTO_TCP_count", IPPROTO_TCP_count,
		"ETHERTYPE_ARP_count", ETHERTYPE_ARP_count,
		"ETHERTYPE_REVARP_count", ETHERTYPE_REVARP_count
	);
}

int
main(int argc, char **argv)
{
	(void)argv;

	char perr[PCAP_ERRBUF_SIZE], *err;
	char now[36];		//  RFC3339Nano

	if (argc != 1)
		die("wrong number of arguments");

	if ((err = jmscott_RFC3339Nano_now(now, sizeof now)))
		die2("RFC3339Nano() failed", err);

	/*
	 *  Create pcap handle reading from stdin.
	 */
	struct loop_invoke l;
	perr[0] = 0;
	l.pcp = pcap_open_offline("-", perr);
	if (perr[0])
		die2("pcap_open_offline(stdin) failed", perr);

	json_open(&l, now);

	pcap_loop(l.pcp, (int)2147483648, pkt2json, (u_char *)&l);
	
	json_close(&l);

	return 0;
}
