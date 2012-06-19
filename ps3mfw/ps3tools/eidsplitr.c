#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void
DumpEidData (FILE * pFile, int iInputSize, int iEidCount,
	     char *pFilenamePrefix)
{
  FILE *pOutput;
  char *szFilename;
  char *szBuf;
  int iRes, iSize;

  printf ("dumping EID%d from eEID at %p, size %d (%x)..\n",
	  iEidCount, pFile, iInputSize, iInputSize);

  szBuf = (char *) malloc (iInputSize + 1);
  szFilename = (char *) malloc (strlen (pFilenamePrefix) + 2);

  if (szBuf == NULL)
    {
      perror ("malloc");
      exit (1);
    };

  iSize = fread (szBuf, iInputSize, 1, pFile);
  sprintf (szFilename, "%s%d", pFilenamePrefix, iEidCount);
  pOutput = fopen (szFilename, "wb");
  iRes = fwrite (szBuf, iInputSize, 1, pOutput);

  if (iRes != iSize)
    {
      perror ("fwrite");
      exit (1);
    };

  free (szBuf);
}

int
main (int argc, char **argv)
{
  FILE *pFile;
  char *pPrefix;

  pFile = fopen (argv[1], "rb");
  if (pFile == NULL)
    {
    usage:
      printf ("usage: %s <eEID> <EID name prefix>\n", argv[0]);
      exit (1);
    }

  if (argc == 2 && argv[2] != NULL)
    {
      pPrefix = argv[2];
      goto usage;
    }

  fseek (pFile, 0x70, SEEK_SET);

  if (pPrefix != NULL)
    {
      DumpEidData (pFile, 2144, 0, pPrefix);
      DumpEidData (pFile, 672, 1, pPrefix);
      DumpEidData (pFile, 1840, 2, pPrefix);
      DumpEidData (pFile, 256, 3, pPrefix);
      DumpEidData (pFile, 48, 4, pPrefix);
      DumpEidData (pFile, 2560, 5, pPrefix);
    }
  return 0;
}
