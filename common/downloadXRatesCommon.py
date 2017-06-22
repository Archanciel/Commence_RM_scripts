import quandl
from forex_python.converter import CurrencyRates
import datetime
import sys

#oMontantUSD)
#	si date exec == today
#		use cours temps réel
#	sinon get cours histo

INPUT_PARMS_FILE_PATH = "c:/temp/input.txt"
OUTPUT_FILE_NAME = "c:/temp/output.txt"

def getXRate():
	quandl.ApiConfig.api_key = "TzTJNAxsD45RySvjBduE"

	statusMsg = 'SUCCESS - getting BTC/USD ({0}) and USD/CHF ({1}) rates at date {2} successful !'

	#getting input parms, i.e transactionDate, btcTransactionAmount, btcFeesAmount
	with open(INPUT_PARMS_FILE_PATH, 'r') as f:
		lines = f.readlines()

		if len(lines) != 3 or any(e == '\n' for e in lines):
			statusMsg = "ERROR - input parms file {0} does not contain expected values".format(INPUT_PARMS_FILE_PATH)
			writeOutputParms(statusMsg, '0', '0')
			sys.exit(1)

	transDateDDMMYYYY = lines[0]
	btcTransactionAmount = float(lines[1])
	btcFeesAmount = float(lines[2])

	transDateComponents = transDateDDMMYYYY.split('.')
	transDateYYYY = int(transDateComponents[2])
	transDateMM = int(transDateComponents[1])
	transDateDD = int(transDateComponents[0])

	transDateObj = datetime.date(transDateYYYY, transDateMM, transDateDD)

	if transDateObj == datetime.date.today():
		#getting realtime rates
		btcUsdPrice = getRealTimeXRates('BTC','USD')
		usdChfRate = getRealTimeXRates('USD','CHF')
	else:
		# getting historical rates
		btcUsdPrice, usdChfRate = getHistoricalXRatesForDate(transDateObj)

	usdTotalTransAmount = (btcTransactionAmount + btcFeesAmount) * btcUsdPrice

	statusMsg = statusMsg.format(btcUsdPrice, usdChfRate, clearEOL(transDateDDMMYYYY))

	writeOutputParms(statusMsg, usdChfRate, usdTotalTransAmount)

	return statusMsg, usdChfRate, usdTotalTransAmount   #for testing purposes


def getHistoricalXRatesForDate(dateObj):
	dateStart = dateObj
	dateEnd = dateStart
	dataBtc = quandl.get(["BCHARTS/KRAKENUSD.4"], start_date=dateStart, end_date=dateEnd, returns="numpy")
	if dataBtc.size > 0:
		btcUsdClosePrice = dataBtc[0][1]
	else:
		statusMsg = "ERROR - BTC/USD close price not found for date {0} !".format(dateStart)
		writeOutputParms(statusMsg, '0', '0')
		sys.exit(1)

	cr = CurrencyRates()
	usdChfRate = cr.get_rate('USD', 'CHF', dateObj)

	return float(btcUsdClosePrice), float(usdChfRate)


def clearEOL(line):
	return line.replace('\n', '')


def writeOutputParms(statusMsg, usdChfRate, usdTotalTransAmount):
	with open(OUTPUT_FILE_NAME, 'w') as f:
		f.write(statusMsg + "\n")
		f.write(str(usdTotalTransAmount) + "\n")
		f.write(str(usdChfRate) + "\n")


from bs4 import BeautifulSoup
from urllib.request import Request, urlopen

def getRealTimeXRates(baseCur, targetCur):
    '''
    Scrap the bitcoin rate in the passed currency
    Usage: getBTCRate("CHF"), getBTCRate("USD")
    :return: bitcoin rate in USD
    '''

    url = "http://markets.businessinsider.com/currencies/realtime-chart/" + baseCur.lower() + '-' + targetCur.lower()
    #req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    req = Request(url)
    page = urlopen(req).read()
    soup = BeautifulSoup(page,"lxml")
    # print(soup.prettify())
    rateStr = soup.find("span",{'class':'push-data price'}).string
    rateStr = cleanRate(rateStr)
    return float(rateStr)


def cleanRate(rateStr):
    '''
    remove thousands divider from passed
    rate string and return cleaned string
    '''
    return rateStr.replace(',','')


if __name__ == '__main__':
	statusMsg, usdChfRate, usdTotalTransAmount = getXRate()
	print("status msg: {0}".format(statusMsg))
	print("USD/CHF hist rate: {0}".format(usdChfRate))
	print("USD total trans amount: {0}".format(usdTotalTransAmount) + '\n')

	baseCur = 'BTC'
	targetCur = 'USD'
	print(baseCur + '/' + targetCur + ': ' + str(getRealTimeXRates(baseCur,targetCur)))

	baseCur = 'BTC'
	targetCur = 'CHF'
	print(baseCur + '/' + targetCur + ': ' + str(getRealTimeXRates(baseCur,targetCur)))

	baseCur = 'USD'
	targetCur = 'CHF'
	print(baseCur + '/' + targetCur + ': ' + str(getRealTimeXRates(baseCur,targetCur)))
