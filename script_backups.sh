#!/bin/bash
USER="admin_user"
PASS="erick"
BASE="musicdb_test"
DIR="/home/erick/uasb_DBA-master"
FECHA=`date +%d-%m-%Y`

echo "Hora del backup: `date +%H:%M:%S`" >> $DIR/musicdb_test[$FECHA].log

ESPACIO_OCUPADO=`df /$DIR | awk '{print $5}' | grep -a %
ESPACIO_OCUPADO=`expr match “$ESPACIO_OCUPADO” '\([0-9]*[0-9]\)'`

if [ $ESPACIO_OCUPADO -le 85 ];
then
	for BASE in $BASE
do
	pg_dump -i -h localhost -p 5432 -U postgres -F p -b -v -f "musicdb_test_$indice[$FECHA].sql" musicdb;
	((indice++))
done

indice=1
for indice in 1 2
do
	tar -czvf $DIR/musicdb_test_$indice[$FECHA].sql.tar.gz $DIR/musicdb_test_$indice[$FECHA].sql >> $DIR/musicdb_test[$FECHA].log
done

for indice in 1 2
do
	if [ -f $DIR/musicdb_test_$indice[$FECHA].sql ]; #comprobamos si se efectuó el backup
	then
		if [ -f $DIR/musicdb_test_$indice[$FECHA].sql.tar.gz ]; #comprobamos si se comprimió.
		then
			find $DIR/musicdb_test* -mtime +15 -exec rm -r -f {} \;
		else
			echo "La compresión del backup realizado el $FECHA no se ha podido llevar a cabo, por algún problema. Se mantiene almacenado la compresión del backup anterior" >> $DIR/musicdb_test[$FECHA].log
	fi
	else
		echo "El backup del día $FECHA no se ha podido llevar a cabo, por algún problema. Se
mantiene almacenado el backup anterior" >> $DIR/musicdb_test[$FECHA].log
	fi
done
echo "Hora de finalización del backup: `date +%H:%M:%S`" >> $DIR/base_datos[$FECHA].log
