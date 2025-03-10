-- scripts/cards.lua
-- Check cards.md for a more readable list

local Cards = {}

-- Resource Cards (20)
Cards.resourceCards = {
    { name = "Gold Coin", effect = "+10 points" },
    { name = "Silver Coin", effect = "+5 points, Draw 1" },
    { name = "Mystic Gem", effect = "+20 points, Lose 3 SE" },
    { name = "Fortune Token", effect = "+15 points, Double if Dealer has more points" },
    { name = "Ancient Relic", effect = "+25 points, Costs 10 SE" },
    -- { name = "Cursed Coin", effect = "+30 points, Flip a coin: Lose 10 SE on heads" },
    { name = "Lucky Charm", effect = "+10 points, Reuse one action card next round" },
    { name = "Ethereal Gold", effect = "+20 points, but is destroyed after use" },
    { name = "Soul Residue", effect = "+10 points, Convert 3 points into SE" },
    { name = "Stacked Fortune", effect = "+15 points, Cannot be used if you played a gamble card this round" },
    { name = "Twisted Wealth", effect = "+25 points, Opponent gains 5 points too" },
    { name = "Fool’s Gold", effect = "+10 points, Reveal Dealer’s next card when played" },
    { name = "Infernal Coin", effect = "+30 points, Costs 5 SE, Steals 5 points from the Dealer" },
    { name = "Phantom Silver", effect = "+5 points, Returns to your hand next round" },
    { name = "Gambler’s Favor", effect = "+15 points, If you win the round, draw an extra card next round" },
    { name = "Soul Shard", effect = "+10 points, Gain 1 SE for every 5 points scored this round" },
    { name = "Blood Diamond", effect = "+40 points, Lose 10 SE and discard a random card" },
    { name = "Crystal Orb", effect = "+15 points, Reveal the top card of your deck" },
    { name = "Rusty Coin", effect = "+5 points, Draw 1 card, then discard 1 card" },
    { name = "Golden Relic", effect = "+50 points, Costs 20 SE" }
}

-- Action Cards (25)
Cards.actionCards = {
    { name = "Card Swap", effect = "Swap one of your cards with a random card from the Dealer's hand" },
    -- { name = "Wheel Reroll", effect = "Reroll the Wheel of Fate effect for this round" },
    { name = "Extra Draw", effect = "Draw two additional cards" },
    { name = "Soul Infusion", effect = "Convert 10 points into 5 SE" },
    { name = "Dealer's Insight", effect = "Reveal the Dealer’s next two cards" },
    { name = "Nullify", effect = "Negate the Dealer’s last played card" },
    { name = "Shadow Play", effect = "Play one of the Dealer’s cards as your own this round" },
    { name = "Time Rewind", effect = "Undo the last played card (both player and Dealer)" },
    { name = "Risky Trade", effect = "Give the Dealer 5 points, but gain 10 points yourself" },
    { name = "Phantom Hand", effect = "Play an additional card this round" },
    { name = "Twisted Pact", effect = "Sacrifice 5 SE to steal a random card from the Dealer" },
    { name = "Point Transfer", effect = "Transfer up to 10 points from the Dealer to yourself" },
    { name = "Soul Surge", effect = "Gain 10 SE but lose 10 points" },
    -- { name = "Fate’s Favor", effect = "Reroll the Wheel of Fate and choose the result" },
    { name = "Mirror Trick", effect = "Copy the Dealer’s last played card" },
    { name = "Soul Bargain", effect = "Trade 5 SE to remove one of the Dealer’s active cards" },
    { name = "Hand Refresh", effect = "Discard your hand and draw 5 new cards" },
    { name = "Dealer’s Bluff", effect = "Force the Dealer to reveal their hand" },
    { name = "Ethereal Swap", effect = "Swap your hand with the Dealer’s hand" },
    { name = "Soul Anchor", effect = "Prevent the Dealer from playing cards for one turn" },
    { name = "Fortune’s Grasp", effect = "Steal 10 points from the Dealer" },
    -- { name = "Twisted Fate", effect = "Swap the Wheel of Fate effect with a random one" },
    { name = "Soul Bind", effect = "Prevent the Dealer from using SE for one round" },
    { name = "Phantom Swap", effect = "Swap one of your cards with a random card from the discard pile" },
    { name = "Fate’s Edge", effect = "Gain 5 SE for every gamble card played this round" }
}

