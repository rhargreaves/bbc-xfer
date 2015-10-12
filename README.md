# bbc-xfer
Transfer files between a BBC Micro and PC. A popular, easy-to-use command-line utility written by Mark de Weger, ported to C by Angus Duggan and extended by Jon Welch.

This version includes some enhancements added to accomodate personal requirements:

* Continue on ADFS and DFS disk transfer errors (disk read, CRC, timeout etc).
* Force ADFS single-sided transfer even if disc is detected as double-sided (command 'E'). This is useful if the disk is accidently formatted as DFS on what would be drive 2. You should then use the Adf2Adl tool included to convert the ADF file produced into an interleaved ADL file.
