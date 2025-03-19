### Running the Game

If you are on Windows, just download the release and run the exe.
Easiest way on other platforms would be to download [LÖVE](https://love2d.org/), cloning the repo and running it with:
   
      love .
---

# **The Dealer's Pact - Game Design Document**

## **Overview**
The Dealer's Pact is a **single-player deck-building roguelike** card game where the player engages in high-stakes gambling with an enigmatic Dealer. The game incorporates **deck customization, power-ups, modifiers, luck-based mechanics**, and a unique **Wheel of Fate** that alters the rules each round. The difficulty escalates as the player progresses, pushing them to make **strategic decisions** with the looming threat of losing their soul.

---

## **Core Gameplay Loop**
1. **Start a Round**
   - The **Wheel of Fate** spins and applies a random rule modifier.
   - The player and Dealer **draw hands** from their respective decks.
   
2. **Action Phase**
   - The player plays **resource cards**, **action cards**, or **gamble cards**.
   - The Dealer plays **counter cards** or modifies outcomes.
   
3. **Resolution & Scoring**
   - The round ends with a resolution of card effects and scoring.
   - The player earns **Soul Essence (SE)** and/or power-ups.
   
4. **Deckbuilding & Upgrades**
   - The player can **buy new cards**, remove weak ones, or modify existing ones.
   - The next round begins with increased difficulty.

---

## **Player Resources**
- **Soul Essence (SE):** Used as a currency to purchase cards, power-ups, or trade with the Dealer.
- **Cards:** Players manage a deck consisting of three types:
  - **Resource Cards:** Generate points needed to outscore the Dealer.
  - **Action Cards:** Affect gameplay, such as rerolling a Wheel spin or altering Dealer cards.
  - **Gamble Cards:** Risk-based cards that can yield high rewards or severe penalties.

---

## **The Wheel of Fate (Random Rule Modifiers)**
Each round, the Wheel of Fate spins and applies a **random rule modifier**, such as:
- **Double or Nothing:** All gains and losses are doubled.
- **Shadow Bet:** The Dealer places a secret wager that is revealed at round end.
- **Twisted Hands:** The player and Dealer must swap a random card from their hand.
- **Lucky Draw:** The player can draw two additional cards but must discard one immediately.
- **Doom Timer:** The round must be completed in a set number of moves or instant loss.

---

## **Card Types & Full Card List**

### **Resource Cards**
- **Gold Coin (+10 points)** – Basic resource.
- **Silver Coin (+5 points, Draw 1)** – Lower points, but provides card advantage.
- **Mystic Gem (+20 points, Lose 3 SE)** – High reward but comes at a cost.
- **Fortune Token (+15 points, Double if Dealer has more points than you)** – Encourages risk-taking.

### **Action Cards**
- **Fate Reroll** – Allows the player to reroll the Wheel of Fate.
- **Soul Shield** – Negates one negative effect from the Dealer.
- **Dealer’s Trick** – Look at the Dealer’s next card before it is played.
- **Stacked Deck** – Draw two additional cards this round.
- **Shadow Bargain** – Trade 5 SE to remove one of the Dealer’s active cards.

### **Gamble Cards**
- **High Risk, High Reward (+50 points or -30 points, coin flip)**
- **Devil’s Draw (Draw 3 cards, Lose 5 SE)**
- **Dealer’s Debt (Steal 10 SE from the Dealer, 50% chance to lose 20 SE instead)**
- **Cursed Bet (+30 points, but Wheel of Fate spins again)**
- **All In (Double your total points this round, Lose 10 SE if you lose the round)**

### **Dealer’s Cards**
- **Reverse Fortune** – Swap player’s highest and lowest score cards.
- **House Edge** – Player loses 5 SE regardless of outcome.
- **False Blessing** – Grants bonus points, but applies a hidden debuff next round.
- **Dealer’s Bluff** – Forces the player to discard their highest-value card.
- **Shadow Contract** – Player can gain +20 SE but permanently loses a random action card.

---

## **How Each Round is Played**

### **1. Wheel of Fate Spin**
- At the beginning of each round, the **Wheel of Fate** spins and applies a new rule that affects the round.

### **2. Draw Phase**
- Both the player and the Dealer **draw 5 cards** from their respective decks.

### **3. Action Phase**
- The player plays **resource, action, or gamble cards** to optimize their score.
- The Dealer plays **counter cards** or applies special effects.
- The player can choose to **spend SE to use power-ups** or **alter game mechanics**.

### **4. Resolution Phase**
- Total points are calculated.
- The player either **wins the round (gaining SE and rewards)** or **loses SE based on the Dealer’s tricks**.
- If the player has **0 SE, they lose the game**.

### **5. Deckbuilding & Progression**
- The player can **buy, remove, or modify cards** before the next round.
- The difficulty **increases each round**, with the Dealer gaining better cards.

---

## **Game Progression & Difficulty Scaling**
- The game starts with **5 rounds** and increases in difficulty as rounds progress.
- Each round, the Dealer gains stronger cards and better counterplays.
- The player must strategically **build their deck** while managing their **Soul Essence**.
- Losing all Soul Essence means the **Dealer claims the player's soul** and ends the game.

---

## **Winning & Losing Conditions**
- **Win:** Successfully complete all rounds while retaining Soul Essence.
- **Lose:** Run out of Soul Essence or fail to beat the Dealer’s score in a round where required.

---

## **Technical Considerations**
- **Engine:** LÖVE (Lua)
- **Platform:** Desktop only
- **Input:** Mouse-driven UI with potential keyboard shortcuts

---

## **Next Steps**
- Finalize **all card designs** and **Wheel of Fate effects**.
- Develop **AI behavior** for the Dealer.
- Implement **UI/UX for deck management and gameplay flow**.

---

## **Assets**
- Card images generated with perchance.org and modified by Myra.
   - Resource: "soul essence, coin, resource icon, magic the gathering inspired, icon only, detailed icon, circle, black textured rim, textured, gothic, (seed:::977005197)"
   - Action: "flame, lightning, swords, action icon, magic the gathering inspired, icon only, detailed icon, circle, black textured rim, textured, gothic, (seed:::977005197)"
   - Gamble: "d20, (red die), magic the gathering inspired, icon only, detailed icon, circle, black textured rim, textured, gothic, (seed:::977005197)"
   - Dealer: "A menacing portrait of a dragon, shrouded in a cloak of midnight black, the fabric adorned with intricate gothic patterns that seem to dance in the flickering candlelight. The creature's scales, a mesmerizing blend of onyx and obsidian, reflect the eerie glow, casting long, ominous shadows across the ornate, velvet-draped table. Its fiery eyes pierce through the darkness, locking onto the unseen player with a gaze that is both alluring and terrifying. In one clawed hand, the dragon deftly shuffles a deck of ancient cards, each emblazoned with mysterious symbols that whisper of arcane power and fate. The other hand is poised to deal, claw tips glistening with a hint of danger. The room itself is a testament to the macabre elegance of its inhabitant, with high arched ceilings, stained glass windows depicting mythical battles, and walls lined with dusty tomes of forgotten lore. The atmosphere is thick with anticipation, the air crackling with unspoken challenges and the scent of treasure long sought but never claimed. This chilling tableau beckons viewers to step into a realm of high stakes and higher risks, where the cards may reveal not just a game's outcome, but the very fabric of destiny itself. (close up portrait)"
   - Card Back: "(back of card), black border, symmetrical, A deep midnight obsidian purple background with intricate gold filigree forming a circular arcane sigil at the center. Faint red embers pulse along the edges, and a spectral handprint lingers beneath the surface, as if a past player’s fate was sealed into the very fabric of the card."
- Audio mostly generated by aimusicgen.ai
   - mainMenu.mp3: "Dark ambient drones weave with melancholic violin and deep, resonant bass, evoking the weight of a pact sealed in shadows."
   - bgm.mp3: "Eerie piano, swirling strings, deep brass, and whispered ambience with ticking clocks and the clink of gold, building tension through gothic jazz and orchestral swells that crescendo as fate unfolds."
   - sad: "A sorrowful yet mysterious tune of soft choral hums, deep cello, and the occasional flicker of an ethereal, wind-like melody."
   - card.ogg: Created by Myra
- Fonts:
   - NotoSans: From fonts.google.com
   - EnchantedLand, ZCOOL, OldLondon: From dafont.com
- Shaders generated by deepseek