#if defined _candyscript_included_
  #endinput
#endif
#define _candyscript_included_

/**
 * Register a candy function
 * @param sName		The Name of the menu item
 * @param iBuyCosts	How much candy does it cost
 * @param iStopTime	After how many seconds should it run fStop
 * @param fStart	The function to run on start
 * @param fStop		The function to run on stop after iStopTime seconds.
 * @return			The CandyId (Only used to remove it from the list)
 */
native RegisterCandy(String:sName[256], iBuyCosts, Float:iStopTime, Function:fStart, Function:fStop);

/**
 * Remove a candy function
 * @param iCandyId	The CandyId to remove
 * @return			Nothing.
 */
native DeregisterCandy(iCandyId);
