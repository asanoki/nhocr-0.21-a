#!/bin/sh

NHOCR_DICCODES=font-1:font-2:font-3:font-4
NHOCR_DICDIR=../dic
NHOCR_GRAMDPORTFILE=/tmp/.gramd

#FONT=/usr/share/tuxpaint/fonts/locale/ja.ttf
FONT=fonts/kiloji/kiloji.ttf
DISTORTION=0.0
SIZE=24

# DO NOT MODIFY BELOW

export NHOCR_DICCODES
export NHOCR_DICDIR
export NHOCR_GRAMDPORTFILE

N=0
mkdir ./big-test-data 2> /dev/null
mkdir ./big-test-results-without 2> /dev/null
mkdir ./big-test-results-with 2> /dev/null

echo "Generating input images..."

time for LINE in `cat small-test.txt`
do
    N=`expr $N + 1`
    echo $LINE > big-test-data/gen-$N.pgm.txt
    convert -background white -fill black \
    -font $FONT -pointsize $SIZE label:@big-test-data/gen-$N.pgm.txt \
    -distort Barrel "0.0 0.0 0.0 1.0   0.0 0.0 $DISTORTION 1.0" \
    -depth 8 -normalize \
     big-test-data/gen-$N.pgm
done

echo "Evaluationg nhocr performance *without* language post-processing"
time for FILE in ./big-test-data/*.pgm
do
    BASENAME=`basename $FILE`
    echo $FILE
    ../nhocr/nhocr -line -o - $FILE > ./big-test-results-without/$BASENAME.txt
done

echo "Calculating score..."
SCORE_SUM=0;
TOTAL_SUM=0;
time for FILE in ./big-test-results-without/*.txt
do
    BASENAME=`basename $FILE`
    VALUE=`./big-test-dist.sub dist big-test-results-without/$BASENAME big-test-data/$BASENAME`
    VALUE2=`./big-test-dist.sub len big-test-results-without/$BASENAME big-test-data/$BASENAME`
    SCORE_SUM=`expr $SCORE_SUM + $VALUE`
    TOTAL_SUM=`expr $TOTAL_SUM + $VALUE2`
done
ACCURACY=`echo "scale=2; ($TOTAL_SUM - $SCORE_SUM) * 100 / $TOTAL_SUM" | bc`
echo "Accuracy: $ACCURACY"

echo "Evaluationg nhocr performance *with* language post-processing"
time for FILE in ./big-test-data/*.pgm
do
    BASENAME=`basename $FILE`
    echo $FILE
    ../nhocr/nhocr -line -o - -gramd $FILE > ./big-test-results-with/$BASENAME.txt
done

echo "Calculating score..."
SCORE_SUM=0;
TOTAL_SUM=0;
time for FILE in ./big-test-results-with/*.txt
do
    BASENAME=`basename $FILE`
    VALUE=`./big-test-dist.sub dist big-test-results-with/$BASENAME big-test-data/$BASENAME`
    VALUE2=`./big-test-dist.sub len big-test-results-with/$BASENAME big-test-data/$BASENAME`
    SCORE_SUM=`expr $SCORE_SUM + $VALUE`
    TOTAL_SUM=`expr $TOTAL_SUM + $VALUE2`
done
ACCURACY=`echo "scale=2; ($TOTAL_SUM - $SCORE_SUM) * 100 / $TOTAL_SUM" | bc`
echo "Accuracy: $ACCURACY"
