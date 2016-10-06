The transmute ahk program will use certain parts of control options from GUI Creators XML templates.

g labels are the default selection for dropdownlist and checkbox
v names are used as the key names in the gui controls map
the text is the default value for most controls (default options for drop down list)
All DDLs are given the altsubmit option by default

Design your gui how you want with all options you want.
Run transmute_gui.ahk
copy the resulting file to your ahk working directory and include it in your ahk script. now you can instantiate a new class (see inside file for name) and use it in a more OO way
