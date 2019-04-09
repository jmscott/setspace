/*
 *  Synopsis:
 *	Extract utf8 individual pages into files from a pdf read on stdin.
 *  Usage:
 *	java -cp $CLASSPATH ExtractPagesUTF8 <hamlet.pdf
 *	cat 0*.txt | shasum
 *  Exit Status:
 *	0	utf8 text extracted to files 0000001.txt to [0-9]{7}.txt
 *	1	extraction failed, some [0-9]{9}.txt may exist.
 *	2	permission denied to extract the text
 *	3	wrong number of arguments
 * Note:
 *	Maximum number of pages in a pdf file is assumed to be 2,603,538.
 *	See this discussion for details on maximum number of pages in a pdf.
 *
 *		http://tex.stackexchange.com/questions/97071
 *
 *	Embedded pdfs are not extracted.  Eventually code from ExtractText.java
 *	will be added to ExtractPagesUTF8.java.
 */
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;

import org.apache.pdfbox.io.IOUtils;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.encryption.AccessPermission;
import org.apache.pdfbox.text.PDFTextStripper;

public final class ExtractPagesUTF8
{
	public static void main(String[] args) throws IOException
	{
		if (args.length != 0) {
			System.err.println("ERROR: ExtractPagesUTF8: " +
				           "wrong number of arguments");
			System.exit(3);
		}

    		PDDocument doc = null;
                doc = PDDocument.load(System.in, "");
 
                if (!doc.getCurrentAccessPermission().canExtractContent())
			System.exit(2);

                PDFTextStripper stripper;
	        stripper = new PDFTextStripper();

		int npages, p;
		npages = doc.getNumberOfPages();

		for (p = 1;  p <= npages;  p++) { 
			
			Writer out = new OutputStreamWriter(
					new FileOutputStream(
						String.format("%07d.txt", p)),
						"UTF-8"
			);

			stripper.setStartPage(p);
			stripper.setEndPage(p);

			stripper.writeText(doc, out);

			IOUtils.closeQuietly(out);
		}
		IOUtils.closeQuietly(doc);
		System.exit(0);
	}
}
