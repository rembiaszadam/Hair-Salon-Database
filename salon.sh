#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Hair Salon ~~~\n"


MAIN_MENU() {
  # get available services
  SERVICE_LIST=$($PSQL "SELECT * FROM services ORDER BY service_id")

  # display available services
  echo "Here is a list of our services:"
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # ask for service
  echo -e "\nWhich would you like?"
  read SERVICE_ID_SELECTED

  SERVICE_ID=$($PSQL "SELECT service_id FROM services
  WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "Service ID not found, please try again."
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services
    WHERE service_id = $SERVICE_ID_SELECTED")

    # get customer info
    echo -e "\nWhat's your number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers
    WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name)
      VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers
    WHERE phone = '$CUSTOMER_PHONE'")

    # insert appointment
    echo -e "\nWhat time?"
    read SERVICE_TIME

    # add appointment info
    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,
    service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

    # show details entered
    SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//')
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//')
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  fi
}

MAIN_MENU
