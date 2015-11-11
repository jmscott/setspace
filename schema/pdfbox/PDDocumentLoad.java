/*
 *  Synopsis:
 *	Is the standard input a loadable pdf document?
 *
 *  Usage:
 *	java PDDocumentLoad
 *
 *  Exit Status:
 *	0	yes, loadable by pdfbox class PDDocument.load
 *	1	no, load failed
 *	2	wrong number of command line arguments
 */
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.util.PDFTextStripper;

import org.apache.pdfbox.pdmodel.PDDocumentCatalog;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;

public class PDDocumentLoad
{
	public static void main(String[] args) throws Exception
	{
		if (args.length != 0) {
			System.err.println(PDDocument.class.getName() +
			                   ": ERROR: wrong number arguments");
			System.exit(2);
		}

		PDDocument doc = null;
		try {
			/*
			 *  Note:
			 *	BufferedInputStream makes no difference in
			 *	speed, as tested on a few pdfs.
			 */
			doc = PDDocument.load(System.in);
			PDFTextStripper stripper = new PDFTextStripper();
			stripper.getText(doc);

		} catch (Exception e) {
			System.exit(1);
		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(0);
	}
}
