# Package

version       = "0.1.0"
author        = "zedeus"
description   = "An alternative front-end for Twitter"
license       = "AGPL-3.0"
srcDir        = "src"
bin           = @["nitter"]


# Dependencies

requires "nim >= 1.6.10"
requires "jester#baca3f"
requires "karax#d86349c"
requires "sass#7dfdd03"
requires "nimcrypto#dc07e30"
requires "markdown#01950b8"
requires "packedjson#9e6fbb6"
requires "supersnappy#ff8fe2b"
requires "redpool#8b7c1db"
requires "https://github.com/zedeus/redis#d0a0e6f"
requires "zippy#a99f6a7"
requires "flatty#e668085"
requires "jsony#1de1f08"
requires "oauth#b8c163b"

# Tasks

task scss, "Generate css":
  exec "nimble c --hint[Processing]:off -d:danger -r tools/gencss"

task md, "Render md":
  exec "nimble c --hint[Processing]:off -d:danger -r tools/rendermd"
