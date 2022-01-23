// Заказчик: vladu4eg
// Js Author: https://vk.com/dev_stranger

var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");
if ($("#BattlePassButton")) {
	if (parentHUDElements.FindChildTraverse("BattlePassButton")){
		$("#BattlePassButton").DeleteAsync( 0 );
	} else {
		$("#BattlePassButton").SetParent(parentHUDElements);
	}
}

var toggle = false;
var first_time = false;
var cooldown_panel = false
var current_sub_tab = "";

// Устаналивает уровни баттлапасс
var exp_battlepass = [
	// Сколько нужно опыта чтоб перейти на следующий уровень !!
	0, // игнорировать
	0, // 1 уровень
	1000,
	5000,
	10000,
	4000,
	5000,
	2000,
	1000,
	1000,
	1000,
	1000,
]


// Опыт, забранные награды

var player_bp_info = [16000, [1, 12]]

var donate_rewards = [
	// Уровень, ID Награды (для хранения в базе + мб сверять с магазином), иконка
	[], // игнорировать
	["1", "1" ,"courier"],
	["2", "2" ,"courier"],
	["3", "3" ,"courier"],
	["4", "4" ,"courier"],
	["5", "5" ,"courier"],
	["6", "6" ,"courier"],
	["7", "7" ,"courier"],
	["8", "8" ,"courier"],
	["9", "9" ,"courier"],
	["10", "10" ,"courier"],
	["11", "11" ,"courier"],	
]

var free_rewards = [
	// Уровень, ID Награды (для хранения в базе + мб сверять с магазином), иконка
	[], // игнорировать
	["1", "12" ,"courier"],
	["2", "13" ,"courier"],
	["3", "14" ,"courier"],
	["9", "15" ,"courier"],
	["10", "16" ,"courier"],
	["11", "17" ,"courier"],
]







function ToggleBattlePass() {
    if (toggle === false) {
    	if (cooldown_panel == false) {
	        toggle = true;
	        if (first_time === false) {
	            first_time = true;
	            InitLevel()
	            InitDonateRewards()
	            $("#BattlePassPanel").AddClass("sethidden");
	        }  
	        if ($("#BattlePassPanel").BHasClass("sethidden")) {
	            $("#BattlePassPanel").RemoveClass("sethidden");
	        }
	        $("#BattlePassPanel").AddClass("setvisible");
	        $("#BattlePassPanel").style.visibility = "visible"

	        $("#BattlePass_Rewards").SetAcceptsFocus(true);
	        $("#BattlePass_Rewards").SetFocus();


	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        })
	    }
    } else {
    	if (cooldown_panel == false) {
	        toggle = false;
	        if ($("#BattlePassPanel").BHasClass("setvisible")) {
	            $("#BattlePassPanel").RemoveClass("setvisible");
	        }
	        $("#BattlePassPanel").AddClass("sethidden");
	        cooldown_panel = true
	        $("#BattlePass_Rewards").SetAcceptsFocus(false);
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        	$("#BattlePassPanel").style.visibility = "collapse"
			})
		}
    }
}

function InitLevel() {
	if (player_bp_info) {
		let level = GetLevelPlayer(player_bp_info[0])
		let get_current_exp = GetExpPlayer(player_bp_info[0])

		$("#LevelText").text = $.Localize("battlepass_level") + ":" + " " + level
     
		let width = 0

		if (exp_battlepass[level+1]) {

			$("#ExpText").text = get_current_exp + " / " + exp_battlepass[level+1]

			if (player_bp_info[0] > 0) {
				width = (100 * get_current_exp ) / exp_battlepass[level+1]
			}
		} else {

			$("#ExpText").text = exp_battlepass[level] + " / " + exp_battlepass[level]

			if (player_bp_info[0] > 0) {
				width = (100 * exp_battlepass[level] ) / exp_battlepass[level]
			}
		}

		$("#BattlePass_Progress_6").style.width = width + "%"
	}
}


function InitDonateRewards() {
	let level = 0

	if (player_bp_info) {
		level = GetLevelPlayer(player_bp_info[0])
	}
	for (var i = 1; i < exp_battlepass.length; i++) {
		CreateLevels(i)
		CreateFreeReward(i, level)
		CreateDonateReward(i, level)
	}
}

function CreateLevels(reward_level, lvl){
	var LevelPanelCenter = $.CreatePanel("Panel", $("#Levels"), "LevelPanelCenter" + reward_level );
	LevelPanelCenter.AddClass("LevelPanel");

	var LevelTextPanel = $.CreatePanel("Label", LevelPanelCenter, "LevelTextPanel");
	LevelTextPanel.AddClass("LevelTextPanel");
	LevelTextPanel.text = $.Localize( "battlepass_level") + " " + reward_level
}

