/*
 *  Synopsis:
 *	Put the PDDocumentInformation metadata data onto standard output.
 *  Description:
 *	putPDDocumentInformation extracts the custom metadata values from the 
 *	java object org.apache.pdfbox.pdmodel.PDDocumentInformation.
 *	The custom values are written in a mimeish format like:
 *
 *		<key1>: <value1>
 *		<key2>: <value2>
 *		<key3>: <value3>
 *  Usage:
 *	java putPDDocumentInformationMetadata <file.pdf
 *  Depends:
 *	pdfbox-app.jar, version 2
 *  Exit Status:
 *	0	extracted all custom metadata data and wrote to stdout
 *	2	wrote all but at least one violating metadata to standard out
 *	3	could not load pdf from standard input
 *	4	program invocation or setup error
 *	5	unexpected java exception getting custom result set
 */
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;

public class putPDDocumentInformationMetadata
{
	private static int violated_constraint = 0;

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
		    key.indexOf("\n") > -1			||
		    key.indexOf("\r") > -1			||
		    key.indexOf("\0") > -1			||
		    value.length() >= 32768			||
		    value.indexOf("\n") > -1			||
		    value.indexOf("\r") > -1			||
		    value.indexOf("\0") > -1
		) {
			violated_constraint = 1;
			return;
		}
		System.out.printf("%s: %s\n", key, value);
	}

	public static void main(String[] args) throws Exception
	{
		if (args.length != 0)
			die("wrong number of arguments", 4);

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
				die("load", ex, 3);
			}
			info = doc.getDocumentInformation();

			for (String key : info.getMetadataKeys())
				put(key, info.getCustomMetadataValue(key));

		} catch (Exception ex) {
			die("get", ex, 5);
		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(violated_constraint);
	}
}
