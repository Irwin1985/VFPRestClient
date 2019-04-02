*---------------------------------------------------------------------------------------------------------------*
*
* @title:		Librería VFPRestClient
* @description:	Librería 100% desarrollada en Visual FoxPro 9.0 para la comunicación via REST con servicios web.
*
* @version:		1.3 (beta)
* @author:		Irwin Rodríguez
* @email:		rodriguez.irwin@gmail.com
* @license:		MIT
*
* -------------------------------------------------------------------------
* Version Log:
*
* Release 2019-04-02	v.1.3		- Función para escapar los caracteres especiales.
*
* Release 2019-03-30	v.1.2		- Liberación formal en https://github.com/Irwin1985/VFPRestClient
*---------------------------------------------------------------------------------------------------------------*

DEFINE CLASS REST AS CUSTOM
	HIDDEN lValidCall
	HIDDEN oXMLHTTP

*-- Request Properties
	HIDDEN VERB
	HIDDEN URL
	HIDDEN requestBody
	HIDDEN ContentType
	HIDDEN ContentValue

	VERSION			= ""
	LastUpdate		= ""
	Author			= ""
	Email			= ""
	LastErrorText 	= ""
	CONTENT_TYPE	= "Content-Type"
	APPICATION_JSON	= "application/json"
	RESPONSE		= ""
	STATUS			= 0
	STATUSTEXT		= ""
	RESPONSETEXT	= ""
	READYSTATE		= 0

*-- Verb List
	GET				= "GET"
	POST			= "POST"
	PUT				= "PUT"
	PATCH			= "PATCH"
	DELETE			= "DELETE"
	COPY			= "COPY"
	HEAD			= "HEAD"
	OPTIONS			= "OPTIONS"
	LINK			= "LINK"
	UNLINK			= "UNLINK"
	PURGE			= "PURGE"
	LOCK			= "LOCK"
	UNLOCK			= "UNLOCK"
	PROPFIND		= "PROPFIND"
	VIEW			= "VIEW"

*-- Set default timeouts
	ResolveTimeOut	= 5	&& The value is applied to mapping hot names to IP addresses.
	CONNECTTIMEOUT	= 60	&& The value is applied for establishing a communication socket with the target server.
	SendTimeOut	= 30	&& The value applies to sending an individual packet of request data on the communication socket to the target server.
	receiveTimeOut	= 30	&& The value applies to receiving a packet of response data from the target server.
	waitTimeOut	= 5	&& The value applies to analyze the readyState change when communitacion socket has established.

	PROCEDURE INIT
*-- Constants Definitions
		#DEFINE TRUE .T.
		#DEFINE FALSE .F.
		#DEFINE HTTP_STATUS_OK        200
		#DEFINE HTTP_COMPLETED        4
		#DEFINE HTTP_OPEN             1

		THIS.lValidCall = .T.
		THIS.VERSION	= "1.3 (beta)"
		THIS.lValidCall = .T.
		THIS.LastUpdate	= "2019-04-02 08:00:51 PM"
		THIS.lValidCall = .T.
		THIS.Author	= "Irwin Rodríguez"
		THIS.lValidCall = .T.
		THIS.Email	= "rodriguez.irwin@gmail.com"
		THIS.__clean_request()
		THIS.oXMLHTTP	= .NULL.
	ENDPROC

	HIDDEN PROCEDURE __create_object
		LOCAL lCreated AS boolean
		lCreated = .F.
		TRY
			THIS.oXMLHTTP	= CREATEOBJECT("Msxml2.ServerXMLHTTP.6.0")
			lCreated = .T.
		CATCH
		ENDTRY
		IF NOT lCreated
			TRY
				THIS.oXMLHTTP	= CREATEOBJECT("MSXML2.ServerXMLHTTP")
				lCreated = .T.
			CATCH
			ENDTRY
		ELSE &&NOT lCreated
		ENDIF &&NOT lCreated
		IF NOT lCreated
			TRY
				THIS.oXMLHTTP	= CREATEOBJECT("Microsoft.XMLHTTP")
				lCreated = .T.
			CATCH
			ENDTRY
		ELSE &&NOT lCreated
		ENDIF &&NOT lCreated

		IF TYPE("THIS.oXMLHTTP") <> "O"
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("could not create the XMLHTTP object")
		ELSE &&TYPE("THIS.oXMLHTTP") <> "O"
			lCreated = .T.
		ENDIF &&TYPE("THIS.oXMLHTTP") <> "O"
		RETURN lCreated
	ENDPROC

	PROCEDURE addRequest(tcVerb AS STRING, tcURL AS STRING) HELPSTRING "Carga una petición al objeto oRest."
		IF EMPTY(tcVerb) .OR. EMPTY(tcURL)
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("Invalid params")
		ELSE &&EMPTY(tcVerb) .OR. EMPTY(tcURL)
		ENDIF &&EMPTY(tcVerb) .OR. EMPTY(tcURL)