-- Gamble Cards (15)
Cards.gambleCards = {
    -- { name = "Lucky Flip", effect = "Flip a coin: Heads, gain 20 points. Tails, lose 10 points" },
    { name = "All or Nothing", effect = "Double your current points or lose half" },
    { name = "Infernal Wager", effect = "Bet 10 SE for a 50% chance to gain 30 SE" },
    { name = "Trickster's Choice", effect = "Choose a random card from the Dealer’s hand and play it as your own" },
    { name = "Risky Draw", effect = "Draw 3 cards but discard 2 immediately" },
    { name = "Cursed Roll", effect = "Roll a die: 1-3, lose 10 SE; 4-6, gain 15 SE" },
    { name = "Soul’s Gamble", effect = "Bet 5 SE: Win, gain 10 SE; Lose, discard a card" },
    { name = "Devil’s Deal", effect = "Gain 50 points, but lose 20 SE" },
    { name = "Fate’s Gamble", effect = "Bet 10 SE: Win, double your points; Lose, lose half your points" },
    { name = "Shadow Wager", effect = "Bet 5 SE: Win, steal 10 SE from the Dealer; Lose, give 10 SE to the Dealer" },
    -- { name = "Cursed Bet", effect = "+30 points, but Wheel of Fate spins again" },
    { name = "All In", effect = "Double your total points this round, Lose 10 SE if you lose the round" },
    { name = "Phantom Gamble", effect = "Bet 5 SE: Win, gain 15 points; Lose, lose 10 points" },
    { name = "Soul’s Risk", effect = "Bet 10 SE: Win, gain 20 SE; Lose, lose 15 SE" },
    { name = "Final Gamble", effect = "Bet all your SE: Win, double it; Lose, lose it all" }
}

-- Dealer Cards (10)
Cards.dealerCards = {
    { name = "Card Ban", effect = "Prevents the player from using one type of card this round" },
    { name = "SE Drain", effect = "Steals 5 SE from the player" },
    { name = "Unstable Points", effect = "The player's points for this round fluctuate randomly (-10 to +10)" },
    { name = "Hand Disruption", effect = "Forces the player to discard a random card" },
    { name = "Forced Wager", effect = "The player must gamble 10 SE" },
    { name = "Extra Draw", effect = "The Dealer draws an extra card this round" },
    -- { name = "Twist of Fate", effect = "The Wheel of Fate is spun twice and both effects apply" },
    { name = "Phantom Stash", effect = "The Dealer can reuse one of their previously played cards" },
    { name = "Soul Tax", effect = "The player loses 1 SE for every 10 points they score this round" },
    { name = "Dealer’s Gambit", effect = "The Dealer gains 20 points but loses 10 SE" }
}

-- Wheel of Fate Effects (20)
Cards.wheelOfFate = {
    { name = "Double or Nothing", effect = "All gains and losses are doubled" },
    { name = "Shadow Bet", effect = "The Dealer places a secret wager revealed at round end" },
    { name = "Twisted Hands", effect = "The player and Dealer must swap a random card from their hand" },
    { name = "Lucky Draw", effect = "The player can draw two additional cards but must discard one immediately" },
    { name = "Doom Timer", effect = "The round must be completed in a set number of moves or instant loss" },
    { name = "Loaded Deck", effect = "The player may pick one card from their discard pile to reuse" },
    { name = "Blindfolded Luck", effect = "The player must play all their cards blindly (without seeing their effects)" },
    { name = "Blood Pact", effect = "The player gains 20 SE but loses 10 SE per round afterward" },
    { name = "Dealer’s Favor", effect = "The Dealer starts with an additional card" },
    { name = "Fate Swap", effect = "The highest value card in play switches between the player and Dealer" },
    { name = "Burning Cards", effect = "Each turn, a random card from both hands is burned (removed from play)" },
    { name = "Corrupt Fortune", effect = "Every coin-flip effect automatically fails" },
    { name = "Ghost Hand", effect = "One random action card is unusable this round" },
    { name = "Stacked Odds", effect = "The Dealer starts with +10 points" },
    { name = "Soul Gamble", effect = "The player can bet half their Soul Essence for a 50% chance to double it" },
    { name = "Delayed Fate", effect = "All Wheel effects are applied in the next round instead of immediately" },
    { name = "Dealer’s Dice", effect = "The Dealer rolls a die; on a 6, they steal one of the player’s cards permanently" },
    { name = "Unstable Reality", effect = "Every card played has a 25% chance to trigger twice" },
    { name = "Cursed Winnings", effect = "If the player wins this round, they lose 5 SE" },
    { name = "Final Gambit", effect = "If this is the last round, all effects are tripled" }
}

return Cards