set title 'Monitoramento de 8.8.8.8'
set xlabel 'timestamp'
set ylabel 'ping rtt \n(0=infinito)'
set timefmt '%s'
set xdata time
set format x '%H:%M:%S'
#set style fill solid

set grid
plot 'data.dat' using ($1 - 3*60*60):2:(1) t 'rtt' with boxes
