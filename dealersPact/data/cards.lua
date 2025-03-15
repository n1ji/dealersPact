-- scripts/cards.lua
-- Check cards.md for a more readable list

local Cards = {}

-- Resource Cards (20)
Cards.resourceCards = {
    { id = 1, name = "Gold Coin", effect = "+10 points" },
    { id = 2, name = "Silver Coin", effect = "+5 points, Draw 1" },
    { id = 3, name = "Mystic Gem", effect = "+20 points, Lose 3 SE" },
    { id = 4, name = "Fortune Token", effect = "+15 points, Double if Dealer has more points" },
    { id = 5, name = "Ancient Relic", effect = "+25 points, Costs 10 SE" },
    -- { id = 6, name = "Cursed Coin", effect = "+30 points, Flip a coin: Lose 10 SE on heads" },
    { id = 7, name = "Lucky Charm", effect = "+10 points, Reuse one action card next round" },
    { id = 8, name = "Ethereal Gold", effect = "+20 points, but is destroyed after use" },
    { id = 9, name = "Soul Residue", effect = "+10 points, Convert 3 points into SE" },
    { id = 10, name = "Stacked Fortune", effect = "+15 points, Cannot be used if you played a gamble card this round" },
    { id = 11, name = "Twisted Wealth", effect = "+25 points, Opponent gains 5 points too" },
    { id = 12, name = "Fool’s Gold", effect = "+10 points, Reveal Dealer’s next card when played" },
    { id = 13, name = "Infernal Coin", effect = "+30 points, Costs 5 SE, Steals 5 points from the Dealer" },
    { id = 14, name = "Phantom Silver", effect = "+5 points, Returns to your hand next round" },
    { id = 15, name = "Gambler’s Favor", effect = "+15 points, If you win the round, draw an extra card next round" },
    { id = 16, name = "Soul Shard", effect = "+10 points, Gain 1 SE for every 5 points scored this round" },
    { id = 17, name = "Blood Diamond", effect = "+40 points, Lose 10 SE and discard a random card" },
    { id = 18, name = "Crystal Orb", effect = "+15 points, Reveal the top card of your deck" },
    { id = 19, name = "Rusty Coin", effect = "+5 points, Draw 1 card, then discard 1 card" },
    { id = 20, name = "Golden Relic", effect = "+50 points, Costs 20 SE" }
}

-- Action Cards (25)
Cards.actionCards = {
    { id = 21, name = "Card Swap", effect = "Swap one of your cards with a random card from the Dealer's hand" },
    -- { id = 22, name = "Wheel Reroll", effect = "Reroll the Wheel of Fate effect for this round" },
    { id = 23, name = "Extra Draw", effect = "Draw two additional cards" },
    { id = 24, name = "Soul Infusion", effect = "Convert 10 points into 5 SE" },
    { id = 25, name = "Dealer's Insight", effect = "Reveal the Dealer’s next two cards" },
    { id = 26, name = "Nullify", effect = "Negate the Dealer’s last played card" },
    { id = 27, name = "Shadow Play", effect = "Play one of the Dealer’s cards as your own this round" },
    { id = 28, name = "Time Rewind", effect = "Undo the last played card (both player and Dealer)" },
    { id = 29, name = "Risky Trade", effect = "Give the Dealer 5 points, but gain 10 points yourself" },
    { id = 30, name = "Phantom Hand", effect = "Play an additional card this round" },
    { id = 31, name = "Twisted Pact", effect = "Sacrifice 5 SE to steal a random card from the Dealer" },
    { id = 32, name = "Point Transfer", effect = "Transfer up to 10 points from the Dealer to yourself" },
    { id = 33, name = "Soul Surge", effect = "Gain 10 SE but lose 10 points" },
    -- { id = 34, name = "Fate’s Favor", effect = "Reroll the Wheel of Fate and choose the result" },
    { id = 35, name = "Mirror Trick", effect = "Copy the Dealer’s last played card" },
    { id = 36, name = "Soul Bargain", effect = "Trade 5 SE to remove one of the Dealer’s active cards" },
    { id = 37, name = "Hand Refresh", effect = "Discard your hand and draw 5 new cards" },
    { id = 38, name = "Dealer’s Bluff", effect = "Force the Dealer to reveal their hand" },
    { id = 39, name = "Ethereal Swap", effect = "Swap your hand with the Dealer’s hand" },
    { id = 40, name = "Soul Anchor", effect = "Prevent the Dealer from playing cards for one turn" },
    { id = 41, name = "Fortune’s Grasp", effect = "Steal 10 points from the Dealer" },
    -- { id = 42, name = "Twisted Fate", effect = "Swap the Wheel of Fate effect with a random one" },
    { id = 43, name = "Soul Bind", effect = "Prevent the Dealer from using SE for one round" },
    { id = 44, name = "Phantom Swap", effect = "Swap one of your cards with a random card from the discard pile" },
    { id = 45, name = "Fate’s Edge", effect = "Gain 5 SE for every gamble card played this round" }
}

