import quandl, sys


def getXRate():
	quandl.ApiConfig.api_key = "TzTJNAxsD45RySvjBduE"

	#getting input parms
	with open("c:/temp/input.txt", 'r') as f:
		dateStart = f.read()

	dateEnd = dateStart
	dataBtc = quandl.get(["BCHARTS/KRAKENUSD.4"], start_date=dateStart, end_date=dateEnd, returns="numpy")
	closePrice = dataBtc[0][1]

	#writting output parms
	with open("c:/temp/output.txt", 'w') as f:
		f.write(str(closePrice))

if __name__ == '__main__':
    getXRate()
