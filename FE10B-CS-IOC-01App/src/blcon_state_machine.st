program blcon_state_machine ("pwr=300")

/*option +r;*/
option +s;

/*
AUTHOR: Ian Gillingham
TITLE: Front End Valve Group Sequence State Machine
DATE VERSION RELEASED ON:
DESCRIPTION:

$Author: ig43 $
$Date: 2011-09-08 08:55:08 +0100 (Thu, 08 Sep 2011) $
$Id: vacuum_state_machine.st 67214 2011-09-08 07:55:08Z ig43 $
$Name: post_review_2 $
$Revision: 67214 $

IJG 19/09/12

Open and Close sequences for all vacuum valves
*/

/* external inputs ************************************************************/

string FV1_sta;
assign FV1_sta to "{dom}-VA-FVALV-01:STA";
string FV1_ilk;
assign FV1_ilk to "{dom}-VA-FVALV-01:ILKSTA";
string FV1_con;
assign FV1_con to "{dom}-VA-FVALV-01:CON";
string FV1_lastcon;
assign FV1_lastcon to "{dom}-VA-FVALV-01:LASTCON";
string V1_sta;
assign V1_sta to "{dom}-VA-VALVE-01:STA";
string V1_ilk;
assign V1_ilk to "{dom}-VA-VALVE-01:ILKSTA";
string V1_con;
assign V1_con to "{dom}-VA-VALVE-01:CON";
string V1_lastcon;
assign V1_lastcon to "{dom}-VA-VALVE-01:LASTCON";

/* These are assigned in the entry section later */
string V2_sta;
string V2_ilk;
string V2_con;
string V2_lastcon;
assign V2_sta to "";
assign V2_ilk to "";
assign V2_con to "";
assign V2_lastcon to "";

string MPS_PERMT_reset;
assign MPS_PERMT_reset to "{dom}-MP-PERMT-01:RESET";

unsigned short valve_driver_pv;
assign valve_driver_pv to "{dom}-VA-GVALV-01:CTL";
unsigned short valve_status_pv;
assign valve_status_pv to "{dom}-VA-GVALV-01:STS";

/* PVs for restricted beamline control */
unsigned short beamline_driver_pv;
assign beamline_driver_pv to "{dom}-CS-BEAM-01:CTL";
uint32_t beamline_status_pv;
assign beamline_status_pv to "{dom}-CS-BEAM-01:STS";

/* The PV from beamline_access.template which reflects the overall status of the beam path */
string beam_path_pv;
assign beam_path_pv to "{dom}-CS-BEAM-01:PATH";


string ABS1_con;
assign ABS1_con to "{dom}-RS-ABSB-01:CON";
string ABS1_lastcon;
assign ABS1_lastcon to "{dom}-RS-ABSB-01:LASTCON";
string ABS1_sta;
assign ABS1_sta to "{dom}-RS-ABSB-01:STA";
string ABS1_ilk;
assign ABS1_ilk to "{dom}-RS-ABSB-01:ILKSTA";

/*
* A PV has been added to allow a valve device to inhibit Open requests
* this is now incorporated into the state machine to report and 
* interlock error if it is inhibiting.
*/
string ABS1_openallowed;
assign ABS1_openallowed to "{dom}-RS-ABSB-01:OPENALLOWED";

string ABS2_con;
string ABS2_lastcon;
string ABS2_sta;
string ABS2_ilk;
assign ABS2_con to "";
assign ABS2_lastcon to "";
assign ABS2_sta to "";
assign ABS2_ilk to "";

/*
 For beamline control of beam admittance, the downstream absorber needs actuating.
 For most front-ends this will be ABSB-02, but some have only one absorber, so will be ABSB-01 in this situation.
 
 === For this front-end, ABSB_BL_con is hard-coded to ABSB-01 ===
*/
string ABSB_BL_con;
assign ABSB_BL_con to "{dom}-RS-ABSB-01:CON";
string ABSB_BL_lastcon;
assign ABSB_BL_lastcon to "{dom}-RS-ABSB-01:LASTCON";
string ABSB_BL_sta;
assign ABSB_BL_sta to "{dom}-RS-ABSB-01:STA";
string ABSB_BL_ilk;
assign ABSB_BL_ilk to "{dom}-RS-ABSB-01:ILKSTA";

