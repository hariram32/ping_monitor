set terminal svg size 1280,720 fname 'Verdana' fsize 10
set output 'monitor.svg'
set title 'Monitoramento de 8.8.8.8'
set style fill solid
set xlabel 'timestamp'
set ylabel 'ping rtt \n(-10=infinito)'
set timefmt '%s'
set xdata time
set format x '%H:%M:%S'
set grid
set yrange [-1:20]
plot 'data.dat' using ($1 - 3*60*60):2:(1) t 'rtt' with boxes
