// A made-up person, to show every part of the template.
// Copy this to cv.typ (gitignored) and fill in your own.
#import "lib.typ": *

#show: cv.with(
  name: "Alex Example",
  tagline: "backend · data · tinkering",
  headline: "Backend engineer who likes small, fast tools",
  site: "https://example.com",
  // photo: image("assets/me.png"),      // leave out for the ascii bird
  // theme: "paper",                     // ferra (default), paper, gruvbox, catppuccin, nord
  // border: "plain",                    // rounded (default), plain, thick
  // hashtags: true,                     // show the `tags:` of each entry
  contacts: (
    ("web", "example.com", "https://example.com"),
    ("email", "alex@example.com", "mailto:alex@example.com"),
    ("github", "github.com/example", "https://github.com/example"),
    ("location", "Somewhere, Earth", none),
  ),
)

#section("Experience")[
  #entry(
    society: [Acme Analytics],
    title: [Backend Engineer],
    date: [03/2024 - Present],
    location: [Remote],
    description: list(
      [Moved report generation from nightly batches to an event stream; reports now land in under a minute instead of next morning],
      [Cut p95 latency of the query API from 840 ms to 120 ms by caching query plans and dropping an ORM layer],
      [Run the on-call rotation for four services; wrote the runbooks that took median incident time from 50 to 20 minutes],
    ),
    tags: ("Go", "Kafka", "PostgreSQL"),
  )
  #entry(
    society: [Bakery around the corner],
    title: [Order website, summer job],
    date: [2022],
    description: list([Replaced phone-in cake orders with a one-page form; the owner still uses it]),
  )
]

#section("Education")[
  #entry(
    society: [Example University],
    title: [B.Sc. Computer Science, thesis graded 1.3],
    date: [10/2020 - 09/2023],
    location: [Somewhere],
    description: list([Thesis: compressing time-series indexes with learned models, 3x smaller than the B-tree baseline at equal lookup time]),
  )
]

#section("Projects")[
  #entry(
    society: [tinykv],
    title: [Embedded key-value store in Rust],
    date: [2024],
    description: list([Log-structured store in 2,000 lines; used as the storage layer of two of my other tools]),
    links: ("https://github.com/example/tinykv",),
  )
  #entry(
    society: [weather-on-e-ink],
    date: [2023],
    description: list([Raspberry Pi and an old e-ink display showing the forecast; runs for three weeks on one charge]),
  )
]

#section("Awards")[
  #honor(
    date: [2023],
    title: [2nd place, regional hackathon],
    issuer: [Example City Hackdays],
    location: [Somewhere],
  )
]

#section("Skills")[
  #skills(
    ("Languages", ("English (native)", "German (B2)")),
    ("Programming", ("Go", "Rust", "Python", "SQL")),
    ("Infrastructure", ("Linux", "Docker", "Kafka", "PostgreSQL")),
  )
]
