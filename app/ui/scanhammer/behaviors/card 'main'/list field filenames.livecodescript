script "list field 'filenames'"

global oldFilename, oldFullFilename


on mouseDown
   if me is empty then exit mouseDown
   select the clickline
   forceReload
end mouseDown



on forceReload 
	put line (the hilitedLine of me) of me into oldFilename
	put field "path"&oldFilename into oldFullFilename

	loadFile oldFullFilename
end forceReload



on arrowKey what
   if what is "left" or "what" is "right" then pass arrowKey
   
   put the hilitedLine of me into currentlySelectedLine
   if what is "up" then # #up moves in negative direction, down in positive
   	subtract 1 from currentlySelectedLine 
   else #what is "down"
   	add 1 to currentlySelectedLine
   end if #what is "up"

   #<funky math>
      # "CSL" is "currentlySelectedLine"
      # calculate (from inside out) max(1,csl).  That way if CSL is <1 then we get 1.
      # Then calculate min (size of list, calculation above).  That way if we're past the end, we return the end.
      # combining the two of those gives a value that is between 1..size of list
      put min (the number of lines in me, max (1,currentlySelectedLine)) into currentlySelectedLine
      set the hilitedLine of me to currentlySelectedLine
   #</funky math>
   
   forceReload
end arrowKey
