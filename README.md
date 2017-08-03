# Nominatim 3.0.0 Docker

Working container for [Nominatim](https://github.com/twain47/Nominatim).


# Supported tags and respective `Dockerfile` links #

- [`3.0.0`, `3.0`, `latest`  (*2.5/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.0)


Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container. Clones the current master and builds it. This is always the latest version, be cautious as it may be unstable.

Uses Ubuntu 16.04 and PostgreSQL 9.5

# Country

To set different country should be used you can set `PBF_DATA` on build.

1. Clone repository

  ```
  # git clone git@github.com:alaminopu/nominatim-docker.git
  # cd nominatim-docker/
  ```

2. Modify Dockerfile, set your url for PBF

  ```
  ENV PBF_DATA http://download.geofabrik.de/asia/bangladesh-latest.osm.pbf
  ```
3. Configure incrimental update. By default CONST_Replication_Url configured for Monaco.
If you want a different update source, you will need to declare `CONST_Replication_Url` in local.php. Documentation [here] (https://github.com/twain47/Nominatim/blob/master/docs/Import_and_update.md#updates). For example, to use the daily country extracts diffs for Gemany from geofabrik add the following:
  ```
  @define('CONST_Replication_Url', 'http://planet.osm.org/replication/day/');
  ```

4. Build 

  ```
  docker-compose up --build
  ```
5. Run

  ```
  docker-compose up
  ```
  If this succeeds, open [http://localhost:8080/](http:/localhost:8080) in a web browser



# Extra

If you want to run extra files inside notinatim wesite, put the file in the extra directory.

---

Inspired from [https://github.com/mediagis/nominatim-docker] (mediagis's nominatim docker)
