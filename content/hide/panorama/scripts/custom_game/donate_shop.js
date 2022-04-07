// Заказчик: vladu4eg
// Js Author: https://vk.com/dev_stranger

// Что нужно сделать в lua
// Заполнить в таблицу игрока примерно как "player_table" и поменять это везде в коде
// При покупке предмета отправлять стоимость и айди предмета и добавлять предмет в таблицу, сделал ивент на вызов ошибки если покупка не удалась ее там же вызвать и не забыть отправить ивент на изменение валюты
// Изменить айди курьеров и айди партиклов в луа, под айди предметов в магазине

// Важное
// Айдишник предметов не должны повторяться
// название питомцев должны начинаться с pet_, эффекты с particle_, а донат с donate_
// Остальное будем менять позже, сундуки если все таки нужны будут, я думаю лучше доделать после окончания магазина

var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");
if ($("#ShopButton")) {
	if (parentHUDElements.FindChildTraverse("ShopButton")){
		$("#ShopButton").DeleteAsync( 0 );
	} else {
		$("#ShopButton").SetParent(parentHUDElements);
	}
}

var toggle = false;
var first_time = false;
var cooldown_panel = false
var current_sub_tab = "";
var chest_opened_time = 1

//////////ССЫЛКИ НА КНОПКИ С ДОНАТОМ ПРИ ПОКУПКЕ ВАЛЮТЫ///////////

var button_donate_link_1 = "https://patreon.com/hidedie"
var button_donate_link_2 = "https://paypal.me/vladu4eg"
var button_donate_link_3 = "https://donate.stream/en/vladu4eg"
var button_donate_link_4 = "https://discord.gg/9k29hP2uVy"

//////////Тестовая таблица игрока 1. валюта, 2. купленные айди, 3. шанс троля и бонус рейт///////////


var player_table = [
	[0,0],
	[""],
	[0, "none"],
	[0, "none"],

	// Массив ID СУНДУКА / КОЛИЧЕСТВО
	[
	]
]









var chests_table = [
	// ID Cундука, валюта, стоимость, локализация, иконка, массив шмоток в сундуке(проверяется со шмоткми в магазине)+шанс, последняя награда всегда коины шанс + gold/gem, от скольки до скольки коинов
	// Здесь только визуал, главное не забудь в луа прописывать сундук 4

	["501", "gold", "100", "chest_1", "chest_1", [["704","60"],["705","60"],["818","40"],["24","60"],["117","60"],["130","60"],["116","50"],["602","5"],["603","5"]],   [20, "gold"], [10, 100] ],
	["503", "gold", "100", "chest_3", "chest_3", [["723","60"],["719","60"],["822","40"],["26","60"],["119","60"],["114","60"],["115","60"],["605","5"],["606","5"]],   [20, "gold"], [10, 100] ],
	["516", "gold", "100", "chest_16", "chest_16", [["701","60"],["814","40"],["827","40"],["18","60"],["46","10"],["133","10"],["134","10"],["624","5"],["621","5"]],  [20, "gold"], [10, 100] ],
	["502", "gold", "150", "chest_2", "chest_2", [["712","60"],["716","60"],["819","40"],["25","60"],["118","60"],["131","60"],["602","10"],["603","5"],["604","5"]],   [20, "gold"], [15, 150] ],
	["504", "gold", "150", "chest_4", "chest_4", [["724","60"],["801","40"],["836","40"],["20","60"],["120","60"],["111","60"],["605","10"],["606","5"],["607","5"]],   [20, "gold"], [15, 150] ],
	["517", "gold", "150", "chest_17", "chest_17", [["702","60"],["816","40"],["833","40"],["23","60"],["115","60"],["135","10"],["624","10"],["621","5"],["622","5"]], [20, "gold"], [15, 150] ],
	["505", "gold", "200", "chest_5", "chest_5", [["720","60"],["802","40"],["838","40"],["21","60"],["122","60"],["112","60"],["606","10"],["607","5"],["608","5"]],   [20, "gold"], [15, 150] ],
	["518", "gold", "200", "chest_18", "chest_18", [["703","60"],["722","60"],["834","40"],["27","60"],["47","10"],["50","20"],["621","10"],["622","5"],["627","5"]], 	[20, "gold"], [20, 200] ],
	["506", "gold", "200", "chest_6", "chest_6", [["706","60"],["803","40"],["41","60"],["31","60"],["35","40"],["103","60"],["607","10"],["613","5"],["609","5"]], 	[20, "gold"], [20, 200] ],
	["519", "gold", "200", "chest_19", "chest_19", [["715","60"],["721","60"],["44","60"],["22","60"],["48","10"],["51","20"],["623","10"],["628","5"],["625","5"]], 	[20, "gold"], [20, 200] ],
	["507", "gold", "250", "chest_7", "chest_7", [["707","60"],["804","40"],["36","60"],["37","60"],["19","20"],["129","10"],["113","60"],["615","5"],["612","5"]], 	[20, "gold"], [25, 250] ],
	["508", "gold", "300", "chest_8", "chest_8", [["708","60"],["805","40"],["29","60"],["39","60"],["28","20"],["132","10"],["615","10"],["612","5"],["616","5"]], 	[20, "gold"], [30, 300] ],
	["509", "gold", "350", "chest_9", "chest_9", [["709","60"],["806","40"],["5","60"],["10","60"],["32","20"],["133","10"],["614","5"],["616","5"],["617","5"]], 		[20, "gold"], [35, 350] ],
	["520", "gold", "350", "chest_20", "chest_20", [["714","60"],["718","60"],["45","60"],["34","60"],["52","20"],["610","10"],["611","10"],["629","5"],["626","5"]], 	[20, "gold"], [35, 350] ],
	["510", "gold", "400", "chest_10", "chest_10", [["710","60"],["807","40"],["6","60"],["38","60"],["127","10"],["134","10"],["46","20"],["635","5"],["636","5"]], 	[20, "gold"], [40, 400] ],
	["511", "gold", "400", "chest_11", "chest_11", [["713","60"],["810","40"],["7","60"],["40","60"],["128","10"],["135","10"],["47","20"],["637","5"],["638","5"]], 	[20, "gold"], [40, 400] ],
	["512", "gold", "450", "chest_12", "chest_12", [["717","60"],["811","40"],["8","60"],["42","60"],["126","60"],["144","10"],["48","20"],["639","10"],["640","5"]], 	[20, "gold"], [45, 450] ],
	["513", "gold", "450", "chest_13", "chest_13", [["711","60"],["813","40"],["9","60"],["43","60"],["124","60"],["146","10"],["49","20"],["641","10"],["642","5"]], 	[20, "gold"], [45, 450] ],
	
	["522", "gold", "450", "chest_22", "chest_22", [["808","60"],["809","50"],["825","15"],["33","60"],["53","40"],["54","60"],["55","20"],["618","10"],["619","10"]], [20, "gold"], [45, 450] ],

	["514", "gold", "1000", "chest_14", "chest_14", [["614","30"],["602","60"],["603","50"],["604","20"],["605","40"],["606","30"],["607","20"],["608","10"],["609","10"]], [20, "gold"], [100, 1000] ],
	["515", "gold", "1000", "chest_15", "chest_15", [["615","60"],["612","10"],["616","50"],["617","20"],["613","40"],["639","10"],["640","10"],["641","10"],["642","10"]], [20, "gold"], [100, 1000] ],
	["521", "gold", "1000", "chest_21", "chest_21", [["620","60"],["624","50"],["621","40"],["622","60"],["627","40"],["628","60"],["625","50"],["629","10"],["626","10"]], [20, "gold"], [100, 1000] ],


	
]


// Последняя инфа в массиве это теперь редкость - вот цвета редкостей

//Common        1       
//Uncommon      2        
//Rare          3 
//Mythical      4     
//Legendary     5     
//Immortal	    6         
//Arcana        7    
//Ancient       8




/////////////////////////////

//////////МАССИВ РЕКОМЕНДУЕМЫХ ПРЕДМЕТОВ МАКСИМУМ 9///////////

var Items_recomended = [
	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)
	["509", "gold", "300", "chest_9", "chest_9", [["709","60"],["806","40"],["5","60"],["10","60"],["32","20"],["133","10"],["612","10"],["616","5"],["617","5"]], 		[20, "gold"], [50, 500] ],
	["520", "gold", "300", "chest_20", "chest_20", [["714","60"],["718","60"],["45","60"],["34","60"],["52","20"],["605","10"],["606","10"],["629","5"],["626","5"]], 	[20, "gold"], [50, 500] ],
	["510", "gold", "350", "chest_10", "chest_10", [["710","60"],["807","40"],["6","60"],["38","60"],["127","10"],["134","10"],["46","20"],["635","5"],["636","5"]], 	[20, "gold"], [60, 600] ],
	["511", "gold", "350", "chest_11", "chest_11", [["713","60"],["810","40"],["7","60"],["40","60"],["128","10"],["135","10"],["47","20"],["637","5"],["638","5"]], 	[20, "gold"], [60, 600] ],
	["512", "gold", "400", "chest_12", "chest_12", [["717","60"],["811","40"],["8","60"],["42","60"],["126","60"],["144","10"],["48","20"],["639","10"],["640","5"]], 	[20, "gold"], [70, 700] ],
	["513", "gold", "400", "chest_13", "chest_13", [["711","60"],["813","40"],["9","60"],["43","60"],["124","60"],["146","10"],["49","20"],["641","10"],["642","5"]], 	[20, "gold"], [70, 700] ],

	["514", "gold", "800", "chest_14", "chest_14", [["601","60"],["602","60"],["603","50"],["604","20"],["605","40"],["606","30"],["607","20"],["608","10"],["609","10"]], [20, "gold"], [250, 2000] ],
	["515", "gold", "800", "chest_15", "chest_15", [["615","60"],["612","10"],["616","50"],["617","20"],["613","40"],["639","10"],["640","10"],["641","10"],["642","10"]], [20, "gold"], [250, 2000] ],
	["521", "gold", "800", "chest_21", "chest_21", [["620","60"],["624","50"],["621","40"],["622","60"],["627","40"],["628","60"],["625","50"],["629","10"],["626","10"]], [20, "gold"], [250, 2000] ],

]

