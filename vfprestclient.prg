*---------------------------------------------------------------------------------------------------------------*
*
* @title:		Librería VFPRestClient
* @description:	Librería 100% desarrollada en Visual FoxPro 9.0 para la comunicación via REST con servicios web.
*
* @version:		1.2 (beta)
* @author:		Irwin Rodríguez
* @email:		rodriguez.irwin@gmail.com
* @license:		MIT
*
*---------------------------------------------------------------------------------------------------------------*
DEFINE CLASS Rest AS CUSTOM
	HIDDEN lValidCall
	HIDDEN oXMLHTTP

*-- Request Properties
	HIDDEN Verb
	HIDDEN URL
	HIDDEN requestBody	
	HIDDEN ContentType
	HIDDEN ContentValue

	VERSION			= ""
	LastUpdate		= ""
	Author			= ""
	Email			= ""
	LastErrorText 		= ""
	CONTENT_TYPE		= "Content-Type"
	APPICATION_JSON		= "application/json"
	Response		= ""
	
	*-- Verb List
	GET			= "GET"
	POST			= "POST"
	PUT			= "PUT"
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
	ConnectTimeOut	= 60	&& The value is applied for establishing a communication socket with the target server.
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
		THIS.VERSION	= "1.2 (beta)"
		THIS.lValidCall = .T.
		THIS.LastUpdate	= "30/03/2019 18:18:54"
		THIS.lValidCall = .T.
		THIS.Author	= "Irwin Rodríguez"
		THIS.lValidCall = .T.
		THIS.Email	= "rodriguez.irwin@gmail.com"
		THIS.__clean_request()
		THIS.oXMLHTTP	= .NULL.
	ENDPROC

	HIDDEN PROCEDURE __create_object
		LOCAL lCreated as boolean
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
		THIS.Verb = tcVerb
		
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

	FUNCTION Send HELPSTRING "Envía la petición al servidor"
*-- Validate Request Params
		LOCAL cMsg as string, bSuccess as boolean
		cMsg 		= ""
		bSuccess 	= .T.

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

		IF THIS.ResolveTimeOut > 0 .AND. THIS.ConnectTimeOut > 0 .AND. THIS.SendTimeOut > 0 .AND. THIS.ReceiveTimeOut > 0
			THIS.ResolveTimeOut		= THIS.ResolveTimeOut 	* 1000
			THIS.ConnectTimeOut		= THIS.ConnectTimeOut	* 1000
			THIS.SendTimeOut		= THIS.SendTimeOut		* 1000
			THIS.receiveTimeOut		= THIS.receiveTimeOut	* 1000
			
			THIS.oXMLHTTP.setTimeouts(THIS.ResolveTimeOut, THIS.ConnectTimeOut, THIS.SendTimeOut, THIS.ReceiveTimeOut)
		ELSE &&THIS.ResolveTimeOut > 0 .AND. THIS.ConnectTimeOut > 0 .AND. THIS.SendTimeOut > 0 .AND. THIS.receiveTimeOut > 0
		ENDIF &&THIS.ResolveTimeOut > 0 .AND. THIS.ConnectTimeOut > 0 .AND. THIS.SendTimeOut > 0 .AND. THIS.receiveTimeOut > 0
		
		THIS.oXMLHTTP.OPEN(THIS.Verb, THIS.URL)
		
		IF THIS.oXMLHTTP.ReadyState <> HTTP_OPEN
			THIS.lValidCall = .T.
			THIS.__setLastErrorText("could not open the communication socket.")
			RETURN FALSE
		ELSE &&THIS.oXMLHTTP.ReadyState <> HTTP_OPEN
		ENDIF &&THIS.oXMLHTTP.ReadyState <> HTTP_OPEN
			
		IF NOT EMPTY(THIS.ContentType) .AND. NOT EMPTY(THIS.ContentValue)
			THIS.oXMLHTTP.setRequestHeader(THIS.ContentType, THIS.ContentValue)
		ELSE &&NOT EMPTY(THIS.ContentType) .AND. NOT EMPTY(THIS.ContentValue)
		ENDIF &&NOT EMPTY(THIS.ContentType) .AND. NOT EMPTY(THIS.ContentValue)
		
		*-- Loops until readyState change or timeouts dies.
		IF EMPTY(THIS.waitTimeOut)
			THIS.waitTimeOut = 5
		ELSE &&EMPTY(THIS.waitTimeOut)
		ENDIF &&EMPTY(THIS.waitTimeOut)
			
		nSeg = SECONDS() + THIS.waitTimeOut
		DO WHILE SECONDS() <= nSeg
			IF THIS.oXMLHTTP.readyState <> HTTP_OPEN
				EXIT && There's an answer.
			ELSE &&THIS.oXMLHTTP.readyState <> HTTP_OPEN
			ENDIF &&THIS.oXMLHTTP.readyState <> HTTP_OPEN
		ENDDO &&WHILE SECONDS() <= nSeg
		
		IF THIS.oXMLHTTP.ReadyState == HTTP_COMPLETED .AND. THIS.oXMLHTTP.Status == HTTP_STATUS_OK
			THIS.lValidCall = .T.			
			THIS.Response 	= THIS.oXMLHTTP.ResponseText
		ELSE &&THIS.oXMLHTTP.ReadyState == HTTP_COMPLETED .AND. THIS.oXMLHTTP.Status == HTTP_STATUS_OK
			bSuccess 				= .F.
			THIS.lValidCall 		= .T.
			THIS.__setLastErrorText("error: could not receive any data. The servers says: " + THIS.oXMLHTTP.ResponseText)
			THIS.__clean_response()			
		ENDIF &&THIS.oXMLHTTP.ReadyState == HTTP_COMPLETED .AND. THIS.oXMLHTTP.Status == HTTP_STATUS_OK
		
		THIS.oXMLHTTP = .NULL.
		RETURN bSuccess
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
		THIS.Response 			= ""
	ENDPROC
	
	HIDDEN PROCEDURE __clean_request
		*-- Clean Response
		THIS.lValidCall 	= .T.
		THIS.Response 		= ""

		*-- Clean Verb
		THIS.lValidCall 	= .T.
		THIS.Verb 			= ""

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
		THIS.RequestBody 	= ""

	ENDPROC

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
		RETURN THIS.Response
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
			THIS.Response = m.vNewVal
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
ENDDEFINE
