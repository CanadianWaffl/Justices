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
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    loc_txt = {
        name = 'Average Justice',
        text = {
            '{C:mult}+#1#{} Mult',
            'Self-destructs in {C:attention}#2# hands'
        }
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.mult, card.ability.extra.timer}}
    end,
    rarity = 1,
    cost = 3,
    config = {extra = {mult = 5, timer = 10}},
    atlas = 'Justices',
    pos = {x = 0, y = 0},
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult}}
            }
        end
        if context.final_scoring_step then
            if card.ability.extra.timer > 1 then
                card.ability.extra.timer = card.ability.extra.timer - 1
                return {
                    message = 'Tick Tock...',
                }
            else
                G.E_MANAGER:add_event(Event({
					func = function()
						play_sound('tarot1')
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						-- This part destroys the card.
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true;
							end
						}))
						return true
					end
				}))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if card.edition then
                            add_joker('j_jst_roboneil', card.edition.key.gsub(card.edition.key,"e_",""))
                        else
                            add_joker('j_jst_roboneil')
                        end
                        return true
                    end
                }))
                return {
                    message = 'Kaboom!'
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'roboneil',
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    no_collection = true,
    loc_txt = {
        name = 'Cybernetic Justice',
        text = {
            'Adds {C:mult}+#1#{} Mult',
            'for each Joker to',
            'the left each hand',
            '{C:inactive}(Currently {C:mult}+#2#{} {C:inactive}Mult)'
        }
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.mult_gain, card.ability.extra.mult}}
    end,
    config = {extra = {mult = 5, mult_gain = 2}},
    yes_pool_flag = "never",
    rarity = 2,
    atlas = 'Justices',
    pos = {x = 0, y = 3},
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers then 
            local count = 0
            for k, v in ipairs(G.jokers.cards) do
                if v == card then break end
                count = count + 1
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        v:juice_up()
                        return true
                    end
                }))
            end
            if count > 0 then
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT
                }
            end
        end
        if context.joker_main then
            return {
                mult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult}}
            }
        end
    end
}

SMODS.Joker{
    key = 'john',
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
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
    cost = 8,
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
                    return true end}))
            playing_card_joker_effects({true})
            return {
                message = 'Order!',
                colour = G.C.black
            }
        end
    end
}

SMODS.Joker{
    key = 'clarence',
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Silent Justice',
        text = {
            '{C:money}-$#1#{} at end of round',
            '{C:green}#3# in #4#{} chance to', 
            'earn {C:money}$#2#{} instead'
        }
    },
    rarity = 2,
    cost = 8,
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.money_loss, card.ability.extra.money_gain, (G.GAME.probabilities.normal or 1), card.ability.extra.odds}}
    end,
    config = {extra = {money_loss = 1, money_gain = 20, odds = 9}},
    atlas = 'Justices',
    pos = {x = 2, y = 0},
    calc_dollar_bonus = function(self, card)
		local bonus
        if pseudorandom('clarence') < G.GAME.probabilities.normal / card.ability.extra.odds then
            bonus = card.ability.extra.money_gain
        else
            bonus = -card.ability.extra.money_loss
        end
        if bonus ~= 0 then return bonus end
	end
}

SMODS.Joker{
    key = 'sam',
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Justice Justice',
        text = {
            'All played {C:attention}Queens{}',
            'become {C:mult}Glass{} cards',
            'when scoring'
        }
    },
    rarity = 1,
    cost = 4,
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
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Social Justice',
        text = {
            'When {C:attention}blind{} is selected,',
            'upgrade the level of',
            'the lowest levelled',
            '{C:}hand type'
        }
    },
    rarity = 1,
    cost = 3,
    atlas = 'Justices',
    pos = {x = 1, y = 1},
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local _least, _hand, _tally = {}, nil, 10000
            for k, v in ipairs(G.handlist) do
                if G.GAME.hands[v].visible then
                    if G.GAME.hands[v].level < _tally then
                        _tally = G.GAME.hands[v].level
                        _least = {}
                        _least[#_least + 1] = v
                    elseif G.GAME.hands[v].level == _tally then
                        _least[#_least + 1] = v
                    end
                end
            end
            _hand = pseudorandom_element(_least, pseudorandom('sonia'))
            if _hand then
                local text = _hand
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(text, 'poker_hands'),chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level=G.GAME.hands[text].level})
                level_up_hand(card, text, nil, 1)
                update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
            end
        end
    end
}

SMODS.Joker{
    key = 'elena',
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Frozen Justice',
        text = {
            '{C:green}#1# in #2#{} chance to',
            'create a {C:dark_edition}negative{}',
            '{C:attention}Ice Cream{} at',
            'start of round'
        }
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {(G.GAME.probabilities.normal or 1), card.ability.extra.odds}}
    end,
    config = {extra = {odds = 4}},
    rarity = 2,
    cost = 6,
    atlas = 'Justices',
    pos = {x = 2, y = 1},
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            if pseudorandom('elena') < G.GAME.probabilities.normal / card.ability.extra.odds then
                add_joker('j_ice_cream', 'negative')
                return {
                    message = 'Yum!'
                }
            end
            return {
                message = 'Nope!'
            }
        end
    end
}

