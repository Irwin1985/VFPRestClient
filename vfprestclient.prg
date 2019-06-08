*====================================================================
* VFPRestClient
*====================================================================
Define Class Rest As Custom
	Hidden lValidCall
	Hidden oXMLHTTP

	Hidden Verb
	Hidden URL
	Hidden requestBody
	Hidden ContentType
	Hidden ContentValue

	Version			= ''
	LastUpdate		= ''
	Author			= ''
	Email			= ''
	LastErrorText 	= ''
	Content_Type	= 'Content-Type'
	Appication_Json	= 'application/json'
	Response		= ''
	Status			= 0
	StatusText		= ''
	ResponseText	= ''
	ReadyState		= 0

	Get				= 'GET'
	POST			= 'POST'
	PUT				= 'PUT'
	PATCH			= 'PATCH'
	Delete			= 'DELETE'
	Copy			= 'COPY'
	Head			= 'HEAD'
	OPTIONS			= 'OPTIONS'
	Link			= 'LINK'
	UNLINK			= 'UNLINK'
	PURGE			= 'PURGE'
	Lock			= 'LOCK'
	Unlock			= 'UNLOCK'
	PROPFIND		= 'PROPFIND'
	View			= 'VIEW'

	#Define True 				.T.
	#Define False 				.F.
	#Define HTTP_STATUS_OK      200
	#Define HTTP_COMPLETED      4
	#Define HTTP_OPEN           1

	ResolveTimeOut	= 5		&& The value is applied to mapping hot names to IP addresses.
	ConnectTimeOut	= 60	&& The value is applied for establishing a communication socket with the target server.
	SendTimeOut		= 30	&& The value applies to sending an individual packet of request data on the communication socket to the target server.
	receiveTimeOut	= 30	&& The value applies to receiving a packet of response data from the target server.
	waitTimeOut		= 5		&& The value applies to analyze the readyState change when communitacion socket has established.

	Procedure Init
		With This
			.lValidCall = True
			.Version	= '1.5 (beta)'
			.lValidCall = True
			.LastUpdate	= '2019-04-09 14:17:51'
			.lValidCall = True
			.Author		= 'Irwin Rodr�guez'
			.lValidCall = True
			.Email		= 'rodriguez.irwin@gmail.com'
			.__clean_request()
			.oXMLHTTP	= .Null.
		Endwith
*====================================================================

	Hidden Procedure __create_object
		Local lCreated As boolean
		lCreated = False
		Try
			This.oXMLHTTP	= Createobject('Msxml2.ServerXMLHTTP.6.0')
			lCreated = True
		Catch
		Endtry
		If Not lCreated
			Try
				This.oXMLHTTP	= Createobject('MSXML2.ServerXMLHTTP')
				lCreated = True
			Catch
			Endtry
		Endif
		If Not lCreated
			Try
				This.oXMLHTTP	= Createobject('Microsoft.XMLHTTP')
				lCreated = True
			Catch
			Endtry
		Endif

		If Type('THIS.oXMLHTTP') <> 'O'
			This.lValidCall = True
			This.__setLastErrorText('could not create the XMLHTTP object')
		Else
			lCreated = True
		Endif
		Return lCreated

*====================================================================
	Procedure addRequest(tcVerb As String, tcURL As String) HelpString 'Carga una petici�n al objeto oRest.'
		If Empty(tcVerb) .Or. Empty(tcURL)
			This.lValidCall = True
			This.__setLastErrorText('Invalid params')
		Endif

		This.lValidCall = True
		This.Verb = tcVerb

		This.lValidCall = True
		This.URL = tcURL

*====================================================================
	Procedure addHeader(tcHeader As String, tcValue As String)
		If Empty(tcHeader) Or Empty(tcValue)
			This.lValidCall = True
			This.__setLastErrorText('Invalid params')
		Endif

*-- Add Header Content
		This.lValidCall 	= True
		This.ContentType 	= tcHeader

*-- Add Header Value
		This.lValidCall 	= True
		This.ContentValue 	= tcValue

*====================================================================
	Procedure addRequestBody(tcRequestBody As String) 'Agrega un contenido en formato JSON al cuerpo de la petici�n.'
		If Empty(tcRequestBody)
			This.lValidCall = True
			This.__setLastErrorText('Invalid request format')
		Endif

		This.lValidCall 	= True
		This.requestBody 	= tcRequestBody

*====================================================================
	Function Send HelpString 'Env�a la petici�n al servidor'
