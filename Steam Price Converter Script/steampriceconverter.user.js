// ==UserScript==
// @name         Steam price converter
// @version      1.0.0
// @namespace    http://luki.net.pl
// @description  None
// @copyright    2010+, Luki (http://luki.net.pl) | Thanks to Tor (http://code.google.com/p/steam-prices/) and Zuko (http://hlds.pl)
// @homepage     http://luki.net.pl
// @license      MIT License; http://www.opensource.org/licenses/mit-license.php
// @include      http://store.steampowered.com/app/*
// @include      https://store.steampowered.com/app/*
// @include      http://store.steampowered.com/sub/*
// @include      https://store.steampowered.com/sub/*
// @match        http://store.steampowered.com/app/*
// @match        https://store.steampowered.com/app/*
// @match        http://store.steampowered.com/sub/*
// @match        https://store.steampowered.com/sub/*
// ==/UserScript==

var currencyFrom = "EUR";
var currencyTo = "PLN";

var urlGamePattern = new RegExp(/^https?:\/\/store.steampowered.com\/app\/\d+\/?$/i);
var urlPackagePattern = new RegExp(/^https?:\/\/store.steampowered.com\/sub\/\d+\/?$/i);
var pricenodes = new Array();
var originalprices = new Array();
var localscript;
var someNode;

if (urlGamePattern.test(document.documentURI) || urlPackagePattern.test(document.documentURI))
{
	someNode = document.getElementById("global_header");
	
	localscript = document.createElement("script");
	localscript.setAttribute("type", "text/javascript");
	localscript.setAttribute("src", "http://javascriptexchangerate.appspot.com/?from=" + currencyFrom + "&to=" + currencyTo);
	document.body.insertBefore(localscript, someNode);

	divnodes = document.getElementsByTagName("div");
	for (i = 0; i < divnodes.length; i++)
	{
		if ((divnodes[i].getAttribute("class") == "game_purchase_price price") ||
			(divnodes[i].getAttribute("class") == "discount_final_price") ||
			((divnodes[i].getAttribute("class") == "game_area_dlc_price") && (divnodes[i].innerHTML.indexOf("<") == -1)))
		{
			pricenodes.push(divnodes[i]);
			originalprices.push(divnodes[i].innerHTML);
			divnodes[i].innerHTML = "<span style='color: rgb(136, 136, 136);'>Computing...</span>"
			divnodes[i].style.textAlign = "left";
		}
	}
	
	var mypriceHtml;
	var myprice;
	
	for (i = 0; i < pricenodes.length; i++)
	{
		try
		{
			var myvaluepattern = new RegExp(/([\d,-]+)/i);
			mypriceHtml = originalprices[i];
			myprice = parseFloat(myvaluepattern.exec(originalprices[i])[1].replace(",", ".").replace("--", "00"));
		}
		catch(err)
		{
			if (!mypriceHtml || mypriceHtml.length == 0)
			mypriceHtml = "N/A";
			myprice = null;
		}
		if(myprice != null)
		{
			pricenodes[i].innerHTML = mypriceHtml + " <span id='mypricepln" + i + "'>" + myprice + "</span>";	  
			var script = document.createElement("script");
			script.setAttribute("type", "text/javascript");
			script.innerHTML = "var mypricepln = document.getElementById('mypricepln" + i + "'); " + 
			"var price = Math.round(" + currencyFrom + "to" + currencyTo + "(mypricepln.innerHTML * 100)) / 100; " +
			"if(price >= 70){ mypricepln.innerHTML = \"(<span style='color: #f00'>\" + price + \"</span> " + currencyTo + ")\"} else { " +
			"mypricepln.innerHTML = \"(<span style='color: #0f0'>\" + price + \"</span> " + currencyTo + ")\"};";
			document.body.insertBefore(script, someNode);
		}
		else
		{
			pricenodes[i].innerHTML = mypriceHtml;
		}
	}
}