script "button 'Load File List'"
on mouseUp
	global folderPath
   put "/Users/me/Desktop/x./" into folderPath #xxx
   put files(folderPath) into filenames
   sort lines of filenames
   put 1 into i
   repeat while i<=the number of lines in filenames
      if char -4 to -1 of line i of filenames is not ".pdf" then delete line i of filenames else add 1 to i
   end repeat #while i<=the number of lines in filenames
   put filenames into field "filenames"
end mouseUp