string SHTR1_con;
assign SHTR1_con to "{dom}-PS-SHTR-01:CON";
string SHTR1_sta;
assign SHTR1_sta to "{dom}-PS-SHTR-01:STA";
string SHTR1_ilk;
assign SHTR1_ilk to "{dom}-PS-SHTR-01:ILKSTA";

string SHTR2_con;
assign SHTR2_con to "{dom}-PS-SHTR-02:CON";
string SHTR2_lastcon;
assign SHTR2_lastcon to "{dom}-PS-SHTR-02:LASTCON";
string SHTR2_sta;
assign SHTR2_sta to "{dom}-PS-SHTR-02:STA";
string SHTR2_ilk;
assign SHTR2_ilk to "{dom}-PS-SHTR-02:ILKSTA";

#define REQ_IDLE 0
#define REQ_OPEN 1
#define REQ_CLOSE 2
#define REQ_ABORT 3
#define REQ_START 1
#define REQ_STOP 2
#define REQ_OPEN_VALVE2 4
#define REQ_CLOSE_VALVE2 5

/*  Associated with beamline_driver_pv */
#define BLREQ_BEAM_IDLE  0
#define BLREQ_BEAM_OPEN  1
#define BLREQ_BEAM_CLOSE 2
#define BLREQ_BEAM_ABORT 3

#define NPUMPS 5

/* Definitions for the bit patterns for status PV 16 bit words */
#define PVREG_VAC_INIT    0x0001
#define PVREG_VAC_COMP    0x0002
#define PVREG_VAC_ABRT    0x0004
#define PVREG_VAC_OPEN    0x0008
#define PVREG_VAC_CLOSE   0x0010
#define PVREG_VAC_ARM     0x0020
#define PVREG_VAC_TIMEOUT 0x0040

#define PVREG_VAC_V01   0x0080
#define PVREG_VAC_V02   0x0100
#define PVREG_VAC_FFLAP 0x0200
#define PVREG_VAC_ABS01 0x0200
#define PVREG_VAC_ABS02 0x0400

#define PVREG_BEAM_INIT  		0x00000001
#define PVREG_BEAM_COMP  		0x00000002
#define PVREG_BEAM_ABRT  		0x00000004
#define PVREG_BEAM_OPEN  		0x00000008
#define PVREG_BEAM_CLOSE 		0x00000010
#define PVREG_BEAM_ARM	 		0x00000020
#define PVREG_BEAM_INTERLOCK 	0x00000040
#define PVREG_BEAM_TIMEOUT 		0x00000080
#define PVREG_BEAM_RESET 		0x00000100

#define PVREG_BEAM_FV   	0x00010000
#define PVREG_BEAM_V1     	0x00020000
#define PVREG_BEAM_V2     	0x00040000
#define PVREG_BEAM_ABSB    	0x00080000
#define PVREG_BEAM_SHTR1	0x00100000
#define PVREG_BEAM_SHTR2	0x00200000
#define PVREG_BEAM_ACTIVE	0x80000000


#define PVREG_PUMP_INIT  0x0001
#define PVREG_PUMP_COMP  0x0002
#define PVREG_PUMP_ABRT  0x0004
#define PVREG_PUMP_START 0x0008
#define PVREG_PUMP_STOP  0x0010
#define PVREG_PUMP_DELAY 0x0020
#define PVREG_PUMP_PWR   0x0040

#define PVREG_PUMP_IONP01   0x0080
#define PVREG_PUMP_IONP02   0x0100
#define PVREG_PUMP_IONP03   0x0200
#define PVREG_PUMP_IONP04   0x0400
#define PVREG_PUMP_IONP05   0x0800


#define PVREG_ERROR_NOERROR   0x0
#define PVREG_ERRNO_INTLK     0x1
#define PVREG_ERRNO_TIMEOUT   0x2
#define PVREG_ERRNO_FAULT     0x3


monitor valve_driver_pv;
monitor beamline_driver_pv;
monitor FV1_sta;
monitor FV1_ilk;
monitor FV1_lastcon;
monitor V1_sta;
monitor V1_ilk;
monitor V1_lastcon;
monitor ABS1_sta;
monitor ABS1_ilk;
monitor ABS1_openallowed;
monitor ABS1_lastcon;
monitor ABSB_BL_sta;
monitor ABSB_BL_ilk;
monitor ABSB_BL_lastcon;
monitor SHTR1_sta;
monitor SHTR1_ilk;
monitor SHTR2_sta;
monitor SHTR2_ilk;
monitor SHTR2_lastcon;


