#include <stdio.h>
#include <stdint.h>

#define getI(f,o,b,s) \
	fseek(f,o,SEEK_SET);\
	fread(b,s,1,f)

typedef struct {
	uint32_t	fsize;
	const char * name;
	uint32_t	mode_400;
	uint32_t	mode_480;
	uint32_t	lfb_H_400;
	uint32_t	lfb_V_400;
	uint32_t	lfb_H_480;
	uint32_t	lfb_V_480;
	uint32_t	iface_H_400;
	uint32_t	iface_V_400;
	uint32_t	iface_H_480;
	uint32_t	iface_V_480;
} SShockBin;

typedef struct {
	uint16_t	hX;
	uint16_t	hY;
	uint8_t		hMode;
	uint16_t	lX;
	uint16_t	lY;
	uint8_t		lMode;
} SShockSet;

SShockBin info[] = {
	{
		1543695, "Original CDSHOCK.EXE",
		0x00172620, // mode numbers
		0x00172622,
		0x0016B5D5, // LFB parameters (640x400)
		0x0016B5D7,
		0x0016B5DA, // (640x480)
		0x0016B5DC,
		0x000E1650, // interface size (640x400)
		0x000E1655,
		0x000E1661, // (640x480)
		0x000E1666
	},
	{
		1362115, "Mok's XP-Patched CDSHOCK.EXE",
		0x001460D4, // mode numbers
		0x001460D6,
		0x0013F089, // LFB parameters (640x400)
		0x0013F08B,
		0x0013F08E, // (640x480)
		0x0013F090,
		0x000B5104, // interface size (640x400)
		0x000B5109,
		0x000B5115, // (640x480)
		0x000B511A
	},
	{
		0,
		"Unknown version",
		0,0,
		0,0,0,0,
		0,0,0,0
	}
};

int interactive = 1;
const char * niargs = NULL;
int nii = 0;

SShockBin
get_info_by_size(uint32_t size) {
	int i;
	for(i = 0; info[i].fsize > 0; ++i) {
		if(info[i].fsize == size) {
			return info[i];
		}
	}
	return info[i];
}

void
load_set(FILE * fout, SShockBin bin, SShockSet * set) {
	// =========== 640x400 ===========
		// mode number
	fseek(fout, bin.mode_400, SEEK_SET);
	fread(&(set->lMode), 1, 1, fout);
		// interface params
	fseek(fout, bin.iface_H_400, SEEK_SET);
	fread(&(set->lX), 2, 1, fout);
	fseek(fout, bin.iface_V_400, SEEK_SET);
	fread(&(set->lY), 2, 1, fout);
		// LFB params
	fseek(fout, bin.lfb_H_400, SEEK_SET);
	fread(&(set->lX), 2, 1, fout);
	fseek(fout, bin.lfb_V_400, SEEK_SET);
	fread(&(set->lY), 2, 1, fout);
	

	// =========== 640x480 ===========
		// mode number
	fseek(fout, bin.mode_480, SEEK_SET);
	fread(&(set->hMode), 1, 1, fout);
		// interface params
	fseek(fout, bin.iface_H_480, SEEK_SET);
	fread(&(set->hX), 2, 1, fout);
	fseek(fout, bin.iface_V_480, SEEK_SET);
	fread(&(set->hY), 2, 1, fout);
		// LFB params
	fseek(fout, bin.lfb_H_480, SEEK_SET);
	fread(&(set->hX), 2, 1, fout);
	fseek(fout, bin.lfb_V_480, SEEK_SET);
	fread(&(set->hY), 2, 1, fout);
}

void
save_set(FILE * fout, SShockBin bin, SShockSet set) {
	// =========== 640x400 ===========
		// mode number
	fseek(fout, bin.mode_400, SEEK_SET);
	fwrite(&(set.lMode), 1, 1, fout);
		// interface params
	fseek(fout, bin.iface_H_400, SEEK_SET);
	fwrite(&(set.lX), 2, 1, fout);
	fseek(fout, bin.iface_V_400, SEEK_SET);
	fwrite(&(set.lY), 2, 1, fout);
		// LFB params
	fseek(fout, bin.lfb_H_400, SEEK_SET);
	fwrite(&(set.lX), 2, 1, fout);
	fseek(fout, bin.lfb_V_400, SEEK_SET);
	fwrite(&(set.lY), 2, 1, fout);
	

	// =========== 640x480 ===========
		// mode number
	fseek(fout, bin.mode_480, SEEK_SET);
	fwrite(&(set.hMode), 1, 1, fout);
		// interface params
	fseek(fout, bin.iface_H_480, SEEK_SET);
	fwrite(&(set.hX), 2, 1, fout);
	fseek(fout, bin.iface_V_480, SEEK_SET);
	fwrite(&(set.hY), 2, 1, fout);
		// LFB params
	fseek(fout, bin.lfb_H_480, SEEK_SET);
	fwrite(&(set.hX), 2, 1, fout);
	fseek(fout, bin.lfb_V_480, SEEK_SET);
	fwrite(&(set.hY), 2, 1, fout);
}

