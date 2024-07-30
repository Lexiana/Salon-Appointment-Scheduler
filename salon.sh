#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?"
  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]; then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")

      INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id, time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME') ")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
  fi

}

MAIN_MENU
