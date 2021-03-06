// vim: set ts=4
// Utilities for L4D2 Vscript Mutations
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================



if(::CompLite.rawin("Utils")) return;
::CompLite.Utils <- {};
IncludeScript("complite/globaltimers.nut", ::CompLite);

/* KeyReset
	Create a KeyReset to track the state of a key before you change its value, and
	reset it to the original value/state when you want to revert it.
	Can detect whether a key existed or not and will delete the key afterwards if it doesn't exists.
	
	e.g.
	myKeyReset = KeyReset(DirectorOptions, "JockeyLimit")
	
	then on some event...
	myKeyReset.set(0); // Set DirectorOptions.JockeyLimit to 0, storing the previous value/state
	
	and later...
	myKeyReset.unset(); // Reset DirectorOptions.JockeyLimit to whatever value it was before, or delete
	

 */

// Class that will detect the existence and old value of a key and store
// it for "identical" resetting at a later time.
// Assumes that while between Set() and Unset() calls no other entity will modify the
// value of this key.
class ::CompLite.Utils.KeyReset
{
	constructor(owner, key)
	{
		m_owner = owner;
		m_key = key;
	}
	function set(val)
	{
		if(!m_bSet)
		{
			m_bExists = m_owner.rawin(m_key);
			if(m_bExists)
			{
				m_oldVal = m_owner.rawget(m_key);
			}
			m_bSet = true;
		}
		m_owner.rawset(m_key,val);
	}
	function unset()
	{
		if(!m_bSet) return;
		
		if(m_bExists)
		{
			m_owner.rawset(m_key,m_oldVal);
		}
		else
		{
			m_owner.rawdelete(m_key);
		}
		m_bSet = false;
	}
	m_owner = null;
	m_key = null;
	m_oldVal = null;
	m_bExists = false;
	m_bSet = false;
}


/* ZeroMobReset
	Class which handles resetting the mob timer without spawning CI.
	
	e.g.
	g_MobTimerCntl = ZeroMobReset(Director, DirectorOptions, g_FrameTimer);
	
	then later on some event
	g_MobTimerCntl.ZeroMobReset();
	

 */
// Can reset the mob spawn timer at any point without
// triggering an CI to spawn. Should not demolish any other state settings.
class ::CompLite.Utils.ZeroMobReset extends Timers.TimerCallback
{
	// Initialize with Director, DirectorOptions, and a GlobalFrameTimer
	constructor(director, dopts, timer)
	{
		m_director = director;
		m_timer = timer;
		m_mobsizesetting = ::CompLite.Utils.KeyReset(dopts, "MobSpawnSize");
	}
	/* ZeroMobReset()
	Resets the director's mob timer.
	Will trigger incoming horde music, but will not spawn any commons.
	 */
	function ZeroMobReset()
	{
		if(m_bResetInProgress) return;
		
		// set DirectorOptions.MobSpawnSize to 0 so the triggered
		// horde won't spawn CI
		m_mobsizesetting.set(0);
		m_director.ResetMobTimer();
		m_timer.AddTimer(1, this)
		m_bResetInProgress = true;
	}
	// Internal use only,
	// resets the mob size setting after the mob timer has been set
	function OnTimerElapsed()
	{
		m_mobsizesetting.unset();
		m_bResetInProgress = false;
	}
	m_bResetInProgress = false;
	m_director = null;
	m_timer = null;
	m_mobsizesetting = null;
}

class ::CompLite.Utils.MapInfo {
	function IdentifyMap(EntList)
	{
		isIntro = EntList.FindByName(null, "fade_intro") != null
			|| EntList.FindByName(null, "lcs_intro") != null;
	}
	isIntro = false
	isFinale = false
	mapname = null
	chapter = 0
}

::CompLite.Utils.KillEntity <- function(ent)
{
	DoEntFire("!activator", "kill", "", 0, ent, null);
}

::CompLite.Utils.GetCurrentRound <- function() 
{ 
	return ::CompLite.Globals.iRoundCount;
}