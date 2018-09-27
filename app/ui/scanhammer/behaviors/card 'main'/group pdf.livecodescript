script "group pdf"
on displayPDF what
   XPDFViewer_Open me, the windowID of this stack
   XPDFViewer_Set me,"filename",what
   XPDFViewer_Set me, "rect", the rect of grc "pdf" of me
   xpdfviewer_set me,"visible", true
end displayPDF



on closePDF
   XPDFViewer_Close me
end closePDF



on resizeControl
   put the rect of me into r
   put the margins of me into m
   
   #<apply margins>
   if the number of items in m > 1 then
      add item 1 of m to item 1 of r
      add item 2 of m to item 2 of r
      subtract item 3 of m from item 3 of r
      subtract item 4 of m from item 4 of r
   else # only 1 item in the margins
      add m to item 1 of r
      add m to item 2 of r
      subtract m from item 3 of r
      subtract m from item 4 of r
   end if #the number of items in m>1
   #</apply margins>
   
   set the rect of grc "pdf" of me to r
   xpdfviewer_set "pdf", "rect",r
end resizeControl
