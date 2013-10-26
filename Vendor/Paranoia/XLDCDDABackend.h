//
//  XLDCDDABackend.h
//  XLD
//
//  Created by tmkk on 10/11/9.
//  Copyright 2010 tmkk. All rights reserved.
//

#ifndef XLD_CDDA_BACKEND_H
#define XLD_CDDA_BACKEND_H

typedef enum
{
	kTrackTypeAudio,
	kTrackTypeData,
} XLDTrackType;

typedef struct
{
	int start;
	int length;
	int session;
	int pregap;
	XLDTrackType type;
	int preEmphasis;
	int dcp;
	char isrc[13];
} xld_track_t;

typedef struct
{
	int opened;
	int nsectors;
	char *device;
	char *vendor;
	char *product;
	char *revision;
	int fd;
	int numTracks;
	int numSessions;
	int error_retry;
	xld_track_t *tracks;
	char mcn[14];
	int nonBCD;
	int maxSpeed;
	char mediaType[64];
} xld_cdread_t;

#define CDIO_CD_FRAMESIZE_RAW 2352
#define CD_FRAMESIZE_RAW 2352

int xld_cdda_open(xld_cdread_t *disc, char *device);
void xld_cdda_close(xld_cdread_t *disc);
int xld_cdda_read(xld_cdread_t *disc, void *buffer, int beginLSN, int nSectors);
int xld_cdda_read_timed(xld_cdread_t *disc, void *buffer, int beginLSN, int nSectors, int *ms);
int xld_cdda_read_with_c2(xld_cdread_t *disc, void *buffer, int beginLSN, int nSectors);
int xld_cdda_disc_firstsector(xld_cdread_t *disc);
int xld_cdda_disc_lastsector(xld_cdread_t *disc);
int xld_cdda_disc_lastsector_currentsession(xld_cdread_t *disc, int session);
int xld_cdda_sector_gettrack(xld_cdread_t *disc, int sector);
int xld_cdda_tracks(xld_cdread_t *disc);
int xld_cdda_track_firstsector(xld_cdread_t *disc, int track);
int xld_cdda_track_lastsector(xld_cdread_t *disc, int track);
int xld_cdda_track_audiop(xld_cdread_t *disc, int track);
int xld_cdda_speed_set(xld_cdread_t *disc, int speed);
void xld_cdda_read_pregap(xld_cdread_t *disc, int track);
void xld_cdda_read_mcn(xld_cdread_t *disc);
void xld_cdda_read_isrc(xld_cdread_t *disc, int track);
int xld_cdda_sector_getsession(xld_cdread_t *disc, int sector);
int xld_cdda_measure_cache(xld_cdread_t *disc);
int xld_cdda_set_max_speed(xld_cdread_t *disc, int speed);

/// CDDA compatibility

typedef xld_cdread_t cdrom_drive_t;
typedef xld_cdread_t cdrom_drive;

extern int cdda_close(cdrom_drive *d);
extern int cdda_open(cdrom_drive *d);
extern long cdda_read(cdrom_drive *d, void *buffer,
					  long beginsector, long sectors);
extern long cdda_read_timed(cdrom_drive *d, void *buffer,
							long beginsector, long sectors, int *milliseconds);

extern long cdda_track_firstsector(cdrom_drive *d,int track);
extern long cdda_track_lastsector(cdrom_drive *d,int track);
extern long cdda_tracks(cdrom_drive *d);
extern int cdda_sector_gettrack(cdrom_drive *d,long sector);
extern int cdda_track_channels(cdrom_drive *d,int track);
extern int cdda_track_audiop(cdrom_drive *d,int track);
extern int cdda_track_copyp(cdrom_drive *d,int track);
extern int cdda_track_preemp(cdrom_drive *d,int track);
extern long cdda_disc_firstsector(cdrom_drive *d);
extern long cdda_disc_lastsector(cdrom_drive *d);

#endif
