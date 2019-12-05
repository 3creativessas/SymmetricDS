#!/bin/bash
set -e

# Configura el nodo segun su tipo
if [ "$TYPE" == "STORE_SQLITE" ]; then

	echo "Copiando archivo de configuracion de esclavo SQLITE"
	rm -rf /workspace/sym/engines
	cd /workspace/sym
	mkdir engines
	cp /workspace/sym/samples/tc-store_sqlite-001.properties /workspace/sym/engines/config.properties

	if [ "$ENGINE_NAME" != "" ]; then
		echo "SET engine.name TO $ENGINE_NAME"
		perl -pi -e "s[engine.name=][engine.name=$ENGINE_NAME]g" /workspace/sym/engines/config.properties
	else
		echo "SET engine.name TO store-001"
		perl -pi -e "s[engine.name=][engine.name=store-001]g" /workspace/sym/engines/config.properties
	fi

	if [ "$REGISTRATION_URL" != "" ]; then
		echo "SET registration.url TO $REGISTRATION_URL"
		perl -pi -e "s[registration.url=][registration.url=$REGISTRATION_URL]g" /workspace/sym/engines/config.properties
	else
		echo "SET registration.url TO http://localhost:31415/sync/corp-000"
		perl -pi -e "s[registration.url=][registration.url=http://localhost:31415/sync/corp-000]g" /workspace/sym/engines/config.properties
	fi

elif [ "$TYPE" != "CORP" ]; then

	echo "Copiando archivo de configuracion de esclavo"
	rm -rf /workspace/sym/engines
	cd /workspace/sym
	mkdir engines
	cp /workspace/sym/samples/tc-store-001.properties /workspace/sym/engines/config.properties

	if [ "$ENGINE_NAME" != "" ]; then
		echo "SET engine.name TO $ENGINE_NAME"
		perl -pi -e "s[engine.name=][engine.name=$ENGINE_NAME]g" /workspace/sym/engines/config.properties
	else
		echo "SET engine.name TO store-001"
		perl -pi -e "s[engine.name=][engine.name=store-001]g" /workspace/sym/engines/config.properties
	fi

	if [ "$REGISTRATION_URL" != "" ]; then
		echo "SET registration.url TO $REGISTRATION_URL"
		perl -pi -e "s[registration.url=][registration.url=$REGISTRATION_URL]g" /workspace/sym/engines/config.properties
	else
		echo "SET registration.url TO http://localhost:31415/sync/corp-000"
		perl -pi -e "s[registration.url=][registration.url=http://localhost:31415/sync/corp-000]g" /workspace/sym/engines/config.properties
	fi

else

	echo "Copiando archivo de configuracion de master"
	rm -rf /workspace/sym/engines
	cd /workspace/sym
	mkdir engines
	cp /workspace/sym/samples/tc-corp-000.properties /workspace/sym/engines/config.properties

	if [ "$ENGINE_NAME" != "" ]; then
		echo "SET engine.name TO $ENGINE_NAME"
		perl -pi -e "s[engine.name=][engine.name=$ENGINE_NAME]g" /workspace/sym/engines/config.properties
	else
		echo "SET engine.name TO corp-000"
		perl -pi -e "s[engine.name=][engine.name=corp-000]g" /workspace/sym/engines/config.properties
	fi

	if [ "$SYNC_URL" != "" ]; then
		echo "SET sync.url TO $SYNC_URL"
		perl -pi -e "s[sync.url=][sync.url=$SYNC_URL]g" /workspace/sym/engines/config.properties
	else
		echo "SET sync.url TO http://localhost:31415/sync/corp-000"
		perl -pi -e "s[sync.url=][sync.url=http://localhost:31415/sync/corp-000]g" /workspace/sym/engines/config.properties
	fi

fi

# Cambia las variablas de conexiona a BD
echo "SET HOST TO $HOST"
perl -pi -e "s[TC-HOST][$HOST]g" /workspace/sym/engines/config.properties

echo "SET DB TO $DB"
perl -pi -e "s[TC-DB][$DB]g" /workspace/sym/engines/config.properties

echo "SET USER TO $USER"
perl -pi -e "s[db.user=][db.user=$USER]g" /workspace/sym/engines/config.properties

#echo "SET PASSWORD TO $PASSWORD"
perl -pi -e "s[db.password=][db.password=$PASSWORD]g" /workspace/sym/engines/config.properties

# Cambia la informacion del nodo
## corp
echo "SET GROUP_ID TO $GROUP_ID"
perl -pi -e "s[group.id=][group.id=$GROUP_ID]g" /workspace/sym/engines/config.properties

echo "SET EXTERNAL_ID TO $EXTERNAL_ID"
perl -pi -e "s[external.id=][external.id=$EXTERNAL_ID]g" /workspace/sym/engines/config.properties

# Iniciando servicio
echo "START SymmetricDS"
sh /workspace/sym/bin/sym 

exec "$@"