//////////МАССИВ ОКОШЕК НА ГЛАВНОЙ///////////

var Items_ADS = [
	["ads_name_1", "ads1"], // переменная названия в локализации, ИКОНКА(именно название png файла)
	["ads_name_2", "ads2"],
]


var Items_sounds = [
	["801",  "gold", "9999999", "sounds", "sounds_1", false, 1], 
	["802",  "gold", "9999999", "sounds", "sounds_2", false, 1], 
	["803",  "gold", "9999999", "sounds", "sounds_3", false, 1], 
	["804",  "gold", "9999999", "sounds", "sounds_4", false, 1],

	["805",  "gold", "9999999", "sounds", "sounds_5", false, 1], 
	["806",  "gold", "9999999", "sounds", "sounds_6", false, 1], 
	["807",  "gold", "9999999", "sounds", "sounds_7", false, 1], 
	["808",  "gold", "9999999", "sounds", "sounds_8", false, 1], 

	["809",  "gold", "9999999", "sounds", "sounds_9", false, 1], 
	["810",  "gold", "9999999", "sounds", "sounds_10", false, 1], 
	["811",  "gold", "9999999", "sounds", "sounds_11", false, 1], 
	//["812",  "gold", "300", "sound_12", "sounds_12", false, 1], 

	["813",  "gold", "9999999", "sounds", "sounds_13", false, 1], 
	["814",  "gold", "9999999", "sounds", "sounds_14", false, 1], 
//	["815",  "gold", "300", "sound_15", "sounds_15", false, 1], 
    ["816",  "gold", "9999999", "sounds", "sounds_16", false, 1],

	//["817",  "gold", "300", "sound_17", "sounds_17", false, 1], 
	["818",  "gold", "9999999", "sounds", "sounds_18", false, 1], 
	["819",  "gold", "9999999", "sounds", "sounds_19", false, 1], 
	//["820",  "gold", "300", "sound_20", "sounds_20", false, 1], 

	//["821",  "gold", "300", "sound_21", "sounds_21", false, 1], 
	["822",  "gold", "9999999", "sounds", "sounds_22", false, 1], 
	//["823",  "gold", "300", "sound_23", "sounds_23", false, 1], 
	//["824",  "gold", "300", "sound_24", "sounds_24", false, 1],

	["825",  "gold", "9999999", "sounds", "sounds_25", false, 1], 
	//["826",  "gold", "300", "sound_26", "sounds_26", false, 1], 
	["827",  "gold", "9999999", "sounds", "sounds_27", false, 1], 
//	["828",  "gold", "300", "sound_28", "sounds_28", false, 1], 

//	["829",  "gold", "300", "sound_29", "sounds_29", false, 1], 
//	["830",  "gold", "300", "sound_30", "sounds_30", false, 1], 
//	["831",  "gold", "300", "sound_31", "sounds_31", false, 1], 
//	["832",  "gold", "300", "sound_32", "sounds_32", false, 1], 

	["833",  "gold", "9999999", "sounds", "sounds_33", false, 1], 
	["834",  "gold", "9999999", "sounds", "sounds_34", false, 1], 
//	["835",  "gold", "300", "sound_35", "sounds_35", false, 1], 
	["836",  "gold", "9999999", "sounds", "sounds_36", false, 1], 

//	["837",  "gold", "300", "sound_37", "sounds_37", false, 1], 
	["838",  "gold", "9999999", "sounds", "sounds_38", false, 1], 
]

var Items_sprays = [
	["701",  "gold", "9999999", "spray_1", "spray_1", false, 1], 
	["702",  "gold", "9999999", "spray_2", "spray_2", false, 1], 
	["703",  "gold", "9999999", "spray_3", "spray_3", false, 1], 
	["704",  "gold", "9999999", "spray_4", "spray_4", false, 1], 

	["705",  "gold", "9999999", "spray_5", "spray_5", false, 1], 
	["706",  "gold", "9999999", "spray_6", "spray_6", false, 1], 
	["707",  "gold", "9999999", "spray_7", "spray_7", false, 1], 
	["708",  "gold", "9999999", "spray_8", "spray_8", false, 1],

	["709",  "gold", "9999999", "spray_9", "spray_9", false, 1], 
	["710",  "gold", "9999999", "spray_10", "spray_10", false, 1], 
	["711",  "gold", "9999999", "spray_11", "spray_11", false, 1], 
	["712",  "gold", "9999999", "spray_12", "spray_12", false, 1], 

	["713",  "gold", "9999999", "spray_13", "spray_13", false, 1], 
	["714",  "gold", "9999999", "spray_14", "spray_14", false, 1], 
	["715",  "gold", "9999999", "spray_15", "spray_15", false, 1], 
	["716",  "gold", "9999999", "spray_16", "spray_16", false, 1],

	["717",  "gold", "9999999", "spray_17", "spray_17", false, 1], 
	["718",  "gold", "9999999", "spray_18", "spray_18", false, 1], 
	["719",  "gold", "9999999", "spray_19", "spray_19", false, 1], 
	["720",  "gold", "9999999", "spray_20", "spray_20", false, 1],

	["721",  "gold", "9999999", "spray_21", "spray_21", false, 1], 
	["722",  "gold", "9999999", "spray_22", "spray_22", false, 1], 
	["723",  "gold", "9999999", "spray_23", "spray_23", false, 1], 
	["724",  "gold", "9999999", "spray_24", "spray_24", false, 1],  
]

//////////МАССИВ ПИТОМЦЕВ///////////

var Items_skin = [
	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)
	["601", "gold", "99999999", "skin_1", "skin_1", false, 7], 
	["602", "gold", "9999999", "skin_2", "skin_2", false, 7], 
	["603", "gold", "9999999", "skin_3", "skin_3", false, 7], 
	["604", "gold", "9999999", "skin_4", "skin_4", false, 7], 
	["605", "gold", "9999999", "skin_5", "skin_5", false, 7], 
	["606", "gold", "9999999", "skin_6", "skin_6", false, 7], 
	["607", "gold", "9999999", "skin_7", "skin_7", false, 7], 
	["608", "gold", "9999999", "skin_8", "skin_8", false, 7], 
	["609", "gold", "9999999", "skin_9", "skin_9", false, 7], 
	["610", "gold", "9999999", "skin_10", "skin_10", false, 7], 
	["611", "gold", "9999999", "skin_11", "skin_11", false, 7], 
	["612", "gold", "9999999", "skin_12", "skin_12", false, 7], 
	["613", "gold", "9999999", "skin_13", "skin_13", false, 7], 
	["614", "gold", "9999999", "skin_14", "skin_14", false, 7], 
	["615", "gold", "9999999", "skin_15", "skin_15", false, 7], 
	["616", "gold", "9999999", "skin_16", "skin_16", false, 7], 
	["617", "gold", "9999999", "skin_17", "skin_17", false, 7], 
	["618", "gold", "9999999", "skin_18", "skin_18", false, 7], 
	["619", "gold", "9999999", "skin_19", "skin_19", false, 7], 
	
	["635", "gold", "9999999", "skin_35", "skin_35", false, 7], 
	["636", "gold", "9999999", "skin_36", "skin_36", false, 7], 
	["637", "gold", "9999999", "skin_37", "skin_37", false, 7], 
	["638", "gold", "9999999", "skin_38", "skin_38", false, 7],
	["639", "gold", "9999999", "skin_39", "skin_39", false, 7], 
	["640", "gold", "9999999", "skin_40", "skin_40", false, 7], 
	["641", "gold", "9999999", "skin_41", "skin_41", false, 7], 
	["642", "gold", "9999999", "skin_42", "skin_42", false, 7],
	
	["620", "gold", "99999999", "skin_20", "skin_20", false, 7], 
	["621", "gold", "9999999", "skin_21", "skin_21", false, 7], 
	["622", "gold", "9999999", "skin_22", "skin_22", false, 7], 
	["623", "gold", "9999999", "skin_23", "skin_23", false, 7], 
	["624", "gold", "9999999", "skin_24", "skin_24", false, 7], 
	["625", "gold", "9999999", "skin_25", "skin_25", false, 7], 
	["626", "gold", "9999999", "skin_26", "skin_26", false, 7], 
	["627", "gold", "9999999", "skin_27", "skin_27", false, 7], 
	["628", "gold", "9999999", "skin_28", "skin_28", false, 7], 
	["629", "gold", "9999999", "skin_29", "skin_29", false, 7],
	
	

//	["630", "gold", "1500", "skin_30", "skin_30", false, 7], 
//	["631", "gold", "1500", "skin_31", "skin_31", false, 7], 
//	["632", "gold", "1500", "skin_32", "skin_32", false, 7], 
//	["633", "gold", "1500", "skin_33", "skin_33", false, 7], 
//	["634", "gold", "1500", "skin_34", "skin_34", false, 7], 
		
]

