#!/bin/bash

PORT="3333"
CLIENT=`ip a | grep inet | grep np0s3 | cut -d " " -f 6 | cut -d "/" -f 1`
TIMEOUT=1
echo "Servidor de EFTP"

echo "(0) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`
echo $DATA

echo "(3) Test & Send"

if [ "$DATA" != "EFTP 1.0" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT 3333
	exit 1
fi

echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT 3333

echo "(4) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA

echo "(7) Test & Send"
if [ "$DATA" != "BOOOM" ]
then echo "ERROR 2: BAD HANDSHAKE"
sleep 1
echo "KO_HANDSHAKE" | nc $CLIENT 3333
exit 2
fi

echo "OK_HANDSHAKE"
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT 3333


echo "(7a) Listen Num_Files"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA


echo "(7b) Send OK/KO"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "NUM_FILES" ]
then
	echo "ERROR: WRONG PREFIX"
	sleep 1
	echo "KO_FILE_NUM" | nc $CLIENT 3333
	exit 5
fi

sleep 1
echo nc $CLIENT 3333
echo "OK_FILE_NUM" | nc $CLIENT 3333

FILE_NUM=`echo $DATA | cut -d " " -f 2`


echo "(8a) Loop Num"


for N in `seq $FILE_NUM`
do

echo "Archivo numero $N"



echo "(8b) Listein File Name"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA


echo "(12) Test & Store & Send"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_NAME" ]
then	
	echo "ERROR 3: WRONG FILE NAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
fi

sleep 1
echo "OK_FILE_NAME" | nc $CLIENT 3333

FILE_NAME=`echo $DATA | cut -d " " -f 2`

MD5=`echo $FILE_NAME | md5sum`
MD5=`echo $MD5 | cut -d " " -f 1`
MD5C=`echo $DATA | cut -d " " -f 3`

echo $MD5
echo $MD5C


if [ "$MD5" != "$MD5C" ]
then
	echo "ERROR 5: Archivo corrupto"
	sleep 1
	echo "Archivo corrupto" | nc $CLIENT 3333
	exit 5
fi


echo "(13) Listen"

`nc -l -p 3333 -w $TIMEOUT > inbox/$FILE_NAME`

echo "(16)Store & Send"

echo cat inbox/$FILE_NAME
DATA=`cat inbox/$FILE_NAME`
if [ "$DATA"  == "" ]
then
	echo "ERROR 5: ARCHIVO VACIO"
	sleep 1
	echo "KO_DATA" | nc $CLIENT 3333
	exit 5
fi


sleep 1
echo "OK_DATA" | nc $CLIENT 3333

echo "(17) Listen"

DATAPREF=`nc -l -p 3333 -w $TIMEOUT | cut -d " " -f 1`
HASH=`nc -l -p 3333 -w $TIMEOUT | cut -d " " -f 2`

echo $DATA 

echo "(20) Test&Send"

if [ "$DATAPREF" != "FILE_MD5" ]
then
	echo "ERROR 6: BAD PREFIX"
	sleep 1
	echo "KO_PREFIX" | nc $CLIENT 3333
	exit 5
fi

HASH1=`cat inbox/$FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$HASH" != "$HASH1" ]
then
	echo "ERROR 7: WRONG HASH"
	sleep 1
	echo "KO_HASH" | nc $CLIENT 3333
	exit 7
fi

echo "OK_HASH" | nc $CLIENT 3333


done

exit 
