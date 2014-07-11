#include <stdlib.h>
#include <stdio.h>
#include "header.h"

#define int8 unsigned char
#define int16 unsigned short int
#define int32 unsigned long int

#define max(a,b) ((a>b)?(a):(b))

#define UP 1
#define DN 4
#define LF 8
#define RT 2

typedef struct {
	int8 type;
	int8 bio;
	int8 rad;
	int8 floor;
	int8 ceiling;
	int8 slope;
	int32 flags;
} tile;

typedef struct {
	int8 type;
	int8 floor;
	int8 ceiling;
	int8 slope;
	int16 o_xref;
	int16 texinfo;
	int32 flags;
	int32 state;
} f_tile;

tile map[64][64];
f_tile row[64];

char * wallids = "0123456789ABCDEF  ";
int rdir[9] = { 0, DN, LF, 0, UP, 0, 0, 0, RT };
char * ny[2] = { "no", "yes" };
char * type[18] = {
	"solid",
	"open",
	"SE diagonal",	/* 2 */
	"SW diagonal",
	"NW diagonal",
	"NE diagonal",
	"S->N slope",	/* 6 */
	"W->E slope",
	"N->S slope",
	"E->W slope",
	"SE->NW valley",/* A */
	"SW->NE valley",
	"NW->SE valley",
	"NE->SW valley",
	"NW->SE ridge",	/* E */
	"NE->SW ridge",
	"SE->NW ridge",
	"SW->NE ridge"
};

char * type_names[18] = {
	"00", "01", "02", "03", "04", "05",
	"06", "07", "08", "09", "0A", "0B",
	"0C", "0D", "0E", "0F", "10", "11"
};

FILE * fin;
FILE * fout;

