/*
 *  Synopsis:
 *	Put the PDDocumentInformation scalar data onto standard output.
 *  Description:
 *	putPDDocumentInformation extracts the scalar values from the 
 *	java object org.apache.pdfbox.pdmodel.PDDocumentInformation.
 *	The scalar values are written in a mimeish format like:
 *
 *		Author: <author>
 *		Subject: <subject>
 *		Keywords: <keywords>
 *		Creator: <creator>
 *		Producer: <producer>
 *		Creation Date: <creation date>
 *		Modification Date: <modification date>
 *		Trapped: <trapped>
 *
 *	The absence of a field implies a null value.
 *
 *	Dates are parsed for correctness using SimpleDateFormat.
 *	Unparsable dates are null and the exit status is set to 1.
 *	Unfortunately unparsable dates seems to be common  - ~10% in academic
 *	sample of 140k pdfs.
 *  Usage:
 *	java putPDDocumentInformation <file.pdf
 *  Depends:
 *	pdfbox-app.jar, version 2
 *  Exit Status:
 *	0	wrote all metadata to stdout
 *	2	loaded ok but violation of database constraints
 *	3	load of pdf failed
 *	4	invocation error
 *	5	unexpected java exception.
 *  Note:
 *	Consider framing the mime headers with Begin/End:
 *
 *		Begin:
 *		...
 *		End:
 */
import java.util.Calendar;
import java.util.TimeZone;
import java.text.SimpleDateFormat;
import java.util.logging.Logger;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;

public class putPDDocumentInformation
{
	static int violates_constraint = 0;

	/*
	 *  The constraints are inherited from the database schema
	 *  for the table pdfbox.pddocument_information.
	 */
	private static String frisk(String s)
	{
		if (s == null)
			return null;
		if (s.indexOf("\n") > -1			||
		    s.length() >= 32768				||
		    s.indexOf("\0") > -1
		) {
			violates_constraint = 1;
			return null;
		}
		return s;
	}

	private static void put(String what, String val)
	{
		val = frisk(val);
		if (val != null)
			System.out.printf("%s: %s\n", what, val);
	}

	private static void put(String what, Calendar cal)
	{
		if (cal == null)
			return;

		String timezone = "";

		TimeZone tz = cal.getTimeZone();
		if (tz != null) {
			if (timezone == null || timezone == "unknown")
				timezone = " UTC";
			else
				timezone = " " + timezone;
		}

		//  assemble reasonable YYYY/MM/DD hh:mm:ss z

		String d = String.format(
			"%4d/%02d/%02d %02d:%02d:%02d%s",
			cal.get(Calendar.YEAR),
			cal.get(Calendar.MONTH),
			cal.get(Calendar.DAY_OF_MONTH),
			cal.get(Calendar.HOUR_OF_DAY),
			cal.get(Calendar.MINUTE),
			cal.get(Calendar.SECOND),
			timezone
		);
		if (frisk(d) == null )
			return;

		//  validate the date by reparsing the string
		//  with a new non-linient DateParse Object.

		SimpleDateFormat df = new SimpleDateFormat(
						"yyyy/MM/dd HH:mm:ss z");
		df.setLenient(false);
		try
		{
			df.parse(d);

		} catch (java.text.ParseException e) {
			violates_constraint = 2;
			return;
		}

		System.out.printf("%s Date: %s\n", what, d);
	}

	public static void main(String[] args) throws Exception
	{
		if (args.length != 0) {
			System.err.println("ERROR: " +
				putPDDocumentInformation.class.getName() +
				   ": wrong number of arguments");
			System.exit(4);
		}

		PDDocument doc = null;
		PDDocumentInformation info;

		try {
			java.util.logging.Logger.getLogger("org.apache.pdfbox").
				setLevel(java.util.logging.Level.SEVERE);
			/*
			 *  Note:
			 *	BufferedInputStream makes no difference in
			 *	speed, according to simple tests on a few
			 *	pdfs.
			 */
			try {
				doc = PDDocument.load(System.in);
			} catch (Exception el) {
				System.err.println("ERROR: load: " +
				      putPDDocumentInformation.class.getName() +
								": " + el);
				System.exit(3);
			}
			info = doc.getDocumentInformation();

			put("Title", info.getTitle());
			put("Author", info.getAuthor());
			put("Subject", info.getSubject());
			put("Keywords", info.getKeywords());
			put("Creator", info.getCreator());
			put("Producer", info.getProducer());

			put("Creation", info.getCreationDate());
			put("Modification", info.getModificationDate());

			put("Trapped", info.getTrapped());

		} catch (Exception e) {
			System.err.println("ERROR: get: " +
				putPDDocumentInformation.class.getName() +
				   	": " + e);
			System.exit(5);

		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(violates_constraint);
	}
}
