using System;
using System.IO;
using System.Runtime.InteropServices;

using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;
using SolidWorks.Interop.gtswutilities;
using static Marshal2;

namespace Charon
{
    class Program
    {
		static void Main(string[] args)
		{
			ISldWorks swApp;

			try {
				var progId = "SldWorks.Application";
				swApp = Marshal2.GetActiveObject(progId)
					as SolidWorks.Interop.sldworks.ISldWorks;
			} catch (COMException e) {
				swApp = new SldWorks();
				swApp.Visible = true;
			}

			// If file paths aren't correctly specified, warn the user and exit
			if (args.Length != 2) {
				Console.Error.Write("Incorrect number of arguments");
				return;
			}

			string ext = Path.GetExtension(args[0]);
			if (ext != Path.GetExtension(args[1])) {
				Console.Error.Write("File types don't match");
				return;
			}

			int filetype_int;

			switch (ext) {
				case ".SLDPRT":
					filetype_int = 1; // swDocPART
					break;

				case ".SLDASM":
					filetype_int = 2; // swDocASSEMBLY
					break;

				default:
					filetype_int = 0; // swDocNONE
					break;
			}

			int openDocOptions = 1; // swOpenDocOptions_Silent
			int fileError = 0;
			int fileWarning = 0;

			// open the second window first to tile properly
			swApp.OpenDoc6(
				args[1],          // FileName
				filetype_int,     // Type
				openDocOptions,   // Options
				"",               // Configuration
				ref fileError,    // Errors
				ref fileWarning   // Warnings
			);
			if (fileError != 0) {
				Console.Error.Write("Encountered error opening file: "
						+ fileError.ToString());
			} else if (fileWarning != 0) {
				Console.WriteLine("Encountered warning opening file: "
						+ fileWarning.ToString());
			}
			swApp.OpenDoc6(
				args[0],          // FileName
				filetype_int,     // Type
				openDocOptions,   // Options
				"",               // Configuration
				ref fileError,    // Errors
				ref fileWarning   // Warnings
			);
			if (fileError != 0) {
				Console.Error.Write("Encountered error opening file: "
						+ fileError.ToString());
			} else if (fileWarning != 0) {
				Console.WriteLine("Encountered warning opening file: "
						+ fileWarning.ToString());
			}
			// Arrange Windows to vertical tiling
			swApp.ArrangeWindows(2);
		}
    }
}
