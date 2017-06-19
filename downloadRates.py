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

	statusMsg = 'SUCCESS - getting BTC/USD and USD/CHF rates at date {0} successful'

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
	statusMsg = statusMsg.format(transDateDDMMYYYY.replace('\n', ''))

	transDateComponents = transDateDDMMYYYY.split('.')
	transDateYYYY = int(transDateComponents[2])
	transDateMM = int(transDateComponents[1])
	transDateDD = int(transDateComponents[0])

	transDateObj = datetime.date(transDateYYYY, transDateMM, transDateDD)
	dateStart = transDateObj
	dateEnd = dateStart
	dataBtc = quandl.get(["BCHARTS/KRAKENUSD.4"], start_date=dateStart, end_date=dateEnd, returns="numpy")
	btcUsdClosePrice = dataBtc[0][1]

	usdTotalTransAmount = (btcTransactionAmount + btcFeesAmount) * btcUsdClosePrice

	cr = CurrencyRates()
	usdChfRate = cr.get_rate('USD', 'CHF', transDateObj)

	writeOutputParms(statusMsg, usdChfRate, usdTotalTransAmount)


def writeOutputParms(statusMsg, usdChfRate, usdTotalTransAmount):
	with open(OUTPUT_FILE_NAME, 'w') as f:
		f.write(statusMsg + "\n")
		f.write(str(usdTotalTransAmount) + "\n")
		f.write(str(usdChfRate) + "\n")


if __name__ == '__main__':
    getXRate()
