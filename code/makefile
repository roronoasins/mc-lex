
all: ficherolex
	g++ -o program ficheroLex.cpp -ll

ficherolex:
	lex -o ficheroLex.cpp specs.lex

ejecuta:
	./program example.txt

clean:
	rm -f -r *.cpp
	rm -f -r program
