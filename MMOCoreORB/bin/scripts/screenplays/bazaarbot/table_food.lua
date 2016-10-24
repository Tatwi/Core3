BBFoodConfig = {
	path = "object/draft_schematic/food/",
	qualityMin = 35,
	qualityAvg = 45, -- 10% chance to use this as the min value and qualityMax as the max value
	qualityMax = 50, -- 1% Chance to get up to +5 to the max value, with qualityMax as the min value
	quantity = 10, -- Make x of each item
	crateQuantity = 5, -- Set higher than 1 to make factory crates rather than individual items
	freq = 8500, -- Every x seconds
	eventName = "BazaarBotAddFood",
	functionName = "addMoreFood",
}

-- Price = Price * (random(QualityRoll/4, QualityRoll/2) / 100 + 1) * crateQuantity
-- {"price", "alternate crafting template number", "templates"...},
BBMFoodItems = {
	-- Deserts
	{"650", "0", "dessert_almond_kwevvu_crisp_munchies"},
	{"600", "0", "dessert_air_cake"},
	{"650", "0", "dessert_blap_biscuit"},
	{"500", "0", "dessert_citros_snow_cake"},
	{"175", "0", "dessert_dweezel"},
	{"335", "0", "dessert_felbar"},
	{"450", "0", "dessert_pastebread"},
	{"675", "0", "dessert_pyollian_cake"},
	{"600", "0", "dessert_sweesonberry_rolls"},
	{"550", "0", "dessert_vagnerian_canape"},
	
	-- Dishes
	{"490", "0", "dish_ahrisa"},
	{"650", "0", "dish_synthsteak"},
	{"550", "0", "dish_thakitillo"},
	{"300", "0", "dish_veghash"},
	{"600", "0", "dish_vercupti_of_agazza_boleruuee"},
	
	-- Drinks
	{"225", "0", "drink_accarragm"},
	{"335", "0", "drink_bespin_port"},
	{"650", "0", "drink_blue_milk"},
	{"650", "0", "drink_flameout"},
	{"285", "0", "drink_garrmorl"},
	{"525", "0", "drink_ithorian_mist"},
	{"650", "0", "drink_vasarian_brandy"},
	
}

-- These are here to make it easier to add them in later. Just cut/paste into the above table and set the prices. 
BBFood_UNUSED = {
	{"", "0", "dessert_bantha_butter"},	
	{"", "0", "dessert_blob_candy"},
	{"", "0", "dessert_bofa_treat"},
	{"", "0", "dessert_cavaellin_creams"},
	{"", "0", "dessert_chandad"},	
	{"", "0", "dessert_corellian_fried_icecream"},
	{"", "0", "dessert_deneelian_fizz_pudding"},	
	{"", "0", "dessert_glazed_glucose_pate"},
	{"", "0", "dessert_gorrnar"},
	{"", "0", "dessert_kiwik_clusjo_swirl"},
	{"", "0", "dessert_nanana_twist"},
	{"", "0", "dessert_para_roll"},
	{"", "0", "dessert_parwan_nutricake"},	
	{"", "0", "dessert_pikatta_pie"},
	{"", "0", "dessert_pkneb"},
	{"", "0", "dessert_puffcake"},	
	{"", "0", "dessert_ryshcate"},
	{"", "0", "dessert_smugglers_delight"},	
	{"", "0", "dessert_sweet_cake_mix"},
	{"", "0", "dessert_tranna_nougat_cream"},	
	{"", "0", "dessert_wedding_cake"},
	{"", "0", "dessert_won_won"},	
	{"", "0", "dish_bivoli_tempari"},
	{"", "0", "dish_blood_chowder"},
	{"", "0", "dish_braised_canron"},
	{"", "0", "dish_cho_nor_hoola"},
	{"", "0", "dish_crispic"},
	{"", "0", "dish_dustcrepe"},
	{"", "0", "dish_exo_protein_wafers"},
	{"", "0", "dish_fire_stew"},
	{"", "0", "dish_fried_endwa"},
	{"", "0", "dish_gruuvan_shaal"},
	{"", "0", "dish_havla"},
	{"", "0", "dish_kanali_wafers"},
	{"", "0", "dish_karkan_ribenes"},
	{"", "0", "dish_meatlump"},
	{"", "0", "dish_ormachek"},
	{"", "0", "dish_patot_panak"},
	{"", "0", "dish_protato"},
	{"", "0", "dish_puk"},
	{"", "0", "dish_rakririan_burnout_sauce"},
	{"", "0", "dish_ramorrean_capanata"},
	{"", "0", "dish_rations"},
	{"", "0", "dish_scrimpi"},
	{"", "0", "dish_soypro"},
	{"", "0", "dish_stewed_gwouch"},	
	{"", "0", "dish_teltier_noodles"},
	{"", "0", "dish_terratta"},	
	{"", "0", "dish_travel_biscuits"},
	{"", "0", "dish_trimpian"},
	{"", "0", "dish_vegeparsine"},		
	{"", "0", "dish_wastril_bread"},
	{"", "0", "dish_xermaauc"},	
	{"", "0", "drink_aitha"},
	{"", "0", "drink_alcohol"},
	{"", "0", "drink_aludium_pu36"},
	{"", "0", "drink_angerian_fishak_surprise"},
	{"", "0", "drink_antakarian_fire_dancer"},
	{"", "0", "drink_bantha_blaster"},		
	{"", "0", "drink_breath_of_heaven"},
	{"", "0", "drink_caf"},
	{"", "0", "drink_charde"},
	{"", "0", "drink_corellian_ale"},
	{"", "0", "drink_corellian_brandy"},
	{"", "0", "drink_cortyg"},
	{"", "0", "drink_deuterium_pyro"},
	{"", "0", "drink_double_dip_outer_rim_rumdrop"},
	{"", "0", "drink_durindfire"},
	{"", "0", "drink_elshandruu_pica_thundercloud"},	
	{"", "0", "drink_gralinyn_juice"},
	{"", "0", "drink_ice_blaster"},	
	{"", "0", "drink_jaar"},
	{"", "0", "drink_jawa_beer"},
	{"", "0", "drink_kylessian_fruit_distillate"},
	{"", "0", "drink_mandalorian_wine"},
	{"", "0", "drink_ruby_bliel"},
	{"", "0", "drink_skannbult_likker"},
	{"", "0", "drink_spiced_tea"},
	{"", "0", "drink_starshine_surprise"},
	{"", "0", "drink_sullustan_gin"},
	{"", "0", "drink_tatooine_sunburn"},
	{"", "0", "drink_tilla_tiil"},
	{"", "0", "drink_tssolok"},	
	{"", "0", "drink_vayerbok"},
	{"", "0", "drink_veronian_berry_wine"},	
}














