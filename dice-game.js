// dice.js — Paste this as a raw message for your bot's installer
// Author: Monarch Edition
// Notes:
// - Command trigger: `-dice ...` (depends on your bot's prefix).
// - Wallet = user.money; Bank = user.data.dice.bankBalance
// - Tracks EXP, wins/losses, streaks, daily reward, loans, transfers, leaderboard, ranks
// - Challenge PvP: `-dice challenge <uid> <amount>` then opponent replies
//   exactly `-dice challenge accepted start` in the same chat.

const DICE_STATE = (global.__DICE_STATE__ ||= {
  pendingChallenges: Object.create(null), // key: threadID -> { challenger, target, amount, createdAt }
});

module.exports = {
  config: {
    name: "dice",
    version: "3.2.0",
    author: "ROZ (Monarch Build)",
    shortDescription: { en: "High-stakes dice with bank, loans, daily, PvP challenges, leaderboard & ranks" },
    longDescription: {
      en: "Roll to win: 6 = 5x, 4–5 = 2x, else lose. Includes bank (deposit/withdraw/loan/payloan/transfer), daily rewards, stats, ranks, leaderboard, all-in, ultrabet (3.4% for 10x), roll x2/x3, and PvP challenge with acceptance.",
    },
    category: "Games",
  },

  langs: {
    en: {
      help: [
        "🎲 DICE GAME COMMANDS 🎲",
        "",
        "-dice <amount> → Roll and bet money",
        "-dice balance → View your wallet & bank balances",
        "-dice leaderboard → Top players by total wealth",
        "-dice rank → Your rank based on EXP",
        "-dice daily → Claim $500 and 100 EXP every 24 hours",
        "-dice stats → Your wins, losses, win/lose streaks, matches played",
        "-dice allin → Bet your entire wallet balance",
        "-dice roll x2 → Roll 2 dice in a single turn (best roll counts)",
        "-dice roll x3 → Roll 3 dice in a single turn (best roll counts)",
        "-dice ultrabet → Bet your entire wallet; 3.4% win for 10x",
        "",
        "🏦 BANK COMMANDS 🏦",
        "-dice bank balance → Check bank balance (supports big numbers)",
        "-dice bank deposit <amount> → Deposit to bank",
        "-dice bank withdraw <amount> → Withdraw from bank",
        "-dice bank loan → Take a loan (limit $200,000,000; only if no outstanding loan)",
        "-dice bank payloan <amount> → Repay your loan",
        "-dice bank transfer <amount> <uid> → Transfer to another player",
        "",
        "🤝 PvP",
        "-dice challenge <uid> <amount> → Challenge a player",
        "(They must reply: -dice challenge accepted start)",
      ].join("\n"),
      invalid_amount: "❌ Enter a valid positive amount.",
      not_enough: "💸 Not enough funds in your wallet.",
      won_jackpot: (roll, gain) => `🎯 You rolled **${roll}** — JACKPOT! You won $${toMoney(gain)} (x5).`,
      won_double: (roll, gain) => `✅ You rolled **${roll}** — You won $${toMoney(gain)} (x2).`,
      lost_bet: (roll, bet) => `💀 You rolled **${roll}** — You lost $${toMoney(bet)}.`,
      result_line: (newBal) => `🏦 Wallet: $${toMoney(newBal)}`,
      played: (bet) => `🎲 Bet placed: $${toMoney(bet)} — rolling...`,
      daily_ready: "🎁 Claimed daily: +$500 and +100 EXP.",
      daily_cooldown: (hrs, mins) => `⏳ Daily not ready. Try again in ${hrs}h ${mins}m.`,
      balance: (wallet, bank, debt, exp) =>
        `💼 Wallet: $${toMoney(wallet)}\n🏦 Bank: $${toMoney(bank)}\n💳 Loan Debt: $${toMoney(debt)}\n⭐ EXP: ${exp}`,
      bank_only_number: "❌ Provide a valid positive amount for bank action.",
      bank_deposit_ok: (amt, bank) => `✅ Deposited $${toMoney(amt)}. Bank: $${toMoney(bank)}.`,
      bank_withdraw_ok: (amt, wallet) => `✅ Withdrew $${toMoney(amt)}. Wallet: $${toMoney(wallet)}.`,
      bank_insufficient: "❌ Insufficient funds.",
      loan_has_debt: "🚫 You already have an active loan. Repay it first.",
      loan_limit: "🚫 Loan limit is $200,000,000.",
      loan_ok: (amt, wallet, debt) =>
        `✅ Loan granted: $${toMoney(amt)}. Wallet: $${toMoney(wallet)}. Current loan debt: $${toMoney(debt)}.`,
      payloan_ok: (amt, debtLeft) => `✅ Loan payment of $${toMoney(amt)} accepted. Remaining debt: $${toMoney(debtLeft)}.`,
      transfer_ok: (amt, toName) => `✅ Transferred $${toMoney(amt)} to ${toName}.`,
      transfer_invalid_uid: "❌ Provide a valid numeric UID.",
      rank_line: (rank, exp, matches) => `🏅 Rank: ${rank}\n⭐ EXP: ${exp}\n🧮 Matches: ${matches}`,
      stats_line: (w, l, mw, ml, streakW, streakL, matches, jackpots) =>
        `📊 Stats\nWins: ${w} (Max Win Streak: ${mw})\nLosses: ${l} (Max Lose Streak: ${ml})\nCurrent Streak: ${streakW > 0 ? `W${streakW}` : streakL > 0 ? `L${streakL}` : "—"}\nMatches Played: ${matches}\nJackpots Hit: ${jackpots}`,
      lb_header: "🏆 Leaderboard (Top 10 by Total Wealth = Wallet + Bank)",
      lb_line: (i, name, total) => `${i}. ${name}: $${toMoney(total)}`,
      allin_empty: "❌ You have nothing to all-in.",
      ultrabet_start: "💥 ULTRABET: Betting your entire wallet...\nWin chance: 3.4% | Payout: 10x",
      ultrabet_win: (gain, bal) => `💸 ULTRABET WIN! You gain $${toMoney(gain)}.\n🏦 Wallet: $${toMoney(bal)}`,
      ultrabet_lose: (lost) => `💀 ULTRABET LOST. You lost $${toMoney(lost)}.`,
      roll_multi_header: (n, bet) => `🎲 Rolling ${n} dice${n > 1 ? " (best roll counts)" : ""} for $${toMoney(bet)}...`,
      challenge_created: (from, to, amt) =>
        `🤝 Challenge created!\nChallenger: <@${from}>\nOpponent: <@${to}>\nBet: $${toMoney(amt)}\nOpponent must reply: -dice challenge accepted start`,
      challenge_exists: "⚠ A pending challenge already exists in this chat. Finish or cancel it first.",
      challenge_no_pending: "❌ No pending challenge to accept here.",
      challenge_started: "🎮 Challenge accepted — rolling for both players...",
      challenge_not_party: "❌ Only the challenged player can accept this challenge.",
      challenge_not_enough: "❌ One of you doesn’t have enough wallet balance for the bet.",
      challenge_result: (p1Name, p1Roll, p2Name, p2Roll, winnerName, amt) =>
        `🎲 Challenge Result\n${p1Name}: ${p1Roll}\n${p2Name}: ${p2Roll}\n🏆 Winner: ${winnerName} (+$${toMoney(amt)})`,
    },
  },

  onStart: async function ({ args, message, event, usersData, getLang }) {
    const { senderID, threadID } = event;
    const say = (txt, mentions) => message.reply(mentions ? { body: txt, mentions } : txt);
    const getName = async (uid) => {
      try {
        const name = await usersData.getName(uid);
        return name || `User ${uid}`;
      } catch {
        return `User ${uid}`;
      }
    };

    // Ensure user profile exists with dice fields
    const ensureProfile = async (uid) => {
      const u = await usersData.get(uid);
      const data = u.data || {};
      data.dice ||= {};
      const d = data.dice;
      d.bankBalance ||= 0;
      d.loanDebt ||= 0;
      d.exp ||= 0;
      d.matches ||= 0;
      d.wins ||= 0;
      d.losses ||= 0;
      d.maxWinStreak ||= 0;
      d.maxLoseStreak ||= 0;
      d.curWinStreak ||= 0;
      d.curLoseStreak ||= 0;
      d.jackpots ||= 0;
      d.lastDailyAt ||= 0;
      await usersData.set(uid, { money: u.money || 0, data });
      return await usersData.get(uid); // refreshed
    };

    const user = await ensureProfile(senderID);

    // If no args, show help
    if (!args.length) return say(this.langs.en.help);

    // Subcommand parsing
    const sub = (args[0] || "").toLowerCase();

    // ==== HELP ====
    if (sub === "help") return say(this.langs.en.help);

    // ==== BALANCE ====
    if (sub === "balance") {
      const u = await ensureProfile(senderID);
      return say(getLang("balance")(u.money, u.data.dice.bankBalance, u.data.dice.loanDebt, u.data.dice.exp));
    }

    // ==== BANK ====
    if (sub === "bank") {
      const bankSub = (args[1] || "").toLowerCase();
      if (bankSub === "balance") {
        const u = await ensureProfile(senderID);
        return say(`🏦 Bank Balance: $${toMoney(u.data.dice.bankBalance)}\n💳 Loan Debt: $${toMoney(u.data.dice.loanDebt)}`);
      }
      if (bankSub === "deposit") {
        const amt = parseAmount(args[2]);
        if (!isPosNumber(amt)) return say(getLang("bank_only_number"));
        if (user.money < amt) return say(getLang("bank_insufficient"));
        user.money -= amt;
        user.data.dice.bankBalance += amt;
        await usersData.set(senderID, { money: user.money, data: user.data });
        return say(getLang("bank_deposit_ok")(amt, user.data.dice.bankBalance));
      }
      if (bankSub === "withdraw") {
        const amt = parseAmount(args[2]);
        if (!isPosNumber(amt)) return say(getLang("bank_only_number"));
        if (user.data.dice.bankBalance < amt) return say(getLang("bank_insufficient"));
        user.data.dice.bankBalance -= amt;
        user.money += amt;
        await usersData.set(senderID, { money: user.money, data: user.data });
        return say(getLang("bank_withdraw_ok")(amt, user.money));
      }
      if (bankSub === "loan") {
        if (user.data.dice.loanDebt > 0) return say(getLang("loan_has_debt"));
        const LIMIT = 200_000_000;
        // Grant full limit or up to LIMIT if you want partial; we grant LIMIT for simplicity.
        user.money += LIMIT;
        user.data.dice.loanDebt = LIMIT;
        await usersData.set(senderID, { money: user.money, data: user.data });
        return say(getLang("loan_ok")(LIMIT, user.money, user.data.dice.loanDebt));
      }
      if (bankSub === "payloan") {
        const amt = parseAmount(args[2]);
        if (!isPosNumber(amt)) return say(getLang("bank_only_number"));
        if (user.money < amt) return say(getLang("bank_insufficient"));
        if (user.data.dice.loanDebt <= 0) return say("✅ You have no outstanding loan.");
        const pay = Math.min(amt, user.data.dice.loanDebt);
        user.money -= pay;
        user.data.dice.loanDebt -= pay;
        await usersData.set(senderID, { money: user.money, data: user.data });
        return say(getLang("payloan_ok")(pay, user.data.dice.loanDebt));
      }
      if (bankSub === "transfer") {
        const amt = parseAmount(args[2]);
        const uidStr = args[3];
        if (!isPosNumber(amt)) return say(getLang("bank_only_number"));
        if (!uidStr || !/^\d+$/.test(uidStr)) return say(getLang("transfer_invalid_uid"));
        const targetID = uidStr;
        if (user.money < amt) return say(getLang("bank_insufficient"));
        const target = await ensureProfile(targetID);
        user.money -= amt;
        target.money += amt;
        await usersData.set(senderID, { money: user.money, data: user.data });
        await usersData.set(targetID, { money: target.money, data: target.data });
        return say(getLang("transfer_ok")(amt, await getName(targetID)));
      }
      // Unknown bank subcommand
      return say(this.langs.en.help);
    }

    // ==== DAILY ====
    if (sub === "daily") {
      const now = Date.now();
      const cd = 24 * 60 * 60 * 1000;
      const last = user.data.dice.lastDailyAt || 0;
      if (now - last < cd) {
        const remain = cd - (now - last);
        const hrs = Math.floor(remain / 3600000);
        const mins = Math.floor((remain % 3600000) / 60000);
        return say(getLang("daily_cooldown")(hrs, mins));
      }
      user.money += 500;
      user.data.dice.exp += 100;
      user.data.dice.lastDailyAt = now;
      await usersData.set(senderID, { money: user.money, data: user.data });
      return say(getLang("daily_ready"));
    }

    // ==== RANK ====
    if (sub === "rank") {
      const rank = rankFromExp(user.data.dice.exp);
      return say(getLang("rank_line")(rank, user.data.dice.exp, user.data.dice.matches));
    }

    // ==== LEADERBOARD ====
    if (sub === "leaderboard") {
      // Collect all users (if your framework provides usersData.getAll, use it; otherwise, show note)
      if (!usersData.getAll) {
        return say("📌 Leaderboard requires usersData.getAll(). Your framework doesn't expose it here.");
      }
      const all = await usersData.getAll();
      const rows = all
        .map((u) => {
          const bank = u.data?.dice?.bankBalance || 0;
          const total = (u.money || 0) + bank;
          return { id: u.userID || u.id, name: u.name || `User ${u.userID || u.id}`, total };
        })
        .sort((a, b) => b.total - a.total)
        .slice(0, 10);

      const lines = [getLang("lb_header")];
      rows.forEach((r, i) => lines.push(getLang("lb_line")(i + 1, r.name, r.total)));
      return say(lines.join("\n"));
    }

    // ==== STATS ====
    if (sub === "stats") {
      const d = user.data.dice;
      return say(getLang("stats_line")(d.wins, d.losses, d.maxWinStreak, d.maxLoseStreak, d.curWinStreak, d.curLoseStreak, d.matches, d.jackpots));
    }

    // ==== ALL-IN ====
    if (sub === "allin" || (sub === "all" && args[1] === "in")) {
      const bet = user.money;
      if (bet <= 0) return say(getLang("allin_empty"));
      return await resolveRollAndPayout({ bet, senderID, usersData, say, getLang, user });
    }

    // ==== ROLL x2 / x3 ====
    if (sub === "roll") {
      const mode = (args[1] || "").toLowerCase();
      if (mode !== "x2" && mode !== "x3") return say(this.langs.en.help);
      // By design here, multi-roll does NOT bet by default. If you want it to bet, use: -dice roll x2 <amount>
      const bet = parseAmount(args[2]);
      if (!isPosNumber(bet)) return say("❌ Usage: -dice roll x2 <amount>  or  -dice roll x3 <amount>");
      const n = mode === "x2" ? 2 : 3;
      if (user.money < bet) return say(getLang("not_enough"));
      await say(getLang("roll_multi_header")(n, bet));
      // Roll n dice and take the best
      let best = 1;
      for (let i = 0; i < n; i++) best = Math.max(best, roll1d6());
      return await resolveRollAndPayout({ bet, senderID, usersData, say, getLang, user, forcedRoll: best });
    }

    // ==== ULTRABET ====
    if (sub === "ultrabet") {
      const bet = user.money;
      if (bet <= 0) return say(getLang("allin_empty"));
      await say(getLang("ultrabet_start"));
      // 3.4% chance to win 10x, else lose bet
      const r = Math.random(); // 0..1
      if (r < 0.034) {
        const gain = bet * 9; // plus original bet makes 10x total
        user.money += gain; // we don't subtract first since we're doing all-in on existing balance
        user.data.dice.wins++;
        user.data.dice.curWinStreak++;
        user.data.dice.curLoseStreak = 0;
        user.data.dice.maxWinStreak = Math.max(user.data.dice.maxWinStreak, user.data.dice.curWinStreak);
        user.data.dice.matches++;
        user.data.dice.exp += 30;
        await usersData.set(senderID, { money: user.money, data: user.data });
        return say(getLang("ultrabet_win")(gain, user.money));
      } else {
        // lose all
        const lost = bet;
        user.money = 0;
        user.data.dice.losses++;
        user.data.dice.curLoseStreak++;
        user.data.dice.curWinStreak = 0;
        user.data.dice.maxLoseStreak = Math.max(user.data.dice.maxLoseStreak, user.data.dice.curLoseStreak);
        user.data.dice.matches++;
        user.data.dice.exp += 5;
        await usersData.set(senderID, { money: user.money, data: user.data });
        return say(getLang("ultrabet_lose")(lost));
      }
    }

    // ==== CHALLENGE ====
    if (sub === "challenge") {
      // Create or accept
      if (args[1] === "accepted" && (args[2] || "").toLowerCase() === "start") {
        const pending = DICE_STATE.pendingChallenges[threadID];
        if (!pending) return say(getLang("challenge_no_pending"));
        if (pending.target !== senderID) return say(getLang("challenge_not_party"));
        // Verify both balances
        const challenger = await ensureProfile(pending.challenger);
        const opponent = await ensureProfile(pending.target);
        if (challenger.money < pending.amount || opponent.money < pending.amount) {
          delete DICE_STATE.pendingChallenges[threadID];
          return say(getLang("challenge_not_enough"));
        }
        // Roll
        await say(getLang("challenge_started"));
        const cRoll = roll1d6();
        const oRoll = roll1d6();
        const cName = await getName(pending.challenger);
        const oName = await getName(pending.target);
        if (cRoll === oRoll) {
          // tie: no money moves
          delete DICE_STATE.pendingChallenges[threadID];
          return say(`🤝 It's a tie!\n${cName}: ${cRoll}\n${oName}: ${oRoll}\nNo changes in balance.`);
        }
        const winnerID = cRoll > oRoll ? pending.challenger : pending.target;
        const loserID = cRoll > oRoll ? pending.target : pending.challenger;
        const winner = cRoll > oRoll ? challenger : opponent;
        const loser = cRoll > oRoll ? opponent : challenger;

        // Move funds
        loser.money -= pending.amount;
        winner.money += pending.amount;

        // Stats
        winner.data.dice.wins++;
        winner.data.dice.curWinStreak++;
        winner.data.dice.curLoseStreak = 0;
        winner.data.dice.maxWinStreak = Math.max(winner.data.dice.maxWinStreak, winner.data.dice.curWinStreak);
        winner.data.dice.matches++;
        winner.data.dice.exp += 25;

        loser.data.dice.losses++;
        loser.data.dice.curLoseStreak++;
        loser.data.dice.curWinStreak = 0;
        loser.data.dice.maxLoseStreak = Math.max(loser.data.dice.maxLoseStreak, loser.data.dice.curLoseStreak);
        loser.data.dice.matches++;
        loser.data.dice.exp += 10;

        await usersData.set(winnerID, { money: winner.money, data: winner.data });
        await usersData.set(loserID, { money: loser.money, data: loser.data });

        delete DICE_STATE.pendingChallenges[threadID];
        const winnerName = await getName(winnerID);
        return say(getLang("challenge_result")(cName, cRoll, oName, oRoll, winnerName, pending.amount));
      }

      // Create challenge: -dice challenge <uid> <amount>
      if (DICE_STATE.pendingChallenges[threadID]) return say(getLang("challenge_exists"));
      const uidStr = args[1];
      const amt = parseAmount(args[2]);
      if (!uidStr || !/^\d+$/.test(uidStr) || !isPosNumber(amt)) return say("❌ Usage: -dice challenge <uid> <amount>");
      const targetID = uidStr;
      if (user.money < amt) return say(getLang("not_enough"));
      DICE_STATE.pendingChallenges[threadID] = {
        challenger: senderID,
        target: targetID,
        amount: amt,
        createdAt: Date.now(),
      };
      return say(getLang("challenge_created")(senderID, targetID, amt), [
        { id: senderID, tag: await getName(senderID) },
        { id: targetID, tag: await getName(targetID) },
      ]);
    }

    // ==== MAIN PLAY: -dice <amount> ====
    if (isPosNumber(parseAmount(sub))) {
      const bet = parseAmount(sub);
      if (!isPosNumber(bet)) return say(getLang("invalid_amount"));
      if (user.money < bet) return say(getLang("not_enough"));
      await say(getLang("played")(bet));
      return await resolveRollAndPayout({ bet, senderID, usersData, say, getLang, user });
    }

    // Unknown -> show help
    return say(this.langs.en.help);
  },
};

// ===== Helpers =====
function isPosNumber(n) {
  return Number.isFinite(n) && n > 0;
}

function parseAmount(raw) {
  if (!raw) return NaN;
  const s = String(raw).trim().toUpperCase();
  // Support shorthand: 1K, 1M, 1B, 1T, etc.
  const multipliers = {
    K: 1e3,
    M: 1e6,
    B: 1e9,
    T: 1e12,
    Q: 1e15, // quadrillion
    QA: 1e15,
    QT: 1e18, // quintillion
    S: 1e21,  // sextillion
    SP: 1e24, // septillion
    O: 1e27,  // octillion
    N: 1e30,  // nonillion
  };
  const m = s.match(/^(\d+(?:\.\d+)?)([A-Z]+)?$/);
  if (!m) return Number(s.replace(/[, ]/g, ""));
  const num = parseFloat(m[1]);
  const suf = m[2];
  if (!suf) return num;
  const k = multipliers[suf];
  if (!k) return num;
  return Math.floor(num * k);
}

function toMoney(n) {
  try {
    return Number(n).toLocaleString("en-US");
  } catch {
    return String(n);
  }
}

function rankFromExp(exp) {
  if (exp >= 5000) return "Mythic";
  i
