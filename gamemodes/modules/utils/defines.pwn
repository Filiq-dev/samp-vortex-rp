#define                 MAX_HOUSES                              (100)
#define                 MAX_BOTS                                (2)
#define                 MAX_TIMERS              				(5)
#define                 MAX_TEXTDRAWS                           (10)
#define                 MAX_JOBS                                (5)
#define                 MAX_GROUPS                              (20)
#define                 MAX_BUSINESSES                          (50)
#define                 MAX_WEAPON_HACK_WARNINGS                (3)
#define                 MAX_ASSETS                              (10)
#define					MAX_SPIKES								(10)
#define					MAX_LOGIN_ATTEMPTS						(3)
#define                 MAX_ATMS                                (25)
#define                 MAX_BUSINESS_ITEMS                      (MAX_BUSINESSES * 6)

#define                 GROUP_VIRTUAL_WORLD						(20000)
#define                 HOUSE_VIRTUAL_WORLD                     (10000)
#define                 BUSINESS_VIRTUAL_WORLD                  (30000)

#define 				INTERIOR_WEATHER_ID						(1) // Outdoor weather is used inside interiors too, blame San Andreas.
#define					MAX_WEATHER_POINTS						(9)

#define					GOVERNMENT_GROUP_ID						(4)

#define                 ADMIN_PIN_TIMEOUT                       (120) // In seconds. 120 seconds (2 minutes) is default. 

#define                 SYNTAX_MESSAGE                          "Syntax: {FFFFFF}"  

#define 				SpeedCheck(%0,%1,%2,%3,%4) 				floatround(floatsqroot(%4?(%0*%0+%1*%1+%2*%2):(%0*%0+%1*%1) ) *%3*1.6)
#define 				strcpy(%0,%1,%2) 						strcat((%0[0] = '\0', %0), %1, %2) // strcpy(dest, source, length)
#define                 hidePlayerDialog(%0)                    ShowPlayerDialog(%0, -1, 0, " ", " ", "", "")
#define					IsPlayerAuthed(%0)						(playerVariables[%0][pStatus] == 1)

native					WP_Hash(buffer[], len, const str[]);

#define                 function%0(%1)                          forward%0(%1); public%0(%1)

#include "modules/utils/colors.pwn"
#include "modules/utils/threads.pwn"