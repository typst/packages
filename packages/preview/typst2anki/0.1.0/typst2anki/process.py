from pathlib import Path
from .api import upload_media, create_deck, add_or_update_card

def process_images(deck_name, cards, decks, ids, output_path):
    create_deck(deck_name)

    for idx, card in enumerate(cards, start=1):
        card_id = ids.get(f"Card {idx}", "Unknown ID")
        if decks.get(f"Card {idx}", "Default") == deck_name:
            front_image = Path(output_path) / f"{card_id}-1.png"
            back_image = Path(output_path) / f"{card_id}-2.png"

            if front_image.exists() and back_image.exists():
                try:
                    front_name = upload_media(front_image)
                    back_name = upload_media(back_image)
                    add_or_update_card(deck_name, front_name, back_name, [card_id])
                finally:
                    front_image.unlink(missing_ok=True)
                    back_image.unlink(missing_ok=True)