var Items_pets = [
	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)
	["24", "gold", "150", "pet_24", "pet_24", false, 2],
	["25", "gold", "150", "pet_25", "pet_25", false, 2],
	["26", "gold", "150", "pet_26", "pet_26", false, 2],
	["20", "gold", "150", "pet_20", "pet_20", false, 2],
	["21", "gold", "150", "pet_21", "pet_21", false, 2],
	["31", "gold", "150", "pet_31", "pet_31", false, 2],
	["36", "gold", "150", "pet_36", "pet_36", false, 2],
	["37", "gold", "150", "pet_37", "pet_37", false, 2],
	["41", "gold", "150", "pet_41", "pet_41", false, 2],

	["29", "gold", "200", "pet_29", "pet_29", false, 2],
	["39", "gold", "200", "pet_39", "pet_39", false, 2],
	
	["5", "gold", "300", "pet_5", "pet_5", false, 3],
	["6", "gold", "300", "pet_6", "pet_6", false, 3],
	["7", "gold", "300", "pet_7", "pet_7", false, 3],
	["8", "gold", "300", "pet_8", "pet_8", false, 3],
	["9", "gold", "300", "pet_9", "pet_9", false, 3],
	["10", "gold", "300", "pet_10", "pet_10", false, 3],
	["38", "gold", "300", "pet_38", "pet_38", false, 3],

	["40", "gold", "300", "pet_40", "pet_40", false, 3],
	["42", "gold", "300", "pet_42", "pet_42", false, 3],
	["43", "gold", "300", "pet_43", "pet_43", false, 3],
	["44", "gold", "300", "pet_44", "pet_44", false, 3],
	["45", "gold", "300", "pet_45", "pet_45", false, 3],
	["18", "gold", "300", "pet_18", "pet_18", false, 3],
	["23", "gold", "300", "pet_23", "pet_23", false, 3],
	["27", "gold", "300", "pet_27", "pet_27", false, 3],
	["22", "gold", "300", "pet_22", "pet_22", false, 3],
	["54", "gold", "300", "pet_54", "pet_54", false, 3],
	["53", "gold", "300", "pet_53", "pet_53", false, 3],
	["34", "gold", "400", "pet_34", "pet_34", false, 4],
	["35", "gold", "400", "pet_35", "pet_35", false, 4],
	["19", "gold", "400", "pet_19", "pet_19", false, 4],
	["28", "gold", "400", "pet_28", "pet_28", false, 5],
	["32", "gold", "400", "pet_32", "pet_32", false, 5],
	["33", "gold", "500", "pet_33", "pet_33", false, 5],
	["55", "gold", "500", "pet_55", "pet_55", false, 5],

	["46", "gold", "9999999", "pet_46", "pet_46", false, 5],
	["47", "gold", "9999999", "pet_47", "pet_47", false, 5],
	["48", "gold", "9999999", "pet_48", "pet_48", false, 5],
	["49", "gold", "9999999", "pet_49", "pet_49", false, 5],
	["50", "gold", "9999999", "pet_50", "pet_50", false, 5],
	["51", "gold", "9999999", "pet_51", "pet_51", false, 5],
	["52", "gold", "9999999", "pet_52", "pet_52", false, 5],

	["1", "gold", "99999999", "pet_1", "pet_1", false, 8], 
	["2", "gold", "99999999", "pet_2", "pet_2", false, 8],
	["3", "gold", "99999999", "pet_3", "pet_3", false, 8],
	["4", "gold", "99999999", "pet_4", "pet_4", false, 8],

	["11", "gold", "99999999", "pet_11", "pet_11", false, 8],
	["12", "gold", "99999999", "pet_12", "pet_12", false, 8],
	["13", "gold", "99999999", "pet_13", "pet_13", false, 8],
	["14", "gold", "99999999", "pet_14", "pet_14", false, 8],
	["15", "gold", "99999999", "pet_15", "pet_15", false, 8],
	["16", "gold", "99999999", "pet_16", "pet_16", false, 8],
	
	["17", "gold", "99999999", "pet_17", "pet_17", false, 8],

	["30", "gold", "99999999", "pet_30", "pet_30", false, 8],
	
]

var Items_gem = [
	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)
	 
	
	["111", "gem", "1500", "particle_11", "particle_11", false, 1], 
	["112", "gem", "1000", "particle_12", "particle_12", false, 1], 
	["113", "gem", "1000", "particle_13", "particle_13", false, 1], 
	["114", "gem", "1000", "particle_14", "particle_14", false, 1], 
	["115", "gem", "1500", "particle_15", "particle_15", false, 1], 
	["116", "gem", "1000", "particle_16", "particle_16", false, 1],
	["103", "gem", "2000", "particle_3", "particle_3", false, 1],
	["127", "gem", "2500", "particle_27", "particle_27", false, 1], 
	["128", "gem", "3000", "particle_28", "particle_28", false, 1], 
	["129", "gem", "3500", "particle_29", "particle_29", false, 1], 
	["132", "gem", "4000", "particle_32", "particle_32", false, 1], 
	["133", "gem", "4000", "particle_33", "particle_33", false, 1], 
	["134", "gem", "4000", "particle_34", "particle_34", false, 1], 
	["135", "gem", "4000", "particle_35", "particle_35", false, 1], 
	["144", "gem", "4500", "particle_44", "particle_44", false, 1], 

	["117", "gem", "600", "particle_17", "particle_17", false, 1], 
	["130", "gem", "600", "particle_30", "particle_30", false, 1], 
	["119", "gem", "800", "particle_19", "particle_19", false, 1],
	["131", "gem", "800", "particle_31", "particle_31", false, 1], 
	["118", "gem", "1000", "particle_18", "particle_18", false, 1], 
	["120", "gem", "1200", "particle_20", "particle_20", false, 1], 
	["122", "gem", "1200", "particle_22", "particle_22", false, 1], 
	["124", "gem", "1200", "particle_24", "particle_24", false, 1],
	["126", "gem", "1200", "particle_26", "particle_26", false, 1], 

	["5", "gem", "600", "pet_5", "pet_5", false, 1],
	["6", "gem", "800", "pet_6", "pet_6", false, 1],
	["7", "gem", "800", "pet_7", "pet_7", false, 1],
	["8", "gem", "1000", "pet_8", "pet_8", false, 1],
	["9", "gem", "1000", "pet_9", "pet_9", false, 1],
	["10", "gem", "1200", "pet_10", "pet_10", false, 1],
		
]

//////////МАССИВ ЭФФЕКТОВ///////////

var Items_effects = [
	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)
	 
	
	["111", "gold", "150", "particle_11", "particle_11", false, 7], 
	["112", "gold", "150", "particle_12", "particle_12", false, 2], 
	["113", "gold", "150", "particle_13", "particle_13", false, 2], 
	["114", "gold", "150", "particle_14", "particle_14", false, 2], 
	["115", "gold", "200", "particle_15", "particle_15", false, 3], 
	["116", "gold", "100", "particle_16", "particle_16", false, 2],
	["103", "gold", "500", "particle_3", "particle_3", false, 7],
	["127", "gold", "800", "particle_27", "particle_27", false, 3], 
	["128", "gold", "900", "particle_28", "particle_28", false, 3], 
	["129", "gold", "1100", "particle_29", "particle_29", false, 4], 
	["132", "gold", "1100", "particle_32", "particle_32", false, 4], 
	["133", "gold", "1100", "particle_33", "particle_33", false, 4], 
	["134", "gold", "1100", "particle_34", "particle_34", false, 4], 
	["135", "gold", "1100", "particle_35", "particle_35", false, 4], 
	["144", "gold", "1500", "particle_44", "particle_44", false, 5], 
	["146", "gold", "1500", "particle_46", "particle_46", false, 5], 

	["117", "gold", "150", "particle_17", "particle_17", false, 2], 
	["118", "gold", "150", "particle_18", "particle_18", false, 2], 
	["119", "gold", "150", "particle_19", "particle_19", false, 2], 
	["120", "gold", "150", "particle_20", "particle_20", false, 2], 
	["122", "gold", "150", "particle_22", "particle_22", false, 2], 
	["124", "gold", "500", "particle_24", "particle_24", false, 3],
	["126", "gold", "500", "particle_26", "particle_26", false, 3], 
	["130", "gold", "150", "particle_30", "particle_30", false, 2], 
	["131", "gold", "150", "particle_31", "particle_31", false, 2], 

	["138", "gold", "99999999", "particle_38", "particle_38", false, 8], 
	["139", "gold", "99999999", "particle_39", "particle_39", false, 8], 
	["140", "gold", "99999999", "particle_40", "particle_40", false, 8], 
	["141", "gold", "99999999", "particle_41", "particle_41", false, 8], 
	["142", "gold", "99999999", "particle_42", "particle_42", false, 8], 
	["143", "gold", "99999999", "particle_43", "particle_43", false, 8],
	["121", "gold", "99999999", "particle_21", "particle_21", false, 8], 
	["125", "gold", "99999999", "particle_25", "particle_25", false, 8],
	["137", "gold", "99999999", "particle_37", "particle_37", false, 8],
	["149", "gold", "99999999", "particle_49", "particle_49", false, 8], 
	["150", "gold", "99999999", "particle_50", "particle_50", false, 8], 
	["105", "gold", "99999999", "particle_5", "particle_5", false, 8], 

	["153", "gold", "99999999", "particle_53", "particle_53", false, 8],
	["152", "gold", "99999999", "particle_52", "particle_52", false, 8],  
	["154", "gold", "99999999", "particle_54", "particle_54", false, 8], 
	["155", "gold", "99999999", "particle_55", "particle_55", false, 8], 
	["156", "gold", "99999999", "particle_56", "particle_56", false, 8], 
	["157", "gold", "99999999", "particle_57", "particle_57", false, 8], 
	["145", "gold", "99999999", "particle_45", "particle_45", false, 8],

	["106", "gold", "99999999", "particle_6", "particle_6", false, 8],
	["102", "gold", "99999999", "particle_2", "particle_2", false, 8], 
	["110", "gold", "99999999", "particle_10", "particle_10", false, 8], 
	["109", "gold", "99999999", "particle_9", "particle_9", false, 8],
	["123", "gold", "99999999", "particle_23", "particle_23", false, 8],  
	

	["107", "gold", "99999999", "particle_7", "particle_7", false, 8], 
	["108", "gold", "99999999", "particle_8", "particle_8", false, 8],
	["104", "gold", "99999999", "particle_4", "particle_4", false, 8], 
	["147", "gold", "99999999", "particle_47", "particle_47", false, 8], 
	["148", "gold", "99999999", "particle_48", "particle_48", false, 8], 
	

	["151", "gold", "99999999", "particle_51", "particle_51", false, 8], 
	["158", "gold", "99999999", "particle_58", "particle_58", false, 8], 
	["159", "gold", "99999999", "particle_59", "particle_59", false, 8], 
	["160", "gold", "99999999", "particle_60", "particle_60", false, 8], 
	["161", "gold", "99999999", "particle_61", "particle_61", false, 8], 
	["162", "gold", "99999999", "particle_62", "particle_62", false, 8], 
	["163", "gold", "99999999", "particle_63", "particle_63", false, 8], 
	["164", "gold", "99999999", "particle_64", "particle_64", false, 8], 
	["165", "gold", "99999999", "particle_65", "particle_65", false, 8], 
	["166", "gold", "99999999", "particle_66", "particle_66", false, 8], 
	["167", "gold", "99999999", "particle_67", "particle_67", false, 8], 
	["168", "gold", "99999999", "particle_68", "particle_68", false, 8], 
	["169", "gold", "99999999", "particle_69", "particle_69", false, 8], 
	["170", "gold", "99999999", "particle_70", "particle_70", false, 8], 
	["171", "gold", "99999999", "particle_71", "particle_71", false, 8], 
	["172", "gold", "99999999", "particle_72", "particle_72", false, 8], 

	["136", "gold", "99999999", "particle_36", "particle_36", false, 8],
	["173", "gold", "99999999", "particle_73", "particle_73", false, 8], 
	["174", "gold", "99999999", "particle_74", "particle_74", false, 8], 
	["175", "gold", "99999999", "particle_75", "particle_75", false, 8],  
]

