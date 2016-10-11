# P Easy Gui for AutoHotkey
###### **Alpha**
![P*** Easy Gui Tools](http://oi65.tinypic.com/rcnj3q.jpg)
___
### **Short Description**
###### An extensible, customizable, hookable multi gui class library for AutoHotKey v1.1.2+
#
#
### **GUI Examples**: 
- Example #1
  - Very simple demonstration of how to use and interact with the GUI classes.
- Example #2
  - N/A - TBC
#
#
#
>See "Arma 3 Macro Tools for GTA" repo [here](https://github.com/uniflare/Arma-3-Macro-Tools-for-GTA "A3MT for GTA") to see all of the gui features used in a practical macro tool.
#
### **Instructions**
To use this class library with your project, you can start with the first example as a basis. 
Alternatively you can start by scratch described below;
```
This library requires AutoHotKey version 1.1.24 or later.

This library consists of 3 main components. 2 of which are the actual GUI classes (The main GUI class you extend from, and the GUI controls classes). The 3rd component consists of 2 tools that comprise the easy generation/design of your custom gui window. These are the very old 0.001.26 version of GUI Creator ahk script by @maestrith (GitHub: https://github.com/maestrith/GUI_Creator - thanks my friend!), and a custom tool designed to convert the saved XML files from the GUI Creator into class extensions for PEasy GUI you can literally drag and drop to your project.

A Quick rundown of the GUI Creation procedure:
   1. Navigate and open the file at 'source/PEASY_GUI/tools/3rdparty/GuiCreator.ahk'
   2. Create the GUI how you like, but make sure to conform to the special note below. *
   3. Save the gui (no need to export).
   4. Navigate to and execute 'source/PEASY_GUI/tools/TransmuteGui.ahk'
   5. Open the xml file you saved with GUI Creator and save the output in your project folder.
   6. Done, you can use this method to iterate your GUI design without altering your project!
   
* Note: The GUI Creator tool is only used to define the gui title/dimensions and controls position/size/default value -and- each controls unique variable name. The unique variable name MUST be applied to every control in the GUI (must be unique, must not be blank). Take note that each control type may have slightly different ways to pass the variable name using the GUI Creator script.
For most simple controls such as buttons or labels/text, the "Name of Control" option is the default value assigned to the control, and the "Variable to associate with this control" is self-explanatory. For some controls such as Checkboxes and Dropdownlists, the "Name of control" is the default text or choices shown, where as the default selected value is put into "Target label to trigger". An example of this can be seen in the simple example 'Example #1' in the 'source/Examples' folder

To integrate your custom GUI with your project check Example #1 for the most basic integration, this method will allow you to easily change your GUI layout or add controls without changing your project at all - just overwrite the previous .peasygui transmuted file with the new one.
```