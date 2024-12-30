def parse_cards(file_path, callback):
    inside_card = False
    balance = 0
    current_card = ""
    card_types = ["#card(", "#custom_card("]

    with open(file_path, "r") as file:
        file_content = file.read()

    i = 0
    while i < len(file_content):
        if not inside_card and any(file_content[i:i+len(card_type)] == card_type for card_type in card_types):
            inside_card = True
            for card_type in card_types:
                if file_content[i:i+len(card_type)] == card_type:
                    balance = 1
                    current_card = card_type
                    i += len(card_type)
                    break
            continue

        if inside_card:
            current_card += file_content[i]
            if file_content[i] == "(":
                balance += 1
            elif file_content[i] == ")":
                balance -= 1

            if balance == 0:
                callback(current_card.strip())
                inside_card = False
                current_card = ""

        i += 1