*-- Validate Request Params
		Local cMsg As String, lError As boolean
		cMsg = ''
		This.__clean_Response()
		If Empty(This.Verb)
			cMsg = 'missing verb param'
		Endif

		If Empty(This.URL)
			cMsg = 'missing URL param'
		Endif

		If Not Empty(cMsg)
			This.lValidCall = True
			This.__setLastErrorText(cMsg)
			Return False
		Endif

		If Not This.__create_object()
			Return False
		Endif

		If This.ResolveTimeOut > 0 .And. This.ConnectTimeOut > 0 .And. This.SendTimeOut > 0 .And. This.receiveTimeOut > 0
			This.ResolveTimeOut		= This.ResolveTimeOut 	* 1000
			This.ConnectTimeOut		= This.ConnectTimeOut	* 1000
			This.SendTimeOut		= This.SendTimeOut		* 1000
			This.receiveTimeOut		= This.receiveTimeOut	* 1000

			This.oXMLHTTP.setTimeouts(This.ResolveTimeOut, This.ConnectTimeOut, This.SendTimeOut, This.receiveTimeOut)
		Endif

		Try
			This.oXMLHTTP.Open(This.Verb, This.URL)
		Catch To oErr
			cMsg = ''
			If Type('oErr.Message') = 'C'
				cMsg = oErr.Message
			Endif
			This.lValidCall = True
			This.__setLastErrorText('error related with send method: ' + cMsg)
			lError = True
		Endtry
		If lError
			Return False
		Endif

		If This.oXMLHTTP.ReadyState <> HTTP_OPEN
			This.lValidCall = True
			This.__setLastErrorText('could not open the communication socket.')
			Return False
		Endif

		If Not Empty(This.ContentType) .And. Not Empty(This.ContentValue)
			This.oXMLHTTP.setRequestHeader(This.ContentType, This.ContentValue)
		Endif

		If !This.__isConnected()
			This.lValidCall = True
			This.__setLastErrorText('there is not an active internet connection.')
			Return False
		Endif

*-- Send the Request

		Try
			This.oXMLHTTP.Send(This.requestBody)
		Catch To oErr
			cMsg = ''
			If Type('oErr.Message') = 'C'
				cMsg = oErr.Message
			Endif
			This.lValidCall = True
			This.__setLastErrorText('error related with send method: ' + cMsg)
			lError = True
		Endtry
		If lError
			Return False
		Endif

*-- Loop until readyState change or timeouts dies.
		If Empty(This.waitTimeOut)
			This.waitTimeOut = 5
		Endif

		nSeg = Seconds() + This.waitTimeOut
		Do While Seconds() <= nSeg
			If This.oXMLHTTP.ReadyState <> HTTP_OPEN
				Exit && There's an answer.
			Endif
		Enddo
		With This
			.lValidCall 	= True
			.Response 		= .__html_entity_decode(.oXMLHTTP.ResponseText)
			.lValidCall 	= True
			.Status			= .oXMLHTTP.Status
			.lValidCall 	= True
			.StatusText		= .oXMLHTTP.StatusText
			.lValidCall 	= True
			.ResponseText	= .Response
			.lValidCall 	= True
			.ReadyState		= .oXMLHTTP.ReadyState
			.oXMLHTTP 		= .Null.
		Endwith
*====================================================================
	Hidden Function __isConnected
		Declare Integer InternetGetConnectedState In WinInet Integer @lpdwFlags, Integer dwReserved
		Local lnFlags, lnReserved, lnSuccess
		lnFlags		= 0
		lnReserved	= 0
		lnSuccess	= InternetGetConnectedState(@lnFlags,lnReserved)
		Clear Dlls
		Return (lnSuccess=1)

*====================================================================
	Hidden Procedure __setLastErrorText(tcErrorText As String)
		This.lValidCall = True
		This.LastErrorText = Iif(!Empty(tcErrorText), tcErrorText, '')

*====================================================================
	Hidden Procedure __clean_Response
		With This
			.lValidCall 	= True
			.Response 		= ''
			.lValidCall 	= True
			.Status			= 0
			.lValidCall 	= True
			.StatusText		= ''
			.lValidCall 	= True
			.ResponseText	= ''
			.lValidCall 	= True
			.ReadyState		= 0
		Endwith
*====================================================================
	Hidden Procedure __clean_request
		With This
			.lValidCall 	= True
			.Response 		= ''
			.lValidCall 	= True
			.Verb 			= ''
			.lValidCall 	= True
			.URL 			= ''
			.lValidCall 	= True
			.ContentType 	= ''
			.lValidCall 	= True
			.ContentValue 	= ''
			.lValidCall 	= True
			.requestBody 	= ''
			.lValidCall 	= True
			.Status			= 0
			.lValidCall 	= True
			.StatusText		= ''
			.lValidCall 	= True
			.ResponseText	= ''
			.lValidCall 	= True
			.ReadyState		= 0
		Endwith
