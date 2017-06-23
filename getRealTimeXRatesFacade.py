import common.downloadXRatesCommon as xr

def fetchRealTimeXRates():
	return xr.populateRealTimeXRate()
'''
Facade file called by commence\VBScript\getRealTimeXRates.bat, which is itself called by InOut.VBS.Form_OnClick()
'''
if __name__ == '__main__':
	fetchRealTimeXRates()