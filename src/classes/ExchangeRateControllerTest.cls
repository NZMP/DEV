@isTest
private class ExchangeRateControllerTest {
	
	@isTest static void ExchangeRateController() {
		ExchangeRateController.allCurrencies();

        String responseJSON = ExchangeRateController.getExchangeData('USDPH');
        system.assert(responseJSON != null);


	}
	
}