int
do_main_menu() {
	int foo;
	if(niargs != NULL) {
		return (int)(niargs[nii++] - '0');
	}
	printf("[1] Change 640x400 mapping\n");
	printf("[2] Change 640x480 mapping\n");
	printf("[3] Restore defaults\n");
	printf("[4] Exit\n");
	do {
		printf("> ");
		fflush(stdout);
		foo = (int)(getchar() - '0');
		if(foo != '\n') {
			while(getchar() != '\n') {;}
		}
	} while(foo < 1 && foo > 4);
	return foo;
}

int
do_mode_menu() {
	int foo;
	if(niargs != NULL) {
		return (int)(niargs[nii++] - '0');
	}
	printf("[1] 640x400\n");
	printf("[2] 640x480\n");
	printf("[3] 800x600\n");
	printf("[4] 1024x768\n");
	printf("[5] 1280x1024\n");
	do {
		printf("> ");
		fflush(stdout);
		foo = (int)(getchar() - '0');
		if(foo != '\n') {
			while(getchar() != '\n') {;}
		}
	} while(foo < 1 && foo > 5);
	return foo;
}
	

int 
main(int argc, char ** argv) {
	long unsigned int fsize;
	
	if(argc < 2) {
		printf("Usage: ss1hr file [command-string]\n");
		return 1;
	} else if(argc == 2) {
		interactive = 1;
	} else if(argc == 3) {
		interactive = 0;
		niargs = argv[2];
		nii = 0;
	}

	FILE * fin = fopen(argv[1],"r+b");
	if(fin == NULL) {
		printf("Error: unable to open %s for read/write.\n", argv[1]);
		return 2;
	}

	fseek(fin, 0, SEEK_END);
	
	SShockBin finfo = get_info_by_size(fsize = ftell(fin));
	printf("%s %lu bytes: %s\n", argv[1], fsize, finfo.name);

	if(finfo.fsize == 0) {
		return 4;
	}

	SShockSet set;
	
	load_set(fin, finfo, &set);
	
	
	if(!interactive) {
		printf("    Current mappings:\n");
		printf("    640x400 -> %ux%u\n", set.lX, set.lY);
		printf("    640x480 -> %ux%u\n", set.hX, set.hY);
	}
	int tmp = 1;
	while(tmp) {
		if(interactive) {
			printf("    Current mappings:\n");
			printf("    640x400 -> %ux%u\n", set.lX, set.lY);
			printf("    640x480 -> %ux%u\n", set.hX, set.hY);
		}
		switch(do_main_menu()) {
		  case 1:
			switch(do_mode_menu()) {
			  case 1:	// 640x400
			  	set.lX = 640;
				set.lY = 400;
				set.lMode = 0;
				save_set(fin,finfo,set);
				break;
			  case 2:	// 640x480
			  	set.lX = 640;
				set.lY = 480;
				set.lMode = 1;
				save_set(fin,finfo,set);
				break;
			  case 3:	// 640x480
			  	set.lX = 800;
				set.lY = 600;
				set.lMode = 3;
				save_set(fin,finfo,set);
				break;
			  case 4:	// 640x480
			  	set.lX = 1024;
				set.lY = 768;
				set.lMode = 5;
				save_set(fin,finfo,set);
				break;
			  case 5:	// 640x480
			  	set.lX = 1280;
				set.lY = 1024;
				set.lMode = 7;
				save_set(fin,finfo,set);
			  default:
				break;
			}
			break;
		  case 2:
			switch(do_mode_menu()) {
			  case 1:	// 640x400
			  	set.hX = 640;
				set.hY = 400;
				set.hMode = 0;
				save_set(fin,finfo,set);
				break;
			  case 2:	// 640x480
			  	set.hX = 640;
				set.hY = 480;
				set.hMode = 1;
				save_set(fin,finfo,set);
				break;
			  case 3:	// 640x480
			  	set.hX = 800;
				set.hY = 600;
				set.hMode = 3;
				save_set(fin,finfo,set);
				break;
			  case 4:	// 640x480
			  	set.hX = 1024;
				set.hY = 768;
				set.hMode = 5;
				save_set(fin,finfo,set);
				break;
			  case 5:	// 640x480
			  	set.hX = 1280;
				set.hY = 1024;
				set.hMode = 7;
				save_set(fin,finfo,set);
			  default:
				break;
			}
			break;
		  case 3:
			set.lX = 640;
			set.lY = 400;
			set.lMode = 0;
			set.hX = 640;
			set.hY = 480;
			set.hMode = 1;
			save_set(fin, finfo, set);
			break;
		  case 4:
			tmp = 0;
		  default:
			break;
		}
	}
	if(!interactive) {
		printf("    New mappings:\n");
		printf("    640x400 -> %ux%u\n", set.lX, set.lY);
		printf("    640x480 -> %ux%u\n", set.hX, set.hY);
	}

	fclose(fin);
	return 0;
}
