#include <stdio.h>

void pakcopy(FILE * src_handle, FILE * tgt_handle, int amount) {
	int i;
	for(i = 0; i < amount; ++i) {
		fputc(fgetc(src_handle), tgt_handle);
	}
	return;
}
