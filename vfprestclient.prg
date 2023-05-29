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
	Version 		= '1.5 (beta)'
	LastUpdate 		= '2023-05-25 10:27'
	Author 			= 'Irwin Rodríguez'
	Email 			= 'rodriguez.irwin@gmail.com'
	LastErrorText 	= ''
	Response 		= ''
	Status 			= 0
	StatusText 		= ''
	ResponseText 	= ''
	ReadyState 		= 0

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


	Hidden Procedure createReplacements
		This.oReplacement = Createobject("Collection")
		With This.oReplacement
			.Add("Ã‚", "\u00a0")
			.Add("Â¡", "\u00a1")
			.Add("Â¢", "\u00a2")
			.Add("Â£", "\u00a3")
			.Add("Â¤", "\u00a4")
			.Add("Â¥", "\u00a5")
			.Add("Â¦", "\u00a6")
			.Add("Â§", "\u00a7")
			.Add("Â¨", "\u00a8")
			.Add("Â©", "\u00a9")
			.Add("Âª", "\u00aa")
			.Add("Â«", "\u00ab")
			.Add("Â¬", "\u00ac")
			.Add("Â®", "\u00ae")
			.Add("Â¯", "\u00af")
			.Add("Â°", "\u00b0")
			.Add("Â±", "\u00b1")
			.Add("Â²", "\u00b2")
			.Add("Â³", "\u00b3")
			.Add("Â´", "\u00b4")
			.Add("Âµ", "\u00b5")
			.Add("Â¶", "\u00b6")
			.Add("Â·", "\u00b7")
			.Add("Â¸", "\u00b8")
			.Add("Â¹", "\u00b9")
			.Add("Âº", "\u00ba")
			.Add("Â»", "\u00bb")
			.Add("Â¼", "\u00bc")
			.Add("Â½", "\u00bd")
			.Add("Â¾", "\u00be")
			.Add("Â¿", "\u00bf")
			.Add("Ã€", "\u00c0")
			.Add("Ã", "\u00c1")
			.Add("Ã‚", "\u00c2")
			.Add("Ãƒ", "\u00c3")
			.Add("Ã„", "\u00c4")
			.Add("Ã…", "\u00c5")
			.Add("Ã†", "\u00c6")
			.Add("Ã‡", "\u00c7")
			.Add("Ãˆ", "\u00c8")
			.Add("Ã‰", "\u00c9")
			.Add("ÃŠ", "\u00ca")
			.Add("Ã‹", "\u00cb")
			.Add("ÃŒ", "\u00cc")
			.Add("Ã", "\u00cd")
			.Add("ÃŽ", "\u00ce")
			.Add("Ã", "\u00cf")
			.Add("Ã", "\u00d0")
			.Add("Ã‘", "\u00d1")
			.Add("Ã’", "\u00d2")
			.Add("Ã“", "\u00d3")
			.Add("Ã”", "\u00d4")
			.Add("Ã•", "\u00d5")
			.Add("Ã–", "\u00d6")
			.Add("Ã—", "\u00d7")
			.Add("Ã˜", "\u00d8")
			.Add("Ã™", "\u00d9")
			.Add("Ãš", "\u00da")
			.Add("Ã›", "\u00db")
			.Add("Ãœ", "\u00dc")
			.Add("Ã", "\u00dd")
			.Add("Ãž", "\u00de")
			.Add("ÃŸ", "\u00df")
			.Add("Ã ", "\u00e0")
			.Add("Ã¡", "\u00e1")
			.Add("Ã¢", "\u00e2")
			.Add("Ã£", "\u00e3")
			.Add("Ã¤", "\u00e4")
			.Add("Ã¥", "\u00e5")
			.Add("Ã¦", "\u00e6")
			.Add("Ã§", "\u00e7")
			.Add("Ã¨", "\u00e8")
			.Add("Ã©", "\u00e9")
			.Add("Ãª", "\u00ea")
			.Add("Ã«", "\u00eb")
			.Add("Ã¬", "\u00ec")
			.Add("Ã­", "\u00ed")
			.Add("Ã®", "\u00ee")
			.Add("Ã¯", "\u00ef")
			.Add("Ã°", "\u00f0")
			.Add("Ã±", "\u00f1")
			.Add("Ã²", "\u00f2")
			.Add("Ã³", "\u00f3")
			.Add("Ã´", "\u00f4")
			.Add("Ãµ", "\u00f5")
			.Add("Ã¶", "\u00f6")
			.Add("Ã·", "\u00f7")
			.Add("Ã¸", "\u00f8")
			.Add("Ã¹", "\u00f9")
			.Add("Ãº", "\u00fa")
			.Add("Ã»", "\u00fb")
			.Add("Ã¼", "\u00fc")
			.Add("Ã½", "\u00fd")
			.Add("Ã¾", "\u00fe")
			.Add("Ã¿", "\u00ff")
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
		loProviders.Add("Msxml2.ServerXMLHTTP.6.0")
		loProviders.Add("WinHttp.WinHttpRequest.5.1")
		loProviders.Add("MSXML2.ServerXMLHTTP")
		loProviders.Add("Microsoft.XMLHTTP")

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
			MessageBox('No se pudo crear la instancia del objeto HTTP.', 16, 'VFPRestClient')
			Return .f.
		Endif

		Return .T.
	Endproc


	Procedure addRequest(tcVerb, tcURL)
		With This
			If Pcount() != 2
				MessageBox('Faltan parámetros: tanto el método como la dirección son obligatorios.', 16, 'VFPRestClient')
				Return
			Endif
			.cleanRequest()
			.Verb = tcVerb
			.URL  = tcURL
		Endwith
	Endproc


	Procedure AddHeader(tcHeader, tcValue)
		If Pcount() != 2
			MessageBox('Faltan parámetros: tanto la clave como el contenido de header son obligatorios.', 16, 'VFPRestClient')
			Return .f.
		Endif
		This.oHeaders.Add(tcValue, tcHeader)
	Endproc


	Procedure addProxy(tcHeader, tcValue)
		If Empty(tcHeader) or Type('tcHeader') != 'C'
			MessageBox('Nombre inválido', 16, "VfpRestClient")
			Return .f.
		Endif
		This.ProxyType = tcHeader
		This.ProxyValue = tcValue
	Endproc


	Procedure addRequestBody(tcRequestBody)
		If Pcount() = 0
			MessageBox('El contenido del cuerpo es obligatorio.', 16, "VfpRestClient")
			Return .f.
		EndIf

		If Type('tcRequestBody') != 'C'
			MessageBox('El contenido del cuerpo debe ser de tipo String.', 16, "VfpRestClient")
			Return .f.
		EndIf
		This.requestBody = tcRequestBody
	Endproc


	Function Send
		If !This.isConnected()
			MessageBox('En este momento la señal de internet no está disponible, inténtelo más tarde.', 16, "VfpRestClient")
			Return .F.
		Endif

		If Empty(This.Verb) or Empty(This.URL)
			MessageBox('Debe ejecutar el método AddRequest() antes de continuar.', 16, "VfpRestClient")
			Return .f.
		Endif

		If !This.getHTTPObject()
			Return .F.
		EndIf

		With this
			If .ResolveTimeOut > 0 And .ConnectTimeOut > 0 And .SendTimeOut > 0 And .receiveTimeOut > 0
				.ResolveTimeOut = .ResolveTimeOut * 1000
				.ConnectTimeOut = .ConnectTimeOut * 1000
				.SendTimeOut 	= .SendTimeOut 	  * 1000
				.receiveTimeOut = .receiveTimeOut * 1000
				.oXMLHTTP.setTimeouts(.ResolveTimeOut, .ConnectTimeOut, .SendTimeOut, .receiveTimeOut)
			EndIf
		endwith

		This.oXMLHTTP.Open(This.Verb, This.URL, .F.)
		If !This.isWinHttp And This.getReadyState() <> HTTP_OPEN
			MessageBox('No se pudo inicializar la solicitud [' + this.verb + '] a la dirección [' + this.url + ']', 16, "VfpRestClient")
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
		Declare Integer InternetGetConnectedState In WinInet Integer @lpdwFlags, Integer dwReserved
		Local lnFlags, lnResult
		lnFlags = 0
		lnResult = InternetGetConnectedState(@lnFlags, 0)
		Clear Dlls InternetGetConnectedState
		Return (lnResult = 1)
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