*-- Add Verb/Method
		THIS.lValidCall = .T.
		THIS.VERB = tcVerb

*-- Add URL
		THIS.lValidCall = .T.
		THIS.URL = tcURL

	ENDPROC

	PROCEDURE addHeader(tcHeader AS STRING, tcValue AS STRING)
		IF EMPTY(tcHeader) OR EMPTY(tcValue)
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("Invalid params")
		ELSE &&EMPTY(tcVerb) OR EMPTY(tcURL)
		ENDIF &&EMPTY(tcVerb) OR EMPTY(tcURL)

*-- Add Header Content
		THIS.lValidCall 	= .T.
		THIS.ContentType 	= tcHeader

*-- Add Header Value
		THIS.lValidCall 	= .T.
		THIS.ContentValue 	= tcValue
	ENDPROC

	PROCEDURE addRequestBody(tcRequestBody AS STRING) "Agrega un contenido en formato JSON al cuerpo de la petición."
		IF EMPTY(tcRequestBody)
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("Invalid request format")
		ELSE &&EMPTY(tcRequestBody)
		ENDIF &&EMPTY(tcRequestBody)
*-- Add Body
		THIS.lValidCall 	= .T.
		THIS.requestBody 	= tcRequestBody
	ENDPROC

	FUNCTION SEND HELPSTRING "Envía la petición al servidor"
*-- Validate Request Params
		LOCAL cMsg AS STRING
		cMsg 		= ""
		THIS.__clean_response()
		IF EMPTY(THIS.VERB)
			cMsg = "missing verb param"
		ELSE &&EMPTY(THIS.VERB)
		ENDIF &&EMPTY(THIS.VERB)

		IF EMPTY(THIS.URL)
			cMsg = "missing URL param"
		ELSE &&EMPTY(THIS.URL)
		ENDIF &&EMPTY(THIS.URL)

		IF NOT EMPTY(cMsg)
			THIS.lValidCall = .T.
			THIS.__setLastErrorText(cMsg)
			RETURN FALSE
		ELSE &&NOT EMPTY(cMsg)
		ENDIF &&NOT EMPTY(cMsg)

		IF NOT THIS.__create_object()
			RETURN FALSE
		ELSE &&NOT THIS.__create_object()
		ENDIF &&NOT THIS.__create_object()

		IF THIS.ResolveTimeOut > 0 .AND. THIS.CONNECTTIMEOUT > 0 .AND. THIS.SendTimeOut > 0 .AND. THIS.receiveTimeOut > 0
			THIS.ResolveTimeOut		= THIS.ResolveTimeOut 	* 1000
			THIS.CONNECTTIMEOUT		= THIS.CONNECTTIMEOUT	* 1000
			THIS.SendTimeOut		= THIS.SendTimeOut		* 1000
			THIS.receiveTimeOut		= THIS.receiveTimeOut	* 1000

			THIS.oXMLHTTP.setTimeouts(THIS.ResolveTimeOut, THIS.CONNECTTIMEOUT, THIS.SendTimeOut, THIS.receiveTimeOut)
		ELSE &&THIS.ResolveTimeOut > 0 .AND. THIS.ConnectTimeOut > 0 .AND. THIS.SendTimeOut > 0 .AND. THIS.receiveTimeOut > 0
		ENDIF &&THIS.ResolveTimeOut > 0 .AND. THIS.ConnectTimeOut > 0 .AND. THIS.SendTimeOut > 0 .AND. THIS.receiveTimeOut > 0

		THIS.oXMLHTTP.OPEN(THIS.VERB, THIS.URL)

		IF THIS.oXMLHTTP.READYSTATE <> HTTP_OPEN
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("could not open the communication socket.")
			RETURN FALSE
		ELSE &&THIS.oXMLHTTP.ReadyState <> HTTP_OPEN
		ENDIF &&THIS.oXMLHTTP.ReadyState <> HTTP_OPEN

		IF NOT EMPTY(THIS.ContentType) .AND. NOT EMPTY(THIS.ContentValue)
			THIS.oXMLHTTP.setRequestHeader(THIS.ContentType, THIS.ContentValue)
		ELSE &&NOT EMPTY(THIS.ContentType) .AND. NOT EMPTY(THIS.ContentValue)
		ENDIF &&NOT EMPTY(THIS.ContentType) .AND. NOT EMPTY(THIS.ContentValue)

