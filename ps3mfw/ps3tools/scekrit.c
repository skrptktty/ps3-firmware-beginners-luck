// SCEkrit.c (v1.01): Compute Sony's Private Keys
// Based on Sven's sceverify.c
// -------------------------------------------------------------
// Compile by copying to fail0verflow's ps3tools and add
// SCEkrit.c to TOOLS in the Makefile.
// Run with two files (selfs, pkgs) signed by the same key.
// Depends on libgmp; add -lgmp to LDFLAGS
// - Aaron Lindsay / @AerialX
// And thanks gbcft!

// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <gmp.h>

static int keyid = -1;
    
static u8 *ptr1 = NULL;
static u8 *ptr2 = NULL;

static u16 type;
typedef struct {
	u16 flags;
	u32 meta_offset;
	u64 info_offset;
	u32 app_type;
	u64 filesize;
	u64 header_len;
} fileinfo;

static fileinfo info1;
static fileinfo info2;

static struct keylist *klist = NULL;

static struct keylist *self_load_keys(fileinfo* info)
{
	enum sce_key id;

	switch (info->app_type) {
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
			fail("invalid type: %08x", info->app_type);	
	}

	return keys_get(id);
}

static void read_self_header(u8* ptr, fileinfo* info)
{
	info->flags    =    be16(ptr + 0x08);
	info->meta_offset = be32(ptr + 0x0c);
	info->header_len =  be64(ptr + 0x10);
	info->filesize =    be64(ptr + 0x18);
	info->info_offset = be64(ptr + 0x28);

	info->app_type =    be32(ptr + info->info_offset + 0x0c);

	klist = self_load_keys(info);
}

static void read_pkg_header(u8* ptr, fileinfo* info)
{
	info->flags    =    be16(ptr + 0x08);
	info->meta_offset = be32(ptr + 0x0c);
	info->header_len =  be64(ptr + 0x10);
	info->filesize =    be64(ptr + 0x18);

	klist = keys_get(KEY_PKG);
}

static void decrypt(u8* ptr)
{
	if (keyid < 0)
		keyid = sce_decrypt_header(ptr, klist);
	else if (keyid != sce_decrypt_header(ptr, klist))
		fail("Both files must have the same key id");

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

static void verify_signature(u8* ptr, fileinfo* info, u8* hash, u8** s, u8** r)
{
	u64 sig_len;

	sig_len = be64(ptr + info->meta_offset + 0x60);
	*r = ptr + sig_len;
	*s = *r + 21;

	sha1(ptr, sig_len, hash);

	printf("Signature\n");
	if (ecdsa_verify(hash, *r, *s))
		printf("  Status: OK\n");
	else
		printf("  Status: FAIL\n");
}

static void load_num(mpz_t n, u8* un)
{
	char buffer[0x100];
	char* ptr = buffer;
	int i;
	for (i = 0; i < 21; i++) {
		sprintf(ptr, "%02x", un[i]);
		ptr += 2;
	}
	mpz_set_str(n, buffer, 16);
}

static char* calculate_private_key(u8* us1, u8* us2, u8* uz1, u8* uz2, u8* un, u8* ur)
{
	mpz_t s1, s2, z1, z2, n, r, k, dA;
	mpz_init(s1); mpz_init(s2); mpz_init(z1); mpz_init(z2); mpz_init(n); mpz_init(r); mpz_init(k); mpz_init(dA);
	load_num(s1, us1); load_num(s2, us2); load_num(z1, uz1); load_num(z2, uz2); load_num(n, un); load_num(r, ur);

	mpz_sub(z2, z1, z2);
	mpz_sub(s2, s1, s2);
	mpz_invert(s2, s2, n);
	mpz_mul(k, z2, s2);
	mpz_mod(k, k, n);

	mpz_mul(s2, s1, k);
	mpz_sub(s2, s2, z1);
	mpz_invert(r, r, n);
	mpz_mul(dA, s2, r);
	mpz_mod(dA, dA, n);

//	printf("k: %s\n", mpz_get_str(NULL, 16, k));
	return mpz_get_str(NULL, 16, dA);
}

int main(int argc, char *argv[])
{
	if (argc != 3)
		fail("usage: scesekrit signedfile1 signedfile2");

	ptr1 = mmap_file(argv[1]);
	ptr2 = mmap_file(argv[2]);

	type = be16(ptr1 + 0x0a);
	if (type != be16(ptr2 + 0x0a))
		fail("Files must be the same type");
	
	if (type == 1) {
		read_self_header(ptr1, &info1);
	} else if(type == 3) {
		read_pkg_header(ptr1, &info1);
	} else
		fail("Unknown type: %d", type);

	if ((info1.flags) & 0x8000)
		fail("devkit file; nothing to verify");

	if (klist == NULL)
		fail("no key found");

	decrypt(ptr1);
	
	if (type == 1) {
		read_self_header(ptr2, &info2);
	} else if(type == 3) {
		read_pkg_header(ptr2, &info2);
	} else
		fail("Unknown type: %d", type);

	if ((info2.flags) & 0x8000)
		fail("devkit file; nothing to verify");

	if (klist == NULL)
		fail("no key found");

	decrypt(ptr2);

	u8* s1;
	u8* s2;
	u8 z1[21];
	u8 z2[21];
	u8* r1;
	u8* r2;
	u8 ec[21];
	u8 n[21];
	z1[0] = 0;
	z2[0] = 0;
	
	ecdsa_get_params(klist->keys[keyid].ctype, ec, ec, ec, n, ec, ec);

	printf("%s ", argv[1]);
	verify_signature(ptr1, &info1, z1 + 1, &s1, &r1);
	printf("%s ", argv[2]);
	verify_signature(ptr2, &info2, z2 + 1, &s2, &r2);

	if (memcmp(r1, r2, 21))
		fail("Both files must share the same r signature value.");

	const char* dA = calculate_private_key(s1, s2, z1, z2, n, r1);

	int len = strlen(dA);
	int i;
	printf("Private Key: ");
	for (i = len / 2; i < 21; i++)
		printf("00");
	printf("%s\n", dA);

	return 0;
}
