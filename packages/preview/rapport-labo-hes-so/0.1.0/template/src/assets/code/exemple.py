'''
Amaury Wailliez
Labo 6 exo porte monnaie
'''


def porte_monnaie (billet,argent_disponible):
    resultat =argent_disponible // billet
    argent_disponible = argent_disponible -resultat*billet
    if resultat != 0:
        print(resultat,"billet(s) de : " , billet, "CHF")
    
    return argent_disponible
    
    
argent_disponible = int(input("Argent disponible : "))

argent_disponible  = porte_monnaie(100,argent_disponible)
argent_disponible  = porte_monnaie(50,argent_disponible)
argent_disponible  = porte_monnaie(20,argent_disponible)
argent_disponible  = porte_monnaie(10,argent_disponible)
argent_disponible  = porte_monnaie(5,argent_disponible)
argent_disponible  = porte_monnaie(2,argent_disponible)
argent_disponible  = porte_monnaie(1,argent_disponible)