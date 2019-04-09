# VFPRestClient ![](images/prg.gif)  

**VFPRestClient** is a simple **Microsoft XMLHTTP Object Wrapper** for communicating client requests with remote web services like API Rest.

**NOTE: you can combine this wrapper with [JSONFox](https://github.com/Irwin1985/JSONFox) to complete the REST Client communications** 
### Project Manager

**Irwin Rodríguez** (Toledo, Spain)

### Latest Release

**[VFPRestClient](/README.md)** - v.1.5 (beta) - Release 2019-04-09 14:17:51

<hr>

## Properties
* ![](images/prop.gif) **LastErrorText:** Stores the possible error generated in the current sentence.
* ![](images/prop.gif) **Response:** Stores the same content of **ResponseText** property.
* ![](images/prop.gif) **ResponseText:** Server's response. Inherited property from **XMLHTTP Object**.
* ![](images/prop.gif) **Status:** holds the HTTP Status Code. Inherited property from **XMLHTTP Object**.
* ![](images/prop.gif) **StatusText:** holds the HTTP Status Text. Inherited property from **XMLHTTP Object**.
* ![](images/prop.gif) **ReadyState:** current object state. Inherited property from **XMLHTTP Object**.

## Methods

* ![](images/meth.gif) **addRequest(tcVerb AS STRING, tcURL AS STRING):** Adds a new Request.
  * **tcVerb:** Method used in request. You can use internal verb attributes as enum. eg. **(loRest.GET, loRest.PUT, loRest.POST, etc)**
  * **tcURL:** Remote server URL.
  
* ![](images/meth.gif) **addHeader(tcHeader AS STRING, tcValue AS STRING):** Adds a header to the request.
  * **tcHeader:** header type. You can use internal attribute as ENUM. eg. **loRest.CONTENT_TYPE**
  * **tcValue:** MIME type. You can use internal attribute as ENUM. eg. **loRest.APPLICATION_JSON**
  
* ![](images/meth.gif) **addRequestBody(tcRequestBody AS STRING):** Adds some data in Request Body **optional**.
  * **tcRequestBody:** request body (any data).

* ![](images/meth.gif) **Send():** Send the request and **RETURNS** boolean.
  * **Response attribute:** either true or false. You can check the **response** property to see the server response.

* ![](images/meth.gif) **Encode(vNewProp as variant):** Encode a JSON object into string.
  * **vNewProp:** represents any value type.
  
### Examples

<pre>
 * Create Object
 SET PROCEDURE TO "VFPRestClient.prg" ADDITIVE
 loREST = NEWOBJECT("Rest", "VFPRestClient.prg")
 
 * Get planet with ID 1 from https://swapi.co
 loRest.addRequest(loRest.GET, "https://swapi.co/api/planets/1/")
 
 * Don't forget check the LastErrorText
 IF !EMPTY(loRest.LastErrorText) 
 	MESSAGEBOX(loRest.LastErrorText, 0+48, "Something went wrong")
	RELEASE loRest
	RETURN
 ELSE &&!EMPTY(loRest.LastErrorText)
 ENDIF &&!EMPTY(loRest.LastErrorText)
 
 * Send the request
 IF loRest.Send()
 	MESSAGEBOX(loRest.Response, 64, "Success")
 ELSE &&loRest.Send()
 	MESSAGEBOX(loRest.Response, 48, "Something went wrong")
 ENDIF &&loRest.Send()
 
RELEASE loRest
</pre>
