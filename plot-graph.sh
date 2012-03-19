#!/bin/bash

# aditional data processing commands here.
width="1024"
high="768"
outfile="graph.jpg"
file="./data.dat"
format="jpeg"

NO_ARGS=0
E_OPTERROR=65

if [ $# -eq "$NO_ARGS" ]  # Сценарий вызван без аргументов?
then
  echo "Скрипт запущен без параметров!
	 Для правильной работы используйте параметры:
	-o	Указывает имя файла графика (по умолчанию \"graph.jpg\")
	-f	Указывает формат файла графика (по умолчанию \"jpeg\")
	-i	Местоположение файла с данными (по умолчанию \"data\")
	-w	Ширина файла (по умолчанию \"1024\")
	-h	Высота файла (по умолчанию \"768\")
Повторите вашу попытку."
  exit $E_OPTERROR
fi
#Выбираем необходимые параметры
while getopts ":h:w:i:f:o:" Option
do
  case $Option in
    h) high="$OPTARG";;
    w) width="$OPTARG";;
    i) file="$OPTARG";;
    f) format="$OPTARG";;
    o) outfile="$OPTARG";;
  esac
done
shift $(($OPTIND - 1))



#Удаляем первые две строчки из файла. И добавляем нулевую дату в первый столбец.
#Записываем результат во временный файл /tmp/datatmp
sed '1,2d' $file  | perl -ne's/^/00\/00\/00-00:00 / unless $f; $f = 1; print;' >> /tmp/datatmp
#Создаем заголовок графика
title=`head -1 $file | perl -ne'print join(" ",(split /\s/)[3,0,1])." \\\\n ".(split /\s/)[4]'`

#echo $title
#Подсчитываем количество столбцов в файле.
cols=`awk '{print NF}' $file | sort -nu | tail -n 1`

#Рисуем график
gnuplot << EOP
#Указываем формат файла и его размер
set terminal $format size $width,$high

#Указываем выходной файл
set output "$outfile"

#Рисуем легенды
set key autotitle columnhead
set key outside center bottom
set key horizontal
#Рисуем заголовок
set title "$title"

#Делаем ось Х в формате отображения дат
set xdata time
set timefmt "%m/%d/%y-%H:%M"
set format x "%H:%M\n%d/%m"
#Указываем имена осей
set xlabel "Время"
set ylabel "Кол-во запросов"
set grid
#Получаем конечный результат.
plot for [i=2:$cols] "/tmp/datatmp" using 1:i smooth unique with lines lw 2

EOP
#Удаляем временный файл.
rm /tmp/datatmp
echo "Image write to \"$outfile\""
exit 0;
