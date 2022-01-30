/*
 *  Synopsis:
 *	Transform output of pcal_loop() function to json.
 *  Usage:
 *	loop2json <file-path> >loop.json
 *  Note:
 *	Code is NOT ready for UTF8.
 *
 *	Be sure to add link layer:
 *
 *		PKTAP (Apple DLT_PKTAP)
 *
 *	The -i any generates that link layer.
 *
 *	Does pcap_open_offline() accept stdin, instead of file path?
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

static long long pkt_count = 0;
static long long ETHERTYPE_IP_count = 0;
static long long unknown_pkt_type = 0;
static long long IPPROTO_TCP_count = 0;

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
_writec(char c)
{
	if (jmscott_write(1, &c, 1) != 0)
		die2("write(stdout) failed", strerror(errno));
}

static void
write_string(char *src)
{
	_write(src, strlen(src));
}

static void
write_ll(long long ll)
{
	char buf[22];

	snprintf(buf, sizeof buf, "%lld", ll);
	_write(buf, strlen(buf));
}

static void
indent(int level)
{
	for (int i = 0;  i < level;  i++)
		_writec('\t');
}

//  write an json escaped ascii string
static void
write_json_string(char *src)
{
	char json[MAX_TCP_PACKET * 4], *err;

	indent(1);
	if ((err = jmscott_ascii2json_string(src, json, sizeof json)))
		die2("jmscott_ascii2json_string() failed", err);
	_write(json, strlen(json));
}

/*
 *  Write
 *
 *	"key":"value",\n
 */
static void
write_kv(char *key, char *value)
{
	write_json_string(key);
	_write(":", 1);
	write_json_string(value);
	_write(",\n", 2);
}

static void
write_kllx(char *key, long long value)
{
	write_json_string(key);
	_write(":", 1);
	write_ll(value);
	_write("\n", 1);
}

static void
write_kll(char *key, long long value)
{
	write_json_string(key);
	_write(":", 1);
	write_ll(value);
	_write(",\n", 2);
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
	(void)args;

	pkt_count++;

	//  do we have an ethernet packet?
	struct ether_header *eth_header;
	eth_header = (struct ether_header *)packet;
	if (ntohs(eth_header->ether_type) != ETHERTYPE_IP) {
		unknown_pkt_type++;
        	return;
	}
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

static void
newline()
{
	_writec('\n');
}

static void
comma()
{
	_writec(',');
}

static void
write_json_array(char *key, char **array, int size, int level)
{
	//  no size, so null teminated array
	if (size < 0) {
		int sz = 0;

		char **a = array;
		while (*a++)
			sz++;
		size = sz;
	}

	indent(level);
	write_json_string(key);
	_write(":[\n", 3);
	for (int i = 0;  i < size;  i++) {
		indent(level + 1);
		write_json_string(array[i]);
		if (i + 1 < size)
			comma();
		newline();
	}
	indent(level + 1);
	_write("],\n", 3);
}

static void
stat_ll(char *key, long long value)
{
	indent(1);
	write_kll(key, value);
}

static void
stat_llx(char *key, long long value)
{
	indent(1);
	write_kllx(key, value);
}

int main(int argc, char **argv, char **env)
{    
	char perr[PCAP_ERRBUF_SIZE], *err;
	pcap_t *handle;
	char now[36];		//  RFC3339Nano

	if (argc != 2)
		die("wrong number of arguments");
	if ((err = jmscott_RFC3339Nano_now(now, sizeof now)))
		die2("RFC3339Nano() failed", err);

	/*
	 *  Open pcap blob as a file.
	 *
	 *  Note:
	 *	Does pcap_open_offline() accept stdin?
	 */
	perr[0] = 0;
	handle = pcap_open_offline(argv[1], perr);
	if (perr[0])
		die2(err, argv[1]);

	_write("{\n", 2);
	write_kv("now", now);
	write_json_array("argv", argv, argc, 0);
	write_json_array("environment", env, -1, 0);
	write_json_string("libpcap.schema.setspace.com");
	write_string(":{\n");
		pcap_loop(handle, (int)2147483648, pkt2json, NULL);

		stat_ll("pkt_count", pkt_count);

		stat_ll("ETHERTYPE_IP_count", ETHERTYPE_IP_count);
		stat_llx("IPPROTO_TCP_count", IPPROTO_TCP_count);
	indent(1);
	write_string("}\n");

	write_string("}\n");

	return 0;
}
