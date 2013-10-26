/*****************************************************************************************
Monkey's Audio MACLib.h (include for using MACLib.lib in your projects)
Copyright (C) 2000-2013 by Matthew T. Ashland   All Rights Reserved.

Overview:

There are two main interfaces... create one (using CreateIAPExxx) and go to town:

    IAPECompress - for creating APE files
    IAPEDecompress - for decompressing and analyzing APE files

Note(s):

Unless otherwise specified, functions return ERROR_SUCCESS (0) on success and an 
error code on failure.

The terminology "Sample" refers to a single sample value, and "Block" refers 
to a collection of "Channel" samples.  For simplicity, MAC typically uses blocks
everywhere so that channel mis-alignment cannot happen. (i.e. on a CD, a sample is
2 bytes and a block is 4 bytes ([2 bytes per sample] * [2 channels] = 4 bytes))

License:

http://monkeysaudio.com/license.html

Questions / Suggestions:

Please direct questions or comments to this email address:
mail at monkeysaudio dot com
[ due to a large volume of email and spams, a response can not be guaranteed ]
*****************************************************************************************/

#define PLATFORM_APPLE
#define __forceinline inline
#include <MAC/All.h>
#include <MAC/MACLib.h>