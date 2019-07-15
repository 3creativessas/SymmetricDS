#!/bin/bash
set -e

# Cambia de rama si se expecifica una como variable de entorno
if [ "$TYPE" != "CORP" ]; then
	echo "Copiando archivo de configuracion de esclavo"
	rm /sym/engines/*
	cp /sym/samples/tc-corp-000.properties /sym/engines/config.properties

	if [ "$ENGINE_NAME" != "" ]; then
		echo "SET engine.name TO $ENGINE_NAME"
		perl -pi -e "s[engine.name=][engine.name=$ENGINE_NAME]g" /sym/engines/config.properties
	else
		echo "SET engine.name TO corp-000"
		perl -pi -e "s[engine.name=][engine.name=corp-000]g" /sym/engines/config.properties
	fi

	if [ "$SYNC_URL" != "" ]; then
		echo "SET sync.url TO $SYNC_URL"
		perl -pi -e "s[sync.url=][sync.url=$SYNC_URL]g" /sym/engines/config.properties
	else
		echo "SET sync.url TO http://localhost:31415/sync/corp-000"
		perl -pi -e "s[sync.url=][sync.url=http://localhost:31415/sync/corp-000]g" /sym/engines/config.properties
	fi

fi

# Cambia las variablas de conexiona a BD
echo "SET HOST TO $HOST"
perl -pi -e "s[TC-HOST][$HOST]g" /sym/engines/config.properties

echo "SET DB TO $DB"
perl -pi -e "s[TC-DB][$DB]g" /sym/engines/config.properties

echo "SET USER TO $USER"
perl -pi -e "s[db.user=][db.user=$USER]g" /sym/engines/config.properties

echo "SET PASSWORD TO $PASSWORD"
perl -pi -e "s[db.password=][db.password=$PASSWORD]g" /sym/engines/config.properties

# Cambia la informacion del nodo
## corp
echo "SET GROUP_ID TO $GROUP_ID"
perl -pi -e "s[group.id=][group.id=$GROUP_ID]g" /sym/engines/config.properties

## 000
echo "SET EXTERNAL_ID TO $EXTERNAL_ID"
perl -pi -e "s[external.id=][external.id=$EXTERNAL_ID]g" /sym/engines/config.properties


# Iniciando servicio
echo "START SymmetricDS"
./sym/bin/sym

exec "$@"