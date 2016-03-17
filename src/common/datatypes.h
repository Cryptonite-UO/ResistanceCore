/**
* @file datatypes.h
* @brief Sphere standard data types.
*/

#pragma once
#ifndef DATATYPES_H
#define DATATYPES_H

#include <stdint.h>

typedef long long				LLONG;
typedef unsigned long long		ULLONG;


#ifdef _WIN32

	#include <winsock2.h>		// winsock2.h and windows.h are already included in os_windows.h (included by common.h), 
								//	but including datatypes.h and not common.h may be needed as well, so this way we are covering this eventuality.
	#include <windows.h>		// Including this because <minwindef.h> can't be directly included.

#else	//	assume unix if !_WIN32

	#undef BYTE
	#undef WORD
	#undef DWORD
	#undef UINT
	#undef LONGLONG
	#undef ULONGLONG
	#undef LONG
	#undef INT8
	#undef INT16
	#undef INT32
	#undef INT64
	#undef UINT8
	#undef UINT16
	#undef UINT32
	#undef UINT64
	#undef BOOL
	
	typedef uint8_t				BYTE;		// 8 bits
	typedef uint16_t			WORD;		// 16 bits
	typedef uint32_t			DWORD;		// 32 bits

	typedef unsigned int		UINT;
	typedef long long			LONGLONG; 	// this must be 64 bits
	typedef unsigned long long	ULONGLONG;
	typedef long				LONG;		// never use long! use int or long long!

	/*
	Use the following types only if you know that you need them.
	These types have a specified size, while standard data types (short, int, etc) haven't:
	for example, sizeof(int) is definied to be >= sizeof(short) and <= sizeof(long), so it hasn't a fixed size;
	nevertheless, most of the times using int instead of INT32 would suit you.
	This concept is valid for both non unix and unix OS.
	*/
	typedef	int8_t				INT8;
	typedef	int16_t				INT16;
	typedef	int32_t				INT32;
	typedef	int64_t				INT64;
	typedef	uint8_t				UINT8;
	typedef	uint16_t			UINT16;
	typedef	uint32_t			UINT32;
	typedef	uint64_t			UINT64;

	typedef	unsigned short		BOOL;
	typedef intptr_t			INT_PTR, *PINT_PTR;
	typedef uintptr_t			UINT_PTR, *PUINT_PTR;

	#include <wchar.h>
	#ifdef UNICODE
		typedef	wchar_t			TCHAR;
	#else
		typedef char			TCHAR;
	#endif
	typedef wchar_t				WCHAR;
	typedef wchar_t *			LPWSTR;
	typedef const wchar_t *		LPCWSTR;
	typedef	char *				LPSTR;
	typedef	const char *		LPCSTR;
	typedef	TCHAR *				LPTSTR;
	typedef const TCHAR *		LPCTSTR;

#endif

#endif