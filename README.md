Horse-racing stats
==================

This project scrapes horse-racing stats from a few different websites. It imports these stats into a SQLite database. I've removed the references to those websites to prevent abuse. You would need to provide them as command-line arguments, or edit the scripts.

The scripts in the bin directory can be used to download stat files and convert them to a format understood by the Python code. I've removed the references to any websites to prevent abuse. You would need to provide the base URLs as command-line arguments, or edit the scripts.

The Python code parses the HTML or text files to import stats into a database. Each of the Python scripts requires 3 parameters:

0. folder containg HTML or text files
0. location ID
0. path to SQLite database

