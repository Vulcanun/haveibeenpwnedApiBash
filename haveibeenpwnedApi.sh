#!/bin/bash

#usage: ./haveibeenpwnedApiBash.sh <wordlist file in plaintext>||<password in plaintext> [<output filename>]
#final result: <queried password>:<number of times the password has been leaked>
if [[ -n $1 ]]; then
  if [[ -f $1 ]]; then
    for line in $( cat $1 ); do

      #encodes the line, parse it apropriately and return it's first five characters (as needed by the API) to a variable then used to process a GET request to the API
      pass=$( echo -n $line | sha1sum | awk '{print substr($1, 0, 5)}' );
      comppass=$( echo -n $line | sha1sum | awk '{print substr($1, 6, 35)}' );

      #if a second parameter is received, define it as the output filename and check to see if it already exists, if so append to it, otherwise create the file and print in it. If the second parameter is not received, output to STDOUT
      echo "Querying "$line"...";
      quant=$( curl -s https://api.pwnedpasswords.com/range/$pass | grep -i $comppass | cut -d":" -f2 )

      if [[ $quant ]]; then
        if [[ -n $2 ]]; then
          echo $line:$quant >> $2
        else
          echo $line:$quant
        fi
      else
        if [[ -n $2 ]]; then
          echo $line:0 >> $2
        else
          echo $line:0
        fi
      fi

      #Necessary timeout as HIBP's api states
      sleep 1.5
      echo "";

    done
  else

    #encodes the line, parse it apropriately and return it's first five characters (as needed by the API) to a variable then used to process a GET request to the API
    pass=$( echo -n $1 | sha1sum | awk '{print substr($1, 0, 5)}' );
    comppass=$( echo -n $1 | sha1sum | awk '{print substr($1, 6, 35)}' );

    #if a second parameter is received, define it as the output filename and check to see if it already exists, if so append to it, otherwise create the file and print in it. If the second parameter is not received, output to STDOUT
    echo "Querying "$1"...";
    quant=$( curl -s https://api.pwnedpasswords.com/range/$pass | grep -i $comppass | cut -d":" -f2 )

    if [[ $quant ]]; then
      if [[ -n $2 ]]; then
        echo $1:$quant >> $2
      else
        echo $1:$quant
      fi
    else
      if [[ -n $2 ]]; then
        echo $1:0 >> $2
      else
        echo $1:0
      fi
    fi
  fi
else
  echo "No parameter received, dying."
fi