//////////МАССИВ ПОДПИСКИ///////////

var Items_subscribe = [
	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)
	["201", "gold", "150", "chance", "subscribe_1", true, 7],
	["202", "gold", "500", "chance", "subscribe_2", true, 7],
	["203", "gold", "1000", "chance", "subscribe_3", true, 7],
	["204", "gold", "150", "bonus", "subscribe_4", true, 7],
	["205", "gold", "99999999", "battlepass", "subscribe_5", true, 7],
]

//////////МАССИВ ВАЛЮТЫ///////////

var Items_currency = [
	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации если стоит вначале donate_ то предмет показывает кнопки на патреон..итд, можно покупать много раз или один раз(проверка на покупку в базе)
	["301",  "", "5$", "gold_icon", "donate_5", true], 
	["302", "", "10$", "gold_icon", "donate_10", true],
	["303", "", "15$", "gold_icon", "donate_15", true],
	["304", "", "20$", "gold_icon", "donate_20", true],
	["305", "", "25$", "gold_icon", "donate_25", true],
]

function ToggleShop() {
	player_table = CustomNetTables.GetTableValue("Shop", Players.GetLocalPlayer());
	SetMainCurrency()
    if (toggle === false) {
    	if (cooldown_panel == false) {
	        toggle = true;
	        if (first_time === false) {
	            first_time = false;
	            $("#DonateShopPanel").AddClass("sethidden");
	            InitMainPanel()
				InitItems()
				InitInventory()
				InitShop()
				
	        }  
	        if ($("#DonateShopPanel").BHasClass("sethidden")) {
	            $("#DonateShopPanel").RemoveClass("sethidden");
	        }
	        $("#DonateShopPanel").AddClass("setvisible");
	        $("#DonateShopPanel").style.visibility = "visible"
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        })
	    }
    } else {
    	if (cooldown_panel == false) {
	        toggle = false;
	        if ($("#DonateShopPanel").BHasClass("setvisible")) {
	            $("#DonateShopPanel").RemoveClass("setvisible");
	        }
	        $("#DonateShopPanel").AddClass("sethidden");
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        	$("#DonateShopPanel").style.visibility = "collapse"
			})
		}
    }
}

function InitShop() {

	$("#TrollChance").SetPanelEvent('onmouseover', function() {
	    $.DispatchEvent('DOTAShowTextTooltip', $("#TrollChance"), $.Localize( "#shop_trollchance" ) + player_table[2][0] + "%<br>" + $.Localize( "#shop_trollchance_date") + player_table[2][1]); 
	});
	    
	$("#TrollChance").SetPanelEvent('onmouseout', function() {
	    $.DispatchEvent('DOTAHideTextTooltip', $("#TrollChance"));
	});

	$("#BonusRate").SetPanelEvent('onmouseover', function() {
    $.DispatchEvent('DOTAShowTextTooltip', $("#BonusRate"), $.Localize( "#shop_bonusrate" ) + player_table[3][0] + "%<br>" + $.Localize( "#shop_bonusrate_date") + player_table[3][1]); });
    
	$("#BonusRate").SetPanelEvent('onmouseout', function() {
	    $.DispatchEvent('DOTAHideTextTooltip', $("#BonusRate"));
	});

	GameEvents.Subscribe( 'shop_set_currency', SetCurrency ); // Установление валюты переменные gold, gem
	GameEvents.Subscribe( 'shop_error_notification', ShopError ); // Вызов ошибки переменная text - название ошибки


	GameEvents.Subscribe( 'shop_reward_request', RewardRequest ); // Показывает полученный предмет

	GameEvents.Subscribe( 'ChestAnimationOpen', ChestAnimationOpen ); // Запускает анимацию
}

function SwitchTab(tab, button) {
	$("#MainContainer").style.visibility = "collapse";
	$("#ItemsContainer").style.visibility = "collapse";
	$("#InventoryContainer").style.visibility = "collapse";
	$("#GemContainer").style.visibility = "collapse";

	$("#DonateMainButton").style.boxShadow = "0px 0px 5px 1px black";
	$("#DonateItemsButton").style.boxShadow = "0px 0px 5px 1px black";
	$("#DonateInventoryButton").style.boxShadow = "0px 0px 5px 1px black";
	

	$("#" + button).style.boxShadow = "0px 0px 2px 0px white";

	InitMainPanel()
	InitItems()
	InitInventory()
	SetMainCurrency()

	$("#" + tab).style.visibility = "visible";
}

function SwitchShopTab(tab, button) {
	$("#AllDonateItems").style.visibility = "collapse";
	$("#PetsDonateItems").style.visibility = "collapse";
	$("#EffectsDonateItems").style.visibility = "collapse";
	$("#GemDonateItems").style.visibility = "collapse";
	$("#SubscribeDonateItems").style.visibility = "collapse";
	$("#ChestDonateItems").style.visibility = "collapse";
	$("#SkinDonateItems").style.visibility = "collapse";
	
	$("#SoundsDonateItems").style.visibility = "collapse";
	$("#SpraysonateItems").style.visibility = "collapse";

	for (var i = 0; i < $("#MenuItems").GetChildCount(); i++) {
		$("#MenuItems").GetChild(i).style.boxShadow = "0px 0px 1px 1px black";
	}

	$("#" + button).style.boxShadow = "0px 0px 1px 1px white";

	InitMainPanel()
	InitItems()
	InitInventory()
	SetMainCurrency()

	$("#" + tab).style.visibility = "visible";
}

function SwitchInventoryShopTab(tab, button) {
	$("#CouriersPanel").style.visibility = "collapse";
	$("#EffectsPanel").style.visibility = "collapse";
	$("#ChestsPanel").style.visibility = "collapse";
	$("#SkinPanel").style.visibility = "collapse";

	for (var i = 0; i < $("#MenuInventory").GetChildCount(); i++) {
		$("#MenuInventory").GetChild(i).style.boxShadow = "0px 0px 1px 1px black";
	}

	$("#" + button).style.boxShadow = "0px 0px 1px 1px white";

	InitMainPanel()
	InitItems()
	InitInventory()
	SetMainCurrency()

	$("#" + tab).style.visibility = "visible";
}


function InitMainPanel() {
	$('#PopularityRecomDonateItems').RemoveAndDeleteChildren()
	for (var i = 0; i < Items_recomended.length; i++) {
		CreateItemInMain($('#PopularityRecomDonateItems'), Items_recomended, i)
	}
	$("#ChestItemText").text = $.Localize("#" +  Items_ADS[0][0] )
	$("#AdsItemText").text = $.Localize("#" +  Items_ADS[1][0] )
	$("#AdsChests").style.backgroundImage = 'url("file://{images}/custom_game/shop/ads/' + Items_ADS[0][1] + '.png")';
	$("#AdsItem_1").style.backgroundImage = 'url("file://{images}/custom_game/shop/ads/' + Items_ADS[1][1] + '.png")';
	$("#AdsChests").style.backgroundSize = "100% 100%"
	$("#AdsItem_1").style.backgroundSize = "100% 100%"
}

