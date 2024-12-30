import logging
from pathlib import Path
from typst2anki.parse import parse_cards
from typst2anki.get_data import extract_ids_and_decks
from typst2anki.generator import generate_card_file, ensure_ankiconf_file
from typst2anki.process import process_images

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def main():
    typ_files_path = Path(".").resolve()
    if not typ_files_path.is_dir():
        logging.error(f"{typ_files_path} is not a valid directory.")
        return

    ensure_ankiconf_file(typ_files_path)

    output_path = Path(".").resolve()
    for typ_file in typ_files_path.glob("*.typ"):
        cards = []
        def capture_cards(card):
            cards.append(card)

        parse_cards(typ_file, callback=capture_cards)

        ids, decks = extract_ids_and_decks(cards)

        for idx, card in enumerate(cards, start=1):
            card_id = ids.get(f"Card {idx}", "Unknown ID")
            if card_id != "Unknown ID":
                generate_card_file(card, card_id, output_path)

        unique_decks = set(decks.values())
        for deck_name in unique_decks:
            process_images(deck_name, cards, decks, ids, output_path)

if __name__ == "__main__":
    main()
