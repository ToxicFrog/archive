#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define	int8	unsigned char
#define	int16	signed int
#define	uint16	unsigned int
#define	int32	signed long int
#define	uint32	unsigned long int

typedef struct {
	int32	version;		//version of the pak file format
	char	comment[24];	//comment header, always "MASSIVE PAKFILE V 4.0\r\n"
	int8	invariant[44];	//constant data
	int32	unknown1;
	int32	toc_nrof;		//number of TOC entries
	int32	unknown2;
	int32	offs_data;		//offset of data start
	int32	fsize;		//file size
} pak_header;

typedef struct {
	int32	csize;		//size of chunk
	int32	cstart;		//offs to chunk start
	int32	cname;		//offs to chunk name entry
	int32	unknown;
} toc_entry;

int get32(int8 * data) {
	return *(int32 *)data;
}

int get16(int8 * data) {
	return *(int16 *)data;
}

void read_header(int8 * buffer, pak_header * header) {
	header->version = get32(buffer);
	header->toc_nrof = get32(buffer+0x4c);
	header->offs_data = get32(buffer+0x54);
	header->fsize = get32(buffer+0x58);
	return;
}

void read_toc(int8 * buffer, toc_entry * toc) {
	toc->csize = get32(buffer);
	toc->cstart = get32(buffer+0x04);
	toc->cname = get32(buffer+0x08);
	toc->unknown = get32(buffer+0x0C);
	return;
}

void pakcp(FILE * src, FILE * tgt, int size) {
	int i;
	for(i - 0; i < size; ++i) {
		fputc(fgetc(src), tgt);
	}
	return;
}
	
int main(int argc, char ** argv) {
	if(argc != 2) {
		fprintf(stderr, "Syntax: %s <pakfile>\n", argv[0]);
		return 1;
	}
	int8 * buffer = (int8 *)malloc(1024);
	toc_entry * toc;
	pak_header * header = (pak_header *)malloc(sizeof(pak_header));
	FILE * handle = fopen(argv[1], "rb");
	fread(buffer, 1, 0x5c, handle);
	read_header(buffer, header);
	printf("Header loaded.\nVersion: %i\nTOC: %i\nData: %i\nSize: %i\n", header->version, header->toc_nrof, header->offs_data, header->fsize);
	toc = malloc(16*header->toc_nrof);
	int i;
	for(i = 0; i < header->toc_nrof; ++i) {
		fread(buffer, 16, 1, handle);
		read_toc(buffer, &toc[i]);
		printf("TOC entry %i: %i bytes at %i, nameindex %i\n", i, toc[i].csize, toc[i].cstart, toc[i].cname);
	}
	char * cname_cur = malloc(256);
	char * poc;
	buffer = (int8 *)realloc((void *)buffer, header->offs_data - 16*header->toc_nrof);
	fread(buffer, 1, header->offs_data - 0x5c - 16*header->toc_nrof, handle);
	FILE * dest;
	for(i = 0; i < header->toc_nrof; ++i) {
		memset(cname_cur, 0, 256);
		poc = buffer + toc[i].cname;
		poc += strlen(poc) - 1;
		int j;
		for(j = 0; j < strlen(buffer + 2 + toc[i].cname); ++j) {
			cname_cur[j] = *poc;
			--poc;
		}
		dest = fopen(cname_cur, "wb");
		fseek(handle, header->offs_data + toc[i].cstart, SEEK_SET);
		printf("Extracting chunk %i to %s...", i, cname_cur);
		fflush(stdout);
		pakcp(handle, dest, toc[i].csize);
		fclose(dest);
		printf("done.\n");
	}
	fclose(handle);
	free(header);
	free(cname_cur);
	free(toc);
	return 0;
}