function InitItems() {
	$('#AllDonateItems').RemoveAndDeleteChildren()
	$('#PetsDonateItems').RemoveAndDeleteChildren()
	$('#EffectsDonateItems').RemoveAndDeleteChildren()
	$('#SubscribeDonateItems').RemoveAndDeleteChildren()
	$('#GemDonateItems').RemoveAndDeleteChildren()
	$('#ChestDonateItems').RemoveAndDeleteChildren()
	$('#SkinDonateItems').RemoveAndDeleteChildren()

	$('#SoundsDonateItems').RemoveAndDeleteChildren()
	$('#SpraysonateItems').RemoveAndDeleteChildren()

	for (var i = 0; i < Items_pets.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_pets, i)
		CreateItemInShop($('#PetsDonateItems'), Items_pets, i)
	}
	for (var i = 0; i < Items_effects.length; i++) {
 		CreateItemInShop($('#AllDonateItems'), Items_effects, i)
 		CreateItemInShop($('#EffectsDonateItems'), Items_effects, i)
	}

	for (var i = 0; i < Items_subscribe.length; i++) {
 		CreateItemInShop($('#AllDonateItems'), Items_subscribe, i)
 		CreateItemInShop($('#SubscribeDonateItems'), Items_subscribe, i)
	}
	for (var i = 0; i < Items_gem.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_gem, i)
		CreateItemInShop($('#GemDonateItems'), Items_gem, i)
   }

   for (var i = 0; i < chests_table.length; i++) {
		CreateChestInShop($('#AllDonateItems'), chests_table, i)
		CreateChestInShop($('#ChestDonateItems'), chests_table, i)
   }

   for (var i = 0; i < Items_skin.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_skin, i)
		CreateItemInShop($('#SkinDonateItems'), Items_skin, i)
	}

	for (var i = 0; i < Items_sounds.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_sounds, i)
		CreateItemInShop($('#SoundsDonateItems'), Items_sounds, i)
	}

	for (var i = 0; i < Items_sprays.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_sprays, i)
		CreateItemInShop($('#SpraysonateItems'), Items_sprays, i)
	}
}

function InitInventory() {
	player_table = CustomNetTables.GetTableValue("Shop", Players.GetLocalPlayer());
	SetMainCurrency()
	$('#CouriersPanel').RemoveAndDeleteChildren()
	$('#EffectsPanel').RemoveAndDeleteChildren()
	$('#ChestsPanel').RemoveAndDeleteChildren()
	$('#SkinPanel').RemoveAndDeleteChildren()

	for (var i = 0; i < Items_pets.length; i++) {
		CreateItemInInventory($('#CouriersPanel'), Items_pets, i)
	}
	for (var i = 0; i < Items_effects.length; i++) {
 		CreateItemInInventory($('#EffectsPanel'), Items_effects, i)
	}

	for (var i = 0; i < chests_table.length; i++) {
 		CreateChestInInventory($('#ChestsPanel'), chests_table, i)
	}
	for (var i = 0; i < Items_skin.length; i++) {
		CreateItemInInventory($('#SkinPanel'), Items_skin, i)
   }
}

	// ID Cундука, валюта, стоимость, иконка, локализация, массив шмоток в сундуке
	//["500", "gold", "450", "chest_rare", ["103", "127", "132", "133"] ],


function CreateChestInInventory(panel, table, i) {

	for ( var chest in player_table[4] )
	{
		if (player_table[4][chest][1] == table[i][0]) {
	
	
		 	var item_chest = $.CreatePanel("Panel", panel, "item_chest_" + table[i][0]);
			item_chest.AddClass("ItemChest");
			
			SetOpenChestPanel(item_chest, table[i])
	
			var ItemImage = $.CreatePanel("Panel", item_chest, "");
			ItemImage.AddClass("ItemImage");
			ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
			ItemImage.style.backgroundSize = "contain"
	
			var ItemName = $.CreatePanel("Label", item_chest, "ItemName");
			ItemName.AddClass("ItemName");
			ItemName.text = $.Localize( table[i][3] )
	
			var CountChest = $.CreatePanel("Label", item_chest, "CountChest");
			CountChest.AddClass("CountChest");
			CountChest.text = $.Localize( "#shop_chest_count" ) + " " + player_table[4][chest][2]
	
			var OpenChestPanel = $.CreatePanel("Panel", item_chest, "OpenChestPanel");
			OpenChestPanel.AddClass("OpenChestPanel");
	
			var ItemPrice = $.CreatePanel("Panel", OpenChestPanel, "ItemPrice");
			ItemPrice.AddClass("ItemPrice");
	
			var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
			PriceLabel.AddClass("PriceLabel");
			PriceLabel.text = $.Localize( "#shop_open" )
	
		}
	}
}







function CreateItemInInventory(panel, table, i) {

	// player_table - Это таблица которая имеет в себе названия всех покупных предметов у игрока !!!
	// Здесь я проверяю питомцев в магазине и питомцев у игрока и добавляю их в инвентарь игрока

	for ( var item in player_table[1] )
    {
		if (item == table[i][0]) {
		 	var Recom_item = $.CreatePanel("Panel", panel, "item_inventory_" + table[i][0]);
			Recom_item.AddClass("ItemInventory");
			SetItemInventory(Recom_item, table[i])

			var ItemImage = $.CreatePanel("Panel", Recom_item, "");
			ItemImage.AddClass("ItemImage");
			ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
			ItemImage.style.backgroundSize = "contain"

			var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
			ItemName.AddClass("ItemName");
			ItemName.text = $.Localize("#" +  table[i][4] )

			var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
			BuyItemPanel.AddClass("BuyItemPanel");

			var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
			ItemPrice.AddClass("ItemPrice");

			var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
			PriceLabel.AddClass("PriceLabel");
			PriceLabel.text = $.Localize( "#shop_activate" )

			UpdateItemActivate(table[i][0])	
		}
	}
}






function CreateItemInMain(panel, table, i) {


	// player_table - Это таблица которая имеет в себе названия всех покупных предметов у игрока !!!
	// Здесь добавляются предметы на главный экран

	var Recom_item = $.CreatePanel("Panel", panel, "");
	Recom_item.AddClass("RecomItem");







	SetItemBuyFunction(Recom_item, table[i])

	var ItemImage = $.CreatePanel("Panel", Recom_item, "");
	ItemImage.AddClass("ItemImage");
	ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
	ItemImage.style.backgroundSize = "contain"

	var ItemName = $.CreatePanel("Label", Recom_item, "");
	ItemName.AddClass("ItemName");
	ItemName.text = $.Localize("#" +  table[i][4] )

	var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
	BuyItemPanel.AddClass("BuyItemPanel");

	if (table[i][6] == "1") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b0c3d9 ), to( #808d9c ))';
	} else if (table[i][6] == "2") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #5e98d9 ), to( #41648c ))';
	} else if (table[i][6] == "3") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #4b69ff ), to( #464e75 ))';
	} else if (table[i][6] == "4") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #8847ff ), to( #594978 ))';
	} else if (table[i][6] == "5") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #d32ce6 ), to( #65196e ))';
	} else if (table[i][6] == "6") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b28a33 ), to( #664c15 ))';
	} else if (table[i][6] == "7") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #ade55c ), to( #426314 ))';
	} else if (table[i][6] == "8") {
		BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #eb4b4b ), to( #571212 ))';
	}



	var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
	ItemPrice.AddClass("ItemPrice");

	var PriceIcon = $.CreatePanel("Panel", ItemPrice, "PriceIcon");
	PriceIcon.AddClass("PriceIcon" + table[i][1]);

	var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
	PriceLabel.AddClass("PriceLabel");
	PriceLabel.text = table[i][2]
	
	for ( var item in player_table[1] )
    {
       	if (item == table[i][0]) {
       		Recom_item.SetPanelEvent("onactivate", function() {} );
			BuyItemPanel.style.backgroundColor = "gray"
			PriceLabel.text = $.Localize( "#shop_bought" )
			PriceIcon.DeleteAsync( 0 );
       	}
    }
}



	// ID Cундука, валюта, стоимость, локализация, иконка, массив шмоток в сундуке
	//["500", "gold", "450", "chest_rare", chest_rare", ["103", "127", "132", "133"] ],



function CreateChestInShop(panel, table, i) {

	// player_table - Это таблица которая имеет в себе названия всех покупных предметов у игрока !!!
	// Здесь добавляются предметы в нужную вкладку магазина
	if(table[i][2] != "99999999")
	{
		var Recom_item = $.CreatePanel("Panel", panel, "");
		Recom_item.AddClass("ItemShop");
	
		var ItemImage = $.CreatePanel("Panel", Recom_item, "");
		ItemImage.AddClass("ItemImage");
		ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][4] + '.png")';
		ItemImage.style.backgroundSize = "contain"

		var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
		ItemName.AddClass("ItemName");
		ItemName.text = $.Localize("#" +  table[i][3] )
	
		var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
		BuyItemPanel.AddClass("BuyItemPanel");
	
	
	
		SetItemBuyFunction(Recom_item, table[i])
	
	
		var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
		ItemPrice.AddClass("ItemPrice");
	
		var PriceIcon = $.CreatePanel("Panel", ItemPrice, "PriceIcon");
		PriceIcon.AddClass("PriceIcon" + table[i][1]);
	
		var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
		PriceLabel.AddClass("PriceLabel");
		PriceLabel.text = table[i][2]
	}

}








