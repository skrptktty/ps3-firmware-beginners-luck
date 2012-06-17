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

  size_t new_len;

  u8 *data;
  u8 dat_key[0x10], dat_iv[0x10];
  u8 *out;

  if (argc != 3)
    fail ("usage: dat version.txt index.dat");

  in = fopen (argv[1], "rb");
  if (in == NULL)
    fail ("Unable to open %s", argv[1]);
  fseek (in, 0, SEEK_END);
  len = ftell (in);
  fseek (in, 0, SEEK_SET);

  data = malloc (len);

  if (fread (data, 1, len, in) != len)
    fail ("Unable to read index.dat file");

  fclose (in);

  new_len = len + 32;
  if (new_len % 16 != 0)
    new_len += 16 - (new_len % 16);
  out = malloc (new_len);
  memset (out, '\n', new_len);
  memset (out, '0', 32);
  memcpy (out + 32, data, len);
  sha1 (out + 32, new_len - 32, out);

  if(key_get_simple("dat-key", dat_key, 0x10) < 0)
    fail ("unable to load dat-key.");
  if(key_get_simple("dat-iv", dat_iv, 0x10) < 0)
    fail ("unable to load dat-iv.");

  aes128cbc_enc (dat_key, dat_iv, out, new_len, out);

  memcpy_to_file (argv[2], out, new_len);

  return 0;
}
