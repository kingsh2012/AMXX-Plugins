/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <zombieplague>
#include <zmvip>

#define PLUGIN "[ZP] S/N Buy"
#define VERSION "1.1"
#define AUTHOR "aaarnas"

new g_msgSayText
new nemesis, survivor
new g_bought[33], bought
new cvar_n_price, cvar_s_price, cvar_limit_all, cvar_everytime, cvar_show_bought, cvar_allow_times

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_everytime = register_cvar("zp_allow_buy", "2")
	cvar_allow_times = register_cvar("zp_allow_times", "4")
	cvar_limit_all = register_cvar("zp_limit_for_all", "1")
	cvar_n_price = register_cvar("zp_nemesis_price", "35")
	cvar_s_price = register_cvar("zp_survivor_price", "35")
	cvar_show_bought = register_cvar("zp_show_who_bought", "1")
	
	g_msgSayText = get_user_msgid("SayText")
	
	// Extra items
	nemesis = zv_register_extra_item("Buy Nemesis", "For one round", get_pcvar_num(cvar_n_price), 0)
	survivor = zv_register_extra_item("Buy Survivor","For one round", get_pcvar_num(cvar_s_price), 0)
}

public zp_round_ended()
	bought = false

public zv_extra_item_selected(id, itemid) {
	
	new value = get_pcvar_num(cvar_everytime)
	
	if(itemid == nemesis) {
		
		if(get_pcvar_num(cvar_limit_all) && bought) {
			client_printcolor(id, "/g[ZP] This is no more avaible in this round. Try next round.")
			return ZV_PLUGIN_HANDLED
		}
		if(g_bought[id] >= get_pcvar_num(cvar_allow_times)) {
			client_printcolor(id, "/g[ZP] You can't buy it more than %d times.", get_pcvar_num(cvar_allow_times))
			return ZV_PLUGIN_HANDLED
		}
		if(value == 2) {
			zp_make_user_nemesis(id)
			new name[64]
			get_user_name(id, name, 63)
			client_printcolor(0, "/g[ZP] %s /ybought nemesis", name)
			g_bought[id]++
		}
		else if(zp_has_round_started() == value) {
			zp_make_user_nemesis(id)
			if(get_pcvar_num(cvar_show_bought)) {
				new name[64]
				get_user_name(id, name, 63)
				client_printcolor(0, "/g[ZP] %s /ybought nemesis", name)
				g_bought[id]++
				bought = true
			}
		}
		else {
			client_printcolor(id, "/g[ZP] /yYou can buy Nemesis only when %s.", value ? "round started":"round not started")
			return ZV_PLUGIN_HANDLED
		}
	}
	else if(itemid == survivor) {
		
		if(get_pcvar_num(cvar_limit_all) && bought) {
			client_printcolor(id, "/g[ZP] This is no more avaible in this round. Try next round.")
			return ZV_PLUGIN_HANDLED
		}
		if(g_bought[id] >= get_pcvar_num(cvar_allow_times)) {
			client_printcolor(id, "/g[ZP] You can't buy it more than %d times.", get_pcvar_num(cvar_allow_times))
			return ZV_PLUGIN_HANDLED
		}
		if(value == 2) {
			zp_make_user_survivor(id)
			new name[64]
			get_user_name(id, name, 63)
			client_printcolor(0, "/g[ZP] %s /ybought nemesis", name)
			g_bought[id]++
		}
		else if(zp_has_round_started() == value) {
			zp_make_user_survivor(id)
			if(get_pcvar_num(cvar_show_bought)) {
				new name[64]
				get_user_name(id, name, 63)
				client_printcolor(0, "/g[ZP] %s /ybought survivor", name)
				g_bought[id]++
				bought = true
			}
		}
		else {
			client_printcolor(id, "/g[ZP] /yYou can buy Survivor only when %s.", value ? "round started":"round not started")
			return ZV_PLUGIN_HANDLED
		}
	}
	return 1
}

stock client_printcolor(const id, const input[], any:...)
{
	new iCount = 1, iPlayers[32]
	
	static szMsg[191]
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	replace_all(szMsg, 190, "/g", "^4") // green txt
	replace_all(szMsg, 190, "/y", "^1") // orange txt
	replace_all(szMsg, 190, "/ctr", "^3") // team txt
	replace_all(szMsg, 190, "/w", "^0") // team txt
	
	if(id) iPlayers[0] = id
	else get_players(iPlayers, iCount, "ch")
		
	for (new i = 0; i < iCount; i++)
	{
		if (is_user_connected(iPlayers[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, iPlayers[i])
			write_byte(iPlayers[i])
			write_string(szMsg)
			message_end()
		}
	}
}
