#pragma semicolon 1

#include <sdkhooks>
#include <vip_core>
#include <smlib>

static const char g_sFeature[] = "Invis";

public Plugin myinfo =
{
	name	= "[VIP] Invisibility",
	author	= "BaFeR",
	version	= "1.1.1"
};

public void VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(g_sFeature, INT, _, OnItemToggle, OnItemDisplay);
}

public void OnPluginStart()
{
	LoadTranslations("vip_modules.phrases");
	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();
}

public void OnPluginEnd()
{
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
		VIP_UnregisterFeature(g_sFeature);
}

public void VIP_OnPlayerSpawn(int client, int team, bool isVIP)
{
	if(isVIP && VIP_IsClientFeatureUse(client, g_sFeature)) GiveInvis(client);
}

public bool OnItemDisplay(int client, const char[] sFeatureName, char[] sDisplay, int max_len)
{
	if(!VIP_IsClientFeatureUse(client, g_sFeature)) return false;

	FormatEx(sDisplay, max_len, "%T", g_sFeature, client);
	return true;
}

public Action OnItemToggle(int client, const char[] sFeatureName, VIP_ToggleState OldStatus, VIP_ToggleState &NewStatus)
{
	if(NewStatus == ENABLED) GiveInvis(client);
	else SetEntityRenderColor(client, -1, -1, -1, 255);

	return Plugin_Continue;
}

void GiveInvis(int client)
{
	int iInvisibleValue = VIP_GetClientFeatureInt(client, g_sFeature);

	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, -1, -1, -1, iInvisibleValue);

	// Установка прозрачности для оружия.
	int iWeapon = -1, iIndex;
	while((iWeapon = Client_GetNextWeapon(client, iIndex)) != -1)
	{
		SetEntityRenderMode(iWeapon, RENDER_TRANSCOLOR);
		Entity_SetRenderColor(iWeapon, -1, -1, -1, iInvisibleValue);
	}

	// Установка прозрачности для аксессуаров.
	char sBuffer[64];
	LOOP_CHILDREN(client, child)
	{
		if(GetEntityClassname(child, sBuffer, sizeof(sBuffer)) && !StrContains(sBuffer, "prop_", false))
		{
			SetEntityRenderMode(child, RENDER_TRANSCOLOR);
			Entity_SetRenderColor(child, -1, -1, -1, iInvisibleValue);
		}
	}
}