*-- Send the Request
		THIS.oXMLHTTP.SEND()

*-- Loop until readyState change or timeouts dies.
		IF EMPTY(THIS.waitTimeOut)
			THIS.waitTimeOut = 5
		ELSE &&EMPTY(THIS.waitTimeOut)
		ENDIF &&EMPTY(THIS.waitTimeOut)

		nSeg = SECONDS() + THIS.waitTimeOut
		DO WHILE SECONDS() <= nSeg
			IF THIS.oXMLHTTP.READYSTATE <> HTTP_OPEN
				EXIT && There's an answer.
			ELSE &&THIS.oXMLHTTP.readyState <> HTTP_OPEN
			ENDIF &&THIS.oXMLHTTP.readyState <> HTTP_OPEN
		ENDDO &&WHILE SECONDS() <= nSeg

		THIS.lValidCall 	= .T.
		THIS.RESPONSE 		= THIS.__html_entity_decode(THIS.oXMLHTTP.RESPONSETEXT)
		THIS.lValidCall 	= .T.
		THIS.STATUS			= THIS.oXMLHTTP.STATUS
		THIS.lValidCall 	= .T.
		THIS.STATUSTEXT		= THIS.oXMLHTTP.STATUSTEXT
		THIS.lValidCall 	= .T.
		THIS.RESPONSETEXT	= THIS.RESPONSE
		THIS.lValidCall 	= .T.
		THIS.READYSTATE		= THIS.oXMLHTTP.READYSTATE

		THIS.oXMLHTTP = .NULL.
	ENDFUNC
*-- Getters and Setters
	HIDDEN PROCEDURE __setLastErrorText
		LPARAMETERS tcErrorText
		THIS.lValidCall = .T.
		IF NOT EMPTY(tcErrorText)
			THIS.LastErrorText = tcErrorText
		ELSE &&NOT EMPTY(tcErrorText)
			THIS.LastErrorText = ""
		ENDIF &&NOT EMPTY(tcErrorText)
	ENDPROC

	HIDDEN PROCEDURE __clean_response
*-- Clean Response
		THIS.lValidCall 		= .T.
		THIS.RESPONSE 			= ""
	ENDPROC

	HIDDEN PROCEDURE __clean_request
*-- Clean Response
		THIS.lValidCall 	= .T.
		THIS.RESPONSE 		= ""

*-- Clean Verb
		THIS.lValidCall 	= .T.
		THIS.VERB 			= ""

*-- Clean URL
		THIS.lValidCall 	= .T.
		THIS.URL 			= ""

*-- Clean ContentType
		THIS.lValidCall 	= .T.
		THIS.ContentType 	= ""

*-- Clean ContentValue
		THIS.lValidCall 	= .T.
		THIS.ContentValue 	= ""

*-- Clean RequestBody
		THIS.lValidCall 	= .T.
		THIS.requestBody 	= ""

		THIS.lValidCall 	= .T.
		THIS.STATUS			= 0

		THIS.lValidCall 	= .T.
		THIS.STATUSTEXT		= ""

		THIS.lValidCall 	= .T.
		THIS.RESPONSETEXT	= ""

		THIS.lValidCall 	= .T.
		THIS.READYSTATE		= 0

	ENDPROC
