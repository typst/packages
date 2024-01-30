#import "@local/linguify:0.1.0": *

#show: linguify_config.with(data: toml("lang.toml"), lang: "en", fallback: true);

= Linguify

#v(1cm)

#smallcaps(linguify("abstract"))
== #linguify("title")
#lorem(40) 
#linguify("test")


#v(1cm)
#show: linguify_config.with(lang: "de");

#smallcaps(linguify("abstract"))
== #linguify("title")
#lorem(40) #linguify("test")

#v(1cm)
#show: linguify_config.with(lang: "es", fallback: true);

#smallcaps(linguify("abstract"))
== #linguify("title")
#lorem(40) #linguify("test")

#v(1cm)
#show: linguify_config.with(lang: "cz");

#smallcaps(linguify("abstract"))
== #linguify("title")
#lorem(40) #linguify("test")