--Jokers
SMODS.Atlas{
    key = 'Justices',
    path = 'jokeratlas.png',
    px = 71,
    py = 95
}

--Consumables
SMODS.Atlas{
    key = 'Consumes',
    path = 'consumatlas.png',
    px = 71,
    py = 95
}

--Seals
SMODS.Atlas{
    key = 'Seals',
    path = 'sealatlas.png',
    px = 71,
    py = 95
}

------------JOKERS---------------
---------------------------------
SMODS.Joker{
    key = 'neil',
    loc_txt = {
        name = 'Neil Gorsuch',
        text = {
            'Hi, I\'m Neil'
        }
    },
    rarity = 2,
    config = {},
    atlas = 'Justices',
    pos = {x = 0, y = 0},
    calculate = function(self, card, context)
    end
}

SMODS.Joker{
    key = 'john',
    loc_txt = {
        name = 'Chief Justice', --get it it's because that's his title in *real* life
        text = {
            'When round begins',
            'add a random {C:attention}playing',
            '{C:attention}card{} with a Black',
            '{C:attention}seal{} to hand'
        }
    },
    rarity = 3,
    atlas = 'Justices',
    pos = {x = 1, y = 0},
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            G.E_MANAGER:add_event(Event({
                func = function() 
                    local _card = create_playing_card({
                        front = pseudorandom_element(G.P_CARDS, pseudoseed('john')), 
                        center = G.P_CENTERS.c_base}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                    _card:set_seal('jst_Black', true)
                    G.GAME.blind:debuff_card(_card)
                    G.hand:sort()
                    return {
                        message = 'Order!',
                        colour = G.C.black
                    }
                end}))
            playing_card_joker_effects({true})
        end
    end
}

SMODS.Joker{
    key = 'clarence',
    loc_txt = {
        name = 'Silent Justice',
        text = {
            '{C:money}-$#1#{} at end of round',
            '{C:green}#3# in #4#{} chance to', 
            'earn {C:money}$#2#{} instead'
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
        name = 'Social Justice',
        text = {
            'When {C:attention}blind{} is selected,',
            'upgrade the level',
            'of the {C:attention}least{} used hand'
        }
    },
    rarity = 1,
    atlas = 'Justices',
    pos = {x = 1, y = 1},
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local _hand, _tally = nil, 10000
            for k, v in ipairs(G.handlist) do
                if G.GAME.hands[v].visible and G.GAME.hands[v].played < _tally then
                    _hand = v
                    _tally = G.GAME.hands[v].played
                end
            end
            if _hand then
                local text, disp_text = _hand, _hand
                --card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                --update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(text, 'poker_hands'),chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level=G.GAME.hands[text].level})
                level_up_hand(self, text, nil, 1)
                --update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
            end
        end
        return true
    end
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

----------JOKERS END-------------
---------------------------------

--Black seal
SMODS.Seal {
    name = 'black-seal',
    key = 'Black',
    badge_colour = HEX('000000'),
    loc_txt = {
        label = 'Black Seal',
        name = 'Black Seal',
        text = {
            'Creates a random',
            '{C:spectral}Spectral card',
            'when destroyed'
        }
    },
    loc_vars = function(self, info_queue, card)
		return {}
	end,
    config = {},
    atlas = 'Seals',
    pos = {x = 0, y = 0},
    calculate = function(self, card, context)
        if context.remove_playing_cards then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                            local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'black-seal')
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            G.GAME.consumeable_buffer = 0
                        return true
                    end)}))
            end
        end
    end
}

--Law Tarot
SMODS.Consumable {
	key = 'law',
	set = 'Tarot',
	loc_txt = {
		'{C:green}#1#{} in {C:green}#2#{} chance to',
		'apply {C:attention}negative to', --Better colour for negative?
		'{C:attention}#3#{} selected Joker',
		'Does not apply to {C:attention}Justices' --Better colour here too?
	},
	loc_vars = function(self, info_queue, card)
		return {vars = {(G.GAME.probabilities.normal or 1), self.config.odds, self.config.max_select}}
	end
	config = {odds = 6, max_select = 1},
	atlas = 'Consumes',
	pos = {x = 0, y = 0},
	use = function(self, card, area, copier)
		for i = 1, math.min(#G.jokers.highlighted, self.config.max_select) do
            		G.E_MANAGER:add_event(Event({func = function()
                	play_sound('tarot1')
                	card:juice_up(0.3, 0.5)
               		return true end }))
            
            		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                	--G.hand.highlighted[i]:set_seal(card.ability.extra, nil, true)
                	return true end }))
            		delay(0.5)
        	end
        	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
	end
}
