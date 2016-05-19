/*
 *  Synopsis:
 *	Put the PDDocumentInformation metadata data onto standard output.
 *  Description:
 *	putPDDocumentInformation extracts the custom metadata values from the 
 *	java object org.apache.pdfbox.pdmodel.PDDocumentInformation.
 *	The custom values are written in a mimeish format like:
 *
 *		Begin:
 *
 *		Key 1:+ <byte count>
 *
 *		<bytes>
 *
 *		Key 2: <value>
 *		End:
 *
 *	The length of the key value and <byte count> are unsigned ints
 *	0 < and <= 2^31 - 1.
 *  Usage:
 *	java putPDDocumentInformationMetadata <file.pdf
 *  Depends:
 *	pdfbox-app.jar, version 2
 *  Exit Status:
 *	0	extracted all custom metadata data and wrote to stdout
 *	1	wrote all but at least on violating metadata to standard out
 *	2	exception loadIng pdf from standard input
 *	3	wrong number of command line arguments
 *	4	unexpected java exception getting custom result set
 */
import java.util.Calendar;
import java.util.TimeZone;
import java.text.SimpleDateFormat;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;

public class putPDDocumentInformationMetadata
{
	private static int failed_constraint = 0;

	private static void die(String msg, int exit_status)
	{
		System.err.println("ERROR: " +
			putPDDocumentInformationMetadata.class.getName() +
				   ": " + msg);
		System.exit(exit_status);
	}

	private static void die(String msg, Exception e, int exit_status)
	{
		die(msg + ": " + e, exit_status);
	}

	private static void put(String key, String value)
	{
		if (value == null)
			return;

		//  insure key and value are reasonable
		//  will add back new line in value

		if (key.length() >= 256				||
		    key.indexOf(": ") > -1      		||
		    key.indexOf(":+ ") > -1			||
		    key.indexOf("\n") > -1			||
		    value.length() >= 32768			||
		    value.indexOf("\n") > -1
		) {
			failed_constraint = 1;
			return;
		}
		System.out.printf("%s: %s\n", key, value);
	}

	public static void main(String[] args) throws Exception
	{
		if (args.length != 0)
			die("wrong number of arguments", 2);

		PDDocument doc = null;
		PDDocumentInformation info;

		try {
			/*
			 *  Note:
			 *	BufferedInputStream makes no difference in
			 *	speed, according to simple tests on a few
			 *	pdfs.
			 */
			try {
				doc = PDDocument.load(System.in);
			} catch (Exception ex) {
				die("load", ex, 2);
			}
			info = doc.getDocumentInformation();

			for (String key : info.getMetadataKeys())
				put(key, info.getCustomMetadataValue(key));

		} catch (Exception ex) {
			die("get", ex, 4);
		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(failed_constraint);
	}
}
