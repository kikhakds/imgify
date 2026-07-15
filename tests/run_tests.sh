#!/bin/sh
# Функциональный round-trip тест для imgify:
# кодируем файл в PNG (bin2png), декодируем обратно (png2bin),
# сравниваем результат с оригиналом.

BIN2PNG=./bin2png
PNG2BIN=./png2bin
TMP=/tmp/imgify_test
FAILED=0

mkdir -p $TMP

run_case() {
	name=$1
	input=$2

	$BIN2PNG -i "$input" -o "$TMP/$name.png" > /dev/null
	$PNG2BIN -i "$TMP/$name.png" -o "$TMP/$name.back" > /dev/null

	if cmp -s "$input" "$TMP/$name.back"; then
		echo "PASS: $name"
	else
		echo "FAIL: $name"
		FAILED=1
	fi
}

# Тест 1: короткий текстовый файл
printf 'Hello, imgify!' > "$TMP/short.txt"
run_case "short_text" "$TMP/short.txt"

# Тест 2: файл в один байт
printf 'A' > "$TMP/single_byte.txt"
run_case "single_byte" "$TMP/single_byte.txt"

# Тест 3: файл среднего размера
for i in $(seq 1 50); do
	printf 'The quick brown fox jumps over the lazy dog. ' >> "$TMP/medium.txt"
done
run_case "medium_text" "$TMP/medium.txt"

# Тест 4: бинарный файл со случайными данными
dd if=/dev/urandom of="$TMP/random.bin" bs=1024 count=4 status=none
run_case "binary_random" "$TMP/random.bin"

rm -rf $TMP

if [ $FAILED -eq 1 ]; then
	echo "Some tests FAILED"
	exit 1
fi

echo "All tests PASSED"
exit 0
