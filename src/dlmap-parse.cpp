// A very simple DL-MAP parser.
// Copyright (C) 2011  Alexander Chemeris
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
// USA

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

// Usage:
//   cat bits.txt | ./dlmap-parse

// If this TSV_OUTPUT is defined, then output is in TSV format,
// ready to be used by do_PDU_extract.m script as input.
//#define TSV_OUTPUT

unsigned bits2unsigned(char *bits, size_t bits_num)
{
    unsigned res = 0;
    assert(bits_num <= 32);
    for (int i=0; i<bits_num; i++)
    {
        res = (res<<1)|bits[i];
    }
    return res;
}

int parse_dlmap_ie(unsigned burst_num, char *bits, size_t bits_num)
{
    int bits_parsed;
    unsigned diuc;

    if (bits_num < 4) return -1;
    diuc = bits2unsigned(bits, 4);
    bits_parsed = 4;
#ifndef TSV_OUTPUT
    printf("%d DIUC %d:", burst_num, diuc);
#endif
    if (diuc == 15)
    {
        if (bits_num < 16) return -1;
        unsigned length = bits2unsigned(&bits[8], 4);
        bits_parsed += 8+8*length;
    }
    else if (diuc == 14)
    {
        if (bits_num < 16) return -1;
        unsigned length = bits2unsigned(&bits[8], 8);
        bits_parsed += 12+8*length;
    }
    else
    {
        if (bits_num < 32) return -1;
        unsigned symbol_offset = bits2unsigned(&bits[4], 8);
        unsigned subchannel_offset = bits2unsigned(&bits[12], 6);
        unsigned boosting = bits2unsigned(&bits[18], 3);
        unsigned symbols_num = bits2unsigned(&bits[21], 7);
        unsigned subchannels_num = bits2unsigned(&bits[28], 6);
        unsigned repetition = bits2unsigned(&bits[34], 2);
        if (repetition == 0)
        {
            repetition = 1;
        }
        else
        {
            repetition = repetition*2;
        }
#ifndef TSV_OUTPUT
        printf("  offset: %d sym + %d subch  len: %d sym + %d subch   repetition: %d   boosting: %d",
               symbol_offset, subchannel_offset, symbols_num, subchannels_num, repetition, boosting);
#else
        printf("%d %d %d %d %d %d %d %d\n",
               burst_num, diuc, symbol_offset, subchannel_offset, symbols_num, subchannels_num, repetition, boosting);
#endif
        bits_parsed += 32;
    }

#ifndef TSV_OUTPUT
    printf(" parsed: %d bits/%d nibles\n", bits_parsed, bits_parsed/4);
#endif

    return bits_parsed;
}

int parse_dlmap(unsigned burst_num, char *bits, size_t bits_num)
{
    unsigned dlmap_length;
    unsigned ie_count;

    if (bits_num < 11*8) return -1;

    // Parse header
    // -- We support only Compressed DL-MAP at this moment.
    if (bits[0] != 1 || bits[1] != 1 || bits[2] != 0) return -1;
    // -- DL-MAP length
    dlmap_length = bits2unsigned(&bits[5], 11);
    if (bits_num < dlmap_length*8) return -1;
    // -- DL-MAP IE Count
    ie_count = bits2unsigned(&bits[80], 8);
#ifndef TSV_OUTPUT
    printf(" length = %d, IE Count = %d\n", dlmap_length, ie_count);
#endif

    // Parse DL-MAP IEs
    int bit_ptr = 88;
    for (int i=0; i < ie_count; i++)
    {
        int bits_parsed = parse_dlmap_ie(burst_num, &bits[bit_ptr], dlmap_length*8-bit_ptr);
        if (bits_parsed <= 0) return -1;
        bit_ptr += bits_parsed;
    }

    return 0;
}

int main()
{
    FILE *fin = stdin;
    while (!feof(fin))
    {
        char line[10240];
        size_t line_len;

        //
        // Read line from the file
        //
        if (fgets(line, sizeof(line), fin) == NULL) break;
        line_len = strlen(line);
        // Skip empty lines
        if (line_len == 0) continue;
        // Remove newline at the end of the string
        if (line[line_len-1] == '\n')
        {
            line[line_len-1] = '\0';
            line_len--;
            // Skip empty lines
            if (line_len == 0) continue;
        } else {
            if (!feof(fin))
            {
                fprintf(stderr, "ERROR: line buffer is too small!\n");
                break;
            }
        }

        //
        // Parse the line
        //
        const char *burst_num_str;  // Burst number
        unsigned burst_num;         // Burst number
        const char *burst_type_str; // Burst type
        const char *burst_len_str;  // Burst length (in subchannels)
        const char *burst_data_str; // Burst binary data
        char *line_ptr = line; // Temp pointer
        // Burst number
        while (*line_ptr == ' ' || *line_ptr == '\t') line_ptr++;
        burst_num_str = strsep(&line_ptr, " \t");
        burst_num = atoi(burst_num_str);
        // Burst type
        if (line_ptr == NULL)
        {
            fprintf(stderr, "ERROR: Error while parsing input for burst type!\n");
            break;
        }
        while (*line_ptr == ' ' || *line_ptr == '\t') line_ptr++;
        burst_type_str = strsep(&line_ptr, " \t");
        // Burst length
        if (line_ptr == NULL)
        {
            fprintf(stderr, "ERROR: Error while parsing input for burst len!\n");
            break;
        }
        while (*line_ptr == ' ' || *line_ptr == '\t') line_ptr++;
        burst_len_str = strsep(&line_ptr, " \t");
        // Burst data
        if (line_ptr == NULL)
        {
            fprintf(stderr, "ERROR: Error while parsing input for burst data!\n");
            break;
        }
        burst_data_str = line_ptr;

//        printf("TYPE: %s\n", burst_type_str);
//        printf("LEN: %s\n", burst_len_str);
//        printf("DATA: %s\n", burst_data_str);

        //
        // Convert DL-MAP from string to bits
        //
        if (strcmp(burst_type_str, "DL-MAP") != 0) continue;
#ifndef TSV_OUTPUT
        printf("%d DL-MAP", burst_num);
#endif
        char burst_bits[10240];
        size_t burst_bits_num = strlen(burst_data_str);
        for (int i=0; i<burst_bits_num; i++)
        {
            if (burst_data_str[i] != '0' && burst_data_str[i] != '1')
            {
                fprintf(stderr, "ERROR: Non-binary burst data!\n");
                break;
            }
            burst_bits[i] = (burst_data_str[i] == '1')?1:0;
        }

        //
        // Process DL-MAP
        //
        parse_dlmap(burst_num, burst_bits, burst_bits_num);
    }
}
