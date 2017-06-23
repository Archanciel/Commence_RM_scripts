import common.downloadXRatesCommon as xr

def fetchXRates():
	return xr.populateXRate()
'''
Facade file called by commence\VBScript\getXRates.bat, which is itself called by InOut.VBS.populateMontantUSDAndUSDCHFRate()
'''
if __name__ == '__main__':
	fetchXRates()