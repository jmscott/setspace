/*
 *  Synopsis:
 *	Transform output of pcal_loop() function to json.
 *  Usage:
 *	loop2json <file-path> >loop.json
 *  Note:
 *	Be sure to add link layer:
 *
 *		PKTAP (Apple DLT_PKTAP)
 *
 *	The -i any generates that link layer.
 *
 *	Can <file-path> be replaced with <stdin>?
 */
#include <string.h>
#include <stdio.h>

#include <pcap.h>
#include <netinet/in.h>
#include <netinet/if_ether.h>

#include "jmscott/hexdump.c"
#include "jmscott/die.c"
#include "jmscott/posio.c"

/*
 *  Note:
 *	Jumbo packets > 1448!?
 */
#define MAX_TCP_PACKET	1448

char *jmscott_progname = "pcap2json";

static int packet_count = 0;

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

static void
_write(char *src, int len)
{
	if (jmscott_write(1, src, len) != 0)
		die2("write(stdout) failed", strerror(errno));
}

static void
_writes(char *src)
{
	_write(src, strlen(src));
}

//  write an json escaped ascii string
static void
write_json_string(char *src)
{
	char c, *s;
	char *j, json[MAX_TCP_PACKET * 4];

	s = src;
	j = json;

	*j++ = '"';
	while ((c = *s++)) {
		if (!isascii(c))
			die("write_json_string: non ascii char");

		switch (c) {
		case '"':
			*j++ = '\\';
			*j++ = '"';
			break;
		case '\\':
			*j++ = '\\';
			*j++ = '\\';
			break;
		case '\b':
			*j++ = '\\';
			*j++ = 'b';
			break;
		case '\f':
			*j++ = '\\';
			*j++ = 'f';
			break;
		case '\n':
			*j++ = '\\';
			*j++ = 'n';
			break;
		case '\r':
			*j++ = '\\';
			*j++ = 'r';
			break;
		case '\t':
			*j++ = '\\';
			*j++ = 't';
			break;
		default:
			*j++ = c;
		}
	}
	*j++ = '"';

	_write(json, j - json);
}
		
/* Finds the payload of a TCP/IP packet */
void parse_packet(
    u_char *args,
    const struct pcap_pkthdr *header,
    const u_char *packet
) {
	(void)args;

	packet_count++;

	/* First, lets make sure we have an IP packet */
	struct ether_header *eth_header;
	eth_header = (struct ether_header *) packet;
	if (ntohs(eth_header->ether_type) != ETHERTYPE_IP) {
        	fprintf(stderr, "Not an IP packet. Skipping...\n\n");
        	return;
	}

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
			sizeof hex-1
		);
		fprintf(stderr, "Hex:\n%s\n", hex);
	}
}

int main(int argc, char **argv)
{    
	char err[PCAP_ERRBUF_SIZE];
	pcap_t *handle;

	if (argc != 2)
		die("wrong number of arguments");

	err[0] = 0;
	handle = pcap_open_offline(argv[1], err);
	if (err[0])
		die(err);

	_writes("{\n\t");
	write_json_string("libpcap.schema.setspace.com");
	_writes(":{}");
	pcap_loop(handle, (int)2147483648, parse_packet, NULL);
	_write("\n}", 2);
	fprintf(stderr, "Packet Count: %d\n", packet_count);

	return 0;
}
