*---------------------------------------------------------------------------------------------------------------*
*
* @title:		Librer�a VFPRestClient
* @description:	Librer�a 100% desarrollada en Visual FoxPro 9.0 para la comunicaci�n via REST con servicios web.
*
* @version:		1.5 (beta)
* @author:		Irwin Rodr�guez
* @email:		rodriguez.irwin@gmail.com
* @license:		MIT
*
* -------------------------------------------------------------------------
* Version Log:
*
* Release 2019-04-09	v.1.5		- Control de excepci�n en m�todos Open y Send "Reportado por: Francisco ('informatica-apliges.com')"
*
* Release 2019-04-04	v.1.4		- Funci�n para detectar la conexi�n a internet.
*
* Release 2019-04-02	v.1.3		- Funci�n para escapar los caracteres especiales.
*
* Release 2019-03-30	v.1.2		- Liberaci�n formal en https://github.com/Irwin1985/VFPRestClient
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
		THIS.VERSION	= "1.5 (beta)"
		THIS.lValidCall = .T.
		THIS.LastUpdate	= "2019-04-09 14:17:51"
		THIS.lValidCall = .T.
		THIS.Author	= "Irwin Rodr�guez"
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

	PROCEDURE addRequest(tcVerb AS STRING, tcURL AS STRING) HELPSTRING "Carga una petici�n al objeto oRest."
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

	PROCEDURE addRequestBody(tcRequestBody AS STRING) "Agrega un contenido en formato JSON al cuerpo de la petici�n."
		IF EMPTY(tcRequestBody)
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("Invalid request format")
		ELSE &&EMPTY(tcRequestBody)
		ENDIF &&EMPTY(tcRequestBody)
*-- Add Body
		THIS.lValidCall 	= .T.
		THIS.requestBody 	= tcRequestBody
	ENDPROC

	FUNCTION SEND HELPSTRING "Env�a la petici�n al servidor"
*-- Validate Request Params
		LOCAL cMsg AS STRING, lError as boolean
		cMsg = ""
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
	
		TRY
			THIS.oXMLHTTP.OPEN(THIS.VERB, THIS.URL)
		CATCH TO oErr
			cMsg = ""
			IF TYPE("oErr.Message") = "C"
				cMsg = oErr.Message
			ELSE &&TYPE("oErr.Message") = "C"				
			ENDIF &&TYPE("oErr.Message") = "C"
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("error related with send method: " + cMsg)
			lError = .T.
		ENDTRY
		IF lError
			RETURN FALSE
		ELSE &&lError
		ENDIF &&lError

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

		IF !THIS.__isConnected()
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("there is not an active internet connection.")
			RETURN FALSE
		ELSE &&!THIS.__isConnected()
		ENDIF &&!THIS.__isConnected()
					
*-- Send the Request
		
		TRY
			THIS.oXMLHTTP.SEND(THIS.REQUESTBODY)
		CATCH TO oErr			
			cMsg = ""
			IF TYPE("oErr.Message") = "C"
				cMsg = oErr.Message
			ELSE &&TYPE("oErr.Message") = "C"				
			ENDIF &&TYPE("oErr.Message") = "C"
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("error related with send method: " + cMsg)
			lError = .T.
		ENDTRY
		IF lError
			RETURN FALSE
		ELSE &&lError
		ENDIF &&lError

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
*-- FUNCTION __isConnected
	HIDDEN FUNCTION __isConnected
		DECLARE INTEGER InternetGetConnectedState IN WinInet INTEGER @lpdwFlags, INTEGER dwReserved
		LOCAL lnFlags, lnReserved, lnSuccess
		lnFlags		= 0
		lnReserved	= 0
		lnSuccess	= InternetGetConnectedState(@lnFlags,lnReserved)
		CLEAR DLLS
		RETURN (lnSuccess=1)
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
	*-- PROCEDURE __clean_response
	HIDDEN PROCEDURE __clean_response
