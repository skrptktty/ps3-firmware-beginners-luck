// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Copyright 2011       glevand <geoffrey.levand@mail.ru>
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

static struct key k;
static FILE *fp;

static u8 *content;
static u64 content_size;

static u8 sce_hdr[0x20];
static u8 meta_hdr[0x1e0];

static u8 *spp;
static u64 spp_size;

static void get_profile(const char *filename)
{
	struct stat st;

	content = mmap_file(filename);

	if (stat(filename, &st) < 0)
		fail("stat(%s) failed", filename);

	content_size = st.st_size;
}

static void get_key(const char *suffix)
{
	if (key_get(KEY_SPP, suffix, &k) < 0)
		fail("key_get() failed");

	if (k.pub_avail < 0)
		fail("no public key available");

	if (k.priv_avail < 0)
		fail("no private key available");

	if (ecdsa_set_curve(k.ctype) < 0)
		fail("ecdsa_set_curve failed");

	ecdsa_set_pub(k.pub);
	ecdsa_set_priv(k.priv);
}

static void build_sce_hdr(void)
{
	memset(sce_hdr, 0, sizeof sce_hdr);

	wbe32(sce_hdr + 0x00, 0x53434500);	// magic
	wbe32(sce_hdr + 0x04, 2);		// version
	wbe16(sce_hdr + 0x08, 0);		// dunno, sdk type?
	wbe16(sce_hdr + 0x0a, 4);		// SCE header type; profile
	wbe32(sce_hdr + 0x0c, 0);		// meta offset
	wbe64(sce_hdr + 0x10, sizeof sce_hdr + sizeof meta_hdr);
	wbe64(sce_hdr + 0x18, content_size);
}

static void build_meta_hdr(void)
{
	u8 *ptr;

	memset(meta_hdr, 0, sizeof meta_hdr);
	ptr = meta_hdr;

	// keys for metadata encryption
	get_rand(ptr, 0x10);
	get_rand(ptr + 0x20, 0x10);
	ptr += 0x40;

	// area covered by the signature
	wbe64(ptr + 0x00, sizeof sce_hdr + sizeof meta_hdr - 0x30);
	wbe32(ptr + 0x08, 1);
	wbe32(ptr + 0x0c, 2);		// number of encrypted headers
	wbe32(ptr + 0x10, 2 * 8);	// number of keys/hashes required
	ptr += 0x20;

	// header
	wbe64(ptr + 0x00, 0x200);	// offset
	wbe64(ptr + 0x08, 0x20);	// size
	wbe32(ptr + 0x10, 1); 		// unknown
	wbe32(ptr + 0x14, 1);		// index
	wbe32(ptr + 0x18, 2);		// unknown again
	wbe32(ptr + 0x1c, 0);		// sha index
	wbe32(ptr + 0x20, 1);		// no encryption
	wbe32(ptr + 0x24, 0xffffffff);	// key index
	wbe32(ptr + 0x28, 0xffffffff);	// iv index
	wbe32(ptr + 0x2c, 0x1);		// no compression
	ptr += 0x30;

	// profile
	wbe64(ptr + 0x00, 0x220);	// offset
	wbe64(ptr + 0x08, content_size - 0x20);
	wbe32(ptr + 0x10, 2); 		// unknown
	wbe32(ptr + 0x14, 2);		// index
	wbe32(ptr + 0x18, 2);		// unknown again
	wbe32(ptr + 0x1c, 8);		// sha index
	wbe32(ptr + 0x20, 3);		// encrypted
	wbe32(ptr + 0x24, 0);		// key index
	wbe32(ptr + 0x28, 1);		// iv index
	wbe32(ptr + 0x2c, 0x1);		// no compression
	ptr += 0x30;

	// add keys/ivs and hmac keys
	get_rand(ptr, 2 * 8 * 0x10);
}

static void build_spp(void)
{
	spp_size = sizeof sce_hdr + sizeof meta_hdr;
	spp_size += content_size;

	spp = malloc(spp_size);
	if (!spp)
		fail("out of memory");

	memset(spp, 0xaa, spp_size);
	memcpy(spp, sce_hdr, 0x20);
	memcpy(spp + 0x20, meta_hdr, 0x1e0);
	memcpy(spp + 0x200, content, content_size);
}

static void calculate_hash(u8 *data, u64 len, u8 *digest)
{
	memset(digest, 0, 0x20);
	sha1_hmac(digest + 0x20, data, len, digest);
}

static void hash_spp(void)
{
	calculate_hash(spp + 0x200, 0x20, spp + 0x80 + 2*0x30);
	calculate_hash(spp + 0x220, content_size - 0x20,
			spp + 0x80 + 2*0x30 + 8*0x10);
}

static void sign_spp(void)
{
	u8 *r, *s;
	u8 hash[20];
	u64 sig_len;

	sig_len = be64(spp + 0x60);
	r = spp + sig_len;
	s = r + 21;

	sha1(spp, sig_len, hash);

	ecdsa_sign(hash, r, s);
}

int main(int argc, char *argv[])
{
	if (argc != 4)
		fail("usage: spp [key suffix] [filename.pp] [filename.spp]");

	fp = fopen(argv[3], "wb");
	if (fp == NULL)
		fail("fopen(%s) failed", argv[3]);

	get_key(argv[1]);
	get_profile(argv[2]);

	build_sce_hdr();
	build_meta_hdr();

	build_spp();
	hash_spp();
	sign_spp();

	sce_encrypt_data(spp);
	sce_encrypt_header(spp, &k);

	fwrite(spp, spp_size, 1, fp);
	fclose(fp);

	return 0;
}
