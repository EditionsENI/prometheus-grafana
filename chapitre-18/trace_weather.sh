#!/bin/bash

# Liste des villes
LOCATIONS=("Paris" "Toulouse" "Saint Jean d'Angély" "Saint-Palais")
OSM="https://nominatim.openstreetmap.org/search"
OM="https://api.open-meteo.com/v1/forecast"

function curl_otel()
{
  name=$1
  shift
  OTEL_SERVICE_NAME=$name otel-cli exec --name $name -- curl -s $@
}

echo "Température instantanée des villes suivantes :"

for CITY in "${LOCATIONS[@]}"; do
    # Encode la ville pour l'URL
    LOCATION=$(echo "$CITY" | jq -sRr @uri)
    export OTEL_RESOURCE_ATTRIBUTES="city=$CITY"

    # Obtenir les coordonnées via OpenStreetMap Nominatim
    GEO=$(curl_otel open-street-map "$OSM?format=json&q=$LOCATION" | jq '.[0]')
    LAT=$(echo "$GEO" | jq -r '.lat')
    LON=$(echo "$GEO" | jq -r '.lon')

    # Obtenir la météo avec Open-Meteo
    PARAM="latitude=$LAT&longitude=$LON&current_weather=true"
    WEATHER=$(curl_otel open-meteo "$OM?$PARAM")
    TEMP=$(echo "$WEATHER" | jq '.current_weather.temperature')
    echo "$CITY → $TEMP°C"
done

