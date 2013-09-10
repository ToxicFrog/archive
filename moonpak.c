#include <stdio.h>		/* fopen fread fwrite feof ferror */
#include <string.h>		/* memcmp */
#include <stdint.h>
#include <stdlib.h>		/* realloc */
#include <sys/stat.h>
#include <sys/types.h>	/* mkdir */
#include <assert.h>		/* assert */
#include <errno.h>

#define MOONPAK_VERSION "0.1 alpha"

#define max(x,y) ((x>y)?(x):(y))

#define dieR(cond, str) \
if( cond )\
{\
	printf(str ": %s\n", strerror(errno));\
	fflush(stdout);\
	return;\
}

#define dieB(cond, str) \
if( cond )\
{\
	printf(str ": %s\n", strerror(errno));\
	fflush(stdout);\
	errflag=1;\
	break;\
}	

#pragma pack(1)
typedef struct
{
	uint32_t	magic;			// 4D 4F 4F 4E "MOON"
	uint8_t 	unknown[14];	// no idea!
	uint32_t	datalen;		// length of file data; 0 for directories
	uint32_t	datalen2;		// same as above?
	uint32_t	namelen;		// length of name, bytes
} MoonTOC;

/* not used yet */
#if 0
struct options {
	int unpack;
	int pack;
	const char * file;
	const char * index;
};
#endif

char * index;

enum {
	CLI_OK	= 0,
	CLI_INCOMPLETE,
	CLI_EXIT,
	CLI_INVALID
};

void do_help()
{
	printf("%s",
		"Usage:\n"
		"  moonpak <commands>\n"
		"to execute <commands> in non-interactive mode, or\n"
		"  moonpak\n"
		"to enter an interactive shell. Valid commands are:\n"
		"?            This text\n"
		"h            This text\n"
		"i filename   Set index file to read or write, '-' for none\n"
		"l filename   List contents of named file\n"
		"u filename   Unpack named file, writing index file if one is set\n"
		"p filename   Read index file and packed name file. Requires a valid index file.\n"
		"q            Quit the program.\n"
	);
}

void set_index(const char * arg)
{
	free(index);
	if( !strcmp(arg, "-") )
	{
		index = NULL;
		printf("Index file unset. No index file will be written when unpacking.\n");
		return;
	}
	index = malloc(strlen(arg));
	strcpy(index, arg);
	printf("Index file set to '%s'\n", index);
	return;
}

const char * cli_arg(const char * input)
{
	++input;
	while( *input == ' ' || *input == '\t' || *input == '\n' || *input == '\r' )
	{
		++input;
	}
	return (strlen(input) > 0)?(input):(NULL);
}

void moon_pack(const char * arg)
{
	return;
}

void moon_list(const char * arg)
{
	FILE * fin = NULL;
	MoonTOC toc;
	uint8_t * namebuf = NULL;
	uint32_t namelen = 0;
	uint8_t errflag = 0;
	
	fin = fopen(arg, "rb");
	dieR(fin == NULL, "Unable to open file for list");
	
	while( !feof(fin) && !ferror(fin) )
	{
		dieB(fread(&toc, sizeof(MoonTOC), 1, fin) != 1, "ERROR\tUnable to read chunk header");
		
		if( memcmp(&toc.magic, "MOON", 4) )
		{
			printf("ERROR\tRead something, but it wasn't a valid moonpak chunk header!\n");
			break;
		}
	
		printf("\t0x%08X\t0x%08X\r", toc.datalen, toc.datalen2);
		fflush(stdout);

		if( toc.namelen >= namelen )
		{
			namelen = toc.namelen +1;
			namebuf = realloc(namebuf, namelen);
		}
	
		namebuf[toc.namelen] = '\0';

		dieB(fread(namebuf, toc.namelen, 1, fin) != 1, "ERROR\n\tUnable to read filename");
		printf("\t0x%08X\t0x%08X\t%s\r", toc.datalen, toc.datalen2, namebuf);
		fflush(stdout);
		
		if( toc.datalen || toc.datalen2 )
		{
			printf("FILE\n");
			fseek(fin, max(toc.datalen, toc.datalen2), SEEK_CUR);
		} else {
			printf("DIR\n");
		}
	} /* while !feof && !ferror */
	
	fclose(fin);

	if( errflag )
	{
		printf("\nError in list procedure; bailing\n");
	} else {
		printf("\nNothing more to list\n");
	}
	return;
}