char *szNumAbsorbers;
int	 nAbsorbers;

char szTemp[80];
char szLastValve[40];
char *pszLastValveParam;


/* Event Flags */
evflag flagValvesOpen;
evflag flagValvesClosed;
evflag flagTemp;

%{#include <string.h>}%
%{#include <stdlib.h>}%
%{#include <unistd.h>}%

/* This new entry section needs testing before rolling out.
   Ensure that the ABSB-02 PV is correctly monitored and updates the state-machine
   for two absorber front-ends.
*/
entry
	{
	szNumAbsorbers = macValueGet("num_absorbers");

	if ((szNumAbsorbers == NULL) || (szNumAbsorbers[0] == 0))
		{
		printf("ENTRY: Macro 'num_absorbers' not defined!!\n");
		nAbsorbers = 2;
		}
	else
		{
		nAbsorbers = atoi(szNumAbsorbers);
		printf("ENTRY: Number of absorbers (nAbsorbers)  set to %d\n", nAbsorbers);
		}

	printf("ENTRY: Number of absorbers (nAbsorbers)  set to %d\n", nAbsorbers);

	if (nAbsorbers > 1)
		{
		sprintf(szTemp, "%s-RS-ABSB-02:CON", macValueGet("dom"));
		printf("pvAssign(ABSB2_con, %s)", szTemp);
		pvAssign(ABS2_con, szTemp);
		sprintf(szTemp, "%s-RS-ABSB-02:LASTCON", macValueGet("dom"));
		printf("pvAssign(ABSB2_lastcon, %s)", szTemp);
		pvAssign(ABS2_lastcon, szTemp);
		sprintf(szTemp, "%s-RS-ABSB-02:STA", macValueGet("dom"));
		pvAssign(ABS2_sta, szTemp);
		sprintf(szTemp, "%s-RS-ABSB-02:ILKSTA", macValueGet("dom"));
		pvAssign(ABS2_ilk, szTemp);
		pvMonitor(ABS2_sta);
		pvMonitor(ABS2_ilk);
		pvMonitor(ABS2_lastcon);
		}

	/*
	 *  Since FE22B, it has become apparent that some front-ends will not have the standard number
	 *  vacuum valves. The Beamline control system will not therefore always be controlling VA-VALVE-02,
	 *  but may be another PV such as VA-VALVE-03. In this instance, it is necessary to inform the state-machine
	 *  of the PV name of the last valve.
	 *  If the last valve PV name is not passed in, then it will assume the standard VA-VALVE-02.
	 *  The string should be in the form expressed above, as the FE domain name will be prepended automatically.
	 *
	 *  IJG 4/9/09
	 */
	 

	pszLastValveParam = macValueGet("last_valve");

	if ((pszLastValveParam == NULL) || (pszLastValveParam[0] == 0))
		{
		printf("ENTRY: Macro 'last_valve' not defined - assuming default VA-VALVE-02\n");
		sprintf(szLastValve, "VA-VALVE-02");
		}
	else
		{
		sprintf(szLastValve, "%s", pszLastValveParam);
		}
		
	printf("ENTRY: Last Valve defined as %s\n", szLastValve);
	
	sprintf(szTemp, "%s-%s:STA", macValueGet("dom"), szLastValve);
	printf("pvAssign(V2_sta, %s)\n", szTemp);
	pvAssign(V2_sta, szTemp);
	sprintf(szTemp, "%s-%s:CON", macValueGet("dom"), szLastValve);
	printf("pvAssign(V2_con, %s)\n", szTemp);
	pvAssign(V2_con, szTemp);
	sprintf(szTemp, "%s-%s:LASTCON", macValueGet("dom"), szLastValve);
	printf("pvAssign(V2_lastcon, %s)\n", szTemp);
	pvAssign(V2_lastcon, szTemp);
	sprintf(szTemp, "%s-%s:ILK", macValueGet("dom"), szLastValve);
	printf("pvAssign(V2_ilk, %s)\n", szTemp);
	pvAssign(V2_ilk, szTemp);

	pvMonitor(V2_sta);
	pvMonitor(V2_ilk);
	pvMonitor(V2_lastcon);

	}


/*

/* This is the Beamline  control interface state-machine
   and is controlled via the :CTL and :STS PVs.
   The overall status is written to :PATH which looks like a
   valve status
*/
ss beam_bl_request
	{
	state init
		{
		entry
			{
			/* Set DONE bit to assume that on boot-up there operations are fully completed */
			beamline_status_pv = PVREG_BEAM_COMP;
			pvPut(beamline_status_pv, SYNC);
			/* sleep required to ensure that status PV change is seen by client systems  */
			%{sleep(1);}%

			printf("Entered init state\n");
			}
			
		/* First need to determine the number of absorbers on this front-end
		   If one, then will need to actuate ABSB-01
		   If two, then will need to actuate ABSB-02
		   
		   The default is two absorbers.
		   
		   Only enter this state once, as it established absorber monitoring.
		*/
		when()
			{
			nAbsorbers = 2;
			
			szNumAbsorbers = macValueGet("num_absorbers");
	
			if ((szNumAbsorbers == NULL) || (szNumAbsorbers[0] == 0))
				{
				printf("Macro 'num_absorbers' not defined!!\n");
				nAbsorbers = 2;
				}
			else
				{
				nAbsorbers = atoi(szNumAbsorbers);
				printf("Number of absorbers (nAbsorbers)  set to %d\n", nAbsorbers);
				}
			
			} state Metastable

		}

	state Metastable
		{
		entry
			{
			printf("Entered Metastable state\n");
			}
			
		when ( strcmp(ABSB_BL_sta, "Closed") == 0 )
			{
			/* ABSB is closed */
			} state Beam_closed

		when ( strcmp(ABSB_BL_sta, "Open") == 0 )
			{
			/* ABSB is open */
			} state Beam_open
		}

	state Beam_open
		{
		entry
			{
			/* Clear the ACTIVE bit
			 * Maintaining any other status bits to reflect any exception conditions.
			 */
			beamline_status_pv &= ~PVREG_BEAM_ACTIVE;
			beamline_status_pv &= ~PVREG_BEAM_CLOSE;
			beamline_status_pv |= PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv, SYNC);
			pvFlush();
			/* It is possible that :CTL may have had a value other than ABORT written to it whilst
			 * the state-machine was active, so ensure it is cleared on entering this state
			 */
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv, SYNC);
			pvFlush();

			/* Update overall beam-path status PV */
			strcpy(beam_path_pv, "Open");
			pvPut(beam_path_pv, SYNC);

			printf("Entered Beam_open state\n");
			}
			
		when (beamline_driver_pv == BLREQ_BEAM_CLOSE)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_CLOSE;
			pvPut(beamline_status_pv, SYNC);
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv, SYNC);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_CLOSE (%d)\n", BLREQ_BEAM_CLOSE);

			strcpy(ABSB_BL_con, "Close");
			pvPut(ABSB_BL_con);
			} state Closing_absorber

		when (beamline_driver_pv == BLREQ_BEAM_OPEN)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv, SYNC);
			pvFlush();
			%{sleep(1);}%
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv, SYNC);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_OPEN (%d) - but already in open state\n", BLREQ_BEAM_OPEN);
			} state Beam_nop_toggle

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv, SYNC);
			pvFlush();
			%{sleep(1);}%
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv, SYNC);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_ABORT (%d) - but already in open state\n", BLREQ_BEAM_ABORT);
			} state Beam_nop_toggle

		when ( strcmp(ABSB_BL_sta, "Open") != 0 )
			{
			/* ABSB-0n is closed */
			} state Beam_closed
		}

	state Beam_closed
		{
		entry
			{
			/* Clear the ACTIVE bit
			 * Maintaining any other status bits to reflect any exception conditions.
			 */
			beamline_status_pv &= ~PVREG_BEAM_ACTIVE;
			beamline_status_pv &= ~PVREG_BEAM_OPEN;
			beamline_status_pv |= PVREG_BEAM_CLOSE;
			pvPut(beamline_status_pv);
			pvFlush();

			/* It is possible that :CTL may have had a value other than ABORT written to it whilst
			 * the state-machine was active, so ensure it is cleared on entering this state
			 */
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv, SYNC);

			/* Update overall beam-path status PV */
			pvFlush();
			strcpy(beam_path_pv, "Closed");
			pvPut(beam_path_pv, SYNC);

			printf("Entered Beam_closed state\n");
			}
			
		when (beamline_driver_pv == BLREQ_BEAM_OPEN)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv, SYNC);
			pvFlush();
			%{	
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_OPEN: STS changed, sleep to allow CA change\n");
			sleep(1);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_OPEN: STS changed, sleep over\n");
			}%
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv, SYNC);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_OPEN (%d)\n", BLREQ_BEAM_OPEN);

			/* Update overall beam-path status PV */
			pvFlush();
			strcpy(beam_path_pv, "Opening");
			pvPut(beam_path_pv, SYNC);
			pvFlush();

			/* 
			 * It was discovered that on issuing RESET when FV is ARMed, 
			 * does not return LASTCON == RESET.
			 * Instead, a simple 1 second sleep has been added after issuing RESET. 
			 */
			strcpy(FV1_con, "Reset"); /* Reset fast valve*/
			printf("beamline_bl_request:issuing FV reset\n");
			pvPut(FV1_con);
			%{	
			printf("Resetting fast-valve, sleep to allow CA change\n");
			sleep(1);
			printf("Resetting fast-valve, sleep over\n");
			}%
			} state Resetting_FV

		/* Beam may be technically closed due to absorber down, but shutter and V2 may still want to be closed.
		   So permit forced close of these
		 */
		when (beamline_driver_pv == BLREQ_BEAM_CLOSE)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_CLOSE;
			pvPut(beamline_status_pv, SYNC);
			pvFlush();
			%{	
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_CLOSE: STS changed, sleep to allow CA change\n");
			sleep(1);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_CLOSE: STS changed, sleep over\n");
			}%
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv, SYNC);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_CLOSE (%d)\n", BLREQ_BEAM_CLOSE);

			strcpy(ABSB_BL_con, "Close");
			pvPut(ABSB_BL_con);
			} state Closing_absorber

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_ABORT - already closed - write PV and wait\n");
			pvPut(beamline_status_pv);
			pvFlush();
			%{
			sleep(1);			
			}%
			beamline_driver_pv = BLREQ_BEAM_IDLE;
			pvPut(beamline_driver_pv);
			printf("beamline_beam_request:beamline_driver_pv == BLREQ_BEAM_ABORT - already in closed - leaving\n");
			} state Beam_nop_toggle

		when ( strcmp(ABSB_BL_sta, "Open") == 0 )
			{
			/* ABSB-0n is open */
			} state Beam_open
		}

	state Beam_nop_toggle
		{
		/* This metastable state is entered from Beam_open or Beam_closed 
		   when no device changes are appropriate. But still need to toggle 
		   the ACTIVE bit in the status PV. The ACTVE bit is actually cleared
		   on subsequent transition to either the Beam_open or Beam_closed states.
		*/
		entry
			{
			printf("Entered Beam_nop_toggle state\n");
			}
			
		when()
			{
			pvFlush();
			} state Metastable
		}

	state Resetting_FV
		{
		/* == Re-implemented 14-1-15 ==
		 * This state is no longer used, but left for posterity.
		 * It was discovered that on issuing RESET when FV is ARMed,
		 * does not return LASTCON == RESET.
		 * Instead, a simple 1 second sleep has been added after issuing RESET in the other state. 
		 */
		entry
			{
			printf("Entered Resetting_FV state\n");
			}

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Sequence aborted!\n");
			} state Metastable

        /* Catch-all in case of things getting stuck - 30s timeout */
        when ( delay( 3.0 ) )
            {
			printf("FV1 Reset (via delay() state) -> Opening\n");
			strcpy(FV1_con, "Open"); /* Open fast-valve */
             } state Opening_FV

		}

	state Opening_FV
		{
		entry
			{
			printf("Entered Opening_FV state\n");
			}
			
		when ((strstr(FV1_sta, "Open ") != NULL) || (strstr(FV1_sta, "Partially ") != NULL))
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_FV | PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv);
			printf("beamline_bl_request:FV Open\n");
			strcpy(FV1_con, "Arm"); /* Arm */
			printf("beamline_bl_request:issuing Arm FV1\n");
			pvPut(FV1_con, SYNC);
			} state Arming_FV

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Sequence aborted!\n");
			} state Metastable

		when (strcmp(FV1_ilk, "Failed") == 0 )
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_FV | PVREG_BEAM_INTERLOCK;
			pvPut(beamline_status_pv);
			printf("Sequence aborted due to FV interlock failure!\n");
			} state Metastable

		}

	state Arming_FV
		{
		entry
			{
			printf("Entered Arming_FV state\n");
			}
			
		when (strcmp(FV1_sta, "Open Armed") == 0)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_FV | PVREG_BEAM_ARM | PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv);
			printf("beamline_bl_request:FV Open Armed\n");
			} state Propogate_interlock_delay

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Sequence aborted!\n");
			} state Metastable

		when (strcmp(FV1_ilk, "Failed") == 0 )
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_FV | PVREG_BEAM_INTERLOCK;
			pvPut(beamline_status_pv);
			printf("Sequence aborted due to FV interlock failure!\n");
			} state Metastable

		}

	state Propogate_interlock_delay
		{
		entry
			{
			printf("Entered Propogate_interlock_delay state\n");
			}
			
		when (delay(7.0))
			{
			} state Resetting_V2
		}

	state Resetting_V2
		{
		entry
			{
			printf("Entered Resetting_V2 state\n");
			strcpy( V2_con, "Reset");
			pvPut( V2_con, SYNC );
			}
			
		when (strcmp(V2_lastcon, "Reset") == 0)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_V2 | PVREG_BEAM_RESET | PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv, SYNC);
			printf("VALVE-02 Reset -> Opening\n");
			strcpy(V2_con, "Open"); /* Open valve 2 */
			pvPut(V2_con, SYNC);
			} state Opening_V2

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv, SYNC);
			printf("Beamline Sequence aborted!\n");
			} state Metastable

		when ( delay( 30.0 ) )
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv, SYNC);
			printf("VALVE-02 Reset -> Timedout - aborted\n");
			} state Metastable
		

		}

	state Opening_V2
		{
		entry
			{
			printf("Entered Opening_V2 state\n");
			printf("V2_sta: %s\n", V2_sta);
			}
			
		when (strcmp(V2_sta, "Open") == 0)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_V2 | PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv, SYNC);
			strcpy(SHTR2_con, "Reset"); /* Reset */
			pvPut(SHTR2_con, SYNC);
			} state Resetting_shutter 

		when (strstr(FV1_sta, "Disarmed") != NULL)
			{ /* Fast valve controller timed out waiting for
			      VALVE-02 to open, so abort sequence
			   */
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT | PVREG_BEAM_TIMEOUT;
			pvPut(beamline_status_pv, SYNC);
			printf("Timeout - open aborted!\n");
			} state Metastable

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_VAC_ABRT;
			/*strcpy(valve_status_pv, "Open Aborted");*/
			pvPut(beamline_status_pv, SYNC);
			printf("Sequence aborted!\n");
			} state Metastable

		when (strcmp(V2_ilk, "Failed") == 0 )
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_V2 | PVREG_BEAM_INTERLOCK;
			pvPut(beamline_status_pv, SYNC);
			printf("Sequence aborted due to V2 interlock failure!\n");
			} state Metastable

		when ( delay( 30.0 ) )
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv, SYNC);
			printf("VALVE-02 Opening -> Timedout - aborted\n");
			} state Metastable
		
		}

	state Resetting_shutter
		{
		entry
			{
			printf("Entered Resetting_shutter state\n");
			}
			
		when (strcmp(SHTR2_lastcon, "Reset") == 0)
			{
			printf("SHTR-02 Reset -> Opening\n");
			strcpy(SHTR2_con, "Open"); /* Open shutter 2 */
			pvPut(SHTR2_con, SYNC);

			} state Opening_shutter

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Beamline Sequence aborted!\n");
			} state Metastable
		}

	state Opening_shutter
		{
		entry
			{
			printf("Entered Opening_shutter state\n");
			}
			
		when (strcmp(SHTR2_sta, "Open") == 0)
			{
			printf("SHTR-02 Open\n");
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_SHTR2 | PVREG_BEAM_OPEN;
			pvPut(beamline_status_pv);

			strcpy(ABSB_BL_con, "Reset"); /* Reset */
			/*pvPut(ABSB_BL_con);*/
			pvPut(ABSB_BL_con);
			} state Resetting_absorber

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Beamline Sequence aborted!\n");
			} state Metastable

		when (strcmp(SHTR2_ilk, "Failed") == 0 )
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_SHTR2 | PVREG_BEAM_INTERLOCK;
			pvPut(beamline_status_pv);
			printf("Sequence aborted due to SHTR2 interlock failure!\n");
			} state Metastable

		}

	state Resetting_absorber
		{
		entry
			{
			printf("Entered Resetting_absorber state\n");
			/* Give time for PLC to perform reset and transmit new status back to ioc */
            printf("Delay 2 seconds for changes post RESET in Resetting_absorber\n");
            %{sleep(2);}%
			}
			
		when (strcmp(ABSB_BL_lastcon, "Reset") == 0)
			{
			printf("Absorber Reset -> Opening\n");
			strcpy(ABSB_BL_con, "Open"); /* Open absorber */
			pvPut(ABSB_BL_con);
			} state Opening_absorber

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Beamline Sequence aborted!\n");
			} state Metastable
		}

	state Opening_absorber
		{
		entry
			{
			printf("Entered Opening_absorber state\n");
			/* sleep required to ensure that status PV change is seen by client systems  */
            printf("Delay 1 second for changes in Opening_absorber state\n");
			%{sleep(1);}%
			printf("ABSB ilk:%s OpenAllowed:%s\n", ABSB_BL_ilk, ABS1_openallowed);
			}
			
		when (strcmp(ABSB_BL_sta, "Open") == 0)
			{
			printf("Absorber Open\n");
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABSB | PVREG_BEAM_OPEN | PVREG_BEAM_COMP;
			pvPut(beamline_status_pv);
			} state Beam_open

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Beamline Sequence aborted!\n");
			} state Metastable
		when ( (strcmp(ABSB_BL_ilk, "Failed") == 0 ) || (strcmp(ABS1_openallowed, "No") == 0) )
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABSB | PVREG_BEAM_INTERLOCK;
			pvPut(beamline_status_pv);
			printf("Sequence aborted due to ABSB interlock failure!\n");
			} state Metastable

		}

	state Closing_absorber
		{
		entry
			{
			printf("Entered Closing_absorber state\n");
			%{sleep(1);}%			

			/* Update overall beam-path status PV */
			strcpy(beam_path_pv, "Closing");
			pvPut(beam_path_pv);
			}
			
		when (strcmp(ABSB_BL_sta, "Closed") == 0)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABSB | PVREG_BEAM_CLOSE;
			pvPut(beamline_status_pv);
			printf("beamline_beam_request:ABSB Closed\n");
			printf("beamline_beam_request:Continuing to close SHTR2\n");

			strcpy(SHTR2_con, "Close");
			pvPut(SHTR2_con);
			} state closing_shutter

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Sequence aborted!\n");
			} state Metastable

		}
		
	state closing_shutter
		{
		entry
			{
			printf("Entered Closing_shutter state\n");
			%{sleep(1);}%			
			}
			
		when ((strcmp(SHTR2_sta, "Closed") == 0))
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_SHTR2 | PVREG_BEAM_CLOSE;
			pvPut(beamline_status_pv);

			strcpy(V2_con, "Close");
			pvPut(V2_con, SYNC);
			efClear( flagValvesOpen );
			} state closing_V2

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Sequence aborted!\n");
			} state Metastable

		}
	
	state closing_V2
		{
		entry
			{
			printf("Entered Closing_V2 state\n");
			}
			
		when ((strcmp(V2_sta, "Closed") == 0))
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_V2 | PVREG_BEAM_CLOSE | PVREG_BEAM_COMP;
			pvPut(beamline_status_pv);
			} state Beam_closed

		when (beamline_driver_pv == BLREQ_BEAM_ABORT)
			{
			beamline_status_pv = PVREG_BEAM_ACTIVE | PVREG_BEAM_ABRT;
			pvPut(beamline_status_pv);
			printf("Sequence aborted!\n");
			} state Metastable

		}
	}






