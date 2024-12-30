import re

def extract_ids_and_decks(cards):
    ids = {}
    decks = {}

    for idx, card in enumerate(cards, start=1):
        id_match = re.search(r'id:\s*"([^"]+)"', card)
        deck_match = re.search(r'target_deck:\s*"([^"]+)"', card)

        card_id = id_match.group(1) if id_match else f"Unknown_{idx}"
        target_deck = deck_match.group(1) if deck_match else "Default"

        ids[f"Card {idx}"] = card_id
        decks[f"Card {idx}"] = target_deck

    return ids, decks
