# bbc-xfer
Transfer files between a BBC Micro and PC. A popular, easy-to-use command-line utility written by Mark de Weger, ported to C by Angus Duggan and extended by Jon Welch.

This version includes some enhancements added to accomodate personal requirements:

* Continue on ADFS disk transfer errors (disk read, CRC, timeout etc). This is a WIP. In future this will be switchable and I will also do the same for DFS.
* Force ADFS single-sided transfer even if disc is detected as double-sided (command 'E'). This is useful if the disk is accidently formatted as DFS on what would be drive 2.
