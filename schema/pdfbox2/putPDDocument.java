/*
 *  Synopsis:
 *	Put a record of the pdfmodel.PDDocument scalar data of PDF from stdin.
 *  Description:
 *	putPDDocument extracts PDDocument metadata from a pdf document read on
 *	standard input and then writes that metadata as a tab-separated,
 *	new-terminated line.  The fields are as follows:
 *
 *		number_of_pages		
 *		document_id
 *		version
 *		is_all_security_to_be_removed
 *		is_encrypted
 *
 *	See docs on pdfbox.apache.org for the object PDDocument.
 *  Usage:
 *	java putPDDocument <file.pdf
 *  Exit Status:
 *	0	extracted the scalar data and wrote to stdout
 *	1	load of pdf failed
 *	2	wrong number of command line arguments
 *	3	unexpected java exception.
 */
import org.apache.pdfbox.pdmodel.PDDocument;

public class putPDDocument
{
	public static void main(String[] args) throws Exception
	{
		if (args.length != 0) {
			System.err.println("ERROR: " +
						putPDDocument.class.getName() +
				   ": wrong number of arguments");
			System.exit(2);
		}

		PDDocument doc = null;
		try {
			/*
			 *  Note:
			 *	BufferedInputStream makes no difference in
			 *	speed, according to simple tests on a few
			 *	pdfs.
			 */
			try {
				doc = PDDocument.load(System.in);
			} catch (Exception el) {
				System.err.println("ERROR: " +
					putPDDocument.class.getName() +
								": " + el);
				System.exit(1);
			}

			Long did = doc.getDocumentId();
			String document_id;
			if (did == null)
				document_id = "null";
			else
				document_id = did.toString();
			/*
			 *  Note:
			 *	How to determine if number of pages is unknown?
			 *	In pdfbox1 the value nop was compared to
			 *	PDDocument.UNKNOWN_NUMBER_OF_PAGES, which does
			 *	not exist in version 2.  The version2 docs make
			 *	no reference to an exception.
			 */
			System.out.println(
				doc.getNumberOfPages()			+"\t"+
				document_id				+"\t"+
				doc.getVersion()			+"\t"+
				doc.isAllSecurityToBeRemoved()		+"\t"+
				doc.isEncrypted()
			);
		} catch (Exception e) {
			System.err.println("ERROR: " +
					putPDDocument.class.getName() +
				   	": " + e);
			System.exit(3);

		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(0);
	}
}
