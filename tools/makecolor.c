#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>

int main(int argc, char const *argv[])
{
	argv[1] = "../kern/graphic/color.h";
	struct stat st;
	if(argc != 1) {
		fprintf(stderr, "Usage: <input filename>\n");
		return -1;
	}
	if(stat(argv[1], &st) != 0) {
		fprintf(stderr, "Error opening file '%s': %s\n", argv[1], strerror(errno));
		return -1;
	}
	char buf[st.st_size], buf2[2*st.st_size];
	memset(buf, 0, sizeof(buf));
	memset(buf2, 0, sizeof(buf2));
	FILE *ifp = fopen(argv[1], "rb");
	int size = fread(buf, 1, st.st_size, ifp);
	fclose(ifp);
	int i=0, j=0;
	char *p = buf, *p2 = buf2;
	while(*p!='$' && p<(buf+sizeof(buf))) *p2++ = *p++; 
	p++; 

	const char * str1 = "#define ";
	const char * str2 = " \t(rgb_t){0x\0";
	const char * str3 = ", 0x";
	const char * str4 = "}\n";


	char buf3[6], buf4[30];

	while(*p!='$' && p<(buf+sizeof(buf))) {
		if(*p == '#') {

 			memset(buf3, 0, sizeof(buf3));
			memset(buf4, 0, sizeof(buf4));

			p++;
			memcpy(buf3, p, 6);
			p+=7;
			int x=0;
			while(*p != '\t' && p<(buf+sizeof(buf))) buf4[x++] = *p++; 
			
			memcpy(p2, str1, 8); 
			p2 += 8;
			memcpy(p2, buf4, x);
			p2 += x; 
			memcpy(p2, str2, 12); 
			p2 += 12;
			memcpy(p2, buf3, 2);
			p2 += 2;
			memcpy(p2, str3, 4);
			p2 += 4;
			memcpy(p2, buf3+2, 2);
			p2 += 2;
			memcpy(p2, str3, 4);
			p2 += 4;
			memcpy(p2, buf3+4, 2);
			p2 += 2; 
			memcpy(p2, str4, 2);
			p2 += 2;
		}
		p++;
	}

	printf("%s\n", buf2);
	int outsize = p2 - buf2; 

	FILE *ofp = fopen(argv[1], "wb+");
	size = fwrite(buf2, 1, outsize, ofp);
	fclose(ofp);

	printf("Success\n");

	return 0;
}