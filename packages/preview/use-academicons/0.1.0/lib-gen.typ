// based on duskmoons typst-fontawesome 
// https://github.com/duskmoon314/typst-fontawesome

  #import "lib-impl.typ": ai-icon

  // Generated icon list of Academicons 1.9.4

  #let ai-icon-map = (
    "academia": "\u{e9af}",
    "academia-square": "\u{e93d}",
    "acclaim": "\u{e92e}",
    "acclaim-square": "\u{e93a}",
    "acm": "\u{e93c}",
    "acm-square": "\u{e95d}",
    "acmdl": "\u{e96a}",
    "acmdl-square": "\u{e9d3}",
    "ads": "\u{e9cb}",
    "ads-square": "\u{e94a}",
    "africarxiv": "\u{e91b}",
    "africarxiv-square": "\u{e90b}",
    "archive": "\u{e955}",
    "archive-square": "\u{e956}",
    "arxiv": "\u{e974}",
    "arxiv-square": "\u{e9a6}",
    "biorxiv": "\u{e9a2}",
    "biorxiv-square": "\u{e98b}",
    "ceur": "\u{e96d}",
    "ceur-square": "\u{e92f}",
    "ciencia-vitae": "\u{e912}",
    "ciencia-vitae-square": "\u{e913}",
    "clarivate": "\u{e924}",
    "clarivate-square": "\u{e925}",
    "closed-access": "\u{e942}",
    "closed-access-square": "\u{e943}",
    "conversation": "\u{e94c}",
    "conversation-square": "\u{e915}",
    "coursera": "\u{e95f}",
    "coursera-square": "\u{e97f}",
    "crossref": "\u{e918}",
    "crossref-square": "\u{e919}",
    "cv": "\u{e9a5}",
    "cv-square": "\u{e90a}",
    "datacite": "\u{e91c}",
    "datacite-square": "\u{e91d}",
    "dataverse": "\u{e9f7}",
    "dataverse-square": "\u{e9e4}",
    "dblp": "\u{e94f}",
    "dblp-square": "\u{e93f}",
    "depsy": "\u{e97a}",
    "depsy-square": "\u{e94b}",
    "doi": "\u{e97e}",
    "doi-square": "\u{e98f}",
    "dryad": "\u{e97c}",
    "dryad-square": "\u{e98c}",
    "elsevier": "\u{e961}",
    "elsevier-square": "\u{e910}",
    "figshare": "\u{e981}",
    "figshare-square": "\u{e9e7}",
    "google-scholar": "\u{e9d4}",
    "google-scholar-square": "\u{e9f9}",
    "hal": "\u{e92c}",
    "hal-square": "\u{e92d}",
    "hypothesis": "\u{e95a}",
    "hypothesis-square": "\u{e95b}",
    "ideas-repec": "\u{e9ed}",
    "ideas-repec-square": "\u{e9f8}",
    "ieee": "\u{e929}",
    "ieee-square": "\u{e9b9}",
    "impactstory": "\u{e9cf}",
    "impactstory-square": "\u{e9aa}",
    "inaturalist": "\u{e900}",
    "inaturalist-square": "\u{e901}",
    "inpn": "\u{e902}",
    "inpn-square": "\u{e903}",
    "inspire": "\u{e9e9}",
    "inspire-square": "\u{e9fe}",
    "isidore": "\u{e936}",
    "isidore-square": "\u{e954}",
    "isni": "\u{e957}",
    "isni-square": "\u{e958}",
    "jstor": "\u{e938}",
    "jstor-square": "\u{e944}",
    "lattes": "\u{e9b3}",
    "lattes-square": "\u{e99c}",
    "mathoverflow": "\u{e9f6}",
    "mathoverflow-square": "\u{e97b}",
    "mendeley": "\u{e9f0}",
    "mendeley-square": "\u{e9f3}",
    "moodle": "\u{e907}",
    "moodle-square": "\u{e908}",
    "mtmt": "\u{e950}",
    "mtmt-square": "\u{e951}",
    "nakala": "\u{e940}",
    "nakala-square": "\u{e941}",
    "obp": "\u{e92a}",
    "obp-square": "\u{e92b}",
    "open-access": "\u{e939}",
    "open-access-square": "\u{e9f4}",
    "open-data": "\u{e966}",
    "open-data-square": "\u{e967}",
    "open-materials": "\u{e968}",
    "open-materials-square": "\u{e969}",
    "openedition": "\u{e946}",
    "openedition-square": "\u{e947}",
    "orcid": "\u{e9d9}",
    "orcid-square": "\u{e9c3}",
    "osf": "\u{e9ef}",
    "osf-square": "\u{e931}",
    "overleaf": "\u{e914}",
    "overleaf-square": "\u{e98d}",
    "philpapers": "\u{e98a}",
    "philpapers-square": "\u{e96f}",
    "piazza": "\u{e99a}",
    "piazza-square": "\u{e90c}",
    "preregistered": "\u{e906}",
    "preregistered-square": "\u{e96b}",
    "protocols": "\u{e952}",
    "protocols-square": "\u{e953}",
    "psyarxiv": "\u{e90e}",
    "psyarxiv-square": "\u{e90f}",
    "publons": "\u{e937}",
    "publons-square": "\u{e94e}",
    "pubmed": "\u{e99f}",
    "pubmed-square": "\u{e97d}",
    "pubpeer": "\u{e922}",
    "pubpeer-square": "\u{e923}",
    "researcherid": "\u{e91a}",
    "researcherid-square": "\u{e95c}",
    "researchgate": "\u{e95e}",
    "researchgate-square": "\u{e99e}",
    "ror": "\u{e948}",
    "ror-square": "\u{e949}",
    "sci-hub": "\u{e959}",
    "sci-hub-square": "\u{e905}",
    "scirate": "\u{e98e}",
    "scirate-square": "\u{e99d}",
    "scopus": "\u{e91e}",
    "scopus-square": "\u{e91f}",
    "semantic-scholar": "\u{e96e}",
    "semantic-scholar-square": "\u{e96c}",
    "springer": "\u{e928}",
    "springer-square": "\u{e99b}",
    "ssrn": "\u{e916}",
    "ssrn-square": "\u{e917}",
    "stackoverflow": "\u{e920}",
    "stackoverflow-square": "\u{e921}",
    "viaf": "\u{e933}",
    "viaf-square": "\u{e934}",
    "wiley": "\u{e926}",
    "wiley-square": "\u{e927}",
    "zenodo": "\u{e911}",
    "zotero": "\u{e962}",
    "zotero-square": "\u{e932}"
  )

  #let ai-academia = ai-icon.with("\u{e9af}")
  #let ai-academia-square = ai-icon.with("\u{e93d}")
  #let ai-acclaim = ai-icon.with("\u{e92e}")
  #let ai-acclaim-square = ai-icon.with("\u{e93a}")
  #let ai-acm = ai-icon.with("\u{e93c}")
  #let ai-acm-square = ai-icon.with("\u{e95d}")
  #let ai-acmdl = ai-icon.with("\u{e96a}")
  #let ai-acmdl-square = ai-icon.with("\u{e9d3}")
  #let ai-ads = ai-icon.with("\u{e9cb}")
  #let ai-ads-square = ai-icon.with("\u{e94a}")
  #let ai-africarxiv = ai-icon.with("\u{e91b}")
  #let ai-africarxiv-square = ai-icon.with("\u{e90b}")
  #let ai-archive = ai-icon.with("\u{e955}")
  #let ai-archive-square = ai-icon.with("\u{e956}")
  #let ai-arxiv = ai-icon.with("\u{e974}")
  #let ai-arxiv-square = ai-icon.with("\u{e9a6}")
  #let ai-biorxiv = ai-icon.with("\u{e9a2}")
  #let ai-biorxiv-square = ai-icon.with("\u{e98b}")
  #let ai-ceur = ai-icon.with("\u{e96d}")
  #let ai-ceur-square = ai-icon.with("\u{e92f}")
  #let ai-ciencia-vitae = ai-icon.with("\u{e912}")
  #let ai-ciencia-vitae-square = ai-icon.with("\u{e913}")
  #let ai-clarivate = ai-icon.with("\u{e924}")
  #let ai-clarivate-square = ai-icon.with("\u{e925}")
  #let ai-closed-access = ai-icon.with("\u{e942}")
  #let ai-closed-access-square = ai-icon.with("\u{e943}")
  #let ai-conversation = ai-icon.with("\u{e94c}")
  #let ai-conversation-square = ai-icon.with("\u{e915}")
  #let ai-coursera = ai-icon.with("\u{e95f}")
  #let ai-coursera-square = ai-icon.with("\u{e97f}")
  #let ai-crossref = ai-icon.with("\u{e918}")
  #let ai-crossref-square = ai-icon.with("\u{e919}")
  #let ai-cv = ai-icon.with("\u{e9a5}")
  #let ai-cv-square = ai-icon.with("\u{e90a}")
  #let ai-datacite = ai-icon.with("\u{e91c}")
  #let ai-datacite-square = ai-icon.with("\u{e91d}")
  #let ai-dataverse = ai-icon.with("\u{e9f7}")
  #let ai-dataverse-square = ai-icon.with("\u{e9e4}")
  #let ai-dblp = ai-icon.with("\u{e94f}")
  #let ai-dblp-square = ai-icon.with("\u{e93f}")
  #let ai-depsy = ai-icon.with("\u{e97a}")
  #let ai-depsy-square = ai-icon.with("\u{e94b}")
  #let ai-doi = ai-icon.with("\u{e97e}")
  #let ai-doi-square = ai-icon.with("\u{e98f}")
  #let ai-dryad = ai-icon.with("\u{e97c}")
  #let ai-dryad-square = ai-icon.with("\u{e98c}")
  #let ai-elsevier = ai-icon.with("\u{e961}")
  #let ai-elsevier-square = ai-icon.with("\u{e910}")
  #let ai-figshare = ai-icon.with("\u{e981}")
  #let ai-figshare-square = ai-icon.with("\u{e9e7}")
  #let ai-google-scholar = ai-icon.with("\u{e9d4}")
  #let ai-google-scholar-square = ai-icon.with("\u{e9f9}")
  #let ai-hal = ai-icon.with("\u{e92c}")
  #let ai-hal-square = ai-icon.with("\u{e92d}")
  #let ai-hypothesis = ai-icon.with("\u{e95a}")
  #let ai-hypothesis-square = ai-icon.with("\u{e95b}")
  #let ai-ideas-repec = ai-icon.with("\u{e9ed}")
  #let ai-ideas-repec-square = ai-icon.with("\u{e9f8}")
  #let ai-ieee = ai-icon.with("\u{e929}")
  #let ai-ieee-square = ai-icon.with("\u{e9b9}")
  #let ai-impactstory = ai-icon.with("\u{e9cf}")
  #let ai-impactstory-square = ai-icon.with("\u{e9aa}")
  #let ai-inaturalist = ai-icon.with("\u{e900}")
  #let ai-inaturalist-square = ai-icon.with("\u{e901}")
  #let ai-inpn = ai-icon.with("\u{e902}")
  #let ai-inpn-square = ai-icon.with("\u{e903}")
  #let ai-inspire = ai-icon.with("\u{e9e9}")
  #let ai-inspire-square = ai-icon.with("\u{e9fe}")
  #let ai-isidore = ai-icon.with("\u{e936}")
  #let ai-isidore-square = ai-icon.with("\u{e954}")
  #let ai-isni = ai-icon.with("\u{e957}")
  #let ai-isni-square = ai-icon.with("\u{e958}")
  #let ai-jstor = ai-icon.with("\u{e938}")
  #let ai-jstor-square = ai-icon.with("\u{e944}")
  #let ai-lattes = ai-icon.with("\u{e9b3}")
  #let ai-lattes-square = ai-icon.with("\u{e99c}")
  #let ai-mathoverflow = ai-icon.with("\u{e9f6}")
  #let ai-mathoverflow-square = ai-icon.with("\u{e97b}")
  #let ai-mendeley = ai-icon.with("\u{e9f0}")
  #let ai-mendeley-square = ai-icon.with("\u{e9f3}")
  #let ai-moodle = ai-icon.with("\u{e907}")
  #let ai-moodle-square = ai-icon.with("\u{e908}")
  #let ai-mtmt = ai-icon.with("\u{e950}")
  #let ai-mtmt-square = ai-icon.with("\u{e951}")
  #let ai-nakala = ai-icon.with("\u{e940}")
  #let ai-nakala-square = ai-icon.with("\u{e941}")
  #let ai-obp = ai-icon.with("\u{e92a}")
  #let ai-obp-square = ai-icon.with("\u{e92b}")
  #let ai-open-access = ai-icon.with("\u{e939}")
  #let ai-open-access-square = ai-icon.with("\u{e9f4}")
  #let ai-open-data = ai-icon.with("\u{e966}")
  #let ai-open-data-square = ai-icon.with("\u{e967}")
  #let ai-open-materials = ai-icon.with("\u{e968}")
  #let ai-open-materials-square = ai-icon.with("\u{e969}")
  #let ai-openedition = ai-icon.with("\u{e946}")
  #let ai-openedition-square = ai-icon.with("\u{e947}")
  #let ai-orcid = ai-icon.with("\u{e9d9}")
  #let ai-orcid-square = ai-icon.with("\u{e9c3}")
  #let ai-osf = ai-icon.with("\u{e9ef}")
  #let ai-osf-square = ai-icon.with("\u{e931}")
  #let ai-overleaf = ai-icon.with("\u{e914}")
  #let ai-overleaf-square = ai-icon.with("\u{e98d}")
  #let ai-philpapers = ai-icon.with("\u{e98a}")
  #let ai-philpapers-square = ai-icon.with("\u{e96f}")
  #let ai-piazza = ai-icon.with("\u{e99a}")
  #let ai-piazza-square = ai-icon.with("\u{e90c}")
  #let ai-preregistered = ai-icon.with("\u{e906}")
  #let ai-preregistered-square = ai-icon.with("\u{e96b}")
  #let ai-protocols = ai-icon.with("\u{e952}")
  #let ai-protocols-square = ai-icon.with("\u{e953}")
  #let ai-psyarxiv = ai-icon.with("\u{e90e}")
  #let ai-psyarxiv-square = ai-icon.with("\u{e90f}")
  #let ai-publons = ai-icon.with("\u{e937}")
  #let ai-publons-square = ai-icon.with("\u{e94e}")
  #let ai-pubmed = ai-icon.with("\u{e99f}")
  #let ai-pubmed-square = ai-icon.with("\u{e97d}")
  #let ai-pubpeer = ai-icon.with("\u{e922}")
  #let ai-pubpeer-square = ai-icon.with("\u{e923}")
  #let ai-researcherid = ai-icon.with("\u{e91a}")
  #let ai-researcherid-square = ai-icon.with("\u{e95c}")
  #let ai-researchgate = ai-icon.with("\u{e95e}")
  #let ai-researchgate-square = ai-icon.with("\u{e99e}")
  #let ai-ror = ai-icon.with("\u{e948}")
  #let ai-ror-square = ai-icon.with("\u{e949}")
  #let ai-sci-hub = ai-icon.with("\u{e959}")
  #let ai-sci-hub-square = ai-icon.with("\u{e905}")
  #let ai-scirate = ai-icon.with("\u{e98e}")
  #let ai-scirate-square = ai-icon.with("\u{e99d}")
  #let ai-scopus = ai-icon.with("\u{e91e}")
  #let ai-scopus-square = ai-icon.with("\u{e91f}")
  #let ai-semantic-scholar = ai-icon.with("\u{e96e}")
  #let ai-semantic-scholar-square = ai-icon.with("\u{e96c}")
  #let ai-springer = ai-icon.with("\u{e928}")
  #let ai-springer-square = ai-icon.with("\u{e99b}")
  #let ai-ssrn = ai-icon.with("\u{e916}")
  #let ai-ssrn-square = ai-icon.with("\u{e917}")
  #let ai-stackoverflow = ai-icon.with("\u{e920}")
  #let ai-stackoverflow-square = ai-icon.with("\u{e921}")
  #let ai-viaf = ai-icon.with("\u{e933}")
  #let ai-viaf-square = ai-icon.with("\u{e934}")
  #let ai-wiley = ai-icon.with("\u{e926}")
  #let ai-wiley-square = ai-icon.with("\u{e927}")
  #let ai-zenodo = ai-icon.with("\u{e911}")
  #let ai-zotero = ai-icon.with("\u{e962}")
  #let ai-zotero-square = ai-icon.with("\u{e932}")
