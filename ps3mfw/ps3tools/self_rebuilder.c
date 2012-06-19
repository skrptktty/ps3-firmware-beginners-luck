// based on fail0verflow reverse engineering of self executables
// Copyright 2010 Sven Peter <svenpeter@gmail.com>
// 2011 Modified By Anonymous developers on EFNET
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#include <sys/stat.h>
#include <zlib.h>

#define	ALIGNMENT	0x20
#define	MAX_PHDR	255
//#define DEBUG		1

// pseudo header for self_rebuilder
// All structure start here
static struct {
  u32 offset ;
  u32 size ;
  u32 compressed ;
  u32 size_uncompressed ;
  u32 elf_offset ;
} self_sections[MAX_PHDR] ;

struct self_sec {
  u32 idx ;
  u64 offset ;
  u64 size ;
  u32 compressed ;
  u32 encrypted ;
  u64 next ;
} ;

static struct {
  u32 count ;
  u32 address ;
  int size ;
  u32 number ;
  u32 compressed ;
} compressed_sections[MAX_PHDR] ;

enum {
  VERIFY_HASH = 0,
  SIGN_HASH,
} ;

// end

static u8 *elf = NULL ;
static u8 *self = NULL ;

static u32 type ;
static int packed_type ;

struct elf_hdr ehdr ;
struct elf_shdr eshdr ;
struct elf_phdr phdr[MAX_PHDR] ;

static int arch64 ;

static u32 meta_offset ;
static u64 elf_size ;
static u64 info_offset ;
static u64 elf_offset ;
static u64 phdr_offset ;
static u64 shdr_offset ;
static u64 sec_offset ;
static u64 ctrl_offset ;
static u64 version ;
static u64 auth_id ;
static u64 vendor_id ;
static u16 sdk_type ;
static char versionsuffix[4] ;

static u32 n_sections ;

// readself
static u64 filesize ;
static int self_size ;
static u64 header_len ;
static u64 ver_info ;
static u64 ctrl_size ;
static int decrypted = -1 ;

//
struct key ks ;

static const char *elf_name = NULL ;
static const char *self_name = NULL ;

struct id2name_tbl t_sdk_type[] = {
  {0, "Retail (Type 0)"},
  {1, "Retail"},
  {2, "Retail (Type 1)"},
  {3, "Unknown SDK3"},
  {4, "Unknown > = 3.42"},
  {5, "Unknown SDK5"},
  {6, "Unknown SDK6"},
  {7, "Unknown > = 3.50"},
  {8, "Unknown SDK8"},
  {9, "Unknown SDK9"},
  {0x8000, "Devkit"},
  {0, NULL}
} ;

struct id2name_tbl t_app_type[] = {
  {1, "level 0"},
  {2, "level 1"},
  {3, "level 2"},
  {4, "application"},
  {5, "isolated SPU module"},
  {6, "secure loader"},
  {7, "unknown app type"},
  {8, "NP-DRM application"},
  {0, NULL}
} ;

static void
get_keys (const char *suffix)
{
  if (key_get (packed_type, suffix, &ks) < 0) {
    fail ("key_get failed") ;
  }

  if (ks.pub_avail < 0) {
    fail ("no public key available") ;
  }

  if (ks.priv_avail < 0) {
    fail ("no private key available") ;
  }

  if (ecdsa_set_curve (ks.ctype) < 0) {
    fail ("ecdsa_set_curve failed") ;
  }

  ecdsa_set_pub (ks.pub) ;
  ecdsa_set_priv (ks.priv) ;
}

static void
parse_elf (void)
{
  u32 i ;

  arch64 = elf_read_hdr (elf, &ehdr) ;

  for (i = 0; i < ehdr.e_phnum; i++) {
    elf_read_phdr (arch64, elf + ehdr.e_phoff + i * ehdr.e_phentsize, &phdr[i]) ;
  }
}

