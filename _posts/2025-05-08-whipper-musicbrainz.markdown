---
layout: post
title:  "Contribute to MusicBrainz when ripping CDs with support of gnudb/FreeDB"
date:   2025-05-08 00:00:00 +0100
categories: music cd rip CDDB
---

I rip my CD collection with [whipper](https://github.com/whipper-team/whipper/).
However, most of this guide also applies to other ripping programs.

I am using whipper, because it is a command line tool, supports bit accurate
ripping with [AccurateRip](https://www.accuraterip.com/) and lossless encoding
with [FLAC](https://xiph.org/flac/).
The track titles are retrieved from [MusicBrainz](https://www.musicbrainz.com/),
which currently provides the highest quality meta data due to its strict review
process.

However, as of 2025 MusicBrainz comprises only 1.1 million disc IDs, whereas
the [Global Network Universal Database (gnudb)](https://gnudb.org/) comprises
5.5 million disc IDs. Gnudb is the successor of FreeDB which was shutdown in
2020, which is the successor of the first database for track listings, the
Compact Disc Database (CDDB) from 1994. Due to its long history it contains
nearly every available CD, but also lots of duplicates and inconsistencies.

Whipper and other ripping programs decided to use the higher quality data of
MusicBrainz and encourage users to grow the MusicBrainz database by submitting
missing CD releases. In this article I provide some help to do so.
There are 4 cases:

 1. MusicBrainz entry with disc ID exists (90% of my CD collection)
 2. MusicBrainz entry without disc ID (6%)
 3. Not in MusicBrainz, but in gnudb (3.5%)
 4. CD is not in any database (0.5%

The next sections describe, how to deal with these cases. My main contribution
is a script to make case 3 much easier.



## 1. Automatic: Disc ID found in MusicBrainz

For the majority of CDs ripping is simple: whipper reads the length of the
tracks from the CD and computes a disc ID of it. The disc ID is found in the
MusicBrainz database and whipper uses the attached metadata to name the tracks.



## 2. Add disc ID to existing MusicBrainz entry

For most of the remaining CDs, there is an entry in MusicBrainz, but no disc ID
is connected to the entry. Then whipper refuses to rip the CD and instead
provides an URL to submit the disc ID to MusicBrainz. *If your favourite ripping
program does not provide the submit URL, you can use the script from the next
section to compute it.*

Before using the URL you have to create an account and log in the MusicBrainz
website. Then you can click on the URL and MusicBrainz asks you to search the
appropriate CD release entry:

![MusicBrainz Lookup CD](/assets/images/musicbrainz_lookup_cd.png)

If the CD is from one artist, you can search the artist and choose the suitable
album release. Compilations with various artists may be hard to find. If you
do not find a match, continue with the script of the next section. It provides
more information than the link and sometimes this helped me to find a
suitable CD release.



## 3. My script: submit gnudb data to MusicBrainz

Since gnudb contains 5 times as many disc IDs than MusicBrainz, it is likely
that the CD is in gnudb. Whipper has no automatic fall back to gnudb metadata
if MusicBrainz metadata is not available. Therefore I wrote a 
[script](https://github.com/bobbl/sammelsurium/seed_mb_from_gnudb/) for it.
It can be found in github.
When you run the script while the CD is in your drive, it computes the disc
IDs and queries gnudb for the track list. The received data is written to a HTML
file. The name of the HTML file is `seed_FOO.html` where FOO is the title of
the CD. Open the HTML file to check and edit the data:

![MusicBrainz seed form](/assets/images/musicbrainz_seed_form.png)

By clicking on **seed** the data is submitted to MusicBrainz. After confirming that
you really want to add something to MusicBrainz you are forwarded to the
**Add release** page. Now you can complete the metadata for this CD release an
add it to MusicBrainz. How this works is beyond the scope of this article.

### Multiple CD sets

The script also supports submitting a multi-CD volumes. Put the first CD in the
drive and start the script with the argument `-m`. After reading the track
information, it asks, if another disc should be added. Insert the next CD and
press enter. After the last CD type anything e.g. `q` and hit enter to leave
the script.


### Technical background of the script

The python script uses [discid](https://pypi.org/project/discid/), a python
wrapper for [libdiscid](https://musicbrainz.org/doc/libdiscid) from
MusicBrainz to compute the disc IDs for gnudb and MusicBrainz and the submit
URL.

Then it uses
[`freedb.py` from Audio Tools](https://audiotools.sourceforge.net/programming/audiotools_freedb.html)
to access gnudb, exracts the track listing and generates a HTML file.
The
[template for the HTML code](https://musicbrainz.org/static/tests/seed-love-bug.html)
is provided by the
[MusicBrainz wiki on seeding a new release](https://wiki.musicbrainz.org/Development/Seeding/Release_Editor).



## 4. Hard: Add entry from scratch

Sorry, I can't help. You have to enter everything by hand.



## Summary of ripping procedure

  * Put CD in disc drive
  * Run whipper
  * If successfully ripped -> done
  * Copy MusicBrainz lookup URL to web browser
  * Search on MusicBrainz for artist and release
  * If found -> attach disc ID to release and run whipper afterwards
  * Run `seed_mb_from_gnudb.py`
  * If multiple disc set, run with argument `-m` and change CD when prompted
  * If not found in gnudb -> enter release by hand
  * Open generated HTML file in browser
  * Check and modify track listings and submit by clicking on the button
  * Complete release submission on MusicBrainz website
  * Run whipper again


