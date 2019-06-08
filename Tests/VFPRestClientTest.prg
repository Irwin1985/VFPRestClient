*====================================================================
* VFPRestClient Unit Test
*====================================================================
Define Class VFPRestClientTest As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As VFPRestClientTest Of VFPRestClientTest.prg
	#Endif

	icTestPrefix = "test"
	Procedure Setup
		Public VFPRest
		VFPRest = Newobject("Rest", "VFPRestClient.prg")

*====================================================================
	Procedure TearDown
		Release VFPRest

*====================================================================
	Procedure test_shoul_create_the_object
		This.AssertNotNull(VFPRest, "VFPRest was not created")

*====================================================================
	Procedure test_should_send_a_get_request_and_return_json
		VFPRest.AddRequest("GET", "https://swapi.co/api/planets/1/")
		This.AssertTrue(Empty(VFPRest.LastErrorText), "LastErrorText: " + VFPRest.LastErrorText)
		VFPRest.Send()
		This.MessageOut("VFPRest.ResponseText: " + VFPRest.ResponseText)
Enddefine