-- Gamble Cards (15)
Cards.gambleCards = {
    -- { id = 46, name = "Lucky Flip", effect = "Flip a coin: Heads, gain 20 points. Tails, lose 10 points" },
    { id = 47, name = "All or Nothing", effect = "Double your current points or lose half" },
    { id = 48, name = "Infernal Wager", effect = "Bet 10 SE for a 50% chance to gain 30 SE" },
    { id = 49, name = "Trickster's Choice", effect = "Choose a random card from the Dealer’s hand and play it as your own" },
    { id = 50, name = "Risky Draw", effect = "Draw 3 cards but discard 2 immediately" },
    { id = 51, name = "Cursed Roll", effect = "Roll a die: 1-3, lose 10 SE; 4-6, gain 15 SE" },
    { id = 52, name = "Soul’s Gamble", effect = "Bet 5 SE: Win, gain 10 SE; Lose, discard a card" },
    { id = 53, name = "Devil’s Deal", effect = "Gain 50 points, but lose 20 SE" },
    { id = 54, name = "Fate’s Gamble", effect = "Bet 10 SE: Win, double your points; Lose, lose half your points" },
    { id = 55, name = "Shadow Wager", effect = "Bet 5 SE: Win, steal 10 SE from the Dealer; Lose, give 10 SE to the Dealer" },
    -- { id = 56, name = "Cursed Bet", effect = "+30 points, but Wheel of Fate spins again" },
    { id = 57, name = "All In", effect = "Double your total points this round, Lose 10 SE if you lose the round" },
    { id = 58, name = "Phantom Gamble", effect = "Bet 5 SE: Win, gain 15 points; Lose, lose 10 points" },
    { id = 59, name = "Soul’s Risk", effect = "Bet 10 SE: Win, gain 20 SE; Lose, lose 15 SE" },
    { id = 60, name = "Final Gamble", effect = "Bet all your SE: Win, double it; Lose, lose it all" }
}

-- Dealer Cards (10)
Cards.dealerCards = {
    { id = 61, name = "Card Ban", effect = "Prevents the player from using one type of card this round" },
    { id = 62, name = "SE Drain", effect = "Steals 5 SE from the player" },
    { id = 63, name = "Unstable Points", effect = "The player's points for this round fluctuate randomly (-10 to +10)" },
    { id = 64, name = "Hand Disruption", effect = "Forces the player to discard a random card" },
    { id = 65, name = "Forced Wager", effect = "The player must gamble 10 SE" },
    { id = 66, name = "Extra Draw", effect = "The Dealer draws an extra card this round" },
    -- { id = 67, name = "Twist of Fate", effect = "The Wheel of Fate is spun twice and both effects apply" },
    { id = 68, name = "Phantom Stash", effect = "The Dealer can reuse one of their previously played cards" },
    { id = 69, name = "Soul Tax", effect = "The player loses 1 SE for every 10 points they score this round" },
    { id = 70, name = "Dealer’s Gambit", effect = "The Dealer gains 20 points but loses 10 SE" }
}

-- Wheel of Fate Effects (20)
Cards.wheelOfFate = {
    { id = 71, name = "Double or Nothing", effect = "All gains and losses are doubled" },
    { id = 72, name = "Shadow Bet", effect = "The Dealer places a secret wager revealed at round end" },
    { id = 73, name = "Twisted Hands", effect = "The player and Dealer must swap a random card from their hand" },
    { id = 74, name = "Lucky Draw", effect = "The player can draw two additional cards but must discard one immediately" },
    { id = 75, name = "Doom Timer", effect = "The round must be completed in a set number of moves or instant loss" },
    { id = 76, name = "Loaded Deck", effect = "The player may pick one card from their discard pile to reuse" },
    { id = 77, name = "Blindfolded Luck", effect = "The player must play all their cards blindly (without seeing their effects)" },
    { id = 78, name = "Blood Pact", effect = "The player gains 20 SE but loses 10 SE per round afterward" },
    { id = 79, name = "Dealer’s Favor", effect = "The Dealer starts with an additional card" },
    { id = 80, name = "Fate Swap", effect = "The highest value card in play switches between the player and Dealer" },
    { id = 81, name = "Burning Cards", effect = "Each turn, a random card from both hands is burned (removed from play)" },
    { id = 82, name = "Corrupt Fortune", effect = "Every coin-flip effect automatically fails" },
    { id = 83, name = "Ghost Hand", effect = "One random action card is unusable this round" },
    { id = 84, name = "Stacked Odds", effect = "The Dealer starts with +10 points" },
    { id = 85, name = "Soul Gamble", effect = "The player can bet half their Soul Essence for a 50% chance to double it" },
    { id = 86, name = "Delayed Fate", effect = "All Wheel effects are applied in the next round instead of immediately" },
    { id = 87, name = "Dealer’s Dice", effect = "The Dealer rolls a die; on a 6, they steal one of the player’s cards permanently" },
    { id = 88, name = "Unstable Reality", effect = "Every card played has a 25% chance to trigger twice" },
    { id = 89, name = "Cursed Winnings", effect = "If the player wins this round, they lose 5 SE" },
    { id = 90, name = "Final Gambit", effect = "If this is the last round, all effects are tripled" }
}

return Cards