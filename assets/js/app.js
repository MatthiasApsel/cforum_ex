// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
//import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import "../css/app.scss";

import "whatwg-fetch";
import "./modules/closest.js";

// import socket from "./socket"

import "./modules/tabs.js";
import "./modules/datetime-polyfill";
import "./modules/confirmation.js";
import "./components/autolist";
import "./components/dropdown";
import "./modules/show-password.js";
import "./components/taglist";
import "./components/user-selector";

// site specific JS
import "./forum-stats";
import "./flag_message.js";
