var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");
if ($("#LeaderboardButton")) {
    if (parentHUDElements.FindChildTraverse("LeaderboardButton")){
        $("#LeaderboardButton").DeleteAsync( 0 );
    } else {
        $("#LeaderboardButton").SetParent(parentHUDElements);
    }
}

var toggle = false;
var first_time = false;
var cooldown_panel = false
var current_sub_tab = "";

function ToggleLeaderboard() {
    if (toggle === false) {
        if (cooldown_panel == false) {
            toggle = true;
            if (first_time === false) {
                first_time = true;
                $("#Leaderboard").AddClass("sethidden");
            }  
            if ($("#Leaderboard").BHasClass("sethidden")) {
                $("#Leaderboard").RemoveClass("sethidden");
            }
            $("#Leaderboard").AddClass("setvisible");
            $("#Leaderboard").style.visibility = "visible"
            cooldown_panel = true
            $.Schedule( 0.503, function(){
                cooldown_panel = false
            })
        }
    } else {
        if (cooldown_panel == false) {
            toggle = false;
            if ($("#Leaderboard").BHasClass("setvisible")) {
                $("#Leaderboard").RemoveClass("setvisible");
            }
            $("#Leaderboard").AddClass("sethidden");
            cooldown_panel = true
            $.Schedule( 0.503, function(){
                cooldown_panel = false
                $("#Leaderboard").style.visibility = "collapse"
            })
        }
    }
}

function UpdateTopPlays(info) {
    for (var i = 1; i <= 10;i++)
    {
        if (info[i.toString()] != null)
        {
            CreatePlayer(info[i.toString()].id, info[i.toString()].col, $("#PlayersColumnMainRating"))
        }
    }
}

function UpdateTopWins(info) {
    for (var i = 1; i <= 10;i++)
    {
        if (info[i.toString()] != null)
        {
            CreatePlayer(info[i.toString()].id, info[i.toString()].col, $("#PlayersColumnElvesRating"))
        }
    }
}

function UpdateTopHardWins(info) {
    for (var i = 1; i <= 10;i++)
    {
        if (info[i.toString()] != null)
        {
            CreatePlayer(info[i.toString()].id, info[i.toString()].col, $("#PlayersColumnTrollRating"))
        }
    }
}

function UpdateTopEventPlays(info)
{
    for (var i = 1; i <= 10;i++)
    {
        if (info[i.toString()] != null)
        {
            CreatePlayer(info[i.toString()].id, info[i.toString()].col, $("#PlayersColumnEventRating"))
        }
    }
}










function CreatePlayer(id, rating, panel) {
    var Line = $.CreatePanel("Panel", panel, "player_id_"+id);
    Line.AddClass("LinePlayer");
    $.CreatePanelWithProperties("DOTAAvatarImage", Line, "AvatarLeaderboard", { style: "width:51px;height:51px;", steamid: id });
    var Rating = $.CreatePanel("Label", Line, "player_id_rating_"+id);
    Rating.AddClass("RatingLabel");
    Rating.text = String(rating)
}

function SwitchTab(tab, button) {
    $("#LeaderboardPanel1").style.visibility = "collapse";
    $("#LeaderboardPanel2").style.visibility = "collapse";

    for (var i = 0; i < $("#MenuButtons").GetChildCount(); i++) {
        $("#MenuButtons").GetChild(i).style.boxShadow = "0px 0px 1px 1px black";
    }

    $("#" + button).style.boxShadow = "0px 0px 1px 0px white";
    $("#" + tab).style.visibility = "visible";
}

(function()
{
    GameEvents.Subscribe( "UpdateTopPlays", UpdateTopPlays)
    GameEvents.Subscribe( "UpdateTopWins", UpdateTopWins)
    GameEvents.Subscribe( "UpdateTopHardWins", UpdateTopHardWins)
    GameEvents.SendCustomGameEventToServer( "UpdateTops", {} );
    GameEvents.Subscribe( "UpdateTopPlaysEvent", UpdateTopEventPlays)
    GameEvents.SendCustomGameEventToServer( "UpdateTopsEvent", {} );
})();