function CreateItemInShop(panel, table, i) {

	// player_table - Это таблица которая имеет в себе названия всех покупных предметов у игрока !!!
	// Здесь добавляются предметы в нужную вкладку магазина
	if(table[i][2] != "999999999")
	{
		var Recom_item = $.CreatePanel("Panel", panel, "");
		Recom_item.AddClass("ItemShop");
	
		var ItemImage = $.CreatePanel("Panel", Recom_item, "");
		ItemImage.AddClass("ItemImage");
		ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
		ItemImage.style.backgroundSize = "contain"
		ItemImage.style.backgroundRepeat = "no-repeat"
		ItemImage.style.backgroundPosition= "center"
		var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
		ItemName.AddClass("ItemName");
		ItemName.text = $.Localize("#" +  table[i][4] )
	
		var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
		BuyItemPanel.AddClass("BuyItemPanel");
	
		if (table[i][6] == "1") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b0c3d9 ), to( #808d9c ))';
		} else if (table[i][6] == "2") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #5e98d9 ), to( #41648c ))';
		} else if (table[i][6] == "3") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #4b69ff ), to( #464e75 ))';
		} else if (table[i][6] == "4") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #8847ff ), to( #594978 ))';
		} else if (table[i][6] == "5") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #d32ce6 ), to( #65196e ))';
		} else if (table[i][6] == "6") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b28a33 ), to( #664c15 ))';
		} else if (table[i][6] == "7") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #ade55c ), to( #426314 ))';
		} else if (table[i][6] == "8") {
			BuyItemPanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #eb4b4b ), to( #571212 ))';
		}
	
		SetItemBuyFunction(Recom_item, table[i])
	
	
	
	
		var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
		ItemPrice.AddClass("ItemPrice");
	
		var PriceIcon = $.CreatePanel("Panel", ItemPrice, "PriceIcon");
		PriceIcon.AddClass("PriceIcon" + table[i][1]);
	
		var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
		PriceLabel.AddClass("PriceLabel");
		PriceLabel.text = table[i][2]
	
		if(table[i][2] == "9999999")
		{
			Recom_item.SetPanelEvent("onactivate", function() {} );
			BuyItemPanel.style.backgroundColor = "Indigo"
			PriceLabel.text = $.Localize( "#shop_gold" )
			PriceIcon.DeleteAsync( 0 );
		}
		else if(table[i][2] == "99999999")
		{
			Recom_item.SetPanelEvent("onactivate", function() {} );
			BuyItemPanel.style.backgroundColor = "SlateBlue"
			PriceLabel.text = $.Localize( "#shop_event" )
			PriceIcon.DeleteAsync( 0 );
		}
		for ( var item in player_table[1] )
		{
			   if (item == table[i][0]) {
				   Recom_item.SetPanelEvent("onactivate", function() {} );
				BuyItemPanel.style.backgroundColor = "gray"
				PriceLabel.text = $.Localize( "#shop_bought" )
				PriceIcon.DeleteAsync( 0 );
			   }
		}
	}

}


function CloseItemInfo(){
  	$("#info_item_buy").style.visibility = "collapse"
  	$("#ItemInfoBody").RemoveAndDeleteChildren()
}

function BuyCurrencyPanelActive(){

	$("#info_item_buy").style.visibility = "visible"

	$("#ItemNameInfo").text = $.Localize( "#buy_currency" )

	var Panel_for_desc = $.CreatePanel("Label", $("#ItemInfoBody"), "Panel_for_desc");
	Panel_for_desc.AddClass("Panel_for_desc");

	var Item_desc = $.CreatePanel("Label", Panel_for_desc, "Item_desc");
	Item_desc.AddClass("Item_desc");
	Item_desc.text = $.Localize( "#buy_currency_description" )

	var columns = $.CreatePanel("Panel", $("#ItemInfoBody"), "columns");
	columns.AddClass("columns_donate");

	var column_1 = $.CreatePanel("Panel", columns, "column_1");
	column_1.AddClass("column_donate");

	var column_2 = $.CreatePanel("Panel", columns, "column_2");
	column_2.AddClass("column_donate");

	$.CreatePanelWithProperties("Panel", column_1, "PatreonButton", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_1});`, text: "Patreon" });
	$.CreatePanelWithProperties("Panel", column_1, "Paypal", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_2});` });
	$.CreatePanelWithProperties("Panel", column_2, "DonateStream", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_3});` });
	$.CreatePanelWithProperties("Panel", column_2, "Discord", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_4});` });
}


function SetItemBuyFunction(panel, table){
	// Проверяет если это курьер или эффект то создает превью при наведении ( В МАГАЗИНЕ )

	if (table[4].indexOf("pet") == 0) {
		panel.SetPanelEvent("onmouseover", function() { 
		//	$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "PreviewItemTooltipPet"+table[0], "file://{resources}/layout/custom_game/pets_tooltips.xml", "num="+table[0]);
		})

		panel.SetPanelEvent("onmouseout", function() { 
		//	$.DispatchEvent( "UIHideCustomLayoutTooltip", panel, "PreviewItemTooltipPet"+table[0]);
		})
	} else if (table[4].indexOf("particle") == 0) {
		panel.SetPanelEvent("onmouseover", function() { 
		//	$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "PreviewItemTooltipParticle"+table[0], "file://{resources}/layout/custom_game/particles_tooltips.xml", "num="+table[0]);
		})

		panel.SetPanelEvent("onmouseout", function() { 
		//	$.DispatchEvent( "UIHideCustomLayoutTooltip", panel, "PreviewItemTooltipParticle"+table[0]);
		})
	}else if (table[4].indexOf("pet") == 0) {
			panel.SetPanelEvent("onmouseover", function() { 
			//	$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "PreviewItemTooltipParticle"+table[0], "file://{resources}/layout/custom_game/particles_tooltips.xml", "num="+table[0]);
			})
	
			panel.SetPanelEvent("onmouseout", function() { 
			//	$.DispatchEvent( "UIHideCustomLayoutTooltip", panel, "PreviewItemTooltipParticle"+table[0]);
			})
	}


	// Создается панель с уточнением нужно ли купить предмет
    panel.SetPanelEvent("onactivate", function() { 
    	$("#info_item_buy").style.visibility = "visible"

    	$("#ItemNameInfo").text = $.Localize("#" +  table[4] )

		$("#ItemInfoBody").style.flowChildren = "down"

		var Panel_for_desc = $.CreatePanel("Label", $("#ItemInfoBody"), "Panel_for_desc");
		Panel_for_desc.AddClass("Panel_for_desc");

		var Item_desc = $.CreatePanel("Label", Panel_for_desc, "Item_desc");
		Item_desc.AddClass("Item_desc");
		Item_desc.text = $.Localize( table[4] + "_description" )

		if (table[4].indexOf("chest") == 0) {

			var ChestItemPreview = $.CreatePanel("Panel", $("#ItemInfoBody"), "ChestItemPreview");
			ChestItemPreview.AddClass("ChestItemPreview");


			for (var i = 0; i < Items_sounds.length; i++) {
				CreateItemInChestPreview(ChestItemPreview, Items_sounds, i, table)
		    }
			for (var i = 0; i < Items_sprays.length; i++) {
				CreateItemInChestPreview(ChestItemPreview, Items_sprays, i, table)
		    }
			for (var i = 0; i < Items_effects.length; i++) {
				CreateItemInChestPreview(ChestItemPreview, Items_effects, i, table)
			}
			for (var i = 0; i < Items_pets.length; i++) {
				CreateItemInChestPreview(ChestItemPreview, Items_pets, i, table)
			}
			for (var i = 0; i < Items_subscribe.length; i++) {
				CreateItemInChestPreview(ChestItemPreview, Items_subscribe, i, table)
			}
			for (var i = 0; i < Items_skin.length; i++) {
				CreateItemInChestPreview(ChestItemPreview, Items_skin, i, table)
		    }
			for (var i = 0; i < Items_gem.length; i++) {
				CreateItemInChestPreview(ChestItemPreview, Items_gem, i, table)
		    }

		    CreateItemCurrencyPreview(ChestItemPreview, table[6][1], table[7], table[6][0])
		}

		var BuyItemPanel = $.CreatePanel("Panel", $("#ItemInfoBody"), "BuyItemPanel");
		BuyItemPanel.AddClass("BuyItemPanelInfo");

		var PriceLabel = $.CreatePanel("Label", BuyItemPanel, "PriceLabel");
		PriceLabel.AddClass("PriceLabelInfo");
		PriceLabel.text = $.Localize( "#shop_buy" )

		BuyItemPanel.SetPanelEvent("onactivate", function() { BuyItemFunction(panel, table); CloseItemInfo(); } );

    } );  
}




function SetItemInventory(panel, table) {
	// Проверяет если это курьер или эффект то создает превью при наведении (В ИНВЕНТАРЕ)
	if (table[4].indexOf("pet") == 0) {
		panel.SetPanelEvent("onmouseover", function() { 
		//	$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "PreviewItemTooltipPet"+table[0], "file://{resources}/layout/custom_game/pets_tooltips.xml", "num="+table[0]);
		})
		panel.SetPanelEvent("onmouseout", function() { 
		//	$.DispatchEvent( "UIHideCustomLayoutTooltip", panel, "PreviewItemTooltipPet"+table[0]);
		})
		panel.SetPanelEvent("onactivate", function() { 
	 		SelectCourier(table[0])
	    });
	} 
	else if (table[4].indexOf("particle") == 0) {
		panel.SetPanelEvent("onmouseover", function() { 
		//	$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "PreviewItemTooltipParticle"+table[0], "file://{resources}/layout/custom_game/particles_tooltips.xml", "num="+table[0]);
		})
		panel.SetPanelEvent("onmouseout", function() { 
		//	$.DispatchEvent( "UIHideCustomLayoutTooltip", panel, "PreviewItemTooltipParticle"+table[0]);
		})
		panel.SetPanelEvent("onactivate", function() { 
	 		SelectParticle(table[0])
	    });
	}
	else if (table[4].indexOf("skin") == 0) {
		panel.SetPanelEvent("onmouseover", function() { 
		//	$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "PreviewItemTooltipParticle"+table[0], "file://{resources}/layout/custom_game/particles_tooltips.xml", "num="+table[0]);
		})
		panel.SetPanelEvent("onmouseout", function() { 
		//	$.DispatchEvent( "UIHideCustomLayoutTooltip", panel, "PreviewItemTooltipParticle"+table[0]);
		})
		panel.SetPanelEvent("onactivate", function() { 
	 		SelectSkin(table[0])
	    });
	}
}

// ТВОЯ ФУНКЦИЯ НА ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЯ КУРЬЕРА

var courier_selected = null;

