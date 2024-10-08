# SPDX-License-Identifier: AGPL-3.0-only
import strutils, strformat, uri, tables, base64
import nimcrypto
import std/times

var
  hmacKey: string
  base64Media = false

const
  https* = "https://"
  twimg* = "pbs.twimg.com/"
  nitterParams = ["name", "tab", "id", "list", "referer", "scroll"]
  twitterDomains = @[
    "twitter.com",
    "pic.twitter.com",
    "twimg.com",
    "abs.twimg.com",
    "pbs.twimg.com",
    "video.twimg.com",
    "x.com"
  ]

let now = now()

proc setHmacKey*(key: string) =
  hmacKey = key

proc setProxyEncoding*(state: bool) =
  base64Media = state

proc getHmac*(data: string): string =
  ($hmac(sha256, hmacKey, data & intToStr(now().year + int(now().month) + now().monthDay)))[0 .. 12]

proc getVidUrl*(link: string): string =
  if link.len == 0: return
  let sig = getHmac(link)
  if base64Media:
    &"https://cdn.xcancel.com/video/enc/{sig}/{encode(link, safe=true)}"
  else:
    &"https://cdn.xcancel.com/video/{sig}/{encodeUrl(link)}"

proc getPicUrl*(link: string): string =
  if base64Media:
    &"https://cdn.xcancel.com/pic/enc/{encode(link, safe=true)}"
  else:
    &"https://cdn.xcancel.com/pic/{encodeUrl(link)}"

proc getOrigPicUrl*(link: string): string =
  if base64Media:
    &"https://cdn.xcancel.com/pic/orig/enc/{encode(link, safe=true)}"
  else:
    &"https://cdn.xcancel.com/pic/orig/{encodeUrl(link)}"

proc filterParams*(params: Table): seq[(string, string)] =
  for p in params.pairs():
    if p[1].len > 0 and p[0] notin nitterParams:
      result.add p

proc isTwitterUrl*(uri: Uri): bool =
  uri.hostname in twitterDomains

proc isTwitterUrl*(url: string): bool =
  isTwitterUrl(parseUri(url))
