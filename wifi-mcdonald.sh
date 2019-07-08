#!/bin/bash
decodeURL() {
  printf "$(sed 's/%\(..\)/\\x\1/g' <<< "$@")"
}
mustBeConnectedMcDonalds() {
  grep -i mcdonald <<< $(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -e '\s\+SSID: ' | cut -d: -f2) > /dev/null
  if [[ "$?" != "0" ]]
  then
    echo "We're current not in McDonald Wifi"
    exit 1
  fi
}
mustBeConnectedMcDonalds
CURL_COOKIE_FILE="/tmp/mcdonald.cookie"
CURL_CONNECT_TIMEOUT=3
FIREFOX_DETECT_PORTAL="http://detectportal.firefox.com/success.txt"

CURL_URL_EFFECTIVE=$(curl -L --connect-timeout $CURL_CONNECT_TIMEOUT -b "$CURL_COOKIE_FILE" -c "$CURL_COOKIE_FILE" "$FIREFOX_DETECT_PORTAL" -sS -I -w %{url_effective} -o /dev/null)
if [[ "$?" == "6" ]]
then
  echo "You need close splash page before."
  exit 1
fi
if [[ ! $(grep mcdonalds <<<$CURL_URL_EFFECTIVE) ]]
then
  exit 0
fi

AUTH_DOMAIN=$(decodeURL `grep -o -e 'base_grant_url=[^&]\+' <<<$CURL_URL_EFFECTIVE  | cut -d= -f2`|cut -d/ -f3)
AUTH_ENCODED_REDIRECT_URL=$(grep -o -e 'user_continue_url=[^&]\+' <<<$CURL_URL_EFFECTIVE  | cut -d= -f2)
URL_REQUEST_GRANT="http://$AUTH_DOMAIN/splash/grant?user_continue_url=$AUTH_ENCODED_REDIRECT_URL&duration=3600"
curl -L --connect-timeout $CURL_CONNECT_TIMEOUT -b "$CURL_COOKIE_FILE" -c "$CURL_COOKIE_FILE" "$URL_REQUEST_GRANT" -sS -I -w %{url_effective} -o /dev/null