function SelectCourier(num)
{
    if (courier_selected != num)
    {

    	for (var i = 0; i < $("#CouriersPanel").GetChildCount(); i++) {
    		$("#CouriersPanel").GetChild(i).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        	$("#CouriersPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
    	} 

    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "SelectPets", { id: Players.GetLocalPlayer(),part:num, offp:false, name:num } );
        courier_selected = num;
		GameEvents.SendCustomGameEventToServer( "SetDefaultPets", { id: Players.GetLocalPlayer(),part:String(courier_selected)} );
    }
    else
    {
    	$("#item_inventory_"+courier_selected).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        $("#item_inventory_"+courier_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "SelectPets", { id: Players.GetLocalPlayer(),part:num, offp:true, name:num } );
        courier_selected = null;
		GameEvents.SendCustomGameEventToServer( "SetDefaultPets", { id: Players.GetLocalPlayer(),part:"0"} );
    } 

}

// ТВОЯ ФУНКЦИЯ НА ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЯ Партикла

var particle_selected = null;

function SelectParticle(num)
{
	var numPart = 0
    if (particle_selected != num)
    {

    	for (var i = 0; i < $("#EffectsPanel").GetChildCount(); i++) {
    		$("#EffectsPanel").GetChild(i).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        	$("#EffectsPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
    	} 

    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
		numPart = Number(num)-100
        GameEvents.SendCustomGameEventToServer( "SelectPart", { id: Players.GetLocalPlayer(),part:String(numPart), offp:false, name:String(numPart) } );
        particle_selected = num;
		GameEvents.SendCustomGameEventToServer( "SetDefaultPart", { id: Players.GetLocalPlayer(),part:String(numPart)} );
    }
    else
    {
    	$("#item_inventory_"+particle_selected).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        $("#item_inventory_"+particle_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "SelectPart", { id: Players.GetLocalPlayer(),part:String(numPart) , offp:true, name:String(numPart)  } );
        particle_selected = null;
		GameEvents.SendCustomGameEventToServer( "SetDefaultPart", { id: Players.GetLocalPlayer(),part:"0"} );
    }	
}

var skin_selected = null;

function SelectSkin(num)
{
    if (skin_selected != num)
    {

    	for (var i = 0; i < $("#SkinPanel").GetChildCount(); i++) {
    		$("#SkinPanel").GetChild(i).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        	$("#SkinPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
    	} 

    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "SelectSkin", { id: Players.GetLocalPlayer(),part:String(num), offp:false, name:String(num) } );
        skin_selected = num;
		GameEvents.SendCustomGameEventToServer( "SetDefaultSkin", { id: Players.GetLocalPlayer(),part:String(num)} );
    }
    else
    {
    	$("#item_inventory_"+skin_selected).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        $("#item_inventory_"+skin_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "SelectSkin", { id: Players.GetLocalPlayer(),part:String(num) , offp:true, name:String(num)  } );
        skin_selected = null;
		GameEvents.SendCustomGameEventToServer( "SetDefaultSkin", { id: Players.GetLocalPlayer(),part:"0"} );
    }	
}


//////////// ФУНКЦИЯ ПОКУПКИ /////////

function BuyItemFunction(panel, table) {
	if ((table[1] == "gold" && Number(table[2]) <= Number(player_table[0][0])) || (table[1] == "gem" && Number(table[2]) <= Number(player_table[0][1])) && Number(table[2]) != "999999") 
	{
		GameEvents.SendCustomGameEventToServer( "BuyShopItem", { id: Players.GetLocalPlayer(), TypeDonate: table[1] , Coint: table[2], Nick: table[4], Num: table[0]  } );
		if (table[1] == "gold")
		{
			player_table[0][0] = Number(player_table[0][0]) - Number(table[2])
		}
		else if (table[1] == "gem")
		{
			player_table[0][1] = Number(player_table[0][1]) - Number(table[2])
		}
		SetMainCurrency()
		panel.SetPanelEvent("onactivate", function() {} );
		panel.FindChildTraverse("BuyItemPanel").style.backgroundColor = "gray"
		panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_bought" )
		panel.FindChildTraverse("PriceIcon").DeleteAsync( 0 );
		ShopBuy("shop_nice_buy")
	} 
	else  
	{
		ShopError("shop_no_money")
	}

	if (!table[5]) {
		//player_table[1].push(table[0]) // player_table - Это таблица которая имеет в себе названия всех покупных предметов у игрока !!! Здесь добавляется в массив купленный предмет но для js тестил, там в луа надо отправлять название и обновлять net table

		
	}
}

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПРИ ПЕРВОМ ОТКРЫТИИ /////////

function SetMainCurrency() {

	if (player_table[0]) {
		$("#Currency").text = String(player_table[0][0])
		$("#Currency2").text = 	String(player_table[0][1])	
	}

	//var table = CustomNetTables.GetTableValue("players", String(Players.GetLocalPlayer()));
	//if (table) {
	//	$("#Currency").text = table.currency_1
	//	$("#Currency2").text = 	table.currency_2	
	//}
}

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПОСЛЕ ПОКУПКИ /////////

function SetCurrency(data) {
	if (data) {
		if (data.gold) {
			$("#Currency").text = String(data.gold)
		}
		if (data.gem) {
			$("#Currency2").text = 	String(data.gem)	
		}
	}
}

function ShopError(data) {
	$( "#shop_error_panel" ).style.visibility = "visible";

	if (data) {
		$( "#shop_error_label" ).text = $.Localize("#" +  data );
	} else {
		$( "#shop_error_label" ).text = "";
	}
	

	$( "#shop_error_label" ).SetHasClass( "error_visible", false );

	$.Schedule( 2, RemoveError );
}

function RemoveError() {
	$( "#shop_error_panel" ).style.visibility = "collapse";
	$( "#shop_error_label" ).SetHasClass( "error_visible", true );
	$( "#shop_error_label" ).text = "";
}

function ShopBuy(data) {
	$( "#shop_buy_panel" ).style.visibility = "visible";

	if (data) {
		$( "#shop_buy_label" ).text = $.Localize("#" +  data );
	} else {
		$( "#shop_buy_label" ).text = "";
	}
	

	$( "#shop_buy_label" ).SetHasClass( "buy_visible", false );

	$.Schedule( 5, RemoveBuy );
	InitInventory()
	SetMainCurrency()
}

function RemoveBuy() {
	$( "#shop_buy_panel" ).style.visibility = "collapse";
	$( "#shop_buy_label" ).SetHasClass( "buy_visible", true );
	$( "#shop_buy_label" ).text = "";
}



function UpdateItemActivate(id) {
	if (courier_selected !== null) {
		if (id == courier_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }
	}
	if (particle_selected !== null) {
		if (id == particle_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }			
	}
}





function CloseOpenChest(){
  	$("#ChestOpenPanelMainClosed").style.visibility = "collapse"
  	$("#ChestBodyInfo").RemoveAndDeleteChildren()
}










function SetOpenChestPanel(panel, table){
	// Создается панель с уточнением нужно ли купить предмет
    panel.SetPanelEvent("onactivate", function() { 
    	$("#ChestOpenPanelMainClosed").style.visibility = "visible"

    	$("#ChestName").text = $.Localize("#" +  table[3] )

		var ChestImage = $.CreatePanel("Panel",  $("#ChestBodyInfo"), "");
		ChestImage.AddClass("ChestImageInfo");
		ChestImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[3] + '.png")';
		ChestImage.style.backgroundSize = "100%"


		var OpenChestButton = $.CreatePanel("Panel",  $("#ChestBodyInfo"), "OpenChestButton");
		OpenChestButton.AddClass("OpenChestButton");

		var ChestAllRewardsPanel = $.CreatePanel("Panel",  $("#ChestBodyInfo"), "ChestAllRewardsPanel");
		ChestAllRewardsPanel.AddClass("ChestAllRewardsPanel");

		var OpenChest_Label = $.CreatePanel("Label", OpenChestButton, "OpenChest_Label");
		OpenChest_Label.AddClass("OpenChest_Label");
		OpenChest_Label.text = $.Localize( "#shop_open" )

		for (var i = 0; i < Items_sounds.length; i++) {
			CreateItemInChest(ChestAllRewardsPanel, Items_sounds, i, table)
	    }
		for (var i = 0; i < Items_sprays.length; i++) {
			CreateItemInChest(ChestAllRewardsPanel, Items_sprays, i, table)
	    }
		for (var i = 0; i < Items_effects.length; i++) {
			CreateItemInChest(ChestAllRewardsPanel, Items_effects, i, table)
		}
		for (var i = 0; i < Items_pets.length; i++) {
			CreateItemInChest(ChestAllRewardsPanel, Items_pets, i, table)
		}
		for (var i = 0; i < Items_subscribe.length; i++) {
			CreateItemInChest(ChestAllRewardsPanel, Items_subscribe, i, table)
		}
		for (var i = 0; i < Items_skin.length; i++) {
			CreateItemInChest(ChestAllRewardsPanel, Items_skin, i, table)
	    }
		for (var i = 0; i < Items_gem.length; i++) {
			CreateItemInChest(ChestAllRewardsPanel, Items_gem, i, table)
	    }

		

	    // Последним добавляется валюта золота "gem", gold
	    CreateItemCurrency(ChestAllRewardsPanel, table[6][1], table[7], table[6][0])





		OpenChestButton.SetPanelEvent("onactivate", function() { OpenChest(table); CloseOpenChest(); } );

    } );  
}

function OpenChest(table) {
	chest_opened_time = 1
  	$("#chest_opened_animation").RemoveAndDeleteChildren()


	var ChestOpenImage = $.CreatePanel("Panel",  $("#chest_opened_animation"), "ChestOpenImage");
	ChestOpenImage.AddClass("ChestOpenImage");
	ChestOpenImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[3] + '.png")';
	//ChestOpenImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[3] + '.png")';
	ChestOpenImage.style.backgroundSize = "100%"
	ChestOpenImage.style.transform = "scaleX(" + 0 + ')' + " " + 'scaleY(' + 0 +')'

	GameEvents.SendCustomGameEventToServer( "OpenChestAnimation", {chest_id : table[0], PlayerID : Players.GetLocalPlayer()});

	// Вызывать в луа рандом именно здесь (желательно сделать задержку в 5 секунд может чуть больше и вызвать функцию RewardRequest )

	$("#chest_opened_animation").style.visibility = "visible"
}

function ChestAnimationOpen(data) {
	if (data.time < 4) {
		$("#chest_opened_animation").FindChildTraverse("ChestOpenImage").style.transform = "scaleX(" + data.time/3 + ')' + " " + 'scaleY(' + data.time/3 +')'
	} else {
		$("#chest_opened_animation").FindChildTraverse("ChestOpenImage").style.opacity = "0"
	}
}


// RewardRequest() - нужно вызывать из луа передавать туда иконку награды

function RewardRequest(data) {
	$("#chest_opened_animation").RemoveAndDeleteChildren()
	var RewardIcon = $.CreatePanel("Panel",  $("#chest_opened_animation"), "RewardIcon");
	RewardIcon.AddClass("ChestOpenImageItem");
	var icon

	if (data.reward) {
		for (var i = 0; i < Items_pets.length; i++) {
			if (Items_pets[i][0] == data.reward) {
				icon = Items_pets[i][3]
			}
		}
		for (var i = 0; i < Items_effects.length; i++) {
			if (Items_effects[i][0] == data.reward) {
				icon = Items_effects[i][3]
			}
		}

		for (var i = 0; i < Items_subscribe.length; i++) {
			if (Items_subscribe[i][0] == data.reward) {
				icon = Items_subscribe[i][3]
			}
		}
		for (var i = 0; i < Items_gem.length; i++) {
			if (Items_gem[i][0] == data.reward) {
				icon = Items_gem[i][3]
			}
	    }
		for (var i = 0; i < Items_skin.length; i++) {
			if (Items_skin[i][0] == data.reward) {
				icon = Items_skin[i][3]
			}
	    }
		for (var i = 0; i < Items_sprays.length; i++) {
			if (Items_sprays[i][0] == data.reward) {
				icon = Items_sprays[i][3]
			}
	    }
		for (var i = 0; i < Items_sounds.length; i++) {
			if (Items_sounds[i][0] == data.reward) {
				icon = Items_sounds[i][3]
			}
	    }
	    if (data.reward == "gold") {
	    	icon = "gold"
	    }
	    if (data.reward == "gem") {
	    	icon = "gem"
	    }
	}

	RewardIcon.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + icon + '.png")';
	RewardIcon.style.backgroundSize = "100%"

	var AcceptButton = $.CreatePanel("Panel",  $("#chest_opened_animation"), "AcceptButton");
	AcceptButton.AddClass("AcceptButton");
	
	var LabelAccept = $.CreatePanel("Label", AcceptButton, "LabelAccept");
	LabelAccept.AddClass("LabelAccept");
	LabelAccept.text = $.Localize( "#shop_accept" )
 
 	// Если нужно что-то передать в закрытие сундука всунь это в closechest
	AcceptButton.SetPanelEvent("onactivate", function() { CloseChest(); } );
	
}

function CloseChest() {
	// Закрытие сундука
	InitInventory() // обновить инвентарь
	SetMainCurrency()
	$("#chest_opened_animation").style.visibility = "collapse"
}




function CreateItemInChest(panel, table, i, table_chest) {

	for ( var chest_items in table_chest[5] ) {

		if (table[i][0] == table_chest[5][chest_items][0] ) {
			if (!panel.FindChildTraverse("item_" + table_chest[5][chest_items][0])) {
				var Chest_in_item = $.CreatePanel("Panel", panel, "item_" + table_chest[5][chest_items][0]);
				Chest_in_item.AddClass("Chest_in_item");

				CreateItemChance(Chest_in_item, $.Localize("#" + "shop_chance") + " " + table_chest[5][chest_items][1] + "%")

			
				var ItemImage = $.CreatePanel("Panel", Chest_in_item, "");
				ItemImage.AddClass("ItemChestImage");
				ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
				ItemImage.style.backgroundSize = "100%"

				var RarePanel = $.CreatePanel("Panel", Chest_in_item, "");
				RarePanel.AddClass("RarePanel");



				if (table[i][6] == "1") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b0c3d9 ), to( #808d9c ))';
				} else if (table[i][6] == "2") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #5e98d9 ), to( #41648c ))';
				} else if (table[i][6] == "3") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #4b69ff ), to( #464e75 ))';
				} else if (table[i][6] == "4") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #8847ff ), to( #594978 ))';
				} else if (table[i][6] == "5") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #d32ce6 ), to( #65196e ))';
				} else if (table[i][6] == "6") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b28a33 ), to( #664c15 ))';
				} else if (table[i][6] == "7") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #ade55c ), to( #426314 ))';
				} else if (table[i][6] == "8") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #eb4b4b ), to( #571212 ))';
				}

				

			
				var ItemName = $.CreatePanel("Label", RarePanel, "ItemName");
				ItemName.AddClass("ItemChestName");
				ItemName.text = $.Localize("#" +  table[i][4] )
			
				for ( var item in player_table[1] )
				{
					if (item == table_chest[5][chest_items][0]) {
						ItemImage.style.brightness = "0.1"
						ItemImage.style.washColor = "gray"
					}
				}
			}
		}
	}

}














