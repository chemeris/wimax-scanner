/****************************************************************************/
/*! \file		getopt_msvc.c
	\brief		getopt function emulation for MSVC
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	1.0
     
	getopt function emulation for MSVC.
*/
/*****************************************************************************/

/*****************************************************************************
	Copyright (C) 2011  Iliya Voronov

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
	USA
*****************************************************************************/

#ifndef _GETOPT_MSVC_
#define _GETOPT_MSVC_


#include <stdio.h>
#include <string.h> 
 

int		opterr;			// global - if nonzero print errors - not implemented
int		optopt;			// global - unknown option character - not implemented
int		optind = 0; 	// global - next argv index
char	*	optarg;			// global - currnet option argument pointer


inline int getopt (int argc, char **argv, const char *options)
{
	static char *next = NULL;
	char c;
	const char *cp;

	if (optind == 0)
		next = NULL;

	optarg = NULL;

	if (next == NULL || *next == '\0')
	{
		if (optind == 0)
			optind++;

		if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0' )
		{
			optarg = NULL;
			if (optind < argc)
				optarg = argv[optind];
			return EOF;
		}

		if (strcmp(argv[optind], "--" ) == 0)
		{
			optind++;
			optarg = NULL;
			if (optind < argc)
				optarg = argv[optind];
			return EOF;
		}

		next = argv[optind];
		next++;		// skip past -
		optind++;
	}

	c = *next++;
	cp = strchr(options, c);

	if (cp == NULL || c == ':')
		return '?';

	cp++;
	if (*cp == ':')
	{
		if (*next != '\0')
		{
			optarg = next;
			next = NULL;
		}
		else if (optind < argc)
		{
			optarg = argv[optind];
			optind++;
		}
		else
		{
			return '?';
		}
	}

	return c;
}



#endif // #ifndef _GETOPT_MSVC_