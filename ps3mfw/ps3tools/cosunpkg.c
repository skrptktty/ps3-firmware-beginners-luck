// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>

#ifdef WIN32
#define MKDIR(x,y) mkdir(x)
#else
#define MKDIR(x,y) mkdir(x,y)
#endif

u8 *pkg = NULL;

static void unpack_file(u32 i)
{
	u8 *ptr;
	u8 name[33];
	u64 offset;
	u64 size;

	ptr = pkg + 0x10 + 0x30 * i;

	offset = be64(ptr + 0x00);
	size   = be64(ptr + 0x08);

	memset(name, 0, sizeof name);
	strncpy((char *)name, (char *)(ptr + 0x10), 0x20);

	printf("unpacking %s...\n", name);
	memcpy_to_file((char *)name, pkg + offset, size);
}

static void unpack_pkg(void)
{
	u32 n_files;
	u64 size;
	u32 i;

	n_files = be32(pkg + 4);
	size = be64(pkg + 8);

	for (i = 0; i < n_files; i++)
		unpack_file(i);
}

int main(int argc, char *argv[])
{
	if (argc != 3)
		fail("usage: cosunpkg filename.pkg target");

	pkg = mmap_file(argv[1]);

	MKDIR(argv[2], 0777);

	if (chdir(argv[2]) != 0)
		fail("chdir");

	unpack_pkg();

	return 0;
}