SMODS.Joker{
    key = 'brett',
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Papal Justice',
        text = {
            'Adds {C:chips}+#2#{} Chips when',
            'a card is {C:mult}destroyed',
            '{C:inactive}(Currently {C:chips}+#1#{} {C:inactive}Chips)'
        }
    },
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain } }
	end,
    config = {extra = {chips = 4, chip_gain = 12}},
    rarity = 1,
    cost = 4,
    atlas = 'Justices',
    pos = {x = 0, y = 2},
    calculate = function(self, card, context)
        if context.remove_playing_cards then
            for k, v in ipairs(context.removed) do
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
            end
            return {
                message = 'Upgrade!',
                colour = G.C.CHIPS
            }
        end
        if context.joker_main then 
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker{
    key = 'amy',
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Nuclear Justice', --nuclear family, specifically
        text = {
            '{X:mult,C:white}X3{} Mult if owned',
            '{C:attention}Jokers{} is at least {C:attention}7'
        }
    },
    config = {extra = {x_mult = 3}},
    rarity = 3,
    cost = 8,
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
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Criminal Justice',
        text = {
            'Every discarded',
            '{C:attention}card{} permanently',
            'gains {C:mult}+#1#{} mult'
        }
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.perma_mult}}
    end,
    config = {extra = {perma_mult = 2}},
    rarity = 2,
    cost = 7,
    atlas = 'Justices',
    pos = {x = 2, y = 2},
    calculate = function(self, card, context)
        if context.pre_discard then
            for k, v in ipairs(G.hand.highlighted) do
                v.ability.perma_mult = v.ability.perma_mult or 0
                v.ability.perma_mult = v.ability.perma_mult + card.ability.extra.perma_mult
                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.MULT})
                --card:juice_up(0.3, 0.5) --only happens once for some reason??
            end
            return true
        end
    end
}

SMODS.Joker{
    key = 'marshall',
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    loc_txt = {
        name = 'Ghostly Justice',
        text = {
            'Gains {X:mult,C:white}X1{} mult for',
            'each {C:tarot}Law tarot{} sold',
            '{C:inactive}(Currently {X:mult,C:white}X#1#{} {C:inactive}mult)'
        }
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    yes_pool_flag = 'law_sold',
    config = {extra = {xmult = 1, xmult_gain = 1}},
    rarity = 4,
    cost = 12,
    atlas = 'Justices',
    pos = {x = 1, y = 3},
    calculate = function(self, card, context)
        if context.selling_card then
            if context.card.ability.name == 'c_jst_law' then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT
                }
            end
        end
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.xmult,
                message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.xmult}}
            }
        end
    end
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
    atlas = 'Seals',
    pos = {x = 0, y = 0},
    calculate = function(self, card, context)
        if context.remove_playing_cards then
            for k, v in ipairs(context.removed) do
                if v == card then
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
        end
    end
}

--Law Tarot
SMODS.Consumable {
	key = 'law',
	set = 'Tarot',
	loc_txt = {
        name = "Law",
        text = {
            '{C:green}#1#{} in {C:green}#2#{} chance to',
            'upgrade the {C:dark_edition}edition{} of',
            'a random joker',
            'Does not apply to {C:attention}Justices',
            '{C:inactive}(Ex: holo -> polychrome)'
        }
	},
	loc_vars = function(self, info_queue, card)
		return {vars = {(G.GAME.probabilities.normal or 1), card.ability.extra.odds}}
	end,
	config = {extra = {odds = 2}},
	atlas = 'Consumes',
	pos = {x = 0, y = 0},
    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then
            if not G.GAME.pool_flags.law_sold then
                G.GAME.pool_flags.law_sold = true
            end
        end
    end,
    can_use = function(self, card)
        if G then
            local eligible_jokers = {}
            for k, v in ipairs(G.jokers.cards) do
                if not string.find(v.ability.name, 'jst') then
                    if v.edition then
                        if not v.edition.negative then 
                        eligible_jokers[#eligible_jokers+1] = v end
                    else
                        eligible_jokers[#eligible_jokers+1] = v end
                end
            end
            if #eligible_jokers > 0 then
                return true
            end
        end
        return false
    end,
	use = function(self, card, area, copier)
        local eligible_jokers = {}
        if pseudorandom('law') < (G.GAME.probabilities.normal / card.ability.extra.odds) then
            for k, v in ipairs(G.jokers.cards) do
                if not string.find(v.ability.name, 'jst') then
                    if v.edition then
                        if not v.edition.negative then 
                        eligible_jokers[#eligible_jokers+1] = v end
                    else
                        eligible_jokers[#eligible_jokers+1] = v end
                end
            end
            if #eligible_jokers > 0 then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    local chosen, num = pseudorandom_element(eligible_jokers, pseudorandom('law2'))
                    if not chosen.edition then
                        chosen:set_edition({foil = true}, true)
                    elseif chosen.edition.foil then
                        chosen:set_edition({holo = true}, true)
                    elseif chosen.edition.holo then
                        chosen:set_edition({polychrome = true}, true)
                    elseif chosen.edition.polychrome then
                        chosen:set_edition({negative = true}, true)
                    end
                    return {
                        message = localize('k_upgrade_ex'),
                        card = chosen
                    }
                end}))
            end
            return true
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function() --Not working
            attention_text({
                text = localize('k_nope_ex'),
                scale = 1.3, 
                hold = 1.4,
                major = copier or self,
                backdrop_colour = G.C.SECONDARY_SET.Tarot,
                align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                silent = true
                })
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                    play_sound('tarot2', 0.76, 0.4);return true end}))
                play_sound('tarot2', 1, 0.4)
                --self:juice_up(0.3, 0.5)
        return true end }))
	end
}