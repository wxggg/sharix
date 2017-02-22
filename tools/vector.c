#include <stdio.h>

int main(int argc, char const *argv[])
{
	FILE *fp;
	fp = fopen("../kern/trap/vectors.S","w");
	fprintf(fp, "# handler\n");
	fprintf(fp, ".text\n");
	fprintf(fp, ".global __alltraps\n");

	for (int i = 0; i < 256; ++i)
	{
		fprintf(fp, ".global vector%d\n", i);
		fprintf(fp, "vector%d:\n", i);
		if ((i<8 || i>14) && i!=17) 
			fprintf(fp, "  pushl $0\n");
		fprintf(fp, "  pushl $%d\n", i);
		fprintf(fp, "  jmp __alltraps\n");
	}
	fprintf(fp, "\n");
	fprintf(fp, "# vector table\n");
	fprintf(fp, ".data\n");
	fprintf(fp, ".global __vectors\n");
	fprintf(fp, "__vectors:\n");
	for (int i = 0; i < 256; ++i)
		fprintf(fp, "  .long vector%d\n", i);
	fclose(fp);
	return 0;
}