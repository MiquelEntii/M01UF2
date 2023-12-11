#!/bin/bash

IP=`ip a | grep inet | grep np0s3 | cut -d " " -f 6 | cut -d "/" -f 1`
echo $IP

TIMEOUT=1
SERVER="localhost"
echo "Cliente de EFTP"

echo "(1) Send"
echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA

echo "(5) Test $ Send"

if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD HEADER"
	exit 1

fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER 3333

echo "(6) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA

echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then
	sleep 1
	echo "ERROR 3: BAD HANDSHAKE"
	exit 3
fi


echo "(9a) Send Num_Files"

NUM_FILES=`ls imgs/ | wc -l`


sleep 1
echo "NUM_FILES $NUM_FILES" | nc $SERVER 3333

echo "(9b) Listen OK/KO"

DATA=`nc -l -p 3333 -w $TIMEOUT`

if [ "$DATA" != "OK_FILE_NUM" ]
then
	echo "ERROR KO_FILE_NAME"
	exit 3
fi

echo "(10a) Loop Num"

for FILE_NAME in `ls imgs/`
do



echo "(10b) Send File Name"

#FILE_NAME="far1.txt"

MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`
NOMBRE="FILE_NAME $FILE_NAME $MD5"
sleep 1
echo "$NOMBRE" | nc $SERVER 3333

echo "(11) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA

echo "(14) Test&Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then
	echo "ERROR 4: BAD FILE NAME PREFIX"
	exit 4
fi

sleep 1
cat imgs/$FILE_NAME | nc $SERVER 3333

echo "(15) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`

if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 6: EMPTY DATA"
	exit 6
fi

echo "(18) Send"

HASH=`cat imgs/$FILE_NAME | md5sum | cut -d " " -f 1`


sleep 1
echo "FILE_MD5 $HASH" | nc $SERVER 3333

echo $HASH

echo "(19) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo "(21) Test"

if [ "$DATA" != "OK_HASH" ]
then
	echo "ERROR: BAD HASH"
	exit 5
fi

done

echo "FIN"
exit 0
