script "button 'Load File Manually'"
# DEPRECATED.  BUTTON HIDDEN.  Now we pick a directory and list all the files in there.
on mouseUp
   global oldFilename, oldFullFilename #original filename

   #<get the file>
   	local tFile
   	answer file "Please choose the file you would like to display" with type "PDF document|pdf|PDF"
   	if it is empty then exit mouseUp
   put it into oldFullFilename #for modifying the name
   #</get the file>
   
   showPDF oldFullFilename
end mouseUp