*====================================================================
	Hidden Function __html_entity_decode(cText As Memo) As Memo
		cText = Strtran(cText, "\u00a0", "�")
		cText = Strtran(cText, "\u00a1", "�")
		cText = Strtran(cText, "\u00a2", "�")
		cText = Strtran(cText, "\u00a3", "�")
		cText = Strtran(cText, "\u00a4", "�")
		cText = Strtran(cText, "\u00a5", "�")
		cText = Strtran(cText, "\u00a6", "�")
		cText = Strtran(cText, "\u00a7", "�")
		cText = Strtran(cText, "\u00a8", "�")
		cText = Strtran(cText, "\u00a9", "�")
		cText = Strtran(cText, "\u00aa", "�")
		cText = Strtran(cText, "\u00ab", "�")
		cText = Strtran(cText, "\u00ac", "�")
		cText = Strtran(cText, "\u00ae", "�")
		cText = Strtran(cText, "\u00af", "�")
		cText = Strtran(cText, "\u00b0", "�")
		cText = Strtran(cText, "\u00b1", "�")
		cText = Strtran(cText, "\u00b2", "�")
		cText = Strtran(cText, "\u00b3", "�")
		cText = Strtran(cText, "\u00b4", "�")
		cText = Strtran(cText, "\u00b5", "�")
		cText = Strtran(cText, "\u00b6", "�")
		cText = Strtran(cText, "\u00b7", "�")
		cText = Strtran(cText, "\u00b8", "�")
		cText = Strtran(cText, "\u00b9", "�")
		cText = Strtran(cText, "\u00ba", "�")
		cText = Strtran(cText, "\u00bb", "�")
		cText = Strtran(cText, "\u00bc", "�")
		cText = Strtran(cText, "\u00bd", "�")
		cText = Strtran(cText, "\u00be", "�")
		cText = Strtran(cText, "\u00bf", "�")
		cText = Strtran(cText, "\u00c0", "�")
		cText = Strtran(cText, "\u00c1", "�")
		cText = Strtran(cText, "\u00c2", "�")
		cText = Strtran(cText, "\u00c3", "�")
		cText = Strtran(cText, "\u00c4", "�")
		cText = Strtran(cText, "\u00c5", "�")
		cText = Strtran(cText, "\u00c6", "�")
		cText = Strtran(cText, "\u00c7", "�")
		cText = Strtran(cText, "\u00c8", "�")
		cText = Strtran(cText, "\u00c9", "�")
		cText = Strtran(cText, "\u00ca", "�")
		cText = Strtran(cText, "\u00cb", "�")
		cText = Strtran(cText, "\u00cc", "�")
		cText = Strtran(cText, "\u00cd", "�")
		cText = Strtran(cText, "\u00ce", "�")
		cText = Strtran(cText, "\u00cf", "�")
		cText = Strtran(cText, "\u00d0", "�")
		cText = Strtran(cText, "\u00d1", "�")
		cText = Strtran(cText, "\u00d2", "�")
		cText = Strtran(cText, "\u00d3", "�")
		cText = Strtran(cText, "\u00d4", "�")
		cText = Strtran(cText, "\u00d5", "�")
		cText = Strtran(cText, "\u00d6", "�")
		cText = Strtran(cText, "\u00d7", "�")
		cText = Strtran(cText, "\u00d8", "�")
		cText = Strtran(cText, "\u00d9", "�")
		cText = Strtran(cText, "\u00da", "�")
		cText = Strtran(cText, "\u00db", "�")
		cText = Strtran(cText, "\u00dc", "�")
		cText = Strtran(cText, "\u00dd", "�")
		cText = Strtran(cText, "\u00de", "�")
		cText = Strtran(cText, "\u00df", "�")
		cText = Strtran(cText, "\u00e0", "�")
		cText = Strtran(cText, "\u00e1", "�")
		cText = Strtran(cText, "\u00e2", "�")
		cText = Strtran(cText, "\u00e3", "�")
		cText = Strtran(cText, "\u00e4", "�")
		cText = Strtran(cText, "\u00e5", "�")
		cText = Strtran(cText, "\u00e6", "�")
		cText = Strtran(cText, "\u00e7", "�")
		cText = Strtran(cText, "\u00e8", "�")
		cText = Strtran(cText, "\u00e9", "�")
		cText = Strtran(cText, "\u00ea", "�")
		cText = Strtran(cText, "\u00eb", "�")
		cText = Strtran(cText, "\u00ec", "�")
		cText = Strtran(cText, "\u00ed", "�")
		cText = Strtran(cText, "\u00ee", "�")
		cText = Strtran(cText, "\u00ef", "�")
		cText = Strtran(cText, "\u00f0", "�")
		cText = Strtran(cText, "\u00f1", "�")
		cText = Strtran(cText, "\u00f2", "�")
		cText = Strtran(cText, "\u00f3", "�")
		cText = Strtran(cText, "\u00f4", "�")
		cText = Strtran(cText, "\u00f5", "�")
		cText = Strtran(cText, "\u00f6", "�")
		cText = Strtran(cText, "\u00f7", "�")
		cText = Strtran(cText, "\u00f8", "�")
		cText = Strtran(cText, "\u00f9", "�")
		cText = Strtran(cText, "\u00fa", "�")
		cText = Strtran(cText, "\u00fb", "�")
		cText = Strtran(cText, "\u00fc", "�")
		cText = Strtran(cText, "\u00fd", "�")
		cText = Strtran(cText, "\u00fe", "�")
		cText = Strtran(cText, "\u00ff", "�")
		cText = Strtran(cText, "\u0026", "&")
		cText = Strtran(cText, "\u2019", "'")
		cText = Strtran(cText, "\u003A", ":")
		cText = Strtran(cText, "\u002B", "+")
		cText = Strtran(cText, "\u002D", "-")
		cText = Strtran(cText, "\u0023", "#")
		cText = Strtran(cText, "\u0025", "%")
		Return cText

