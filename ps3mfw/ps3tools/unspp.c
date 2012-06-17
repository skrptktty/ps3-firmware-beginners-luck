// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>

u8 *pkg = NULL;
static u64 header_size;
static u64 dec_size;

static void decrypt_spp(void)
{
	u16 flags;
	u16 type;
	u32 hdr_len;
	struct keylist *k;

	flags    = be16(pkg + 0x08);
	type     = be16(pkg + 0x0a);
	hdr_len  = be64(pkg + 0x10);
	dec_size = be64(pkg + 0x18);

	if (type != 4)
		fail("no .spp file");

	k = keys_get(KEY_SPP);

	if (k == NULL)
		fail("no key found");

	if (sce_decrypt_header(pkg, k) < 0)
		fail("header decryption failed");

	if (sce_decrypt_data(pkg) < 0)
		fail("data decryption failed");

	header_size = be64(pkg + 0x10);
    dec_size = be64(pkg + 0x18);
}

int main(int argc, char *argv[])
{
	if (argc == 3) {
		pkg = mmap_file(argv[1]);

		decrypt_spp();
        memcpy_to_file(argv[2], pkg + header_size, dec_size);
	} else {
		fail("usage: unspp default.spp target");
	}


	return 0;
}
