#!/bin.bash
loopConnection() {
  CURL_CONNECT_TIMEOUT=3
  FIREFOX_DETECT_PORTAL="http://detectportal.firefox.com/success.txt"

  AWING_URL=`curl "$FIREFOX_DETECT_PORTAL" --connect-timeout $CURL_CONNECT_TIMEOUT -L -o /dev/null -sS -w %{url_effective}`
  grep connect\.awing\.vn <<< "$AWING_URL" >/dev/null
  if [[ "$?" != "0" ]]
  then
    return 0
  fi
  AWING_HS_SERVER=`grep -o 'hs_server=[^&]\+' <<< "$AWING_URL" | sed 's/^hs_server=//'`
  AWING_QV=`grep -o 'Qv=[^&]\+' <<< "$AWING_URL" | sed 's/^Qv=//'`

  AWING_HS_PORT=`curl "$FIREFOX_DETECT_PORTAL" --connect-timeout $CURL_CONNECT_TIMEOUT -L -sS | grep -o 'var *port *= *\d\+' | cut -d= -f2`
  if [[ "$AWING_HS_PORT" == "" ]]
  then
    AWING_HS_PORT=80
  fi
  curl -d "f_flex=&f_flex_type=log&f_hs_server=$AWING_HS_SERVER&f_Qv=$AWING_QV" --connect-timeout $CURL_CONNECT_TIMEOUT "http://$AWING_HS_SERVER:$AWING_HS_PORT/cgi-bin/hslogin.cgi" -L -sS | grep "Authentication Success"
}
while [[ 1 ]]
do
  loopConnection
  if [[ "$?" == "0" ]]
  then
    echo "Done"
  fi
  sleep 60
done
