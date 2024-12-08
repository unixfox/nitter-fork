# SPDX-License-Identifier: AGPL-3.0-only
import strutils, strformat, uri, tables, base64
import nimcrypto
import std/times

var
  hmacKey: string
  base64Media = false
  cdnUrl: string

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

proc setCdnUrl*(url: string) =
  cdnUrl = url

proc getHmac*(data: string): string =
  ($hmac(sha256, hmacKey, data & intToStr(now().year + int(now().month) + now().monthDay)))[0 .. 12]

proc getVidUrl*(link: string): string =
  if link.len == 0: return
  let sig = getHmac(link)
  if "m3u8" in link:
    &"/video/{sig}/{encodeUrl(link)}"
  elif base64Media:
    &"{cdnUrl}/video/enc/{sig}/{encode(link, safe=true)}"
  else:
    &"{cdnUrl}/video/{sig}/{encodeUrl(link)}"

proc getPicUrl*(link: string, proxyPics: bool): string =
  if not proxyPics:
    var url = link
    if "twimg.com" notin url:
      url.insert(twimg)
    if not url.startsWith(https):
      url.insert(https)
    & "{url}"
  else:
    let sig = getHmac(link)
    if base64Media:
      &"{cdnUrl}/pic/enc/{sig}/{encode(link, safe=true)}"
    else:
      &"{cdnUrl}/pic/{sig}/{encodeUrl(link)}"
  

proc getOrigPicUrl*(link: string, proxyPics: bool): string =
  if not proxyPics:
    var url = link
    if "twimg.com" notin url:
      url.insert(twimg)
    if not url.startsWith(https):
      url.insert(https)
    url.add("?name=orig")
    & "{url}"
  else:
    let sig = getHmac(link)
    if base64Media:
      &"{cdnUrl}/pic/orig/enc/{sig}/{encode(link, safe=true)}"
    else:
      &"{cdnUrl}/pic/orig/{sig}/{encodeUrl(link)}"

proc filterParams*(params: Table): seq[(string, string)] =
  for p in params.pairs():
    if p[1].len > 0 and p[0] notin nitterParams:
      result.add p

proc isTwitterUrl*(uri: Uri): bool =
  uri.hostname in twitterDomains

proc isTwitterUrl*(url: string): bool =
  isTwitterUrl(parseUri(url))