*-- Clean Response
		THIS.lValidCall 	= .T.
		THIS.RESPONSE 		= ""
		
		THIS.lValidCall 	= .T.
		THIS.STATUS			= 0

		THIS.lValidCall 	= .T.
		THIS.STATUSTEXT		= ""

		THIS.lValidCall 	= .T.
		THIS.RESPONSETEXT	= ""

		THIS.lValidCall 	= .T.
		THIS.READYSTATE		= 0		
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
		cText = STRTRAN(cText, "\u00a0", "�")
		cText = STRTRAN(cText, "\u00a1", "�")
		cText = STRTRAN(cText, "\u00a2", "�")
		cText = STRTRAN(cText, "\u00a3", "�")
		cText = STRTRAN(cText, "\u00a4", "�")
		cText = STRTRAN(cText, "\u00a5", "�")
		cText = STRTRAN(cText, "\u00a6", "�")
		cText = STRTRAN(cText, "\u00a7", "�")
		cText = STRTRAN(cText, "\u00a8", "�")
		cText = STRTRAN(cText, "\u00a9", "�")
		cText = STRTRAN(cText, "\u00aa", "�")
		cText = STRTRAN(cText, "\u00ab", "�")
		cText = STRTRAN(cText, "\u00ac", "�")
		cText = STRTRAN(cText, "\u00ae", "�")
		cText = STRTRAN(cText, "\u00af", "�")
		cText = STRTRAN(cText, "\u00b0", "�")
		cText = STRTRAN(cText, "\u00b1", "�")
		cText = STRTRAN(cText, "\u00b2", "�")
		cText = STRTRAN(cText, "\u00b3", "�")
		cText = STRTRAN(cText, "\u00b4", "�")
		cText = STRTRAN(cText, "\u00b5", "�")
		cText = STRTRAN(cText, "\u00b6", "�")
		cText = STRTRAN(cText, "\u00b7", "�")
		cText = STRTRAN(cText, "\u00b8", "�")
		cText = STRTRAN(cText, "\u00b9", "�")
		cText = STRTRAN(cText, "\u00ba", "�")
		cText = STRTRAN(cText, "\u00bb", "�")
		cText = STRTRAN(cText, "\u00bc", "�")
		cText = STRTRAN(cText, "\u00bd", "�")
		cText = STRTRAN(cText, "\u00be", "�")
		cText = STRTRAN(cText, "\u00bf", "�")
		cText = STRTRAN(cText, "\u00c0", "�")
		cText = STRTRAN(cText, "\u00c1", "�")
		cText = STRTRAN(cText, "\u00c2", "�")
		cText = STRTRAN(cText, "\u00c3", "�")
		cText = STRTRAN(cText, "\u00c4", "�")
		cText = STRTRAN(cText, "\u00c5", "�")
		cText = STRTRAN(cText, "\u00c6", "�")
		cText = STRTRAN(cText, "\u00c7", "�")
		cText = STRTRAN(cText, "\u00c8", "�")
		cText = STRTRAN(cText, "\u00c9", "�")
		cText = STRTRAN(cText, "\u00ca", "�")
		cText = STRTRAN(cText, "\u00cb", "�")
		cText = STRTRAN(cText, "\u00cc", "�")
		cText = STRTRAN(cText, "\u00cd", "�")
		cText = STRTRAN(cText, "\u00ce", "�")
		cText = STRTRAN(cText, "\u00cf", "�")
		cText = STRTRAN(cText, "\u00d0", "�")
		cText = STRTRAN(cText, "\u00d1", "�")
		cText = STRTRAN(cText, "\u00d2", "�")
		cText = STRTRAN(cText, "\u00d3", "�")
		cText = STRTRAN(cText, "\u00d4", "�")
		cText = STRTRAN(cText, "\u00d5", "�")
		cText = STRTRAN(cText, "\u00d6", "�")
		cText = STRTRAN(cText, "\u00d7", "�")
		cText = STRTRAN(cText, "\u00d8", "�")
		cText = STRTRAN(cText, "\u00d9", "�")
		cText = STRTRAN(cText, "\u00da", "�")
		cText = STRTRAN(cText, "\u00db", "�")
		cText = STRTRAN(cText, "\u00dc", "�")
		cText = STRTRAN(cText, "\u00dd", "�")
		cText = STRTRAN(cText, "\u00de", "�")
		cText = STRTRAN(cText, "\u00df", "�")
		cText = STRTRAN(cText, "\u00e0", "�")
		cText = STRTRAN(cText, "\u00e1", "�")
		cText = STRTRAN(cText, "\u00e2", "�")
		cText = STRTRAN(cText, "\u00e3", "�")
		cText = STRTRAN(cText, "\u00e4", "�")
		cText = STRTRAN(cText, "\u00e5", "�")
		cText = STRTRAN(cText, "\u00e6", "�")
		cText = STRTRAN(cText, "\u00e7", "�")
		cText = STRTRAN(cText, "\u00e8", "�")
		cText = STRTRAN(cText, "\u00e9", "�")
		cText = STRTRAN(cText, "\u00ea", "�")
		cText = STRTRAN(cText, "\u00eb", "�")
		cText = STRTRAN(cText, "\u00ec", "�")
		cText = STRTRAN(cText, "\u00ed", "�")
		cText = STRTRAN(cText, "\u00ee", "�")
		cText = STRTRAN(cText, "\u00ef", "�")
		cText = STRTRAN(cText, "\u00f0", "�")
		cText = STRTRAN(cText, "\u00f1", "�")
		cText = STRTRAN(cText, "\u00f2", "�")
		cText = STRTRAN(cText, "\u00f3", "�")
		cText = STRTRAN(cText, "\u00f4", "�")
		cText = STRTRAN(cText, "\u00f5", "�")
		cText = STRTRAN(cText, "\u00f6", "�")
		cText = STRTRAN(cText, "\u00f7", "�")
		cText = STRTRAN(cText, "\u00f8", "�")
		cText = STRTRAN(cText, "\u00f9", "�")
		cText = STRTRAN(cText, "\u00fa", "�")
		cText = STRTRAN(cText, "\u00fb", "�")
		cText = STRTRAN(cText, "\u00fc", "�")
		cText = STRTRAN(cText, "\u00fd", "�")
		cText = STRTRAN(cText, "\u00fe", "�")
		cText = STRTRAN(cText, "\u00ff", "�")
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
