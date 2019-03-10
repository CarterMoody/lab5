lab5:
	javac *.java

clean:
	rm *.class

# lab5 tests

test_lab5:
	java lab5 in/lab4_fib20.asm scripts/lab5.script 2 > my/lab5_ghr2.output
	diff -w -B out/lab5_ghr2.output my/lab5_ghr2.output
	echo
	java lab5 in/lab4_fib20.asm scripts/lab5.script 4 > my/lab5_ghr4.output
	diff -w -B out/lab5_ghr4.output my/lab5_ghr4.output
	echo
	java lab5 in/lab4_fib20.asm scripts/lab5.script 8 > my/lab5_ghr8.output
	diff -w -B out/lab5_ghr8.output my/lab5_ghr8.output

run_lab5_2:
	java lab5 in/lab4_fib20.asm scripts/lab5.script 2

test_lab5_2:
	java lab5 in/lab4_fib20.asm scripts/lab5.script 2 > my/lab5_ghr2.output
	diff -w -B out/lab5_ghr2.output my/lab5_ghr2.output

run_lab5_4:
	java lab5 in/lab4_fib20.asm scripts/lab5.script 4

test_lab5_4:
	java lab5 in/lab4_fib20.asm scripts/lab5.script 4 > my/lab5_ghr4.output
	diff -w -B out/lab5_ghr4.output my/lab5_ghr4.output

run_lab5_8:
	java lab5 in/lab4_fib20.asm scripts/lab5.script 8

test_lab5_8:
	java lab5 in/lab4_fib20.asm scripts/lab5.script 8 > my/lab5_ghr8.output
	diff -w -B out/lab5_ghr8.output my/lab5_ghr8.output

# figure run
test_figure:
	java lab5 figure.asm scripts/figure.script
	diff -w -B out/coordinates.csv coordinates.csv