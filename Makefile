unmpak4:	unmpak4.o pakio.o
	gcc -o unmpak4 unmpak4.o pakio.o

unmpak4.o:	src/unmpak4.c include/defines.h include/structs.h
	gcc -c -o unmpak4.o src/unmpak4.c

pakio.o:	src/pakio.c include/defines.h
	gcc -c -o pakio.o src/pakio.c
