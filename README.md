# VFPRestClient ![](images/prg.gif)  

## VFPRestClient es una clase que permite realizar peticiones HTTP a un servidor REST y obtener su respuesta. Internamente utiliza una instancia de uno de los siguientes componentes ActiveX: 

1. WinHttp.WinHttpRequest.5.1
2. MSXML2.ServerXMLHTTP.6.0
3. MSXML2.ServerXMLHTTP
4. Microsoft.XMLHTTP


Si te gusta mi trabajo puedes apoyarme con un donativo:   
[![DONATE!](http://www.pngall.com/wp-content/uploads/2016/05/PayPal-Donate-Button-PNG-File-180x100.png)](https://www.paypal.com/donate/?hosted_button_id=LXQYXFP77AD2G) 

Gracias por tu apoyo!

**NOTA: puedes combinar esta clase con [JSONFox](https://github.com/Irwin1985/JSONFox) para convertir la respuesta del servidor en un objeto JSON.**

### Project Manager

**Irwin Rodríguez** (Toledo, Spain)

### Collaborators

- Gaston Alberto Cardenas Chicangana
- Jairo Cedeño Adrian


### Historial de versiones

**[VFPRestClient](/README.md)** - v.1.5 (beta) - Release 2019-04-09 14:17:51

**Release Version** - v.1.6 - Release 2023-06-11 12:26

<hr>

## Propiedades
* ![](images/prop.gif) **LastErrorText:** Almacena el último error ocurrido en la clase.
* ![](images/prop.gif) **Response:** Almacena el mismo contenido que **ResponseText**.
* ![](images/prop.gif) **ResponseText:** Almacena el contenido de la respuesta del servidor en formato texto.
* ![](images/prop.gif) **Status:** Almacena el código de estado HTTP. Heredado de **XMLHTTP Object**.
* ![](images/prop.gif) **StatusText:** Almacena el texto de estado HTTP. Heredado de **XMLHTTP Object**.
* ![](images/prop.gif) **ReadyState:** Almacena el estado de la petición. Heredado de **XMLHTTP Object**.

## Métodos

* ![](images/meth.gif) **addRequest(tcVerb AS STRING, tcURL AS STRING, tbSyncMode):** Agrega una petición al objeto. El listado de parámetros es el siguiente:

- **tcVerb:** verbo HTTP. Puedes usar atributos internos como ENUM. Ejemplo: **loRest.GET**
- **tcURL:** URL del servidor. Ejemplo: **https://jsonplaceholder.typicode.com/todos**
- **tbSyncMode:** modo de sincronización.
  
* ![](images/meth.gif) **addHeader(tcHeader AS STRING, tcValue AS STRING):** Agrega una cabecera a la petición. El listado de parámetros es el siguiente:

- **tcHeader:** nombre de la cabecera. Ejemplo: **Content-Type**
- **tcValue:** valor de la cabecera. Ejemplo: **application/json**
  
* ![](images/meth.gif) **addRequestBody(tcRequestBody AS STRING):** Agrega el cuerpo de la petición. El listado de parámetros es el siguiente:

- **tcRequestBody:** cuerpo de la petición. Ejemplo: **{"name":"Irwin","age":37}**

* ![](images/meth.gif) **Send():** Envía la petición al servidor. Devuelve un valor lógico. **True** si la petición se ha enviado correctamente, **False** en caso contrario.

  
### Ejemplo de uso

```xBase
* Cargar el PRG en memoria
Set Procedure To "VFPRestClient.prg" Additive
local loRest
loRest = CreateObject("Rest")
 
* Agregar una petición
loRest.AddRequest(loRest.GET, "https://jsonplaceholder.typicode.com/todos")
 
* Verificar si hay errores
If !Empty(loRest.LastErrorText) 
  ?loRest.LastErrorText, "Error"
  Release loRest
  Return
EndIf

* Enviar información por cabecera
loRest.AddHeader("Content-Type", "application/json")

* Enviar la petición
If loRest.Send()
    ?loRest.Response, "OK"
Else
    ?loRest.Response, "Error"
EndIf

Release loRest
```