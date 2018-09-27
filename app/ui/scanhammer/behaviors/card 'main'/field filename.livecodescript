script "field 'filename'"
on returninfield
   send "mouseUp" to button "rename"
end returninfield



on arrowKey what
   if what is "up" or what is "down" then pass arrowKey #to card, which will send it to the 'filenames' field
end arrowKey
