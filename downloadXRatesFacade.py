import common.downloadXRatesCommon as xr

def fetchXRates():
	return xr.getXRate()
'''
Facade file called by commence\VBScript\downl.bat, which is itself called by InOut.VBS.populateMontantUSDAndUSDCHFRate()
'''
if __name__ == '__main__':
	fetchXRates()