void moon_unpack(const char * arg)
{
	FILE * fin = NULL;
	FILE * findex = NULL;
	FILE * fout = NULL;
	MoonTOC toc;
	uint8_t * namebuf = NULL;
	uint32_t namelen = 0;
	uint8_t * databuf = NULL;
	uint32_t datalen = 0;
	uint8_t errflag = 0;
	
	fin = fopen(arg, "rb");
	dieR(fin == NULL, "Unable to open file for unpacking");
	
	if( index != NULL )
	{
		findex = fopen(index, "wb");
		dieR(findex == NULL, "Unable to open index file");
	}
	
	while( !feof(fin) && !ferror(fin) )
	{
		dieB(fread(&toc, sizeof(MoonTOC), 1, fin) != 1, "ERROR\tUnable to read chunk header");
		
		if( memcmp(&toc.magic, "MOON", 4) )
		{
			printf("ERROR\tRead something, but it wasn't a valid moonpak chunk header!\n");
			break;
		}
	
		printf("\t0x%08X\t0x%08X\r", toc.datalen, toc.datalen2);
		fflush(stdout);

		if( toc.namelen >= namelen )
		{
			namelen = toc.namelen +1;
			namebuf = realloc(namebuf, namelen);
		}
	
		namebuf[toc.namelen] = '\0';

		dieB(fread(namebuf, toc.namelen, 1, fin) != 1, "ERROR\n\tUnable to read filename");
		printf("\t0x%08X\t0x%08X\t%s\r", toc.datalen, toc.datalen2, namebuf);
		fflush(stdout);
		
		/* If findex is set, we're expected to write an index file for later
			use re-packing this file.
		*/
		if( findex != NULL )
		{
			dieB(fwrite(&toc, sizeof(MoonTOC), 1, findex) != 1
			  || fwrite(namebuf, toc.namelen, 1, findex) != 1,
			  "ERROR\n\tError writing to index file");
		}
		
		if( toc.datalen || toc.datalen2 )
		{
			/* at the moment, we just assume that a nonzero length means a file
				Presumbly there are bits in the header that are meant to tell
				us this. This means that it kind of breaks on empty files.
			*/
			printf("FILE\r");
			fflush(stdout);

			if( max(toc.datalen, toc.datalen2) > datalen )
			{
				datalen = max(toc.datalen, toc.datalen2);
				databuf = realloc(databuf, datalen);
			}
			
			dieB(fread(databuf, max(toc.datalen, toc.datalen2), 1, fin) != 1, "ERROR\n\tUnable to read file data");
			fout = fopen(namebuf, "wb");
			dieB(fout == NULL, "ERROR\n\tUnable to open output file");
			dieB(fwrite(databuf, max(toc.datalen, toc.datalen2), 1, fout) != 1, "ERROR\n\tUnable to write to output file");
			fclose(fout); fout = NULL;
			
			printf("FILE OK\n");
		} else {
			printf("DIR\r"); fflush(stdout);
			dieB(mkdir(namebuf, 0777) && errno != EEXIST, "ERROR\n\tUnable to create directory");
			printf("DIR OK\n");
		}
	} /* while !feof && !ferror */
	
	fclose(fin);
	if(findex != NULL)
		fclose(findex);
	if(fout != NULL)
		fclose(fout);
	
	if( errflag )
	{
		printf("\nError in unpack procedure; bailing\n");
	} else {
		printf("\nNothing more to unpack\n");
	}
	return;
}

int cli(const char * input)
{
	const char * arg;

	switch(*input)
	{
	  case 'h':
	  case '?':
		do_help();
		return CLI_OK;
	  case 'q':
		return CLI_EXIT;
	  case 'i':
		arg = cli_arg(input);
		if( arg == NULL )
			return CLI_INCOMPLETE;
		set_index(arg);
		return CLI_OK;
	  case 'l':
		arg = cli_arg(input);
		if( arg == NULL )
			return CLI_INCOMPLETE;
		moon_list(arg);
		return CLI_OK;
	  case 'u':
		arg = cli_arg(input);
		if( arg == NULL )
			return CLI_INCOMPLETE;
		moon_unpack(arg);
		return CLI_OK;
	  case 'p':
		arg = cli_arg(input);
		if( arg == NULL )
			return CLI_INCOMPLETE;
		moon_pack(arg);
		return CLI_OK;
	  default:
		return CLI_INVALID;
	}
	
}

void strip_newlines(char * buf)
{
	char * tmp = buf + strlen(buf) - 1;
	while(strlen(buf) && (*tmp == '\n' || *tmp == '\r'))
	{
		*tmp = '\0';
		--tmp;
	}
}

int main(int argc, char ** argv)
{
	printf("MoonPak v%s by ToxicFrog\nUse 'h' or '?' for help\n", MOONPAK_VERSION);
	
	if( argc > 1 )
	{
		/* non-interactive mode */
		char cmdbuf[2048];
		cmdbuf[0] = '\0';
		for( int i = 1; i < argc; ++i )
		{
			strcat(cmdbuf, argv[i]);
			switch(cli(cmdbuf))
			{
			  case CLI_OK:
				cmdbuf[0] = '\0';
				break;
			  case CLI_INCOMPLETE:
				strcat(cmdbuf, " ");
				break;
			  case CLI_INVALID:
				fprintf(stderr, "Invalid command '%s'\n", argv[i]);
				return 1;
			  case CLI_EXIT:
			  	return 0;
			  default:
			  	assert(0);
			}
		} /* foreach argv */
	} else {
		/* interactive mode */
		const char * prompt = "(moonpak)";
		char cmdbuf[2048];
		cmdbuf[0] = '\0';
		char * buf = cmdbuf;
		while(1)
		{
			printf("%s ", prompt);
			if(fgets(buf, (cmdbuf + 2048 - buf), stdin) == NULL) break;
			
			strip_newlines(buf);
			
			switch(cli(cmdbuf))
			{
			  case CLI_INVALID:
				fprintf(stderr, "Invalid command '%s'\n", cmdbuf);
				/* fallthrough: reset input buffer */
			  case CLI_OK:
				cmdbuf[0] = '\0';
				buf = cmdbuf;
				prompt = "(moonpak)";
				break;
			  case CLI_INCOMPLETE:
				strcat(cmdbuf, " ");
				buf = cmdbuf + strlen(cmdbuf);
				prompt = ">";
				break;
			  case CLI_EXIT:
			  	return 0;
			  default:
			  	assert(0);
			}
		}
	}
	
	
	return 0;
}
