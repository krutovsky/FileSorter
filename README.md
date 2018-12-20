# FileSorter
Программа для сортировки текстовых строк из файла. 
Программа компилируется и работает на Linux. 
Подразумевается, памяти достаточно, чтобы вместить данные целиком. 
Программа рассчитана на паралелльное выполнение на нескольких ядрах\гипертредах

# Implementation plan
1. Генератор случайных строк, тесты
2. Открытие файла, чтение в буфер (mmap?), вывод в консоль
3. Поиск строк, сортировка
4. Параллелная сортировка (параллелный поиск строк?)
5. Запись в файл построчно (fstream) или формирование буфера и маппинг
6. Профилирование(на разных компиляторах?), рефакторинг

# Первые замеры
Для файла размером 2,8 GB (2 781 897 561 bytes) (строки длинной от 5 до 100 символов). Время работы sort: 0m32.244s

1. На рекурсивных async вызовах с ограничением по числу доступных потоков 0m45.026s
2. На ThreadPool с ограничением воркеров по числу доступных потоков 0m47.031s
3. На синхронном поиске строк и __gnu_parallel::sort 0m36.607s  
```
File reading elapsed time: 10.7721 s  
Finding and sorting strings elapsed time: 14.8702 s  
Writing file elapsed time: 12.0137 s
```  

При этом  

```
Finding lines elapsed time: 0.97648 s  
Sorting elapsed time: 14.1089 s
```  

Поиск строк ускорять нет смысла, написать сортировку быстрее чем интрисик компилятора вряд ли получится.
Стоит попробовать ускорить чтение и запись.
___
mmap не дал ускорения по сравнению с потоками с++ (?), C-style чтение дало небольшой прирост перфоманса (<10%), unistd read/pread ускорили чтение большого файла почти в 3 раза по сравнению с стд стримами.

Есть идея читать по кускам, определять где закончилась текущая строка, создавать задачу по поиску строк и сортировке в тредпуле, читать следующий кусок и т.д. Возможно на больших файлах будет небольшой буст за счет одновременного чтения и сортировки, но повлечет сильное усложнение кода.

