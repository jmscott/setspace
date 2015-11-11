import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;

/*
 * Synopsis:
 *	Extract the number of pages in the pdf document.
 * Usage:
 *	java ExtractDocument file.pdf
 * Exit Status:
 *	0	title metadata exists and written to standard out
 *	1	unknown number of pages: Pageable.UNKNOWN_NUMBER_OF_PAGES
 *	255	system error
 * Note:
 *	This program assumes the locale is UTF-8.
 *
 *	To query the default charset, see the function
 *	java.nio.charset.Charset.defaultCharset().
 */
public class ExtractNumberOfPages
{
	public static void main(String[] args) throws Exception
	{
		if (args.length != 0) {
			System.err.println("ERROR: " +
					ExtractNumberOfPages.class.getName() +
				   ": wrong number of arguments");
			System.exit(255);
		}

		PDDocument doc = null;
		try {
			/*
			 *  Note:
			 *	BufferedInputStream makes no difference in
			 *	speed, according to simple tests on a few
			 *	pdfs.
			 */
			doc = PDDocument.load(System.in);

			int nop = doc.getNumberOfPages();
			if (nop == PDDocument.UNKNOWN_NUMBER_OF_PAGES)
				System.exit(1);
			System.out.println(nop + "");
		} catch (Exception e) {
			System.err.println("ERROR: " +
					ExtractNumberOfPages.class.getName() +
				   	": " + e);
			System.exit(255);
		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(0);
	}
}
