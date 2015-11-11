public class ValidateISO19005
{
	ValidationResult result = null;
	FileDataSource fd = new FileDataSource(args[0]);
	PreflightParser parser = new PreflightParser(fd);
	try {

		parser.parse();

		/* Once the syntax validation is done, 
		 * the parser can provide a PreflightDocument 
		 * (that inherits from PDDocument) 
		 * This document process the end of PDF/A validation.
		 */
		PreflightDocument document = parser.getPreflightDocument();
		document.validate();

		// Get validation result
		result = document.getResult();
		document.close();

	} catch (SyntaxValidationException e) {
		result = e.getResult();
	}

	// display validation result
	if (result.isValid()) {
		System.out.println("The file " + args[0] +
					" is a valid PDF/A-1b file");
	} else {
		System.out.println("The file" + args[0] +
					" is not valid, error(s) :");
		for (ValidationError error : result.getErrorsList()) {
			System.out.println(error.getErrorCode() + " : " +
					error.getDetails());
		}
	}
}
