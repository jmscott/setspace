/*
 *  Synopsis:
 *	Put the PDDocumentInformation scalar data onto standard output.
 *  Description:
 *	putPDDocumentInformation extracts PDDocument metadata from a pdf
 *	document read on standard input and then writes that metadata as a
 *	new-line separated list of mime-header fields.
 *
 *		Author: <author>
 *		Subject: <subecj>
 *		Keywords: <keywords>
 *		Creator: <creator>
 *		Producer: <producer>
 *		Creation Date: <creation date>
 *		Modification Date: <modification date>
 *		Trapped: <trapped>
 *
 *  Usage:
 *	java putPDDocument <file.pdf
 *  Exit Status:
 *	0	extracted the scalar data and wrote to stdout
 *	1	load of pdf failed
 *	2	wrong number of command line arguments
 *	3	field contained new-line character
 *	4	field >= 4096 characters (not bytes)
 *	5	unexpected java exception.
 */
import java.util.Calendar;
import java.util.TimeZone;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;

public class putPDDocumentInformation
{
	private static String frisk(String s)
	{
		if (s == null)
			return null;
		if (s.indexOf("\n") > -1)
			System.exit(3);
		if (s.length() >= 4096)
			System.exit(4);
		return s;
	}

	private static void put(Calendar cal, String what)
	{
		if (cal == null)
			return;

		String timezone = "";

		TimeZone tz = cal.getTimeZone();
		if (tz != null) {

			timezone = tz.getID();
			if (timezone == "unknown")
				timezone = " UTC";
			else
				timezone = " " + timezone;
		}

		System.out.printf(
			"%s Date: %4d/%02d/%02d %02d:%02d:%02d%s\n",
			what,
			cal.get(Calendar.YEAR),
			cal.get(Calendar.MONTH),
			cal.get(Calendar.DAY_OF_MONTH),
			cal.get(Calendar.HOUR_OF_DAY),
			cal.get(Calendar.MINUTE),
			cal.get(Calendar.SECOND),
			timezone
		);
	}

	public static void main(String[] args) throws Exception
	{
		if (args.length != 0) {
			System.err.println("ERROR: " +
				putPDDocumentInformation.class.getName() +
				   ": wrong number of arguments");
			System.exit(2);
		}

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
			} catch (Exception el) {
				System.err.println("ERROR: " +
				      putPDDocumentInformation.class.getName() +
								": " + el);
				System.exit(1);
			}
			info = doc.getDocumentInformation();

			//  Author: ...

			String s = frisk(info.getTitle());
			if (s != null)
				System.out.println("Title: " + s);

			//  Title: ...

			s = frisk(info.getAuthor());
			if (s != null)
				System.out.println("Author: " + s);

			//  Subject: ...

			s = frisk(info.getSubject());
			if (s != null)
				System.out.println("Subject: " + s);

			//  Keywords: ...

			s = frisk(info.getKeywords());
			if (s != null)
				System.out.println("Keywords: " + s);

			//  Creator: ...

			s = frisk(info.getCreator());
			if (s != null)
				System.out.println("Creator: " + s);

			//  Producer: ...

			s = frisk(info.getProducer());
			if (s != null)
				System.out.println("Producer: " + s);

			//  Creation Date: ...

			put(info.getCreationDate(), "Creation");

			//  Modification Date: ...

			put(info.getModificationDate(), "Modification");

			//  Trapped: ...

			s = frisk(info.getTrapped());
			if (s != null)
				System.out.println("Trapped: " + s);

		} catch (Exception e) {
			System.err.println("ERROR: " +
				putPDDocumentInformation.class.getName() +
				   	": " + e);
			System.exit(5);

		} finally {
			if (doc != null)
				doc.close();
		}
		System.exit(0);
	}
}
