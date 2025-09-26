import 'dart:math';

import 'package:flutter/material.dart';

List<String> softQuestions = [
  "🤫 What’s one secret you’ve never told anyone?",
  "😳💘 Have you ever had a crush on someone you shouldn’t have?",
  "🙈 What’s the most embarrassing thing you’ve ever done?",
  "🎭😅 What’s something you pretend to like but actually don’t?",
  "😏🤥 What’s the biggest lie you’ve ever told and got away with?",
  "🔥😉 What’s your biggest turn-on?",
  "😨🕳️ What’s a secret fear you’ve never told anyone?",
  "⏳🔁 If you could change one thing about your past, what would it be?",
  "❤️🚨 Who’s the one person you’d drop everything for?",
  "🧠💬 What’s something you wish people understood about you?",
  "💖🌹 What’s the most romantic thing you’ve ever done for someone?",
  "😍💬 What’s the sexiest thing someone could say to you?",
  "👀💋 What part of a person do you find most attractive?",
  "💄👄🪞 Have you ever practiced kissing in the mirror?",
  "🤗💋 Would you rather cuddle or make out?",
  "📸😈 Have you ever sent a naughty pic?",
  "🎁🔥 Do you like giving or receiving more?",
  "🛏️😉 Have you ever had a “friends with benefits” situation?",
  "😴🩳❌ What do you wear to bed — or do you sleep naked?",
  "🔥🕒💥 What’s the most number of times you’ve done it in one day?",
  "💌😉 What’s your go-to flirty move?",
  "🍫😏 Sweet or spicy — which are you?",
  "🎶💃 Ever danced seductively for someone?",
  "📱🔥 Ever had a secret crush DM you?",
  "🛁🕯️ Would you prefer a bubble bath or shower together?",
  "🌙🌹 Describe your perfect romantic night.",
  "🍷🍫 Wine and chocolate or cocktails and dessert?",
  "👀💌 Ever been caught checking someone out?",
  "🎬🍿 Movie night: cuddling or watching alone?",
  "💬🫣 Share a flirty message you regret sending?",
  "🏖️☀️ Beach day: swimwear or casual cover-up?",
  "🎯😈 Truth or dare: which would you pick first?",
  "📸🫣 Ever taken a selfie you regretted sending?",
  "🛏️💤 Nap together or separate?",
  "🕺💃 Have you ever flirted while dancing?"
];

List<String> hardQuestions = [
  "Are you more dominant, submissive, or a switch?",
  "What’s your favorite safe word — or would you want one?",
  "Have you ever been tied up, or tied someone else up?",
  "What’s your opinion on spanking — giving or receiving?",
  "What’s a BDSM act you’ve always wanted to try but haven’t?",
  "Would you ever let someone completely take control of you in the bedroom?",
  "What are your hard limits — things you’d never do?",
  "Would you ever wear a collar — or put one on someone else?",
  "Have you ever done orgasm control or denial?",
  "What’s your opinion on public BDSM (discreet play in public settings)?",
  "What’s one dirty command you’d love to be given — or give?",
  "Do you enjoy being punished? If yes, what kind of punishment turns you on?",
  "What’s your ultimate BDSM scene or fantasy?",
  "Have you ever been pushed to the point of safe-wording? What was the reason?",
];

List<Color?> colors = [
  Colors.pink[100],
  Colors.blue[100],
  Colors.green[100],
  Colors.orange[100],
  Colors.purple[100],
  Colors.teal[100],
];

String generateRandomName() {
  final List<String> usernames = [
    // Real first names
    "Alex", "Taylor", "Jordan", "Casey", "Riley",
    "Morgan", "Avery", "Jamie", "Cameron", "Quinn",
    "Charlie", "Dakota", "Skyler", "Peyton", "Emerson",
    "Rowan", "Finley", "Harper", "Reese", "River",
    "Logan", "Blake", "Elliot", "Dakota", "Sydney",
    "Sawyer", "Phoenix", "Shawn", "Kai", "Justice",
    "Hayden", "Sage", "Jaden", "Tatum", "Remy",
    "Alexis", "Jordan", "Casey", "Rowan", "Rory",

    // Initials / short names
    "AJ", "LB", "KJ", "MR", "TJ", "ZP", "XM", "SY",
    "QJ", "DP", "CF", "EV", "GH", "IR", "JK", "LM",
    "NP", "OS", "PR", "RW", "SX", "TY", "UZ", "VL",
    "WB", "XY", "YZ", "AC", "BD", "CE",

    // Fun / quirky names
    "Ziggy",
    "Bubbles",
    "Pickle",
    "Nibbles",
    "Waffles",
    "Tofu",
    "Snaps",
    "Muffin",
    "Pogo",
    "Fizzy",
    "Nacho",
    "Goober",
    "Churro",
    "Twix",
    "Binky",
    "Mocha",
    "Taco",
    "Doodle",
    "Skittles",
    "Jelly",
    "Puff",
    "Peppy",
    "Zappy",
    "Nugget",
    "Bingo",
    "Kiki",
    "Tater",
    "Pogo",
    "Boop",
    "Zuzu",
    "Snick",
    "Fluff",
    "Wiggles",
    "Lolly",
    "Bobo",
    "Popcorn",
    "Scoot",
    "Pips",
    "Sprout"
  ];

  final random = Random();

  return usernames[random.nextInt(usernames.length)];
}