static void
parse_self (void)
{
  //here we are taking every self information needed and more
  sdk_type = be16 (self + 0x08) ;
  meta_offset = be32 (self + 0x0c) ;
  header_len = be64 (self + 0x10) ;
  filesize = be64 (self + 0x18) ;
  info_offset = be64 (self + 0x28) ;
  elf_offset = be64 (self + 0x30) ;
  phdr_offset = be64 (self + 0x38) - elf_offset ;
  shdr_offset = be64 (self + 0x40) - elf_offset ;
  sec_offset = be64 (self + 0x48) ;
  ver_info = be64 (self + 0x50) ;
  ctrl_offset = be64 (self + 0x58) ;
  ctrl_size = be64 (self + 0x60) ;

  vendor_id = be32 (self + info_offset + 0x08) ;
  auth_id = be64 (self + info_offset + 0x00) ;
  type = be32 (self + info_offset + 0x0c) ;
  packed_type = (type - 1) ;
  version = be64 (self + info_offset + 0x10) ;

  elf = self + elf_offset ;
  arch64 = elf_read_hdr (elf, &ehdr) ;
}

static int
qsort_compare (const void *a, const void *b)
{
  const struct self_sec *sa, *sb ;

  sa = a ;
  sb = b ;

  if (sa->offset > sb->offset) {
    return 1 ;
  } else if (sa->offset < sb->offset) {
    return -1 ;
  } else {
    return 0 ;
  }
}

static void
read_section (u32 i, struct self_sec *sec)
{
  u8 *ptr ;

  ptr = self + sec_offset + i * 0x20 ;

  sec->idx = i ;
  sec->offset = be64 (ptr + 0x00) ;
  sec->size = be64 (ptr + 0x08) ;
  sec->compressed = be32 (ptr + 0x10) ==  2 ? 1 : 0 ;
  sec->encrypted = be32 (ptr + 0x1c) ;
  sec->next = be64 (ptr + 0x20) ;
}


// Change compressed section size
static void
change_section_size (u32 i, u64 size)
{
  u8 *ptr ;

  ptr = self + sec_offset + i * 0x20 ;

  self_sections[i + 1].size = size ;
  wbe64 (ptr + 0x08, size) ;
  wbe64 (self + meta_offset + 0x60 + 0x20 + i * 0x30 + 0x08, size) ;
}

// Change compressed section offset
/*
static void
change_section_offset (u32 i, int delta)
{
  u8 *ptr ;
  u64 val ;

  ptr = self + sec_offset + i * 0x20 ;
  val = be64 (ptr) ;
  val +=  delta ;
  wbe64 (ptr, val) ;

  self_sections[i + 1].offset = val ;
  wbe64 (self + meta_offset + 0x60 + 0x20 + i * 0x30 + 0x00, val) ;
  compressed_sections[i].address +=  delta ;

}
*/

