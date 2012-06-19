// Copyright 2011 Ninjas
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

int
main (int argc, char *argv[])
{
  FILE *in = NULL;

  size_t len;

  u8 *data;
  u8 dat_key[0x10], dat_iv[0x10];
  u8 digest[20];

  if (argc != 3)
    fail ("usage: undat index.dat version.txt");

  in = fopen (argv[1], "rb");
  if (in == NULL)
    fail ("Unable to open %s", argv[1]);
  fseek (in, 0, SEEK_END);
  len = ftell (in);
  fseek (in, 0, SEEK_SET);

  if (len < 0x1f)
    fail ("invalid index.dat size : 0x%X", len);

  data = malloc (len);

  if (fread (data, 1, len, in) != len)
    fail ("Unable to read index.dat file");

  fclose (in);

  if(key_get_simple("dat-key", dat_key, 0x10) < 0)
    fail ("unable to load dat-key.");
  if(key_get_simple("dat-iv", dat_iv, 0x10) < 0)
    fail ("unable to load dat-iv.");

  aes128cbc (dat_key, dat_iv, data, len, data);
  sha1 (data + 32, len - 32, digest);

  if (memcmp (data, digest, 20) != 0)
    fail ("SHA1 mac mismatch");

  memcpy_to_file (argv[2], data + 32, len - 32);

  return 0;
}
