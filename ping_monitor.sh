PINGID_FILE=".pingmonitorid"
ADDRESS="8.8.8.8"
RAWDATA="monitor.dat"
PLOT_FILE="plot.plt"
PLOT_DATA="data.dat"
SVG_OUT="monitor.svg"

# Se houver um rodando, matamos:
if [ -e "$PINGID_FILE" ] ; then
	PINGID=`cat $PINGID_FILE`

	# confirmamos que este ID refere-se ao processo ping:
	CONFIRM=`ps -a | grep '$PINGID.*ping'`
	if [ "$CONFIRM" != "" ] ; then
		# Ok, matamos ele 
		kill -s SIGKILL 'cat $PINGID_FILE'
	fi
fi

# Iniciamos o ping:
ping -D -n -W 1 -i 10 -O "$ADDRESS" >> $RAWDATA &
echo $! > $PINGID_FILE

# Criamos o HTML de monitoramento:
echo "<!DOCTYPE html> <html> <head> <title>Monitoramento de conexão com $ADDRESS</title> <meta charset='UTF-8' /> <meta http-equiv='refresh' content='10'></head><body><img src='monitor.svg'/></body></html>" > monitor.html

# Criamos o arquivo do gnuplot:
echo "set terminal svg size 1280,720 fname 'Verdana' fsize 10" > $PLOT_FILE
echo "set output '$SVG_OUT'" >> $PLOT_FILE
echo "set title 'Monitoramento de 8.8.8.8'" >> $PLOT_FILE
echo "set style fill solid" >> $PLOT_FILE
echo "set xlabel 'timestamp'" >> $PLOT_FILE
echo "set ylabel 'ping rtt \\n(-10=infinito)'" >> $PLOT_FILE
echo "set timefmt '%s'" >> $PLOT_FILE
echo "set xdata time" >> $PLOT_FILE
echo "set format x '%H:%M:%S'" >> $PLOT_FILE
echo "set grid" >> $PLOT_FILE
echo "set yrange [-1:20]" >> $PLOT_FILE
#echo "set xrange [1471440261:]" >> $PLOT_FILE
echo "plot 'data.dat' using (\$1 - 3*60*60):2:(1) t 'rtt' with boxes" >> $PLOT_FILE

# Iniciamos o loop de coleta e render:
while true
do
	tail -n 400 $RAWDATA | sed -r 's/\[([0-9]+)\.[0-9]+\] no answer.*/\1\t-10/' | sed -r 's/\[([0-9]+)\.[0-9]+\] 64 bytes.*time=(.*) ms/\1\t\2/' | sed -r 's/PING .* bytes of data.$//' | grep -E "^[0-9]+\s-?[0-9]+(?:\.[0-9])?" > $PLOT_DATA && gnuplot $PLOT_FILE
	sleep 10
done
