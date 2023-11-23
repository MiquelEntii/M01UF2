#!/bin/bash

IP=`ip a | grep inet | grep np0s3 | cut -d " " -f 6 | cut -d "/" -f 1`
echo $IP

SERVER="localhost"
echo "Cliente de EFTP"

echo "(1) Send"
echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"

DATA=`nc -l -p 3333 -w -0`

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

DATA=`nc -l -p 3333 -w 0`

echo $DATA

echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then
	sleep 1
	echo "ERROR 3: BAD HANDSHAKE"
	exit 3
fi

echo "(10) Send"

sleep 1
echo "FILE_NAME fary1.txt" | nc $SERVER 3333

echo "(11) Listen"
DATA=`nc -l -p 3333 -w 0`

echo $DATA

echo "(14) Test$Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then
	echo "ERROR 4: BAD FILE NAME PREFIX"
	exit 4
fi

sleep 1
cat imgs/fary1.txt | nc $SERVER 3333

echo "(15) Listen"

DATA=`nc -l -p 3333 -w 0`

if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 6: EMPTY DATA"
	exit 6
fi

echo "FIN"
exit 0

