var favourites = new Array();
var nowrings = 8;
var rings = new Array(
    new Array(//0 start
        new Array("#favourites","#BirzhaPass_sound_1","#BirzhaPass_sound_2","#BirzhaPass_sound_3","#BirzhaPass_next_wheel","BirzhaPass_sprays_3","BirzhaPass_sprays_2","BirzhaPass_sprays_1"),
        new Array(false,false,false,false,false,false,false,false),
        new Array(7,1,2,3,8,6,5,4)
    ),

    new Array(//1 Sound list 1 RUS
        new Array("#sounds_1","#sounds_9","#sounds_3","#sounds_4","#sounds_5","#sounds_6","#sounds_7","#sounds_8"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(801,809,803,804,805,806,807,808)
    ),
    new Array(//2 Sound list 2 ENG
        new Array("#sounds_2","#sounds_19","#sounds_34","","","","",""),
        new Array(true,true,true,true,true,true,true,true),
        new Array(802,819,834,0,0,0,0,0)
    ),
    new Array(//3 Sound list 3 RUS
        new Array("#sounds_18","#sounds_10","#sounds_11","#sounds_13","#sounds_22","#sounds_14","#sounds_33","#sounds_36"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(818,810,811,813,822,814,833,836)
    ),


    new Array(//4 Sprays list 1
        new Array("#spray_1","#spray_2","#spray_3","#spray_4","#spray_5","#spray_6","#spray_7","#spray_8"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(701,702,703,704,705,706,707,708)
    ),
    new Array(//5 Sprays list 2
        new Array("#spray_9","#spray_10","#spray_11","#spray_12","#spray_13","#spray_14","#spray_15","#spray_16"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(709,710,711,712,713,714,715,716)
    ),
    new Array(//6 Sprays list 3
        new Array("#spray_17","#spray_18","#spray_19","#spray_20","#spray_21","#spray_22","#spray_23","#spray_24"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(717,718,719,720,721,722,723,724)
    ),
    

    new Array(//7 Favourites
        new Array("#favoriteWhat","","","","","","",""),
        new Array(false,false,false,false,false,false,false,false),
        new Array(0,0,0,0,0,0,0,0)
    ),

    new Array(//8 New Wheel
        new Array("#BirzhaPass_sound_4","#BirzhaPass_sound_5","","","","","",""),
        new Array(false,false,false,false,false,false,false,false),
        new Array(9,10,0,0,0,0,0,0)
    ),
    new Array(//9 Sound list 4
        new Array("#sounds_38","#sounds_25","#sounds_27","","","","",""),
        new Array(true,true,true,true,true,true,true,true),
        new Array(838,825,827,0,0,0,0,0)
    ),
  //  new Array(//10 Sound list 5
 //       new Array("#sounds_33","#sounds_34","#sounds_35","#sounds_36","#sounds_37","#sounds_38","",""),
 //       new Array(true,true,true,true,true,true,false,false),
 //       new Array(833,,,836,,838,0,0)
 //   ),
);
var nowselect = 0;

function StartWheel() {
    $("#Wheel").visible = true;
    $("#Bubble").visible = true;
    $("#PhrasesContainer").visible = true;
}

function StopWheel() {
    $("#Wheel").visible = false;
    $("#Bubble").visible = false;
    $("#PhrasesContainer").visible = false;
    if (nowselect != 0)
    {
        $("#PhrasesContainer").RemoveAndDeleteChildren();
        for ( var i = 0; i < 8; i++ )
        {
            $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, {
                class: `MyPhrases`,
                onmouseactivate: `OnSelect(${i})`,
                onmouseover: `OnMouseOver(${i})`,
                onmouseout: `OnMouseOut(${i})`,
            });
            $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
            $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];
            $("#Phrase"+i).GetChild(0).GetChild(1).text = $.Localize(rings[0][0][i]);
        }
        nowselect = 0;
    }
}

function OnSelect(num) {
    var newnum = rings[nowselect][2][num];
    if (rings[nowselect][1][num])
    {
        GameEvents.SendCustomGameEventToServer("SelectVO", {num: newnum});
    }
    else
    {
        $("#PhrasesContainer").RemoveAndDeleteChildren();
        for ( var i = 0; i < 8; i++ )
        {
            let properities_for_panel = {
                class: `MyPhrases`,
                onmouseactivate: `OnSelect(${i})`,
                onmouseover: `OnMouseOver(${i})`,
                onmouseout: `OnMouseOut(${i})`,
            };

            if (rings[newnum][1][i]) {
                properities_for_panel.oncontextmenu = `AddOnFavourites(${i})`;
            }

            $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, properities_for_panel);
            $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
            $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[newnum][1][i];

            //var plyData = CustomNetTables.GetTableValue("birzhainfo", Players.GetLocalPlayer());

             var player_table = CustomNetTables.GetTableValue("Shop", Players.GetLocalPlayer());
             var player_table_js = []
            
             for (var d = 701; d < 899; d++) {
                 player_table_js.push(player_table[1][d])
             }
            
             var phase_deactive = true
            
             for ( var item of player_table_js )
             {
                 if (item == rings[newnum][2][i]) {
                     phase_deactive = false
                     break
                 }
             }

            $("#Phrase"+i).GetChild(0).GetChild(1).text = $.Localize(rings[newnum][0][i]);

            if (phase_deactive && rings[newnum][2][i] != 0 && rings[newnum][2][i] != 7 && rings[newnum][2][i] != 1 && rings[newnum][2][i] != 2 && rings[newnum][2][i] != 3 && rings[newnum][2][i] != 8 && rings[newnum][2][i] != 6 && rings[newnum][2][i] != 5 && rings[newnum][2][i] != 4 && rings[newnum][2][i] != 9) {   
                $("#Phrase"+i).GetChild(0).GetChild(1).style.textDecoration = "line-through"
            }
        }
        nowselect = newnum;
    }
}

function AddOnFavourites(num) {
    if (nowselect != 8)
    {
        favourites.unshift(rings[nowselect][2][num]);
        if (favourites.length > 8)
            favourites[8] = null;
        favourites = favourites.filter(function (el) {
            return el != null;
        });
        Game.EmitSound( "ui.crafting_gem_create" )
        UpdateFavourites();
    }
    else
    {
        favourites[num] = null;
        favourites = favourites.filter(function (el) {
            return el != null;
        });
        UpdateFavourites();
        nowselect = 0;
        OnSelect(2);
    }
}

function UpdateFavourites() {
    var msg = new Array();
    var numsb = new Array();
    var numsi = new Array();
    for ( var i = 0; i < 8; i++ )
    {
        if (favourites[i])
        {
            msg[i] = FindLabelByNum(favourites[i]);
            numsi[i] = favourites[i];
            numsb[i] = true;
        }
        else
        {
            msg[i] = "";
            numsi[i] = 0;
            numsb[i] = false;
        }
    }
    rings[7] = new Array(msg,numsb,numsi);
}

function FindLabelByNum(num) {
    for (var key in rings) {
        var element = rings[key];
        for ( var i = 0; i < 8; i++ )
        {
            if (element[1][i] == true && element[2][i] == num)
            {
                return element[0][i];
            }
        }
    }
}

function OnMouseOver(num) {
    //$.Msg(num);
    $( "#WheelPointer" ).RemoveClass( "Hidden" );
    $( "#Arrow" ).RemoveClass( "Hidden" );
    for ( var i = 0; i < 8; i++ )
    {
        if ($("#Wheel").BHasClass("ForWheel"+i))
            $( "#Wheel" ).RemoveClass( "ForWheel"+i );
    }
    $( "#Wheel" ).AddClass( "ForWheel"+num );
}

function OnMouseOut(num) {
    $( "#WheelPointer" ).AddClass( "Hidden" );
    $( "#Arrow" ).AddClass( "Hidden" );
}

(function() {
	GameUI.CustomUIConfig().chatWheelLoaded = true;

    for ( var i = 0; i < 8; i++ )
    {
        $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, {
            class: `MyPhrases`,
            onmouseactivate: `OnSelect(${i})`,
            onmouseover: `OnMouseOver(${i})`,
            onmouseout: `OnMouseOut(${i})`,
        });
        $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
        $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];
        $("#Phrase"+i).GetChild(0).GetChild(1).text = $.Localize(rings[0][0][i]);
    }
    Game.AddCommand("+WheelButton", StartWheel, "", 0);
    Game.AddCommand("-WheelButton", StopWheel, "", 0);
    $("#Wheel").visible = false;
    $("#Bubble").visible = false;
    $("#PhrasesContainer").visible = false;
})();
