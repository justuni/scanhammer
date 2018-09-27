script "button 'Select Folder'"
on mouseUp
   answer folder "Please select your default folder."
   if it is empty then exit mouseup
   updatePath it # can also be updated via user selecting a file manually
   loadFileList 1
end mouseUp
