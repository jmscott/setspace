/*
 *  Synopsis:
 *	Put the PDDocument scalar data onto standard output.
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
 *	2	load of pdf failed
 *	3	invocation error
 *	4	unexpected java exception.
 *  Note:
 *	Need to frisk the string values.  See out putPDDocument* classes.
 *
 *	Consider adding an exit code to indicate when number_of_pages == 0.
 */
import org.apache.pdfbox.pdmodel.PDDocument;

public class putPDDocument
{
	public static void main(String[] args) throws Exception
	{
		if (args.length != 0) {
			System.err.println(putPDDocument.class.getName() +
				": ERROR: wrong number of arguments");
			System.exit(3);
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
				System.exit(2);
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
			System.exit(4);

		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(0);
	}
}
