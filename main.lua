SMODS.Atlas{
    key = 'Justices',
    path = 'jokeratlas.png',
    px = 71,
    py = 95
}

SMODS.Joker{
    key = 'neil',
    loc_txt = {
        name = 'Neil Gorsuch',
        text = {
            'Hi, I\'m Neil'
        }
    },
    atlas = 'Justices',
    pos = {x = 0, y = 0}
}

SMODS.Joker{
    key = 'john',
    loc_txt = {
        name = 'Chief Justice', --get it it's because that's his title in *real* life
        text = {
            'Hello. I\'m John G. Roberts.'
        }
    },
    atlas = 'Justices',
    pos = {x = 1, y = 0}
}

SMODS.Joker{
    key = 'clarence',
    loc_txt = {
        name = 'Silent Justice',
        text = {
            '{C:money}-$#1#{} at end of round',
            '{C:green}#3# in #4#{} chance to earn {C:money}$#2#{} instead'
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        return { vars = {self.config.money_loss, self.config.money_gain, (G.GAME.probabilities.normal or 1), self.config.odds}}
    end,
    config = {money_loss = 1, money_gain = 20, odds = 9},
    atlas = 'Justices',
    pos = {x = 2, y = 0},
    calc_dollar_bonus = function(self, card)
		local bonus
        if pseudorandom('clarence') < G.GAME.probabilities.normal / self.config.odds then
            bonus = self.config.money_gain
        else
            bonus = -self.config.money_loss
        end
        if bonus ~= 0 then return bonus end
	end
}

SMODS.Joker{
    key = 'sam',
    loc_txt = {
        name = 'Pro-Life Justice', --replace with something less obvious
        text = {
            'All played {C:attention}Queens{}',
            'become {C:mult}Glass{} cards',
            'when scoring'
        }
    },
    rarity = 1,
    atlas = 'Justices',
    pos = {x = 0, y = 1},
    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            if context.before then
                local queens = {}
                for k, v in ipairs(context.scoring_hand) do
                    if v:get_id() == 12 then
                        queens[#queens+1] = v
                        v:set_ability(G.P_CENTERS.m_glass, nil, true)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                return true
                            end
                        }))
                    end
                end
                if #queens > 0 then
                    return {
                        message = 'Life!',
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
}

SMODS.Joker{
    key = 'sonia',
    loc_txt = {
        name = 'Sonia Sotomayor',
        text = {
            'Sotomayor, pleased to make',
            'your acquaintance.'
        }
    },
    atlas = 'Justices',
    pos = {x = 1, y = 1}
}

SMODS.Joker{
    key = 'elena',
    loc_txt = {
        name = 'Frozen Justice',
        text = {
            'Hi, I\'m Mrs. Kagan.'
        }
    },
    atlas = 'Justices',
    pos = {x = 2, y = 1}
}

SMODS.Joker{
    key = 'brett',
    loc_txt = {
        name = 'Papal Justice',
        text = {
            'Adds {C:chips}+#2#{} Chips when',
            'a card is {C:mult}destroyed',
            '{C:inactive}(Currently {C:chips}+#1#{} {C:inactive}Chips)'
        }
    },
    loc_vars = function(self, info_queue, card)
		return { vars = { self.config.chips, self.config.chip_gain } }
	end,
    config = {chips = 4, chip_gain = 12},
    rarity = 1,
    atlas = 'Justices',
    pos = {x = 0, y = 2},
    calculate = function(self, card, context)
        if context.remove_playing_cards then
            for k, v in ipairs(context.removed) do
                self.config.chips = self.config.chips + self.config.chip_gain
            end
            return {
                message = 'Upgrade!',
                colour = G.C.CHIPS
            }
        end
        if context.joker_main then 
            return {
                chips = self.config.chips
            }
        end
    end
}

SMODS.Joker{
    key = 'amy',
    loc_txt = {
        name = 'Nuclear Justice', --nuclear family, specifically
        text = {
            '{X:mult,C:white} X3 {} Mult if owned',
            '{C:attention}Jokers{} is at least {C:attention}7'
        }
    },
    config = {extra = {x_mult = 3}},
    rarity = 3,
    atlas = 'Justices',
    pos = {x = 1, y = 2},
    calculate = function(self, card, context)
        if context.joker_main then
            if #G.jokers.cards >= 7 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult}}
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'ketanji',
    loc_txt = {
        name = 'Ketanji Jackson',
        text = {
            'Hi, I\'m Ketanji.'
        }
    },
    atlas = 'Justices',
    pos = {x = 2, y = 2}
}