*====================================================================
	Hidden Procedure LastErrorText_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.LastErrorText = m.vNewVal
		Endif

*====================================================================
	Hidden Procedure Version_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.Version = m.vNewVal
		Endif

*====================================================================
	Hidden Function Version_Access
		Return This.Version

*====================================================================
	Hidden Procedure LastUpdate_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.LastUpdate = m.vNewVal
		Endif

*====================================================================
	Hidden Function LastUpdate_Access
		Return This.LastUpdate

*====================================================================
	Hidden Procedure Author_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.Author = m.vNewVal
		Endif

*====================================================================
	Hidden Function Author_Access
		Return This.Author

*====================================================================
	Hidden Procedure Email_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.Email = m.vNewVal
		Endif

*====================================================================
	Hidden Function Email_Access
		Return This.Email

*====================================================================
	Hidden Procedure RequestBody_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.requestBody = m.vNewVal
		Endif

*====================================================================
	Hidden Function RequestBody_Access
		Return This.requestBody

*====================================================================
	Hidden Function Verb_Access
		Return This.Verb

*====================================================================
	Hidden Function URL_Access
		Return This.URL

*====================================================================
	Hidden Function RequestBody_Access
		Return This.requestBody

*====================================================================
	Hidden Function Response_Access
		Return This.Response

*====================================================================
	Hidden Procedure Verb_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.Verb = m.vNewVal
		Endif

*====================================================================
	Hidden Procedure URL_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.URL = m.vNewVal
		Endif

*====================================================================
	Hidden Procedure RequestBody_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.requestBody = m.vNewVal
		Endif

*====================================================================
	Hidden Procedure Response_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.Response = m.vNewVal
		Endif

*====================================================================
	Hidden Function ContentType_Access
		Return This.ContentType

*====================================================================
	Hidden Procedure ContentType_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.ContentType = m.vNewVal
		Endif

*====================================================================
	Hidden Function ContentValue_Access
		Return This.ContentValue

*====================================================================
	Hidden Procedure ContentValue_Assign(vNewVal)
		If This.lValidCall
			This.lValidCall = False
			This.ContentValue = m.vNewVal
		Endif

*====================================================================
	Hidden Function STATUS_Access
		Return This.Status

*====================================================================
	Hidden Function StatusText_Access
		Return This.StatusText

*====================================================================
	Hidden Function ResponseText_Access
		Return This.ResponseText

*====================================================================
	Hidden Function ReadyState_Access
		Return This.ReadyState

*====================================================================
	Hidden Procedure STATUS_Assign(vNewVal)
		If This.lValidCall
			This.Status = m.vNewVal
		Endif

*====================================================================
	Hidden Procedure StatusText_Assign(vNewVal)
		If This.lValidCall
			This.StatusText = m.vNewVal
		Endif

*====================================================================
	Hidden Procedure ResponseText_Assign(vNewVal)
		If This.lValidCall
			This.ResponseText = m.vNewVal
		Endif

*====================================================================
	Hidden Procedure ReadyState_Assign(vNewVal)
		If This.lValidCall
			This.ReadyState = m.vNewVal
		Endif

*====================================================================
Enddefine
