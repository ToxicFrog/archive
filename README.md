## System Shock 1 in 800x600 and 1024x768 [v2.0]

(This text is lazily converted from the original post I made on the Through the Looking Glass forums. You can still find it at http://www.ttlg.com/forums/showthread.php?t=100041)

A while ago, I read something about how SS1 could have supported resolutions higher than 640x480, but they disabled those in the final build because no computer at the time could run them playably.
This got me thinking: getting SS1 working at higher resolutions might be as simple as finding the SVGA mode set call and changing its parameters.
It turned out to be a bit more complicated than that (in some ways; getting the interface working, on the other hand, was far easier than I expected), but here it is: SS1 with support for high resolution rendering.

Version 2.0 has been released!
This version takes the form of a seperate patch (about 550kb) which can be used to override the 640x400 and 640x480 modes seperately on both Mok's patched version and the original CDSHOCK.EXE.

### Usage

`ss1hr CDSHOCK.EXE` (or drag-dropping CDSHOCK.EXE onto it, for you GUI addicts) will give you an interactive interface from which you can adjust the settings.

If you want to use it in batch mode, `ss1hr CDSHOCK.EXE <string of numbers>` will run non-interactively, behaving as though you had entered those numbers as the menu options (as in, `ss1hr CDSHOCK.EXE 13244`). For example, some useful sequences:

    34      Reset to defaults
    114     Reset 640x400 to default
    224     Reset 640x480 to default
    13244   640x400 -> 800x600, 640x480 -> 1024x768
    15224   640x400 -> 1280x1024, 640x480 to default
    The basic commands being (if you're too lazy to look at the menus :p )
    1M      Map 640x400 to mode M
    2M      Map 640x480 to mode M
    3       Reset all to defaults
    4       Exit

And the mode numbers (the ones in the menu, not the actual SVGA mode numbers!):

    1    640x400
    2    640x480
    3    800x600
    4    1024x768
    5    1280x1024

Note that failure to end with 4 (exit) may result in crashes, lost settings, etc (but any damage to your copy of SS1 can be corrected with 3, reset to defaults).

The only real difference from the technical details below is that the code is left unchanged, and instead the SVGA mode number table at 0x00172620 (original) or 0x001460D4 (Mok's) is changed.

### Known bugs

  * there's some intermittent but serious chop in 1024x768; I think this is a memory page-flipping issue, but I'm not sure. If it's too slow to be playable try the 800x600 version.
  * no widescreen support yet (is this possible?)
  * Movies haven't been rescaled, so they still play at 640x480 in the upper left corner of the screen. They also seem to exhibit some corruption (horizontal streaks across the movie) - if you're seeing them for the first time you might want to watch the movies using 640x480.

## Technical details

The information below is obsolete, applying to version 1.0 of SS1-highres, which consisted of several different, hardpatched copies. It is preserved here for informational purposes.

The actual implementation is kind of ugly. 320x240 and 320x400 should behave normally. 640x400 or 640x480 will actually kick it into high-resolution mode. There are two such modes available, 800x600x8 and 1024x768x8; since this was done, in effect, by replacing the 640x* modes with a single new mode, there are actually two versions of CDSHOCK.EXE, each one supporting a different mode: CDSH800.EXE and CDSH1024.EXE.

If all you want to do is play in high-res you don't need to read this; this is for people interested in how I did it.
(note: all offsets are within CDSHOCK.EXE and have no relation to what the program looks like once it's loaded and relocated in memory.)

    Offsets:
      Original CDSHOCK.EXE:
        E1661   ; interface control calls
        15815B  ; set video mode
        16B5B0  ; resolution/bit depth tables
      
      Mok's patched binary:
        B5115   ; interface control calls
        12BC0F  ; set video mode for in-game SVGA
        13f070  ; resolution/bit depth tables

### The SVGA mode switch

At 0x0012BB68 is a function which is used to do a mode switch to an SVGA mode specified by the caller[?]. The actual interesting code starts at 0x0012BC0E, using INT 31 (DPMI SERVICES) to invoke DPMI function 300h (SIMULATE REAL MODE INTERRUPT), simulating INT 10h with AX=4f02 (SVGA SET VIDEO MODE) to change modes:

                                ; 4f02h = SVGA (4f) SET VIDEO MODE (02)
    66 b8 02 4f                 mov     ax, 4F02h
                                ; load mode # into EBX
    0f b7 1c 4d 7c 2f 01 00     movzx   ebx, word ptr ds:12F7Ch[ecx*2]
    c1 e2 0f                    shl     edx, 0Fh
    57                          push    edi
                                ; load pointer to real-mode call struct into EDI
    bf b0 28 01 00              mov     edi, 128B0h
    0b da                       or      ebx, edx
                                ; store AX,BX into struct
    66 89 47 1c                 mov     [edi+1Ch], ax
    89 5f 10                    mov     [edi+10h], ebx
    51                          push    ecx
                                ; real-mode interrupt to simulate (10h)
    b3 10                       mov     bl, 10h
                                ; paragraphs to copy from real-mode stack (0)
    66 b9 00 00                 mov     cx, 0
                                ; DPMI function (300h SIMULATE REAL-MODE INTERRUPT)
    66 b8 00 03                 mov     ax, 300h
    32 ff                       xor     bh, bh
                                ; DPMI services, AX = function #
    cd 31                       int     31h
                                ; cleanup
    59                          pop     ecx

This was changed by removing the XOR BH,BH (which is unecessary) and the OR EBX,EDX (which is unecessary in the new code, since the video mode # is hardcoded). This freed up 4 bytes which could be used to set BX just before it gets copied into the real-mode call struct:

                                ; 4f02h = SVGA (4f) SET VIDEO MODE (02)
    66 b8 02 4f                 mov     ax, 4F02h
                                ; load mode # into EBX
    0f b7 1c 4d 7c 2f 01 00     movzx   ebx, word ptr ds:12F7Ch[ecx*2]
    c1 e2 0f                    shl     edx, 0Fh
    57                          push    edi
                                ; load pointer to real-mode call struct into EDI
    bf b0 28 01 00              mov     edi, 128B0h
    ; REMOVED 0b da             or      ebx, edx
                                ; BX = 0x0103 (mode 103h, 800x600x8)
    b3 03                       mov     bl, 03h ; ADDED
    b7 01                       mov     bh, 01h ; ADDED
                                ; store AX,BX into struct
    66 89 47 1c                 mov     [edi+1Ch], ax
    89 5f 10                    mov     [edi+10h], ebx
    51                          push    ecx
                                ; real-mode interrupt to simulate (10h)
    b3 10                       mov     bl, 10h
                                ; paragraphs to copy from real-mode stack (0)
    66 b9 00 00                 mov     cx, 0
                                ; DPMI function (300h SIMULATE REAL-MODE INTERRUPT)
    66 b8 00 03                 mov     ax, 300h
    ; REMOVED 32 ff             xor     bh, bh
                                ; DPMI services, AX = function #
    cd 31                       int     31h
                                ; cleanup
    59                          pop     ecx

Thus, whenever it does an SVGA mode change, it's forced into the new mode I picked for it (800x600 in this case; changing MOV BL,03h to MOV BL,05h is used in the 1024x768 version). This is ugly, hackish and inelegant, but it works.

### The LFB parameters

Just changing the resolution does not result in a usable display, because the renderer completely ignores the values returned by INT 10h/AX=4f01h (SVGA GET VIDEO MODE INFORMATION) and instead uses values from a hardcoded table to determine the width, length and depth of the framebuffer. This table starts at 0x0013F070 and appears to consist of 5-byte structs of the following format:

    0000    uint16_t    screen width
    0002    uint16_t    screen height
    0004    uint8_t     bits per pixel? always 8

So, making the renderer happy was a simple matter of finding 80 02 E0 01 08 in this table (640x480x8) and changing it to 20 03 58 02 08 (800x600x8) or 00 04 00 03 08 (1024x768x8), then doing the same for 80 02 90 01 08 (640x400x8).

### The interface

This was actually the first part I got working, having stumbled upon it while looking for something completely different (the SVGA mode switch). At 0x000B50F2 there's a series of function calls, looking something like this (in C):

    baz(320,400)      // SS1
    baz(640,400)      // SS1,SVGA mode 100h
    baz(640,480)      // SS1,SVGA mode 101h
    baz(1024,768)     // SVGA mode 107h
    if(thingy == 3) {
      baz(320,240)    // SS1
      baz(640,240)
    } else {
      baz(320,100)    // are these even valid modes?
      baz(640,350)
    }

These control, albeit in ways I don't fully understand, the interface scaling and positioning parameters. It's very interesting to note that there's already an entry in place for 1024x768. Replacing the 640,400 and 640,480 calls with 800,600 (for CDSH800) or 1024,768 (for CDSH1024) causes the interface to be properly scaled and all buttons and suchlike to be properly positioned (although the text isn't scaled, resulting in a lot of empty space in the buttons!).
