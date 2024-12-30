import base64
import requests
from pathlib import Path

ANKI_CONNECT_URL = "http://localhost:8765"

def send_request(payload):
    response = requests.post(ANKI_CONNECT_URL, json=payload).json()
    if response.get("error"):
        raise Exception(f"Anki API Error: {response['error']}")
    return response.get("result")

def upload_media(file_path):
    file_path = Path(file_path)
    with open(file_path, "rb") as file:
        encoded_data = base64.b64encode(file.read()).decode("utf-8")

    payload = {
        "action": "storeMediaFile",
        "version": 6,
        "params": {
            "filename": file_path.name,
            "data": encoded_data,
        }
    }
    send_request(payload)
    return file_path.name

def create_deck(deck_name):
    payload = {"action": "createDeck", "version": 6, "params": {"deck": deck_name}}
    send_request(payload)

def find_note_id_by_tag(tag):
    payload = {
        "action": "findNotes",
        "version": 6,
        "params": {
            "query": f"tag:{tag}"
        }
    }
    return send_request(payload)

def update_note(note_id, front_image, back_image, tags):
    payload = {
        "action": "updateNoteFields",
        "version": 6,
        "params": {
            "note": {
                "id": note_id,
                "fields": {
                    "Front": f'<img src="{front_image}">',
                    "Back": f'<img src="{back_image}">'
                },
                "tags": tags
            }
        }
    }
    send_request(payload)

def add_or_update_card(deck_name, front_image, back_image, tags):
    note_ids = find_note_id_by_tag(tags[0])
    if note_ids:
        update_note(note_ids[0], front_image, back_image, tags)
    else:
        payload = {
            "action": "addNote",
            "version": 6,
            "params": {
                "note": {
                    "deckName": deck_name,
                    "modelName": "Basic",
                    "fields": {
                        "Front": f'<img src="{front_image}">',
                        "Back": f'<img src="{back_image}">'
                    },
                    "tags": tags
                }
            }
        }
        send_request(payload)
