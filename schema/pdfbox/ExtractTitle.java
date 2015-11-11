import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentCatalog;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;

/*
 * Synopsis:
 *	Extract the UTF-8 metadata 'Title' from a pdf document read on stdin.
 * Usage:
 *	java ExtractTitle <blob.pdf
 * Exit Status:
 *	0	title metadata exists and written to standard out
 *	1	title does not exist, nothing written to standard out
 *	255	system error
 */
public class ExtractTitle
{
	public static void main(String[] args) throws Exception
	{
		if (args.length != 0) {
			System.err.println(ExtractTitle.class.getName() +
			                   ": ERROR: wrong number arguments");
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

			PDDocumentInformation info =
						doc.getDocumentInformation();
			String title = info.getTitle();
			if (title == null)
				System.exit(1);
			System.out.println(title);
		} catch (Exception e) {
			System.err.println(ExtractTitle.class.getName() +
			                   ": ERROR: " + e);
			System.exit(255);
		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(0);
	}
}