// read every original section to know the number and the position
static void
read_sections (void)
{
  struct self_sec s[MAX_PHDR] ;
  struct elf_phdr p ;
  u32 i ;
  u32 j ;
  u32 n_secs ;
  u32 self_offset, elf_offset ;

  memset (s, 0, sizeof s) ;
  for (i = 0, j = 0; i < ehdr.e_phnum; i++) {
    read_section (i, &s[j]) ;
    if (s[j].compressed) {
      j++ ;
    }
  }

  n_secs = j ;
  qsort (s, n_secs, sizeof (*s), qsort_compare) ;

  elf_offset = 0 ;
  self_offset = header_len ;
  j = 0 ;
  i = 0 ;
  while (elf_offset < filesize) {
    if (i ==  n_secs) {
      self_sections[j].offset = self_offset ;
      self_sections[j].size = filesize - elf_offset ;
      self_sections[j].compressed = 0 ;
      self_sections[j].size_uncompressed = filesize - elf_offset ;
      self_sections[j].elf_offset = elf_offset ;
      elf_offset = filesize ;
    } else if (self_offset ==  s[i].offset) {
      self_sections[j].offset = self_offset ;
      self_sections[j].size = s[i].size ;
      compressed_sections[i].size = self_sections[j].size ;
      compressed_sections[i].address = self_sections[j].offset ;
      self_sections[j].compressed = 1 ;
      elf_read_phdr (arch64, elf + phdr_offset + (ehdr.e_phentsize * s[i].idx), &p) ;
      self_sections[j].size_uncompressed = p.p_filesz ;
      self_sections[j].elf_offset = p.p_off ;
      elf_offset = p.p_off + p.p_filesz ;
      self_offset = s[i].next ;
      compressed_sections[i].number = j ;
      compressed_sections[i].compressed = 1 ;
#ifdef DEBUG
      printf ("section number compressed %d size 0x%x\n",
          compressed_sections[0].count, compressed_sections[i].size) ;
#endif
      i++ ;
      compressed_sections[0].count = i ;
    } else {
      elf_read_phdr (arch64, elf + phdr_offset + (ehdr.e_phentsize * s[i].idx), &p) ;
      self_sections[j].offset = self_offset ;
      self_sections[j].size = p.p_off - elf_offset ;
      self_sections[j].compressed = 0 ;
      self_sections[j].size_uncompressed = self_sections[j].size ;
      self_sections[j].elf_offset = elf_offset ;

      elf_offset +=  self_sections[j].size ;
      self_offset +=  s[i].offset - self_offset ;
    }
    j++ ;
  }
  n_sections = j ;
}


static void
write_sections (void)
{
  unsigned int i = 0 ;
  unsigned int level ;
  unsigned long size_compressed = 16 * 1024 * 1024 ;
  u8 *compressed_buffer = NULL ;

  for (i = 0; i < compressed_sections[0].count; i++) {
    level = 7 ;
    if (compressed_sections[i].compressed) {
      size_compressed = 16 * 1024 * 1024 ;
      compressed_buffer = malloc (size_compressed) ;
      if (compress2 (compressed_buffer, &size_compressed,
              elf + phdr[i].p_off, phdr[i].p_filesz, 6) !=  Z_OK) {
        perror ("couldn't compress data") ;
        exit (-1) ;
      }

#if 1
      while ( (int) size_compressed > compressed_sections[i].size ) {
        if (compress2 (compressed_buffer, &size_compressed,
                elf + phdr[i].p_off, phdr[i].p_filesz, level) !=  Z_OK) {
          perror ("couldn't compress data") ;
          exit (-1) ;
        }
        if ( (int) size_compressed > compressed_sections[i].size) {
          if ( level > 9 ) {
            perror ("Compressed data is too big") ;
            exit (-1) ;
          }
        }
        level++;
      }
#else
      {
        int delta, j ;
        delta = size_compressed - compressed_sections[i].size ;

        if (delta % 0x10 !=  0) {
          delta +=  (0x10 - delta % 0x10) ;
        }
        self_size +=  delta ;
        for (j = i + 1; j < compressed_sections[0].count; j++) {
          change_section_offset (j, delta) ;
        }
      }
#endif

      printf ("  ELF section %02x\n    level:    %d\n    size:     0x%x\n    new size: 0x%x\n",
          compressed_sections[i].number,
          (int) level,
          compressed_sections[i].size,
          (unsigned int) size_compressed) ;
      change_section_size (i, size_compressed) ;

      memcpy (self + compressed_sections[i].address, compressed_buffer,
          size_compressed) ;
      compressed_sections[i].size = size_compressed ;
      free (compressed_buffer) ;
    }
  }
  printf ("\n") ;
}

static void
sign_header (void)
{
  u8 *r, *s ;
  u8 hash[20] ;
  u64 sig_len ;

  sig_len = be64 (self + meta_offset + 0x60) ;
  r = self + sig_len ;
  s = r + 21 ;

  sha1 (self, sig_len, hash) ;

  ecdsa_sign (hash, r, s) ;
}