function CreateItemInChestPreview(panel, table, i, table_chest) {

	for ( var chest_items in table_chest[5] ) {

		if (table[i][0] == table_chest[5][chest_items][0] ) {
			if (!panel.FindChildTraverse("item_" + table_chest[5][chest_items][0])) {
				var Chest_in_item = $.CreatePanel("Panel", panel, "item_" + table_chest[5][chest_items][0]);
				Chest_in_item.AddClass("Chest_in_item_preview");

				CreateItemChance(Chest_in_item, $.Localize("#" + "shop_chance") + " " + table_chest[5][chest_items][1] + "%")

			
				var ItemImage = $.CreatePanel("Panel", Chest_in_item, "");
				ItemImage.AddClass("ItemChestImage_preview");
				ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
				ItemImage.style.backgroundSize = "100%"

				var RarePanel = $.CreatePanel("Panel", Chest_in_item, "");
				RarePanel.AddClass("RarePanel");



				if (table[i][6] == "1") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b0c3d9 ), to( #808d9c ))';
				} else if (table[i][6] == "2") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #5e98d9 ), to( #41648c ))';
				} else if (table[i][6] == "3") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #4b69ff ), to( #464e75 ))';
				} else if (table[i][6] == "4") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #8847ff ), to( #594978 ))';
				} else if (table[i][6] == "5") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #d32ce6 ), to( #65196e ))';
				} else if (table[i][6] == "6") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b28a33 ), to( #664c15 ))';
				} else if (table[i][6] == "7") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #ade55c ), to( #426314 ))';
				} else if (table[i][6] == "8") {
					RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #eb4b4b ), to( #571212 ))';
				}

				

			
				var ItemName = $.CreatePanel("Label", RarePanel, "ItemName");
				ItemName.AddClass("ItemChestName_preview");
				ItemName.text = $.Localize("#" +  table[i][4] )
			
				for ( var item in player_table[1] )
				{
					if (item == table_chest[5][chest_items][0]) {
						ItemImage.style.brightness = "0.1"
						ItemImage.style.washColor = "gray"
					}
				}
			}
		}
	}

}

function CreateItemCurrencyPreview(panel, currency, count, chance) {

	var Chest_in_item = $.CreatePanel("Panel", panel, "item_" + currency);
	Chest_in_item.AddClass("Chest_in_item_preview");

	CreateItemChance(Chest_in_item, $.Localize("#" + "shop_chance") + " " + chance + "%<br>" + $.Localize("#" + "shop_currency_count") + " " + $.Localize("#" + "shop_currency_count_from") + " " + count[0] + " " + $.Localize("#shop_currency_count_to") + " " + count[1])

	var ItemImage = $.CreatePanel("Panel", Chest_in_item, "");
	ItemImage.AddClass("ItemChestImage_preview");
	ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + currency + '.png")';
	ItemImage.style.backgroundSize = "100%"

	var RarePanel = $.CreatePanel("Panel", Chest_in_item, "");
	RarePanel.AddClass("RarePanel");
	RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b28a33 ), to( #664c15 ))';

	var ItemName = $.CreatePanel("Label", RarePanel, "ItemName");
	ItemName.AddClass("ItemChestName_preview");
	ItemName.text = $.Localize( "#shop_currency_" + currency)
}

























function CreateItemCurrency(panel, currency, count, chance) {

	var Chest_in_item = $.CreatePanel("Panel", panel, "item_" + currency);
	Chest_in_item.AddClass("Chest_in_item");

	CreateItemChance(Chest_in_item, $.Localize("#" + "shop_chance") + " " + chance + "%<br>" + $.Localize("#" + "shop_currency_count") + " " + $.Localize("#" + "shop_currency_count_from") + " " + count[0] + " " + $.Localize("#" + "shop_currency_count_to") + " " + count[1])

	var ItemImage = $.CreatePanel("Panel", Chest_in_item, "");
	ItemImage.AddClass("ItemChestImage");
	ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + currency + '.png")';
	ItemImage.style.backgroundSize = "100%"

	var RarePanel = $.CreatePanel("Panel", Chest_in_item, "");
	RarePanel.AddClass("RarePanel");
	RarePanel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #b28a33 ), to( #664c15 ))';

	var ItemName = $.CreatePanel("Label", RarePanel, "ItemName");
	ItemName.AddClass("ItemChestName");
	ItemName.text = $.Localize( "#shop_currency_" + currency)
}



function CreateItemChance(panel, label) {
	panel.SetPanelEvent('onmouseover', function() {
	    $.DispatchEvent('DOTAShowTextTooltip', panel, label); 
	});
	    
	panel.SetPanelEvent('onmouseout', function() {
	    $.DispatchEvent('DOTAHideTextTooltip', panel);
	});
}