function CreateFreeReward(reward_level, lvl){
	var create_reward_check = false
	var reward_id = 0
	var reward_no_recieve = true

	for (var i = 0; i < free_rewards.length; i++) {
		if (free_rewards[i][0] == reward_level) {
			create_reward_check = true
			reward_id = free_rewards[i][1]
		}
	}

	for ( var reward_inventory in player_bp_info[1] )
    {
    	if (player_bp_info[1][reward_inventory] == reward_id) {
    		reward_no_recieve = false
    	}
	}

	

	if (create_reward_check){
		var RewardPanelFree = $.CreatePanel("Panel", $("#BattlePass_Free"), "RewardPanelFree" + reward_level );
		RewardPanelFree.AddClass("RewardPanelFree");

		var RewardImage = $.CreatePanel("Panel", RewardPanelFree, "RewardImage" );
		RewardImage.AddClass("reward_image");
		RewardImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + "courier" + '.png")';
		RewardImage.style.backgroundSize = "100% 100%"

		var PanelLock = $.CreatePanel("Panel", RewardPanelFree, "PanelLock" );

		if (lvl >= reward_level) {
			if (reward_no_recieve) {
				PanelLock.AddClass("PanelLock");
				PanelLock.SetPanelEvent("onactivate", function() { GiveReward(reward_id, PanelLock) } );
			} else {
				PanelLock.AddClass("PanelGives");
			}
			
		} else {
			PanelLock.AddClass("PanelLockOn");
			PanelLock.SetPanelEvent("onactivate", function() {} );
		}

		var BpLockedText = $.CreatePanel("Label", PanelLock, "BpLockedText");
		BpLockedText.AddClass("BpLockedText");

		if (lvl >= reward_level) {
			if (reward_no_recieve) {
				BpLockedText.text = $.Localize( "battleshop_gives" )
			} else {
				BpLockedText.text = $.Localize( "battlepass_gives" )
			}
		} else {
			BpLockedText.text = $.Localize( "battleshop_locked" )
			RewardImage.style.brightness = "0.05"
		}


		var PanelDesc = $.CreatePanel("Panel", RewardPanelFree, "PanelDesc" );
		PanelDesc.AddClass("PanelDesc");

		var DonateInfo = $.CreatePanel("Panel", PanelDesc, "DonateInfo" );
		DonateInfo.AddClass("DonateInfo");

		var BpDonateText = $.CreatePanel("Label", DonateInfo, "BpDonateText");
		BpDonateText.AddClass("BpDonateText");
		BpDonateText.text = $.Localize( "battlepass_free" )
	} else {
		var RewardPanelFree = $.CreatePanel("Panel", $("#BattlePass_Free"), "RewardPanelFree" + reward_level );
		RewardPanelFree.AddClass("RewardPaneClear");	
	}

}


function GiveReward(id, panel) {
	$.Msg(id)

	panel.SetPanelEvent("onactivate", function() {} );
	panel.RemoveClass("PanelLock")
	panel.AddClass("PanelGives");
	panel.FindChildTraverse("BpLockedText").text = $.Localize("battlepass_gives")
	panel.FindChildTraverse("BpLockedText").style.textTransform = "uppercase"

	// Здесь нужно отправить в луа проверку на получение шмотки  id - айди шмотки
}









function CreateDonateReward(reward_level, lvl) {

	var create_reward_check = false
	var reward_id = 0
	var reward_no_recieve = true

	for (var i = 0; i < donate_rewards.length; i++) {
		if (donate_rewards[i][0] == reward_level) {
			create_reward_check = true
			reward_id = donate_rewards[i][1]
		}
	}

	for ( var reward_inventory in player_bp_info[1] )
    {
    	if (player_bp_info[1][reward_inventory] == reward_id) {
    		reward_no_recieve = false
    	}
	}

	if (create_reward_check){
		var RewardPanelDonate = $.CreatePanel("Panel", $("#BattlePass_Donate"), "RewardPanelDonate" + reward_level );
		RewardPanelDonate.AddClass("RewardPanelDonate");

		var RewardImage = $.CreatePanel("Panel", RewardPanelDonate, "RewardImage" );
		RewardImage.AddClass("reward_image");
		RewardImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + "courier" + '.png")';
		RewardImage.style.backgroundSize = "100% 100%"

		var PanelLock = $.CreatePanel("Panel", RewardPanelDonate, "PanelLock" );

		if (lvl >= reward_level) {
			if (reward_no_recieve) {
				PanelLock.AddClass("PanelLock");
				PanelLock.SetPanelEvent("onactivate", function() { GiveReward(reward_id, PanelLock) } );
			} else {
				PanelLock.AddClass("PanelGives");
			}
		} else {
			PanelLock.AddClass("PanelLockOn");
			PanelLock.SetPanelEvent("onactivate", function() {} );
		}

		var BpLockedText = $.CreatePanel("Label", PanelLock, "BpLockedText");
		BpLockedText.AddClass("BpLockedText");

		if (lvl >= reward_level) {
			if (reward_no_recieve) {
				BpLockedText.text = $.Localize( "battleshop_gives" )
			} else {
				BpLockedText.text = $.Localize( "battlepass_gives" )
			}
		} else {
			BpLockedText.text = $.Localize( "battleshop_locked" )
			RewardImage.style.brightness = "0.05"
		}

		


		var PanelDesc = $.CreatePanel("Panel", RewardPanelDonate, "PanelDesc" );
		PanelDesc.AddClass("PanelDesc");

		var DonateInfo = $.CreatePanel("Panel", PanelDesc, "DonateInfo" );
		DonateInfo.AddClass("DonateInfo");

		var BpDonateIcon = $.CreatePanel("Panel", DonateInfo, "BpDonateIcon" );
		BpDonateIcon.AddClass("BpDonateIcon");

		var BpDonateText = $.CreatePanel("Label", DonateInfo, "BpDonateText");
		BpDonateText.AddClass("BpDonateText");
		BpDonateText.text = $.Localize( "battlepass_inbp" )
	} else {
		var RewardPanelDonate = $.CreatePanel("Panel", $("#BattlePass_Donate"), "RewardPanelDonate" + reward_level );
		RewardPanelDonate.AddClass("RewardPaneClear");		
	}
}



function GetLevelPlayer(exp) {
	let level = 0
	for (var i = 1; i <= exp_battlepass.length; i++)
	{
		if (exp >= exp_battlepass[i]) {
			exp = exp - exp_battlepass[i]
			level = level + 1
		} else {
			break
		}
	}
	return level
}

function GetExpPlayer(exp) {
	for (var i = 1; i <= exp_battlepass.length; i++)
	{
		if (exp >= exp_battlepass[i]) {
			exp = exp - exp_battlepass[i]
		} else {
			break
		}
	}
	return exp
}