static u64
get_filesize (const char *path)
{
  struct stat st ;

  stat (path, &st) ;

  return st.st_size ;
}

static struct keylist *
self_load_keys (void)
{
  enum sce_key id ;

  switch (type) {
    case 1:
      id = KEY_LV0 ;
      break ;
    case 2:
      id = KEY_LV1 ;
      break ;
    case 3:
      id = KEY_LV2 ;
      break ;
    case 4:
      id = KEY_APP ;
      break ;
    case 5:
      id = KEY_ISO ;
      break ;
    case 6:
      id = KEY_LDR ;
      break ;
    default:
      fail ("invalid type: %08x", type) ;
      return NULL ;
      break ;
  }
  return keys_get (id) ;
}

static void
decrypt_header (void)
{
  struct keylist *klist ;

  klist = self_load_keys () ;
  if (klist ==  NULL)
    return ;

  decrypted = sce_decrypt_header (self, klist) ;

  free (klist->keys) ;
  free (klist) ;
}

static void
show_self_header (void)
{
  printf ("SELF header information\n") ;
  printf ("  auth id:        %08x%08x \n", (u32) (auth_id >> 32),
      (u32) auth_id) ;
  printf ("  vendor id:      %08x%08x\n", (u32) (vendor_id >> 32),
      (u32) vendor_id) ;
  printf ("  app version:    %x.%x.%x\n", (u16) (version >> 48),
      (u16) (version >> 32), (u32) version) ;

  /* take version suffix */
  sprintf (versionsuffix, "%x%02x", (u16) (version >> 48), (u16) (version >> 32)) ;
  printf ("  version suffix: %s ", versionsuffix) ;
  printf ("\n") ;

  printf ("  SDK type:       %s\n", id2name (sdk_type, t_sdk_type, "unknown")) ;
#ifdef DEBUG
  printf ("  type:           %d\n  sdk_type:       %d\n", type, sdk_type) ;
#endif
  printf ("  app type:       %s\n", id2name (type, t_app_type, "unknown")) ;
}

static void
verify_signature (void)
{
  u8 *r, *s ;
  u8 hash[20] ;
  u64 sig_len ;

  sig_len = be64 (self + meta_offset + 0x60) ;
  r = self + sig_len ;
  s = r + 21 ;

  sha1 (self, sig_len, hash) ;

  printf ("Signature of the SELF header\n") ;
  if (ecdsa_verify (hash, r, s)) {
    printf ("  Status: OK\n") ;
  } else {
    printf ("  Status: FAIL\n") ;
  }
  printf ("\n") ;
}

static int
verify_sign_hash (u8 * p, u8 * hashes, u8 * result, int sign)
{
  u64 offset ;
  u64 size ;
  u64 id ;
  u8 *hash, *key ;

  offset = be64 (p + 0x00) ;
  size = be64 (p + 0x08) ;
  id = be32 (p + 0x1c) ;

  if (id ==  0xffffffff) {
    return 0 ;
  }

  hash = hashes + id * 0x10 ;
  key = hash + 0x20 ;

  // XXX: possible integer overflow here
  if (offset > (filesize + header_len)) {
    return 1 ;
  }

  // XXX: possible integer overflow here
  if ( (offset + size) > (filesize + header_len)) {
    return 1 ;
  }

  //Fix all section sign
  if (sign) {
    sha1_hmac (key, self + offset, size, hash) ;
  } else {
    sha1_hmac (key, self + offset, size, result) ;
  }

  if (memcmp (result, hash, 20) ==  0) {
    return 0 ;
  } else {
    return -1 ;
  }
}

