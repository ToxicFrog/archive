//the pakfile header
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

//an entry in the TOC
typedef struct {
	int32	csize;		//size of chunk
	int32	cstart;		//offs to chunk start
	int32	cname;		//offs to chunk name entry
	int32	unknown;
} toc_entry;
