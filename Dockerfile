FROM ubuntu:latest
MAINTAINER Al-Amin <alaminopu.opu10@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Install packages https://github.com/openstreetmap/Nominatim/blob/master/docs/Install-on-Ubuntu-16.md
RUN apt-get -y update --fix-missing && \
    apt-get install -y build-essential cmake g++ libboost-dev libboost-system-dev \
    libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev\
    libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev \
    postgresql-server-dev-9.5 postgresql-9.5-postgis-2.2 postgresql-contrib-9.5 \
    apache2 php php-pgsql libapache2-mod-php php-pear php-db \
    python3-dev python3-pip python3-psycopg2 python3-tidylib phpunit \
    php-intl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*

# Adding test suite
RUN pip3 install --user behave nose && pear install PHP_CodeSniffer

# Adding user
RUN useradd -d /app -s /bin/bash -m nominatim && \
    export USERNAME=nominatim && \
    export USERHOME=/app && \
    chmod a+x $USERHOME


# Setting working directory
WORKDIR /app

# Configure postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

# Nominatim install
ENV NOMINATIM_VERSION v.3.0.0

# clonig from git
RUN git clone --recursive https://github.com/openstreetmap/Nominatim ./src

# downloading wikidata
RUN wget http://www.nominatim.org/data/wikipedia_article.sql.bin
RUN wget http://www.nominatim.org/data/wikipedia_redirect.sql.bin
RUN wget -O ./src/data/country_osm_grid.sql.gz http://www.nominatim.org/data/country_grid.sql.gz

#run extra folder
RUN mkdir ./src/website/extra

# make
RUN cd ./src && git checkout $NOMINATIM_VERSION && git submodule update --recursive --init && \
  ./autogen.sh && ./configure && make


# Nominatim create site
COPY local.php ./src/settings/local.php

# Apache configure
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf

# Load initial data
ENV PBF_DATA http://download.geofabrik.de/asia/bangladesh-latest.osm.pbf
RUN curl -L $PBF_DATA --create-dirs -o /app/src/data.osm.pbf
RUN service postgresql start && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
    sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
    useradd -m -p password1234 nominatim && \
    chown -R nominatim:nominatim ./src && \
    sudo -u nominatim ./src/utils/setup.php --osm-file /app/src/data.osm.pbf --all --threads 2 && \
    service postgresql stop

EXPOSE 5432
EXPOSE 8080

COPY start.sh /app/start.sh
CMD /app/start.sh
