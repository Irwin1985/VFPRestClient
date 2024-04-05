*====================================================================
* VFPRestClient
*====================================================================
Define Class Rest As Custom

	Hidden oXMLHTTP	, ;
		Verb		, ;
		URL			, ;
		requestBody	, ;
		ProxyType	, ;
		ProxyValue	, ;
		isWinHttp	, ;
		oHeaders	, ;
		oReplacement

	oXMLHTTP 		= .Null.
	Version 		= '1.6'
	LastUpdate 		= '2023-06-11 12:26'
	Author 			= 'Irwin Rodr�guez'
	Email 			= 'rodriguez.irwin@gmail.com'
	LastErrorText 	= ''
	Response 		= ''
	Status 			= 0
	StatusText 		= ''
	ResponseText 	= ''
	ReadyState 		= 0
	ShowErrors		= .t.

	Get 		= 'GET'
	POST 		= 'POST'
	PUT 		= 'PUT'
	PATCH 		= 'PATCH'
	Delete 		= 'DELETE'
	Copy 		= 'COPY'
	Head 		= 'HEAD'
	OPTIONS 	= 'OPTIONS'
	Link 		= 'LINK'
	UNLINK 		= 'UNLINK'
	PURGE 		= 'PURGE'
	Lock 		= 'LOCK'
	Unlock 		= 'UNLOCK'
	PROPFIND 	= 'PROPFIND'
	View 		= 'VIEW'
	SyncMode	= .F.

	#Define HTTP_STATUS_OK      200
	#Define HTTP_COMPLETED      4
	#Define HTTP_OPEN           1

	ResolveTimeOut 	= 5 	&& The value is applied to mapping hot names to IP addresses.
	ConnectTimeOut 	= 180	&& 60 the value is applied for establishing a communication socket with the target server.
	SendTimeOut 	= 30 	&& The value applies to sending an individual packet of request data on the communication socket to the target server.
	receiveTimeOut 	= 30 	&& The value applies to receiving a packet of response data from the target server.
	waitTimeOut 	= 5 	&& The value applies to analyze the readyState change when communitacion socket has established.


	Procedure Init
		With This
			.oHeaders = Createobject("Collection")
			.createReplacements()
		Endwith
	Endproc

	Function GetResponseHeader(tcHeader)
		Local lcResponse
		lcResponse = ""
		Try
			lcResponse = This.oXMLHTTP.getResponseHeader(tcHeader)
		Catch
		EndTry
		Return lcResponse
	EndFunc

	Hidden Procedure createReplacements
		This.oReplacement = Createobject("Collection")
		With This.oReplacement
			.Add("Â", "\u00a0")
			.Add("¡", "\u00a1")
			.Add("¢", "\u00a2")
			.Add("£", "\u00a3")
			.Add("¤", "\u00a4")
			.Add("¥", "\u00a5")
			.Add("¦", "\u00a6")
			.Add("§", "\u00a7")
			.Add("¨", "\u00a8")
			.Add("©", "\u00a9")
			.Add("ª", "\u00aa")
			.Add("«", "\u00ab")
			.Add("¬", "\u00ac")
			.Add("®", "\u00ae")
			.Add("¯", "\u00af")
			.Add("°", "\u00b0")
			.Add("±", "\u00b1")
			.Add("²", "\u00b2")
			.Add("³", "\u00b3")
			.Add("´", "\u00b4")
			.Add("µ", "\u00b5")
			.Add("¶", "\u00b6")
			.Add("·", "\u00b7")
			.Add("¸", "\u00b8")
			.Add("¹", "\u00b9")
			.Add("º", "\u00ba")
			.Add("»", "\u00bb")
			.Add("¼", "\u00bc")
			.Add("½", "\u00bd")
			.Add("¾", "\u00be")
			.Add("¿", "\u00bf")
			.Add("À", "\u00c0")
			.Add("Ý", "\u00c1")
			.Add("Â", "\u00c2")
			.Add("Ã", "\u00c3")
			.Add("Ä", "\u00c4")
			.Add("Å", "\u00c5")
			.Add("Æ", "\u00c6")
			.Add("Ç", "\u00c7")
			.Add("È", "\u00c8")
			.Add("É", "\u00c9")
			.Add("Ê", "\u00ca")
			.Add("Ë", "\u00cb")
			.Add("Ì", "\u00cc")
			.Add("Ý", "\u00cd")
			.Add("Î", "\u00ce")
			.Add("Ý", "\u00cf")
			.Add("Ý", "\u00d0")
			.Add("Ñ", "\u00d1")
			.Add("Ò", "\u00d2")
			.Add("Ó", "\u00d3")
			.Add("Ô", "\u00d4")
			.Add("Õ", "\u00d5")
			.Add("Ö", "\u00d6")
			.Add("×", "\u00d7")
			.Add("Ø", "\u00d8")
			.Add("Ù", "\u00d9")
			.Add("Ú", "\u00da")
			.Add("Û", "\u00db")
			.Add("Ü", "\u00dc")
			.Add("Ý", "\u00dd")
			.Add("Þ", "\u00de")
			.Add("ß", "\u00df")
			.Add("à", "\u00e0")
			.Add("á", "\u00e1")
			.Add("â", "\u00e2")
			.Add("ã", "\u00e3")
			.Add("ä", "\u00e4")
			.Add("å", "\u00e5")
			.Add("æ", "\u00e6")
			.Add("ç", "\u00e7")
			.Add("è", "\u00e8")
			.Add("é", "\u00e9")
			.Add("ê", "\u00ea")
			.Add("ë", "\u00eb")
			.Add("ì", "\u00ec")
			.Add("í", "\u00ed")
			.Add("î", "\u00ee")
			.Add("ï", "\u00ef")
			.Add("ð", "\u00f0")
			.Add("ñ", "\u00f1")
			.Add("ò", "\u00f2")
			.Add("ó", "\u00f3")
			.Add("ô", "\u00f4")
			.Add("õ", "\u00f5")
			.Add("ö", "\u00f6")
			.Add("÷", "\u00f7")
			.Add("ø", "\u00f8")
			.Add("ù", "\u00f9")
			.Add("ú", "\u00fa")
			.Add("û", "\u00fb")
			.Add("ü", "\u00fc")
			.Add("ý", "\u00fd")
			.Add("þ", "\u00fe")
			.Add("ÿ", "\u00ff")
			.Add("&", "\u0026")
			.Add("'", "\u2019")
			.Add(":", "\u003A")
			.Add("+", "\u002B")
			.Add("-", "\u002D")
			.Add("#", "\u0023")
			.Add("%", "\u0025")
		Endwith
	Endproc


	Hidden Procedure getHTTPObject
		If Type('this.oXMLHTTP') == 'O'
			Return .t.
		EndIf

		Local i, loProviders, lbCreated
		loProviders = Createobject("Collection")
		loProviders.Add("Microsoft.XMLHTTP")
		loProviders.Add("WinHttp.WinHttpRequest.5.1")
		loProviders.Add("MSXML2.ServerXMLHTTP")
		loProviders.Add("Msxml2.ServerXMLHTTP.6.0")

		For Each lcProvider In loProviders
			Try
				This.oXMLHTTP = Createobject(lcProvider)
				If "WinHttp"$lcProvider
					This.oXMLHTTP.Option(9) = 2720 && TLS SUPPORT
					This.isWinHttp = .T.
				Endif
			Catch
			Endtry
			If Type('this.oXMLHTTP') == 'O'
				lbCreated = .T.
				Exit
			Endif
		Endfor

		If !lbCreated
			If this.ShowErrors
				this.LastErrorText = 'No se pudo crear la instancia del objeto HTTP.'
				MessageBox(this.LastErrorText, 16, 'VFPRestClient')
			EndIf
			Return .f.
		Endif

		Return .T.
	Endproc


	Procedure addRequest(tcVerb, tcURL, tbSyncMode)
		With This
			If Pcount() <= 1
				If this.ShowErrors
					this.LastErrorText = 'Faltan par�metros: tanto el m�todo como la direcci�n son obligatorios.'
					MessageBox(this.LastErrorText, 16, 'VFPRestClient')
				EndIf
				Return
			Endif
			.cleanRequest()
			.Verb 		= tcVerb
			.URL  		= tcURL
			.SyncMode 	= tbSyncMode
		Endwith
	Endproc


	Procedure AddHeader(tcHeader, tcValue)
		If Pcount() != 2
			If this.ShowErrors
				this.LastErrorText = 'Faltan par�metros: tanto la clave como el contenido de header son obligatorios.'
				MessageBox(this.LastErrorText, 16, 'VFPRestClient')
			EndIf
			Return .f.
		Endif
		This.oHeaders.Add(tcValue, tcHeader)
	Endproc


	Procedure addProxy(tcHeader, tcValue)
		If Empty(tcHeader) or Type('tcHeader') != 'C'
			If this.ShowErrors
				this.LastErrorText = 'Nombre inv�lido'
				MessageBox(this.LastErrorText, 16, "VfpRestClient")
			EndIf
			Return .f.
		Endif
		This.ProxyType = tcHeader
		This.ProxyValue = tcValue
	Endproc


	Procedure addRequestBody(tcRequestBody)
		If Pcount() = 0
			If this.ShowErrors
				this.LastErrorText = 'El contenido del cuerpo es obligatorio.'
				MessageBox(this.LastErrorText, 16, "VfpRestClient")
			EndIf
			Return .f.
		EndIf

		If Type('tcRequestBody') != 'C'
			If this.ShowErrors
				this.LastErrorText = 'El contenido del cuerpo debe ser de tipo String.'
				MessageBox(this.LastErrorText, 16, "VfpRestClient")
			EndIf
			Return .f.
		EndIf
		This.requestBody = tcRequestBody
	Endproc


	Function Send
		If !This.isConnected()
			If this.ShowErrors
				this.LastErrorText = 'En este momento la se�al de internet no est� disponible, int�ntelo m�s tarde.'
				MessageBox(this.LastErrorText, 16, "VfpRestClient")
			EndIf
			Return .F.
		Endif

		If Empty(This.Verb) or Empty(This.URL)
			If this.ShowErrors
				this.LastErrorText = 'Debe ejecutar el m�todo AddRequest() antes de continuar.'
				MessageBox(this.LastErrorText, 16, "VfpRestClient")
			EndIf
			Return .f.
		Endif

		If !This.getHTTPObject()
			Return .F.
		EndIf

		With this
			try
				If .ResolveTimeOut > 0 And .ConnectTimeOut > 0 And .SendTimeOut > 0 And .receiveTimeOut > 0
					.ResolveTimeOut = .ResolveTimeOut * 1000
					.ConnectTimeOut = .ConnectTimeOut * 1000
					.SendTimeOut 	= .SendTimeOut 	  * 1000
					.receiveTimeOut = .receiveTimeOut * 1000
					.oXMLHTTP.setTimeouts(.ResolveTimeOut, .ConnectTimeOut, .SendTimeOut, .receiveTimeOut)
				EndIf
			Catch
			endtry
		endwith

		This.oXMLHTTP.Open(This.Verb, This.URL, This.SyncMode)
		If !This.isWinHttp And This.getReadyState() <> HTTP_OPEN
			If this.ShowErrors
				this.LastErrorText = 'No se pudo inicializar la solicitud [' + this.verb + '] a la direcci�n [' + this.url + ']'
				MessageBox(this.LastErrorText, 16, "VfpRestClient")
			EndIf
			Return .F.
		Endif

		* Add Headers
		Local i, lnSeg
		For i = 1 To This.oHeaders.Count
			This.oXMLHTTP.setRequestHeader(This.oHeaders.GetKey(i), This.oHeaders.Item(i))
		Endfor
		* Clean oHeaders
		This.oHeaders = Createobject("Collection")

		If !Empty(This.ProxyType) And !Empty(This.ProxyValue)
			This.oXMLHTTP.setProxy(2, This.ProxyType, "")
		Endif

		*-- Send the Request
		This.oXMLHTTP.Send(This.requestBody)

		*-- Loop until readyState change or timeouts dies.
		If Empty(This.waitTimeOut)
			This.waitTimeOut = 5
		Endif

		lnSeg = Seconds() + This.waitTimeOut
		Do While Seconds() <= lnSeg
			If This.getReadyState() <> HTTP_OPEN
				Exit
			Endif
			DoEvents
		Enddo

		With This
			.Response 	  	= .htmlEntityDecode(.oXMLHTTP.ResponseText)
			.Status 	  	= .oXMLHTTP.Status
			.StatusText   	= .oXMLHTTP.StatusText
			.ResponseText 	= .Response
			.ReadyState 	= .getReadyState()
		Endwith
	Endfunc


	Hidden Function getReadyState
		If This.isWinHttp
			Return This.oXMLHTTP.Status
		Endif
		Return This.oXMLHTTP.ReadyState
	Endfunc


	Hidden Function isConnected
		Local lbConnected
		Declare Integer InternetCheckConnection In WiniNet String lpszUrl, Integer dwFlags, Integer dwReserved
		lbConnected = (InternetCheckConnection('https://www.google.com', 1, 0) == 1)
		Clear Dlls InternetCheckConnection

		Return lbConnected
	Endfunc


	Hidden Procedure cleanRequest
		With This			
			.Response = ''
			.Verb = ''
			.URL = ''
			.ProxyType = ''
			.ProxyValue = ''
			.requestBody = ''
			.Status = 0
			.StatusText = ''
			.ResponseText = ''
			.ReadyState = 0
		Endwith
	Endproc


	Hidden Function htmlEntityDecode(tcText As Memo)
		Local i, lcKey, lcValue
		For i = 1 To This.oReplacement.Count
			lcKey = This.oReplacement.GetKey(i)
			lcValue = This.oReplacement.Item(i)
			If At(lcKey, tcText) > 0
				tcText = Strtran(tcText, lcKey, lcValue)
			Endif
		Endfor
		Return Strconv(tcText, 11)
	Endfunc
Enddefine
