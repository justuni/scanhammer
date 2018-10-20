script "group xpdf"
on xpdf_show theFile
   /* debug
   Getting page scrolling, maybe as the thumbnails are being created, before the first page appears.  That could be a problem for large files
   */
   #lock screen #debugy
   XPDFViewer_Set "pdfViewer","visible",false
   XPDFViewer_Open "pdfViewer",the windowID of this stack
   XPDFViewer_Set "pdfViewer","rect",the rect of grc "pdfViewArea" of group "pdfViewer"
   XPDFViewer_Set "pdfViewer","filename",theFile 
   XPDFViewer_Set "pdfViewer","visible",true #debugy
   call "pdfUpdatePageDisplay" of grp "pdfViewer"
   call "pdfUpdateZoomDisplay" of grp "pdfViewer"
   call "GenerateThumbnails" of grp "pdfViewer"
   #XPDFViewer_Set "pdfViewer","visible",true #debugy
   #unlock screen #debugy
end xpdf_show



on rawKeyDown pKeyNum
   if pKeyNum is 65365 then #pageUp
      put "page up"#debugx
      docPDF_PrevPage
   else if pKeyNum is 65366 then #pageDown
      put "page down"#debugx
      docPDF_NextPage
   else if pKeyNum is 65309 then # mouse scroll wheel
      if the controlKey is down then # zoom
         put "scroll wheel...down?"#debugx
         docPDF_ZoomIn
      else #ctrl key not down
         put XPDFViewer_Get("pdfViewer","SCROLL") into tScroll -- h,v
         put MAX((item 2 of tScroll - 30),0) into item 2 of tScroll -- mouse wheel vScroll
         XPDFViewer_Set "pdfViewer","SCROLL",tScroll
      end if #the controlKey is down
   else if pKeyNum is 65308 then
      put "scroll wheel...up?"#debugx
      if the controlKey is down then -- zoom
         docPdf_ZoomOut
      else #ctrl key is not down
         put XPDFViewer_Get("pdfViewer","HEIGHT") into tHeight
         put XPDFViewer_Get("pdfViewer","hScrollbar") into tScrollbar -- true/false
         put (tHeight - (the height of grc "xpdf")) into tMaxScroll
         if tScrollbar then add 16 to tMaxScroll
         if tMaxScroll < 0 then put 0 into tMaxScroll -- if the zoom is such that the page is smaller than the viewport
         put XPDFViewer_Get("pdfViewer","SCROLL") into tScroll -- h,v
         put MIN((item 2 of tScroll + 30),tMaxScroll) into item 2 of tScroll -- mouse wheel vScroll
         XPDFViewer_Set "pdfViewer","SCROLL",tScroll
      end if #the controlKey is down
   else if pKeyNum is 65311 then
      put "uhhhh, some special key - scroll wheel left maybe?"#debugx
      put XPDFViewer_Get("pdfViewer", "SCROLL") into tScroll -- h,v
      put MAX((item 1 of tScroll - 30),0) into item 1 of tScroll -- mouse wheel hScroll
      XPDFViewer_Set "pdfViewer","SCROLL",tScroll
   else if pKeyNum is 65310 then
      put "uhhhh, some special key - scroll wheel right maybe?"#debugx
      put XPDFViewer_Get("pdfViewer","WIDTH") into tWidth
      put XPDFViewer_Get("pdfViewer","vScrollbar") into tScrollbar -- true/false
      put (tWidth - (the width of grc "xpdf")) into tMaxScroll
      if tScrollbar then add 16 to tMaxScroll
      if tMaxScroll < 0 then put 0 into tMaxScroll -- if the zoom is such that the page is smaller than the viewport
      put XPDFViewer_Get("pdfViewer","SCROLL") into tScroll -- h,v
      put MIN((item 1 of tScroll + 30),tMaxScroll) into item 1 of tScroll -- mouse wheel hScroll
      XPDFViewer_Set "pdfViewer","SCROLL",tScroll
   else #none of thee above
      pass rawKeyDown
   end if #pKeyNum is...
end rawKeyDown



on docPDF_PrevPage
   set the pdfPage of grp "pdfViewer" to "prev"
end docPDF_PrevPage



on docPDF_NextPage
   set the pdfPage of grp "pdfViewer" to "next"
end docPDF_NextPage



on docPDF_ZoomIn
   set the pdfZoom of control "pdfViewer" to "In"
end docPDF_ZoomIn



on docPDF_ZoomOut
   set the pdfZoom of control "pdfViewer" to "Out"
end docPDF_ZoomOut
