echo Compile...
g++ main.cpp -std=gnu++1z -lstdc++fs -fopenmp -O3

echo generate input file...
python3 string_generator.py 100000

echo standart sort start...
time sort input.txt > out_sort.txt
echo FileSorter start...
time ./a.out input.txt out.txt

diff -q out.txt out_sort.txt
 
