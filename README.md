# SymmetricDS by 3Creatives S.A.S.

La imagen Docker esta basada en SymmetricDS v3.10.3 con soporte de replicacion de MySQL, para otros motores de bases de datos debera simplemente modificar los archivos referencia de configuracion de la carpeta 'samples'

## Como usar - Build

```
git clone https://github.com/3creativessas/SymmetricDS.git

docker build \
 --rm \
 -t 3creatives/symmetricds \
 -f Dockerfile .
```

## Parametros

* TYPE: Tipo de nodo, CORP para el nodo principal o STORE para los nodos esclavos
* ENGINE_NAME: Nombre del nodo
* SYNC_URL: URL de sincronizacion del nodo CORP
* HOST: Host de la base de datos
* DB: Nombre de la base de datos 
* USER: Usuario de la base de datos
* PASSWORD: Clave de la base de datos
* GROUP_ID: Grupo ID del nodo
* EXTERNAL_ID: ID del nodo
* REGISTRATION_URL: URL que resuelve el nodo CORP (Principal)

Para mas informacion consulte la documentacion de SymmetricDS

**IMPORTANTE:** Asegurese que el usuaro utilizado para la conexion a la base de datos tenga permisos para la creacion de procedimientos almacenados

## Como iniciar el contenedor

### Iniciar el contenedor - CORP (Principal)
Para iniciar el contenedor en produccion ejecute el siguiente comando:

```
docker run -d \
-p 31415:31415 \
--name symmetricds_corp \
--env TYPE=CORP \
--env ENGINE_NAME=corp-000 \
--env SYNC_URL=http://XXXXXX:31415/sync/corp-000 \
--env HOST=xxxxx.ccdj4e2qthfq.us-east-1.rds.amazonaws.com \
--env DB=nd_corp \
--env USER=nd_user \
--env PASSWORD=xxxx \
--env GROUP_ID=corp \
--env EXTERNAL_ID=000 \
--restart always \
-i 3creatives/symmetricds
```

### Iniciar el contenedor - STORE (Esclavo)
Para iniciar el contenedor en produccion ejecute el siguiente comando:

```
docker run -d \
-p 31420:31415 \
--name symmetricds_store \
--env TYPE=STORE \
--env ENGINE_NAME=store-001 \
--env REGISTRATION_URL=http://3.92.70.173:31415/sync/corp-000 \
--env HOST=xxxxx.ccdj4e2qthfq.us-east-1.rds.amazonaws.com \
--env DB=nd_store \
--env USER=nd_user \
--env PASSWORD=xxxx \
--env GROUP_ID=store \
--env EXTERNAL_ID=001 \
--restart always \
-i 3creatives/symmetricds
```

## Configuracion inicial de sincronizacion de un nodo maestro y un nodo esclavo

La configuracion de SymmetricDS se realiza a traves de la base de datos. Para esto ejecute los siguientes comandos SQL en la base del nodo CORP (Principal)

Limpie las configuracion existente

```
delete from sym_trigger_router;
delete from sym_trigger;
delete from sym_router;
delete from sym_node_group_link;
delete from sym_node_group;
delete from sym_node_host;
delete from sym_node_identity;
delete from sym_node_security;
delete from sym_node;
```

Se crea el registro en la tabla de channel

**Nota:** Las siguientes sentencias SQL ejemplifican la configuracion para la sincronizacion de la tabla 'container_type'

```
insert into sym_channel 
(channel_id, processing_order, max_batch_size, enabled, description)
values('container_type', 1, 100000, 1, '');
```

Se crea el grupo de nodos

```
insert into sym_node_group (node_group_id) values ('corp');
insert into sym_node_group (node_group_id) values ('store');
```

Links entre nodos

-- Corp sends changes to Store when Store pulls from Corp
```
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) 
values ('corp', 'store', 'W');
```

-- Store sends changes to Corp when Store pushes to Corp
```
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) 
values ('store', 'corp', 'P');
```

Crea el trigger de la tabla a sincronizar (Para este ejemplo la tabla 'container_type')

```
insert into sym_trigger 
(trigger_id,source_table_name,channel_id,last_update_time,create_time)
values('container_type','container_type','container_type',current_timestamp,current_timestamp);
```

Se crea el enrutamiento (Routers)

-- Default router sends all data from corp to store 
```
insert into sym_router 
(router_id,source_node_group_id,target_node_group_id,router_type,create_time,last_update_time)
values('corp_2_store', 'corp', 'store', 'default',current_timestamp, current_timestamp);
```

-- Default router sends all data from store to corp
```
insert into sym_router 
(router_id,source_node_group_id,target_node_group_id,router_type,create_time,last_update_time)
values('store_2_corp', 'store', 'corp', 'default',current_timestamp, current_timestamp);
```

-- Column match router will subset data from corp to specific store
```
insert into sym_router 
(router_id,source_node_group_id,target_node_group_id,router_type,router_expression,create_time,last_update_time)
values('corp_2_one_store', 'corp', 'store', 'column','STORE_ID=:EXTERNAL_ID or OLD_STORE_ID=:EXTERNAL_ID',current_timestamp, current_timestamp);
```

Se crea el enrutamiento (Routers) de los triggers

-- Send container_type to all stores
```
insert into sym_trigger_router 
(trigger_id,router_id,initial_load_order,last_update_time,create_time)
values('container_type','corp_2_store', 100, current_timestamp, current_timestamp);

insert into sym_trigger_router 
(trigger_id,router_id,initial_load_order,last_update_time,create_time)
values('container_type','store_2_corp', 200, current_timestamp, current_timestamp);
```

## Cargue inicial

Para enviar la informacion inicial (existente) en el nodo CORP a los nodos STORE, cambie en la tabla 'sym_node_security' del nodo CORP el campo 'initial_load_enabled' de 0 a 1, del nodo a forzar la sincronizacion inicial, la consulta SQL deberia ser algo similar a esto:

```
UPDATE `sym_node_security` SET `initial_load_enabled` = '1' WHERE `sym_node_security`.`node_id` = '000';
```

Luego de la sincronizacion el campo 'initial_load_enabled' volvera automaticamente a 0