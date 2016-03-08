/*
 *  Synopsis:
 *	Example code to extract keywords from pdf.
 *  Depends:
 *	xmpbox jar from pdfbox
 *  Note:
 *	Keywords are not supported in pdfbox2 schema (yet) because so few pdf
 *	appear to support them, at least in a random sample of 140k documents.
 */

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentCatalog;
import org.apache.pdfbox.pdmodel.common.PDMetadata;

import java.io.File;
import java.io.IOException;

import org.apache.xmpbox.XMPMetadata;
import org.apache.xmpbox.schema.AdobePDFSchema;
import org.apache.xmpbox.schema.XMPBasicSchema;
import org.apache.xmpbox.xml.DomXmpParser;
import org.apache.xmpbox.xml.XmpParsingException;

public final class ExtractKeywords
{
	public static void main(String[] args) throws
		IOException, XmpParsingException
	{
		PDDocument doc = PDDocument.load(System.in);
		PDDocumentCatalog catalog = doc.getDocumentCatalog();
		PDMetadata meta = catalog.getMetadata();
		DomXmpParser xmpParser = new DomXmpParser();
		XMPMetadata metadata=xmpParser.parse(meta.createInputStream());
		AdobePDFSchema pdf = metadata.getAdobePDFSchema();

		if (pdf == null)
			System.exit(1);
		if (pdf.getKeywords() != null)
			System.out.println(pdf.getKeywords() + "\n");
		doc.close();
		System.exit(0);
	}
}