static void
calculate_hashes (void)
{
  u32 i ;
  u32 meta_n_hdr ;
  u8 result[20] ;
  u8 *hashes ;

  meta_n_hdr = be32 (self + meta_offset + 0x60 + 0xc) ;
  hashes = self + meta_offset + 0x80 + (0x30 * meta_n_hdr) ;

  for (i = 0; i < meta_n_hdr; i++) {
    verify_sign_hash (self + meta_offset + 0x80 + 0x30 * i,
        hashes, result, SIGN_HASH) ;
  }
}

static void
verify_hashes (void)
{
  u32 meta_n_hdr ;
  u32 i ;
  u8 *hashes ;
  u8 result[20] ;
  int res ;

  meta_n_hdr = be32 (self + meta_offset + 0x60 + 0xc) ;
  hashes = self + meta_offset + 0x80 + 0x30 * meta_n_hdr ;

  printf ("Verifying hashes\n") ;

  for (i = 0; i < meta_n_hdr; i++) {
    printf ("  Section %02d\n", i) ;
    res = verify_sign_hash (self + meta_offset + 0x80 + 0x30 * i,
        hashes, result, VERIFY_HASH) ;
    if (res < 0) {
      printf ("    hash: FAIL\n") ;
    } else if (res > 0) {
      printf ("    hash: wtf phony???\n") ;
    } else {
      printf ("    hash: OK\n") ;
    }
  }

  printf ("\n") ;
}

static void
decrypt (void)
{
  int keyid ;
  struct keylist *klist ;

  klist = self_load_keys () ;
  if (klist ==  NULL)
    return ;

  keyid = sce_decrypt_header (self, klist) ;

  if (keyid < 0) {
    fail ("sce_decrypt_header failed") ;
  }

  if (sce_decrypt_data (self) < 0) {
    fail ("sce_decrypt_data failed") ;
  }

  if (klist->keys[keyid].pub_avail < 0) {
    fail ("no public key available") ;
  }

  if (ecdsa_set_curve (klist->keys[keyid].ctype) < 0) {
    fail ("ecdsa_set_curve failed") ;
  }

  ecdsa_set_pub (klist->keys[keyid].pub) ;
}

int
main (int argc, char *argv[])
{
  FILE *fp ;

  printf ("SELF Rebuilder by Anonymous developers on EFNET\n") ;
  printf ("  SELF and SPRX packer and signer \n") ;
  printf ("  Based on the fail0verflow Tools \n") ;
  printf ("  ! use with caution ! \n") ;

  printf ("\n") ;
  if (argc !=  4) {
    printf ("Usage: %s <input.elf> <output.self> <original.self>\n", argv[0]) ;
    printf ("\tinput.elf: The input ELF to sign \n"
	"\toutput.self: The output SELF/SPRX to generate\n"
	"\toriginal.self: The reference original SELF/SPRX\n") ;
    return -1 ;
  }
  self_size = get_filesize (argv[3]) ;
  self = mmap_file (argv[3]) ;

  parse_self () ;
  decrypt_header () ;

  show_self_header () ;

  read_sections () ;

  get_keys (versionsuffix) ;

  elf_name = argv[1] ;
  self_name = argv[2] ;

  printf ("\nStarting to build self or sprx now...\n") ;

  elf_size = get_filesize (elf_name) ;
  elf = mmap_file (elf_name) ;

  parse_elf () ;

  write_sections () ;

  calculate_hashes () ;
  sign_header () ;
  sce_decrypt_data (self) ;
  sce_encrypt_header (self, &ks) ;
  fp = fopen (self_name, "wb") ;
  if (fp ==  NULL) {
    fail ("fopen (%s) failed", self_name) ;
  }

  if (fwrite (self, self_size, 1, fp) !=  1) {
    fail ("unable to write self") ;
  }

  fclose (fp) ;

  self = mmap_file (self_name) ;

  parse_self () ;
  decrypt () ;
  verify_signature () ;
  verify_hashes () ;

  printf ("  Finished\n") ;

  return 0 ;
}
