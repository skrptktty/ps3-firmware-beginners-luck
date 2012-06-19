// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <inttypes.h>

#include "tools.h"

#ifdef WIN32
#define MKDIR(x,y) mkdir(x)
#else
#define MKDIR(x,y) mkdir(x,y)
#endif

static u8 *pup = NULL;
static u8 pup_hmac[0x40];
static int got_hmac = -1;
static u64 n_sections;
static u64 hdr_size;

static struct id2name_tbl t_names[] = {
	{0x100, "version.txt"},
	{0x101, "license.xml"},
	{0x102, "promo_flags.txt"},
	{0x103, "update_flags.txt"},
	{0x104, "patch_build.txt"},
	{0x200, "ps3swu.self"},
	{0x201, "vsh.tar"},
	{0x202, "dots.txt"},
	{0x203, "patch_data.pkg"},
	{0x300, "update_files.tar"},
        {0x501, "spkg_hdr.tar"},
	{0x601, "ps3swu2.self"},
	{0, NULL}
};

static int check_hmac(u8 *hmac, u8 *bfr, u64 len)
{
	u8 calc[0x14];

	if (hmac == NULL)
		return 1;

	if (got_hmac < 0)
		return 1;

	sha1_hmac(pup_hmac, bfr, len, calc);

	if (memcmp(calc, hmac, sizeof calc) == 0)
		return 0;
	else
		return -1;
}

static u8 *find_hmac(u32 entry)
{
	u8 *ptr;
	u32 i;

	ptr = pup + 0x30 + 0x20 * n_sections;

	for(i = 0; i < n_sections; i++) {
		if (be64(ptr) == entry)
			return ptr + 8;
		ptr += 0x20;
	}

	fail("not found: %d", entry);
	return NULL;
}

static void do_section(u64 i)
{
	u8 *ptr;
	u64 entry;
	u64 offset;
	u64 size;
	int hmac_res;
	const char *fname;
	const char *hmac_status;

	ptr = pup + 0x30 + 0x20 * i;
	entry  = be64(ptr);
	offset = be64(ptr + 0x08);
	size   = be64(ptr + 0x10);

	fname = id2name(entry, t_names, NULL);
	if (fname == NULL)
		fail("unknown entry id: %08x_%08x", (u32)(entry >> 32), (u32)entry);

	hmac_res = check_hmac(find_hmac(i), pup + offset, size);
	if (hmac_res < 0)
		hmac_status = "FAIL";
	else if (hmac_res == 0)
		hmac_status = "OK";
	else
		hmac_status = "???";

	printf("unpacking %s (%08x_%08x bytes; hmac: %s)...\n", fname, (u32)(size >> 32), (u32)size, hmac_status);
	memcpy_to_file(fname, pup + offset, size);
}

static void do_pup(void)
{
	u64 data_size;
	u64 i;
	int res;

	n_sections = be64(pup + 0x18);
	hdr_size   = be64(pup + 0x20);
	data_size  = be64(pup + 0x28);

	printf("sections:    %" PRIu64 "\n", n_sections);
	printf("hdr size:    %08x_%08x\n", (u32)(hdr_size >> 32), (u32)hdr_size);
	printf("data size:   %08x_%08x\n", (u32)(data_size >> 32), (u32)data_size);
	printf("header hmac: ");

	res = check_hmac(pup + 0x30 + 0x40 * n_sections, pup, 0x30 + 0x40 * n_sections);

	if (res < 0)
		printf("FAIL\n");
	else if (res == 0)
		printf("OK\n");
	else
		printf("???\n");

	for (i = 0; i < n_sections; i++)
		do_section(i);
}

int main(int argc, char *argv[])
{
	(void)argc;

	if (argc < 3)
		fail("usage: pupunpack filename.pup directory");

	got_hmac = key_get_simple("pup-hmac", pup_hmac, sizeof pup_hmac);
	pup = mmap_file(argv[1]);

	if(pup != NULL)
	{
		if (MKDIR(argv[2], 0777) < 0)
			fail("mkdir(%s)", argv[2]);
		if (chdir(argv[2]) < 0)
			fail("chdir(%s)", argv[2]);
		do_pup();
	}

	return 0;
}
