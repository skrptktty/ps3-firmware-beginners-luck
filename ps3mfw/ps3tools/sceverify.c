// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

static u8 *ptr = NULL;

static u16 type;
static u16 flags;
static u32 meta_offset;
static u64 info_offset;
static u32 app_type;
static u64 filesize;
static u64 header_len;
static int did_fail = 0;

static struct keylist *klist = NULL;

static struct keylist *self_load_keys(void)
{
	enum sce_key id;

	switch (app_type) {
		case 1:
			id = KEY_LV0;
			break;
	 	case 2:
			id = KEY_LV1;
			break;
		case 3:
			id = KEY_LV2;
			break;
		case 4:	
			id = KEY_APP;
			break;
		case 5:
			id = KEY_ISO;
			break;
		case 6:
			id = KEY_LDR;
			break;
		default:
			fail("invalid type: %08x", app_type);	
	}

	return keys_get(id);
}

static void read_self_header(void)
{
	flags    =    be16(ptr + 0x08);
	meta_offset = be32(ptr + 0x0c);
	header_len =  be64(ptr + 0x10);
	filesize =    be64(ptr + 0x18);
	info_offset = be64(ptr + 0x28);

	app_type =    be32(ptr + info_offset + 0x0c);

	klist = self_load_keys();
}

static void read_pkg_header(void)
{
	flags    =    be16(ptr + 0x08);
	meta_offset = be32(ptr + 0x0c);
	header_len =  be64(ptr + 0x10);
	filesize =    be64(ptr + 0x18);

	klist = keys_get(KEY_PKG);
}

static void read_spp_header(void)
{
	flags    =    be16(ptr + 0x08);
	meta_offset = be32(ptr + 0x0c);
	header_len =  be64(ptr + 0x10);
	filesize =    be64(ptr + 0x18);

	klist = keys_get(KEY_SPP);
}

static void decrypt(void)
{
	int keyid;
       
	keyid = sce_decrypt_header(ptr, klist);

	if (keyid < 0)
		fail("sce_decrypt_header failed");

	if (sce_decrypt_data(ptr) < 0)
		fail("sce_decrypt_data failed");

	if (klist->keys[keyid].pub_avail < 0)
		fail("no public key available");

	if (ecdsa_set_curve(klist->keys[keyid].ctype) < 0)
		fail("ecdsa_set_curve failed");

	ecdsa_set_pub(klist->keys[keyid].pub);
}

static void verify_signature(void)
{
	u8 *r, *s;
	u8 hash[20];
	u64 sig_len;

	sig_len = be64(ptr + meta_offset + 0x60);
	r = ptr + sig_len;
	s = r + 21;

	sha1(ptr, sig_len, hash);

	printf("Signature\n");
	if (ecdsa_verify(hash, r, s))
		printf("  Status: OK\n");
	else
		printf("  Status: FAIL\n");

	printf("\n");
}

static int verify_hash(u8 *p, u8 *hashes)
{
	u64 offset;
	u64 size;
	u64 id;
	u8 *hash, *key;
	u8 result[20];

	offset = be64(p + 0x00);
	size   = be64(p + 0x08);
	id     = be32(p + 0x1c);

	if (id == 0xffffffff)
		return 0;

	hash = hashes + id * 0x10; 
	key = hash + 0x20;

	// XXX: possible integer overflow here
	if (offset > (filesize + header_len))
		return 1;

	// XXX: possible integer overflow here
	if ((offset + size) > (filesize + header_len))
		return 1;

	sha1_hmac(key, ptr + offset, size, result);

	if (memcmp(result, hash, 20) == 0)
		return 0;
	else
		return -1;
}

static void verify_hashes(void)
{
	u32 meta_n_hdr;
	u32 i;
	u8 *hashes;
	int res;

	meta_n_hdr = be32(ptr + meta_offset + 0x60 + 0xc);
	hashes = ptr + meta_offset + 0x80 + 0x30 * meta_n_hdr;

	printf("Hashes\n");

	for (i = 0; i < meta_n_hdr; i++) {
		printf("  Section #%02d:  ", i);
		res = verify_hash(ptr + meta_offset + 0x80 + 0x30 * i, hashes);
		if (res < 0) {
			did_fail = 1;
			printf("FAIL*\n");
		} else if (res > 0) {
		       printf("???\n");
		} else {
			printf("OK\n");
		}
	}
	
	printf("\n");
}

int main(int argc, char *argv[])
{
	if (argc != 2)
		fail("usage: sceverify filename");

	ptr = mmap_file(argv[1]);

	type = be16(ptr + 0x0a);

	if (type == 1)
		read_self_header();
	else if(type == 3)
		read_pkg_header();
	else if(type == 4)
		read_spp_header();
	else
		fail("Unknown type: %d", type);

	if (flags & 0x8000)
		fail("devkit file; nothing to verify");

	if (klist == NULL)
		fail("no key found");

	decrypt();
	verify_signature();
	verify_hashes();

	if (did_fail)
		printf(" * please not that the hash will always fail for "
		       "unaligned non-LOAD phdrs\n");
	return 0;
}