int get_slope_mod_ceiling(int r, int c, int dir) {
	/*
		If it's not sloped, or is sloped in the wrong direction, return 0.
		Otherwise, return slope.
	*/
	if((map[r][c].flags & 0x00000C00) == 0x00000800) {
		return 0;
	}
	if((map[r][c].flags & 0x00000C00) != 0x00000400) {
		dir = rdir[dir];
	}
	switch(dir) {
		case DN:
			if(strchr("8CD", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		case LF:
			if(strchr("9AD", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		case UP:
			if(strchr("6AB", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		case RT:
			if(strchr("7BC", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		default:
			return 0;
	}
	return map[r][c].slope;
}

int get_slope_mod_floor(int r, int c, int dir) {
	/*
		If it's not sloped, or is sloped in the wrong direction, return 0.
		Otherwise, return slope.
	*/
	if((map[r][c].flags & 0x00000C00) == 0x00000C00) {
		return 0;
	}
	switch(dir) {
		case DN:
			if(strchr("8CD", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		case LF:
			if(strchr("9AD", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		case UP:
			if(strchr("6AB", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		case RT:
			if(strchr("7BC", wallids[map[r][c].type]) == NULL) {
				return 0;
			}
			break;
		default:
			return 0;
	}
	return map[r][c].slope;
}


int check_connect(int r, int c) {
	int blocks = 0;
	int df1 = 0;
	int df2 = 0;
	int df4 = 0;
	int df8 = 0;
	switch(map[r][c].type) {
		case 2:
			blocks |= 9;
			break;
		case 3:
			blocks |= 3;
			break;
		case 4:
			blocks |= 6;
			break;
		case 5:
			blocks |= 12;
			break;
		default:
			break;
	}
	if(r > 0) {
		df1 = 	max(map[r-1][c].floor + map[r][c].ceiling + get_slope_mod_floor(r-1,c,DN) + get_slope_mod_ceiling(r,c,UP),
					map[r-1][c].ceiling + map[r][c].floor + get_slope_mod_ceiling(r-1,c,DN) + get_slope_mod_floor(r,c,UP));
		if(map[r][c].ceiling + get_slope_mod_ceiling(r,c,UP) + map[r][c].floor + get_slope_mod_floor(r,c,UP) >= 32)
			df1 = 32;
	}
	if(r < 63) {
		df4 = 	max(map[r+1][c].floor + map[r][c].ceiling + get_slope_mod_floor(r+1,c,UP) + get_slope_mod_ceiling(r,c,DN),
					map[r+1][c].ceiling + map[r][c].floor + get_slope_mod_ceiling(r+1,c,UP) + get_slope_mod_floor(r,c,DN));
		if(map[r][c].ceiling + get_slope_mod_ceiling(r,c,DN) + map[r][c].floor + get_slope_mod_floor(r,c,DN) >= 32)
			df4 = 32;
	}
	if(c > 0) {
		df8 = 	max(map[r][c-1].floor + map[r][c].ceiling + get_slope_mod_floor(r,c-1,RT) + get_slope_mod_ceiling(r,c,LF),
					map[r][c-1].ceiling + map[r][c].floor + get_slope_mod_ceiling(r,c-1,RT) + get_slope_mod_floor(r,c,LF));
		if(map[r][c].ceiling + get_slope_mod_ceiling(r,c,LF) + map[r][c].floor + get_slope_mod_floor(r,c,LF) >= 32)
			df8 = 32;
	}
	if(c < 63) {
		df2 = 	max(map[r][c+1].floor + map[r][c].ceiling + get_slope_mod_floor(r,c+1,LF) + get_slope_mod_ceiling(r,c,RT),
					map[r][c+1].ceiling + map[r][c].floor + get_slope_mod_ceiling(r,c+1,LF) + get_slope_mod_floor(r,c,RT));
		if(map[r][c].ceiling + get_slope_mod_ceiling(r,c,RT) + map[r][c].floor + get_slope_mod_floor(r,c,RT) >= 32)
			df2 = 32;
	}

	if(df1 >= 32 && map[r-1][c].type)
		blocks |= 1;
	if(df4 >= 32 && map[r+1][c].type)
		blocks |= 4;
	if(df8 >= 32 && map[r][c-1].type)
		blocks |= 8;
	if(df2 >= 32 && map[r][c+1].type)
		blocks |= 2;
	return blocks;
}

int main(int argc, char ** argv) {
	int i,r,j;
	if(argc != 3) {
		fprintf(stderr, "Syntax: %s <infile> <outfile>\n");
		return 1;
	}
	fin = fopen(argv[1], "rb");
	if(fin == NULL) {
		fprintf(stderr, "Could not open %s for read!\n", argv[1]);
		return 2;
	}
	fout = fopen(argv[2], "wb");
	if(fin == NULL) {
		fprintf(stderr, "Could not open %s for overwrite!\n", argv[2]);
		return 3;
	}
	memset(row, 0, 64*sizeof(f_tile));
	for(i = 0; i < 64; ++i) {
		if((r = fread(row, 16, 64, fin)) != 64) {
			fprintf(stderr, "Read error on mapline %i: read %i/64\n", i, r);
			return 4;
		}
		for(j = 0; j < 64; ++j) {
			map[63-i][j].type = 1;
			map[63-i][j].type = row[j].type;
			map[63-i][j].bio = ((row[j].floor & 128)?(1):(0));
			map[63-i][j].rad = ((row[j].ceiling & 128)?(1):(0));
			map[63-i][j].floor = row[j].floor & 31;
			map[63-i][j].ceiling = row[j].ceiling & 31;
			map[63-i][j].slope = row[j].slope;
			map[63-i][j].flags = row[j].flags;
		}
	}
	fprintf(fout, "%s", html_header);
	fprintf(fout, "%s", html_header_2);
	for(i = 0; i < 64; ++i) {
		fprintf(fout, "\t\t\t\t<tr>\n");
		for(j = 0; j < 64; ++j) {
			if(map[i][j].type != 1) {
				fprintf(fout, "\t\t\t\t\t<td>\n\
						<img height=\"12\" width=\"12\" border=0 src=\"images/%s.jpeg\" title=\"Tile +%i+%i \n- Type: %s \n- Floor: %i \n- Ceiling: %i \n- Bio: %s \n- Rad: %s \n- Flags: 0x%08X \n- Slope: %i\">\n\
					</td>\n", type_names[map[i][j].type], j, i, type[map[i][j].type], map[i][j].floor, map[i][j].ceiling, ny[map[i][j].bio], ny[map[i][j].rad], map[i][j].flags, map[i][j].slope);
			} else {
				
				fprintf(fout, "\t\t\t\t\t<td>\n\
						<img height=\"12\" width=\"12\" border=0 src=\"images/%s.%c.jpeg\" title=\"Tile +%i+%i \n- Type: %s \n- Floor: %i \n- Ceiling: %i \n- Bio: %s \n- Rad: %s \n- Flags: 0x%08X \n- Slope: %i\">\n\
					</td>\n", type_names[map[i][j].type], wallids[check_connect(i,j)], j, i, type[map[i][j].type], map[i][j].floor, map[i][j].ceiling, ny[map[i][j].bio], ny[map[i][j].rad], map[i][j].flags, map[i][j].slope);
			}			
		}
		fprintf(fout, "\t\t\t\t</tr>\n");
	}
	fprintf(fout, "%s", html_footer);
	fclose(fin);
	fclose(fout);
	return 0;
}