*-- FUNCTION __html_entity_decode(cText AS MEMO)
	HIDDEN FUNCTION __html_entity_decode(cText AS MEMO) AS MEMO
		cText = STRTRAN(cText, "\u00a0", "Â")
		cText = STRTRAN(cText, "\u00a1", "¡")
		cText = STRTRAN(cText, "\u00a2", "¢")
		cText = STRTRAN(cText, "\u00a3", "£")
		cText = STRTRAN(cText, "\u00a4", "¤")
		cText = STRTRAN(cText, "\u00a5", "¥")
		cText = STRTRAN(cText, "\u00a6", "¦")
		cText = STRTRAN(cText, "\u00a7", "§")
		cText = STRTRAN(cText, "\u00a8", "¨")
		cText = STRTRAN(cText, "\u00a9", "©")
		cText = STRTRAN(cText, "\u00aa", "ª")
		cText = STRTRAN(cText, "\u00ab", "«")
		cText = STRTRAN(cText, "\u00ac", "¬")
		cText = STRTRAN(cText, "\u00ae", "®")
		cText = STRTRAN(cText, "\u00af", "¯")
		cText = STRTRAN(cText, "\u00b0", "°")
		cText = STRTRAN(cText, "\u00b1", "±")
		cText = STRTRAN(cText, "\u00b2", "²")
		cText = STRTRAN(cText, "\u00b3", "³")
		cText = STRTRAN(cText, "\u00b4", "´")
		cText = STRTRAN(cText, "\u00b5", "µ")
		cText = STRTRAN(cText, "\u00b6", "¶")
		cText = STRTRAN(cText, "\u00b7", "·")
		cText = STRTRAN(cText, "\u00b8", "¸")
		cText = STRTRAN(cText, "\u00b9", "¹")
		cText = STRTRAN(cText, "\u00ba", "º")
		cText = STRTRAN(cText, "\u00bb", "»")
		cText = STRTRAN(cText, "\u00bc", "¼")
		cText = STRTRAN(cText, "\u00bd", "½")
		cText = STRTRAN(cText, "\u00be", "¾")
		cText = STRTRAN(cText, "\u00bf", "¿")
		cText = STRTRAN(cText, "\u00c0", "À")
		cText = STRTRAN(cText, "\u00c1", "Á")
		cText = STRTRAN(cText, "\u00c2", "Â")
		cText = STRTRAN(cText, "\u00c3", "Ã")
		cText = STRTRAN(cText, "\u00c4", "Ä")
		cText = STRTRAN(cText, "\u00c5", "Å")
		cText = STRTRAN(cText, "\u00c6", "Æ")
		cText = STRTRAN(cText, "\u00c7", "Ç")
		cText = STRTRAN(cText, "\u00c8", "È")
		cText = STRTRAN(cText, "\u00c9", "É")
		cText = STRTRAN(cText, "\u00ca", "Ê")
		cText = STRTRAN(cText, "\u00cb", "Ë")
		cText = STRTRAN(cText, "\u00cc", "Ì")
		cText = STRTRAN(cText, "\u00cd", "Í")
		cText = STRTRAN(cText, "\u00ce", "Î")
		cText = STRTRAN(cText, "\u00cf", "Ï")
		cText = STRTRAN(cText, "\u00d0", "Ð")
		cText = STRTRAN(cText, "\u00d1", "Ñ")
		cText = STRTRAN(cText, "\u00d2", "Ò")
		cText = STRTRAN(cText, "\u00d3", "Ó")
		cText = STRTRAN(cText, "\u00d4", "Ô")
		cText = STRTRAN(cText, "\u00d5", "Õ")
		cText = STRTRAN(cText, "\u00d6", "Ö")
		cText = STRTRAN(cText, "\u00d7", "×")
		cText = STRTRAN(cText, "\u00d8", "Ø")
		cText = STRTRAN(cText, "\u00d9", "Ù")
		cText = STRTRAN(cText, "\u00da", "Ú")
		cText = STRTRAN(cText, "\u00db", "Û")
		cText = STRTRAN(cText, "\u00dc", "Ü")
		cText = STRTRAN(cText, "\u00dd", "Ý")
		cText = STRTRAN(cText, "\u00de", "Þ")
		cText = STRTRAN(cText, "\u00df", "ß")
		cText = STRTRAN(cText, "\u00e0", "à")
		cText = STRTRAN(cText, "\u00e1", "á")
		cText = STRTRAN(cText, "\u00e2", "â")
		cText = STRTRAN(cText, "\u00e3", "ã")
		cText = STRTRAN(cText, "\u00e4", "ä")
		cText = STRTRAN(cText, "\u00e5", "å")
		cText = STRTRAN(cText, "\u00e6", "æ")
		cText = STRTRAN(cText, "\u00e7", "ç")
		cText = STRTRAN(cText, "\u00e8", "è")
		cText = STRTRAN(cText, "\u00e9", "é")
		cText = STRTRAN(cText, "\u00ea", "ê")
		cText = STRTRAN(cText, "\u00eb", "ë")
		cText = STRTRAN(cText, "\u00ec", "ì")
		cText = STRTRAN(cText, "\u00ed", "í")
		cText = STRTRAN(cText, "\u00ee", "î")
		cText = STRTRAN(cText, "\u00ef", "ï")
		cText = STRTRAN(cText, "\u00f0", "ð")
		cText = STRTRAN(cText, "\u00f1", "ñ")
		cText = STRTRAN(cText, "\u00f2", "ò")
		cText = STRTRAN(cText, "\u00f3", "ó")
		cText = STRTRAN(cText, "\u00f4", "ô")
		cText = STRTRAN(cText, "\u00f5", "õ")
		cText = STRTRAN(cText, "\u00f6", "ö")
		cText = STRTRAN(cText, "\u00f7", "÷")
		cText = STRTRAN(cText, "\u00f8", "ø")
		cText = STRTRAN(cText, "\u00f9", "ù")
		cText = STRTRAN(cText, "\u00fa", "ú")
		cText = STRTRAN(cText, "\u00fb", "û")
		cText = STRTRAN(cText, "\u00fc", "ü")
		cText = STRTRAN(cText, "\u00fd", "ý")
		cText = STRTRAN(cText, "\u00fe", "þ")
		cText = STRTRAN(cText, "\u00ff", "ÿ")
		cText = STRTRAN(cText, "\u0026", "&")
		cText = STRTRAN(cText, "\u2019", "'")
		cText = STRTRAN(cText, "\u003A", ":")
		cText = STRTRAN(cText, "\u002B", "+")
		cText = STRTRAN(cText, "\u002D", "-")
		cText = STRTRAN(cText, "\u0023", "#")
		cText = STRTRAN(cText, "\u0025", "%")
		RETURN cText
	ENDFUNC
	*-- PROCEDURE LastErrorText_Assign
	HIDDEN PROCEDURE LastErrorText_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.LastErrorText = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN PROCEDURE Version_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.VERSION = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION Version_Access
		RETURN THIS.VERSION
	ENDFUNC
	HIDDEN PROCEDURE LastUpdate_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.LastUpdate = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION LastUpdate_Access
		RETURN THIS.LastUpdate
	ENDFUNC
	HIDDEN PROCEDURE Author_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.Author = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION Author_Access
		RETURN THIS.Author
	ENDFUNC
	HIDDEN PROCEDURE Email_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.Email = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION Email_Access
		RETURN THIS.Email
	ENDFUNC
	HIDDEN PROCEDURE RequestBody_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.requestBody = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION RequestBody_Access
		RETURN THIS.requestBody
	ENDFUNC
	HIDDEN FUNCTION Verb_Access
		RETURN THIS.VERB
	ENDFUNC
	HIDDEN FUNCTION URL_Access
		RETURN THIS.URL
	ENDFUNC
	HIDDEN FUNCTION RequestBody_Access
		RETURN THIS.requestBody
	ENDFUNC
	HIDDEN FUNCTION Response_Access
		RETURN THIS.RESPONSE
	ENDFUNC
	HIDDEN PROCEDURE Verb_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.VERB = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN PROCEDURE URL_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.URL = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN PROCEDURE RequestBody_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.requestBody = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN PROCEDURE Response_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.RESPONSE = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION ContentType_Access
		RETURN THIS.ContentType
	ENDFUNC
	HIDDEN PROCEDURE ContentType_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.ContentType = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION ContentValue_Access
		RETURN THIS.ContentValue
	ENDFUNC
	HIDDEN PROCEDURE ContentValue_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.lValidCall = .F.
			THIS.ContentValue = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDPROC
	HIDDEN FUNCTION STATUS_Access
		RETURN THIS.STATUS
	ENDPROC
	HIDDEN FUNCTION STATUSTEXT_Access
		RETURN THIS.STATUSTEXT
	ENDPROC
	HIDDEN FUNCTION RESPONSETEXT_Access
		RETURN THIS.RESPONSETEXT
	ENDPROC
	HIDDEN FUNCTION READYSTATE_Access
		RETURN THIS.READYSTATE
	ENDPROC
	HIDDEN PROCEDURE STATUS_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.STATUS = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDFUNC
	HIDDEN PROCEDURE STATUSTEXT_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.STATUSTEXT = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDFUNC
	HIDDEN PROCEDURE RESPONSETEXT_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.RESPONSETEXT = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDFUNC
	HIDDEN PROCEDURE READYSTATE_Assign
		LPARAMETERS vNewVal
		IF THIS.lValidCall
			THIS.READYSTATE = m.vNewVal
		ELSE &&THIS.lValidCall
		ENDIF &&THIS.lValidCall
	ENDFUNC
ENDDEFINE
